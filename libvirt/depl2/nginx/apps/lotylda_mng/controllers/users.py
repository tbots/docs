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
    users = None
    domains = None
    
    if request.args:
        selectedDomain = request.args[0]
    
    sql = "select a.domain_id, a.domain_name from domains a, domain_users b where a.domain_id = b.domain_id and b.user_id = '"+auth.user.user_id+"' order by domain_name"
    domains = db.executesql(sql) 
            
    if selectedDomain == None:
        if len(domains) > 0:
            selectedDomain = domains[0][0]   
            
    if selectedDomain != None:        
        sql = "select id, first_name, last_name, email, a.user_id,active, registration_key from auth_user a, domain_users d \
                where d.user_id = a.user_id and domain_admin != True and domain_id = '"+selectedDomain+"' order by last_name"
        users = db.executesql(sql)
    
    return dict(domains=domains,selectedDomain=selectedDomain, users=users)


@auth.requires_login()
def editUser():
    userId = request.args[0]    
    user = None
    
    if userId != '0':    
        sql = "select id, first_name, last_name, email, user_id,username from auth_user where user_id = '"+userId+"'"
        user = db.executesql(sql)[0]
    
    return dict(user=user,domainId = request.args[1])

@auth.requires_login()
def saveUser():    
    userData = request.post_vars

    if userData["userId"] == '0':
        m = hashlib.md5()
        m.update(unicode(userData["email"]))
        userId = m.hexdigest() 
        sql = "insert into auth_user (first_name, last_name, email, active,username, user_id) values \
            ('"+userData["first_name"]+"','"+userData["last_name"]+"','"+userData["email"]+"','f','"+userData["username"]+"','"+userId+"')"
        db.executesql(sql)
        sql = "insert into domain_users values ('"+userData["domainId"]+"','"+userId+"','f')"
        db.executesql(sql) 
    else:
        sql = "update auth_user set first_name = '"+userData["first_name"]+"', last_name = '"+userData["last_name"]+"', email = '"+userData["email"]+"' \
            where user_id = '"+userData["userId"]+"'"
        db.executesql(sql)
        userId = userData["userId"]
    db.commit()
    
    if userData["userId"] == '0' or userData["userId"] != None:
        user = db(db.auth_user.user_id == userId).select()[0]        
        auth.email_reset_password(user)
        sql = "update auth_user set active = 't' where user_id = '"+userId+"'"
        db.executesql(sql)
        
    return userId

def testUsername():
    testName = request.args[0]
    sql = "select user_id from auth_user where username = '"+testName+"'"
    row = db.executesql(sql)
    if(len(row) > 0):
        return row[0][0]
    else:
        return 0
    
def updateUserStatus():
    userId = request.args[0]
    status = request.args[1]    
    stat = ''
    if status == 'false':
        stat = 'pending'
    sql = "update auth_user set registration_key = '"+stat+"' \
            where user_id = '"+userId+"'"
    db.executesql(sql)
    
    return True

@auth.requires_login()
def deleteUser():
    domainId = request.args[0]
    user_id = request.args[1] 
    
    # projekty, ve kterych je uzivatel
    user_projects_q = "SELECT project_id FROM project_users WHERE user_id = '%s'"%user_id
    user_projects = db.executesql(user_projects_q, as_dict=True)
    
    del_user_pj_q = "DELETE FROM userspace.users WHERE user_id = '{user_id}'; \
                     DELETE FROM auth_user WHERE user_id = '{user_id}'; \
                     ".format(user_id = user_id)
    
    if len(user_projects):
        for pj in user_projects:
            
            mng.executeRemoteSQL(pj['project_id'], del_user_pj_q, False, True, False)
    
    
    del_user_q = "DELETE FROM auth_user WHERE user_id = '%s'"%user_id
    db.executesql(del_user_q)

    
    return True

def userProject():
    domainId = request.args[1]
    userId = request.args[0] 
    
    sql = "select concat(first_name,' ', last_name, ' - ', username) from auth_user where user_id = '"+userId+"'"
    username = db.executesql(sql)[0][0]   
    
    # get users project by domain and their privileges 
    usr_projects_q = "SELECT p.project_id, p.project_name, pu.privilege_id FROM projects p \
            INNER JOIN project_users pu USING(project_id) \
            INNER JOIN domain_projects dp USING(project_id) \
            WHERE domain_id = '{domain_id}' AND user_id = '{user_id}'\
            ".format(domain_id = domainId,
                     user_id = userId
                     )
    usr_projects = db.executesql(usr_projects_q) #, as_dict=True

    selProjects = {}    
    for project in usr_projects:
        selProjects[project[0]+'|sep|'+str(project[2])]=project[0]+'|sep|'+str(project[2])    

    sql = "select privilege_id, privilege_descr from privileges order by privilege_name"
    privileges = db.executesql(sql)
    
    return dict(userId = userId, domainId = domainId, projects = usr_projects, selProjects=selProjects,privileges=privileges,username=username)

