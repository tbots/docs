# -*- coding: utf-8 -*-
'''
Created on Mar 3, 2014

@author: Snorlax
'''

from gluon import *
from gluon.sql import *
from gluon import current
import json,hashlib,datetime
import urllib2
import mng


db = current.db
auth = current.auth


@auth.requires_login()
def index():
    selectedDomain = None
    groups = None
    domains = None
    
    if request.args:
        selectedDomain = request.args[0]
    
    sql = "select a.domain_id, a.domain_name from domains a, domain_users b where a.domain_id = b.domain_id and b.user_id = '"+auth.user.user_id+"' order by domain_name"
    domains = db.executesql(sql) 
    
    if selectedDomain == None:
        if len(domains) > 0:
            selectedDomain = domains[0][0]

    if selectedDomain != None:        
        sql = "select domaingroup_id,domain_id,domaingroup_name,domaingroup_descr from domain_groups where domain_id = '"+selectedDomain+"' order by domaingroup_name"
        groups = db.executesql(sql)
    
    return dict(domains=domains,selectedDomain=selectedDomain,groups=groups)


@auth.requires_login()      
def editGroup():      
    groupId = request.args[0]
    domainId = request.args[1]
    
    group = None
    
    if groupId != '0':
        sql = "select domaingroup_id, domaingroup_name, domaingroup_descr from domain_groups where domaingroup_id = '"+groupId+"'"
        group = db.executesql(sql)[0]
    
    return dict(group=group,domainId=domainId)

def saveGroup():
    postData = request.post_vars
    if postData['domaingroup_id'] == '0':
        m = hashlib.md5()
        m.update(unicode(datetime.datetime.now())+postData["domaingroup_name"])
        domainGroupId = m.hexdigest() 
        sql = "insert into domain_groups values ('"+domainGroupId+"','"+postData["domainId"]+"','"+postData["domaingroup_name"]+"','"+postData["domaingroup_descr"]+"')"
        db.executesql(sql)
    else:
        domainGroupId = postData["domaingroup_id"]
        sql = "update domain_groups set domaingroup_name = '"+postData["domaingroup_name"]+"', domaingroup_descr = '"+postData["domaingroup_descr"]+"' where domaingroup_id = '"+domainGroupId+"'"
        db.executesql(sql)
        
    return domainGroupId

def getSqlInCond(input_list):
    list_a = []
    if len(input_list):
        for item in input_list:
            list_a.append("'{item}'".format(item = item))
    list_s = ','.join(list_a) if len(list_a) else ''
    return list_s

def deleteGroup():
    group_id = request.args[0]
    
    # projekty, kde je skupina
    projects_q = "SELECT project_id FROM project_domaingroups WHERE domaingroup_id = '%s'"%group_id
    projects = db.executesql(projects_q, as_dict = True)
    
    del_users_q = "SELECT user_id FROM domaingroup_users WHERE domaingroup_id = '%s'"%group_id
    del_users = db.executesql(del_users_q, as_dict = True)
    
    del_user_q = "DELETE FROM project_users WHERE user_id IN ({uids}) AND project_id = '{pid}'"                  
    del_user_pj_q = "DELETE FROM userspace.users WHERE user_id IN ({uids}); \
                     DELETE FROM auth_user WHERE user_id IN ({uids});"
    
    del_group_q = "DELETE FROM domain_groups WHERE domaingroup_id = '%s'"%group_id    
    del_group_pj_q = "DELETE FROM userspace.usergroups WHERE usergroup_id = '%s'"%group_id
    
    # odstrani uzivatele ze vsch projektu, kde byli pridani touhle skupinou
    if len(projects) and len(del_users):
        del_users_s = getSqlInCond([uid['user_id'] for uid in del_users])
        for pj in projects:
            del_users_q = "SELECT user_id FROM project_users WHERE project_id = '{pid}' \
                        AND user_id IN ({del_users}) AND user_id NOT IN ( \
                        SELECT user_id FROM project_users WHERE privilege_id != -1 AND project_id = '{pid}' \
                        ) AND user_id NOT IN ( \
                        SELECT gu.user_id FROM project_domaingroups pg \
                        INNER JOIN domaingroup_users gu USING(domaingroup_id) \
                        WHERE project_id = '{pid}' AND domaingroup_id != '{gid}')\
                        ".format(del_users = del_users_s, pid = pj['project_id'], gid = group_id)
            del_users = db.executesql(del_users_q, as_dict = True)

            # uzivatele, kteri pujdou uplne smazat
            if len(del_users):
                
                del_users_l = getSqlInCond([uid['user_id'] for uid in del_users])
                
                db.executesql(del_user_q.format(uids = del_users_l, pid = pj['project_id']))
                mng.executeRemoteSQL(pj['project_id'], del_user_pj_q.format(uids = del_users_l)
                                         , False, True, False)
            
            mng.executeRemoteSQL(pj['project_id'], del_group_pj_q, False, True, False)
    
    # smaze skupinu v lotylda mng
    db.executesql(del_group_q)
           
    return False