def saveUserProject():
    projectData = request.post_vars        

    upd_priv_q = "UPDATE project_users SET privilege_id = {priv_id} \
                    WHERE project_id = '{project_id}' AND user_id = '{user_id}'"

    upd_priv_pj_q = "UPDATE userspace.users SET privilege_id = {priv_id} \
                    WHERE user_id = '{user_id}'"                    

    # only one project -> string 
    if type(projectData['projectPrivileges']) is str:
        pom = projectData['projectPrivileges'].split('|sep|')
        if pom[1] != '0':                
            db.executesql(upd_priv_q.format(priv_id = pom[1],
                                            project_id = pom[0],
                                            user_id = projectData['userId']
                                            )
                          )
            
            mng.executeRemoteSQL(pom[0], upd_priv_pj_q.format(user_id = projectData['userId'],
                                                              priv_id = pom[1]
                                                              )
                                     , False, True, False)            
    # more than one projects -> array
    else: 
        for project in projectData['projectPrivileges']:
            pom = project.split('|sep|')            
            if pom[1] == '0':
                continue
            db.executesql(upd_priv_q.format(priv_id = pom[1],
                                            project_id = pom[0],
                                            user_id = projectData['userId']
                                            )
                          )
            mng.executeRemoteSQL(pom[0], upd_priv_pj_q.format(user_id = projectData['userId'],
                                                              priv_id = pom[1]
                                                              )
                                     , False, True, False)
    return True
#auth.settings.login_onaccept


def userGroups():
    domainId = request.args[1]
    userId = request.args[0]
    
    sql = "select concat(first_name,' ', last_name, ' - ', username) from auth_user where user_id = '"+userId+"'"
    username = db.executesql(sql)[0][0]    
    
    sql = "select domaingroup_id,domaingroup_name from domain_groups where domain_id = '"+domainId+"' order by domaingroup_name"
    domainGroups = db.executesql(sql)    
    
    sql = "select domaingroup_id from domaingroup_users where user_id = '"+userId+"' order by domaingroup_id"
    pom = db.executesql(sql)
    
    selGroups = {}
    for item in pom:
        selGroups[item[0]]=item[0] 
        
    return dict(domainGroups=domainGroups,selGroups=selGroups,userId=userId,domainId=domainId,username=username)
     