def editGroupUsers():
    groupId = request.args[0]
    domainId = request.args[1]

    sql = "select id, first_name, last_name, email, a.user_id,active from auth_user a, domain_users d \
            where d.user_id = a.user_id and domain_admin = False and domain_id = '"+domainId+"' order by last_name"
    users = db.executesql(sql)

    sql="select domaingroup_name from domain_groups where domaingroup_id= '"+groupId+"'"
    group = db.executesql(sql)[0][0]
    
    sql="select user_id from domaingroup_users where domaingroup_id= '"+groupId+"'"
    rows = db.executesql(sql)
    
    ret = ''
    if len(rows) > 0:
        for item in rows: 
            ret += item[0]+','     
    
    return dict(users=users,domainId=groupId,selUsers=ret[:-1],group=group)

      
def saveUserGroup():
    postData = request.post_vars
    group_id = postData['domainId']
    
    prev_users_q = "SELECT user_id FROM domaingroup_users WHERE domaingroup_id = '%s'"%group_id
    prev_users = db.executesql(prev_users_q, as_dict=True)
    
    prev_users_a = []
    if len(prev_users):
        prev_users_a = [u['user_id'] for u in prev_users]
    
    cur_users = []
    if 'userGroup' in postData:
        if type(postData['userGroup']) is str:
            cur_users.append(postData['userGroup'])
        else:
            cur_users = postData['userGroup']

    add_users = list(set(cur_users) - set(prev_users_a))
    del_users = list(set(prev_users_a) - set(cur_users))
                
    # prida uzivatele do projektu, kde je skupina, pokud tam jeste neni
    
    ins_user_g_q = "INSERT INTO domaingroup_users(user_id, domaingroup_id) VALUES ('{uid}','%s');"%group_id
    ins_user_g_pj_q = "INSERT INTO userspace.usergroup_users(usergroup_id, user_id) VALUES ('%s','{uid}');"%group_id
    
    ins_user_q = "INSERT INTO project_users(project_id, user_id, privilege_id) VALUES ('{pid}', '{uid}', -1);"
    ins_user_pj_q = "INSERT INTO userspace.users(user_id,  username) VALUES ('{uid}', '{username}');\
                          INSERT INTO auth_user(first_name, last_name, email, user_id, username) \
                          VALUES ('{f_name}', '{l_name}', '{email}', '{uid}', '{username}');"
    
    del_user_g_q = "DELETE FROM domaingroup_users WHERE user_id IN ({uids}) AND domaingroup_id = '{gid}'"
    del_user_q = "DELETE FROM project_users WHERE user_id IN ({uids}) AND project_id = '{pid}'"
     
    del_user_g_pj_q = "DELETE FROM userspace.usergroup_users WHERE user_id IN ({uids}) AND usergroup_id = '%s';"%group_id                
    del_user_pj_q = "DELETE FROM userspace.users WHERE user_id IN ({uids}); \
                     DELETE FROM auth_user WHERE user_id IN ({uids});"
    

    
    projects_q = "SELECT project_id FROM project_domaingroups WHERE domaingroup_id = '%s'"%postData['domainId']
    projects = db.executesql(projects_q, as_dict = True)
    
    if len(projects):
        for pj in projects:
            if len(add_users):
                add_users_l = getSqlInCond(add_users)
                add_users_a = []
                add_users_q = "SELECT first_name, last_name, email, user_id, username FROM auth_user WHERE user_id IN (%s)"%add_users_l
                add_users_tmp = db.executesql(add_users_q, as_dict=True)
                add_users_a = [u['user_id'] for u in add_users_tmp]
                
                pj_users_a = []
                pj_users_q = "SELECT user_id FROM project_users WHERE project_id = '%s'"%pj['project_id']
                pj_users = db.executesql(pj_users_q, as_dict=True)
                
                if len(pj_users):
                    pj_users_a = [u['user_id'] for u in pj_users]
    
                pj_new_users = set(add_users_a) - set(pj_users_a)

                # prida uzivatele do tabulky users a user groups
                for au in add_users_tmp:
                    if au['user_id'] in pj_new_users:
                        db.executesql(ins_user_q.format(pid = pj['project_id'], uid = au['user_id']))

                        mng.executeRemoteSQL(pj['project_id'], ins_user_pj_q.format(uid = au['user_id'],
                                                                                    username = au['username'],
                                                                                    f_name = au['first_name'],
                                                                                    l_name = au['last_name'],
                                                                                    email = au['email']
                                                                      )
                                                 , False, True, False)                        

                    db.executesql(ins_user_g_q.format(uid = au['user_id']))

                    mng.executeRemoteSQL(pj['project_id'], ins_user_g_pj_q.format(uid = au['user_id'])
                                             , False, True, False)                        
            
            if len(del_users):
                del_users_s = getSqlInCond(del_users)
                
                # vybere uzivatele, kteri pujdou smazat
                del_users_q = "SELECT user_id FROM project_users WHERE project_id = '{pid}' \
                            AND user_id IN ({del_users}) AND user_id NOT IN ( \
                            SELECT user_id FROM project_users WHERE privilege_id != -1 AND project_id = '{pid}' \
                            ) AND user_id NOT IN ( \
                            SELECT gu.user_id FROM project_domaingroups pg \
                            INNER JOIN domaingroup_users gu USING(domaingroup_id) \
                            WHERE project_id = '{pid}' AND domaingroup_id != '{gid}')\
                            ".format(del_users = del_users_s, pid = pj['project_id'], gid = group_id)
                
                del_users = db.executesql(del_users_q, as_dict = True)
                 

                db.executesql(del_user_g_q.format(uids = del_users_s, gid = group_id))
                mng.executeRemoteSQL(pj['project_id'], del_user_g_pj_q.format(uids = del_users_s)
                                         , False, True, False)                
                 
                # uzivatele, kteri pujdou uplne smazat
                if len(del_users):
                    
                    del_users_l = getSqlInCond([uid['user_id'] for uid in del_users])
                    
                    db.executesql(del_user_q.format(uids = del_users_l, pid = pj['project_id']))
                    mng.executeRemoteSQL(pj['project_id'], del_user_pj_q.format(uids = del_users_l)
                                             , False, True, False)                     
    else:
        ins_user_g_q = "INSERT INTO domaingroup_users(user_id, domaingroup_id) VALUES ('{uid}','%s');"%group_id
        del_users_q = "DELETE FROM domaingroup_users WHERE domaingroup_id = '%s' AND user_id IN ({del_users_s})"%group_id
        if len(add_users):
            for u in add_users:
                db.executesql(ins_user_g_q.format(uid = u))

        if len(del_users):
            del_users_s = getSqlInCond(del_users)
            db.executesql(del_users_q.format(del_users_s = del_users_s))
    
    return True