def saveUserGroups():
    postData = request.post_vars    
    
    user_id = postData['userId']
    
    user_info_q = "SELECT first_name, last_name, email, user_id, username FROM auth_user WHERE user_id = '%s'"%user_id
    user_info = db.executesql(user_info_q, as_dict = True)[0]

    print postData
    prev_user_groups_a = []
    prev_user_groups_q = "SELECT domaingroup_id FROM domaingroup_users WHERE user_id = '%s'"%user_id
    prev_user_groups = db.executesql(prev_user_groups_q, as_dict = True)
    
    if len(prev_user_groups):
        for g in prev_user_groups:
            prev_user_groups_a.append(g['domaingroup_id'])  
    
    cur_user_groups = []
    
    if 'groupNodes' in postData:
        if type(postData['groupNodes']) is str:
            cur_user_groups.append(postData['groupNodes'])
        else:
            cur_user_groups = postData['groupNodes']

    new_user_groups = list(set(cur_user_groups) - set(prev_user_groups_a))
    del_user_groups = list(set(prev_user_groups_a) - set(cur_user_groups))
    user_groups = list(set(prev_user_groups_a  + cur_user_groups))
    
    # prida uzivatele do projektu, kde je skupina, pokud tam jeste neni
    
    ins_user_g_q = "INSERT INTO domaingroup_users(user_id, domaingroup_id) VALUES ('%s','{gid}');"%user_id
    ins_user_g_pj_q = "INSERT INTO userspace.usergroup_users(usergroup_id, user_id) VALUES ('{gid}','%s');"%user_id
    
    ins_user_q = "INSERT INTO project_users(project_id, user_id, privilege_id) VALUES ('{pid}', '%s', -1);"%user_id
    ins_user_pj_q = "INSERT INTO userspace.users(user_id,  username) VALUES ('{uid}', '{username}'); \
                          INSERT INTO auth_user(first_name, last_name, email, user_id, username) \
                          VALUES ('{f_name}', '{l_name}', '{email}', '{uid}', '{username}');"
    
    del_user_g_q = "DELETE FROM domaingroup_users WHERE user_id = '{user_id}' AND domaingroup_id = '{gid}'"
    del_user_g_pj_q = "DELETE FROM userspace.usergroup_users WHERE user_id = '{user_id}' AND \
                        usergroup_id = '{gid}'"
                            
    del_user_q = "DELETE FROM project_users WHERE user_id = '{user_id}' AND project_id = '{pid}'"
    del_user_pj_q = "DELETE FROM userspace.users WHERE user_id = '{user_id}'; \
                     DELETE FROM auth_user WHERE user_id = '{user_id}';".format(user_id = user_id)
    
    
    for user_group in user_groups:
    
        projects_q = "SELECT project_id FROM project_domaingroups WHERE domaingroup_id = '%s'"%user_group
        projects = db.executesql(projects_q, as_dict = True)
        
        if len(projects):
            for pj in projects:
                # prida uzivatele do skupin
                if user_group in new_user_groups:
                    # kontrola, jeli uzivatel jiz v projektu
                    user_pj_q = "SELECT 1 FROM project_users WHERE project_id = '{pid}' AND \
                                    user_id = '{user_id}'".format(pid = pj['project_id'],
                                                                  user_id = user_id
                                                                  )
                    user_pj = db.executesql(user_pj_q)
                    
                    # prida uzivatele do users projektu, pokud tam neni
                    if not len(user_pj):
                        db.executesql(ins_user_q.format(pid = pj['project_id']))
                        mng.executeRemoteSQL(pj['project_id'], ins_user_pj_q.format(uid = user_info['user_id'], 
                                                                                    username = user_info['username'],
                                                                                    f_name = user_info['first_name'],
                                                                                    l_name = user_info['last_name'],
                                                                                    email = user_info['email']
                                                                                    
                                                                                    ), False, True, False)                        
                        
                    # prida uzivatele do skupiny
                    db.executesql(ins_user_g_q.format(gid = user_group))
                    mng.executeRemoteSQL(pj['project_id'], ins_user_g_pj_q.format(gid = user_group)
                                         , False, True, False)
                # vymaze uzivatele ze skupin
                elif user_group in del_user_groups:
                    # ma smazat uzivatele v projektu?
                    delUser_q = "SELECT 1 FROM project_users WHERE project_id = '{pid}' \
                                AND user_id = '{user_id}' AND user_id NOT IN ( \
                                SELECT user_id FROM project_users WHERE privilege_id != -1 AND project_id = '{pid}' \
                                AND user_id = '{user_id}') AND user_id NOT IN ( \
                                SELECT gu.user_id FROM project_domaingroups pg \
                                INNER JOIN domaingroup_users gu USING(domaingroup_id) \
                                WHERE project_id = '{pid}' AND domaingroup_id != '{gid}' AND gu.user_id = '{user_id}')\
                                ".format(user_id = user_id, pid = pj['project_id'], gid = user_group)
                    delUser = db.executesql(delUser_q)
                    # smaze uzivatele v projektu
                    if len(delUser):
                        db.executesql(del_user_q.format(pid = pj['project_id'], user_id = user_id))
                        mng.executeRemoteSQL(pj['project_id'], del_user_pj_q, False, True, False)
                    # vymaze pouze ze skupiny
                    db.executesql(del_user_g_q.format(gid = user_group, user_id = user_id))
                    mng.executeRemoteSQL(pj['project_id'], del_user_g_pj_q.format(gid = user_group, 
                                                                                  user_id = user_id
                                                                                  )
                                         , False, True, False)
                        
        # skupina neni v zadnem projektu - prida/ odebere uzivatele pouze do skupiny
        else:
            
            # prida
            if user_group in new_user_groups:
                db.executesql(ins_user_g_q.format(gid = user_group))
            # odebere
            elif user_group in del_user_groups:
                print "MAZU VOE"
                db.executesql(del_user_g_q.format(gid = user_group, user_id = user_id))                                      

    
    return True