def editGroupProjects():
    groupId = request.args[0]
    domainId = request.args[1]
    
    sql = "select  a.project_id, (select project_name from projects where project_id = a.project_id) as project_name, privilege_id from project_domaingroups a where domaingroup_id = '"+groupId+"' order by project_name"
    projects = db.executesql(sql)
    
    sql = "select privilege_id, privilege_descr from privileges where privilege_id != -1 order by privilege_name"
    privileges = db.executesql(sql)
    
    sql="select domaingroup_name from domain_groups where domaingroup_id= '"+groupId+"'"
    groupName = db.executesql(sql)[0][0]
    
    # get groups projects by domain and their privileges 
    group_projects_q = "SELECT p.project_id, p.project_name, pu.privilege_id FROM projects p \
            INNER JOIN project_domaingroups pu USING(project_id) \
            INNER JOIN domain_projects dp USING(project_id) \
            WHERE domain_id = '{domain_id}' AND pu.domaingroup_id = '{group_id}'\
            ".format(domain_id = domainId,
                     group_id = groupId
                     )
    group_projects = db.executesql(group_projects_q) #, as_dict=True

    selProjects = {}
    for group in group_projects:
        selProjects[group[0]+'|sep|'+str(group[2])]=group[0]+'|sep|'+str(group[2])  
    
    return dict(groupId=groupId,domainId=domainId,projects=projects,privileges=privileges,selProjects=selProjects,group=groupName)

def saveGroupProjects():
    postData = request.post_vars

    upd_priv_q = "UPDATE project_domaingroups SET privilege_id = {priv_id} \
                    WHERE project_id = '{project_id}' AND domaingroup_id = '{group_id}'"

    upd_priv_pj_q = "UPDATE userspace.usergroups SET privilege_id = {priv_id} WHERE usergroup_id = '{group_id}'"

    # only one project -> string 
    if type(postData['projectPrivileges']) is str:
        pom = postData['projectPrivileges'].split('|sep|')
        if pom[1] != '0':                
            db.executesql(upd_priv_q.format(priv_id = pom[1],
                                            project_id = pom[0],
                                            group_id = postData['groupId']
                                            )
                          )
            mng.executeRemoteSQL(pom[0], upd_priv_pj_q.format(priv_id = pom[1], group_id = postData['groupId'])
                                     , False, True, False)             
    
    # more than one projects -> array
    else: 
        for project in postData['projectPrivileges']:
            pom = project.split('|sep|')            
            if pom[1] == '0':
                continue
            db.executesql(upd_priv_q.format(priv_id = pom[1],
                                            project_id = pom[0],
                                            group_id = postData['groupId']
                                            )
                          )
            
            mng.executeRemoteSQL(pom[0], upd_priv_pj_q.format(priv_id = pom[1], group_id = postData['groupId'])
                                     , False, True, False)
    
    return True