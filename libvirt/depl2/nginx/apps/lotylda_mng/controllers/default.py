# -*- coding: utf-8 -*-
'''
Created on Mar 3, 2014

@author: Snorlax
'''

from gluon import *
from gluon.sql import *
from gluon import current
import json,hashlib,datetime
import mng
import users_mod


db = current.db
auth = current.auth

def user():        
#     auth.settings.login_onaccept = onLogin
    auth.settings.register_onaccept = setAdmin 
    xx = ""
    if(session.loginError == None):
        session.loginError = False
    if(session.loginError == True):
        session.loginError = None        
        response.flash = 'Bad login or password!'
    auth.settings.login_onfail = onFail   
    return dict(form=auth())  

def onFail(aa):
    session.loginError = True


def setAdmin(regForm):
    sql = "insert into auth_membership (user_id, group_id) values ("+str(regForm.vars.id)+",6)"
    db.executesql(sql)
    return 

def onLogin(aa):
    if auth.user.active == False:
        redirect(URL('user',args=['logout']))

@auth.requires_login()
def index():
    selDomain = None
    projects = None    
    domains = None
    
    if len(request.args) > 0:
        selDomain = request.args[0]

    sql = "select domain_id, domain_name from domains where domain_id in (select domain_id from domain_users where user_id = '"+auth.user.user_id+"') order by domain_name"
    domains = db.executesql(sql)    
    
    if selDomain == None:        
        if len(domains) > 0:
            selDomain = domains[0][0]
            
    if selDomain != None:        
        sql=" select project_id, project_name from projects where project_id in (select project_id from domain_projects  \
              inner join project_users using(project_id) where domain_id = '"+selDomain+"' \
              and user_id = '"+auth.user.user_id+"' and privilege_id != 4) \
              order by project_name"
        projects = db.executesql(sql)
            
    return dict(domains = domains,selDomain=selDomain,projects=projects)

@auth.requires_login()
def indexAdmin():
    domains = None
    projects = None    
               
    sql = "SELECT d.domain_id, d.domain_name, d.domain_descr, p.project_id, p.project_name,p.project_descr,p.url,p.created, du.domain_admin, p.project_admin,d.created \
          FROM domains d \
          INNER JOIN domain_users du ON du.domain_id = d.domain_id \
          LEFT JOIN ( \
          SELECT dp.domain_id, p.project_id, p.project_name,p.project_descr,p.url,p.created,pu.project_admin  FROM projects p \
          INNER JOIN project_users pu USING(project_id) \
          INNER JOIN domain_projects dp ON dp.project_id = p.project_id \
          WHERE pu.user_id = '{user_id}' \
          ) p ON p.domain_id = d.domain_id \
          WHERE du.user_id = '{user_id}' ORDER BY d.domain_name, p.project_name \
          ".format(user_id = auth.user.user_id)    
    projects = db.executesql(sql) 
    

    sql = 'SELECT status_id, status_descr FROM status order by status_descr'
    pom = db.executesql(sql)
      
    sNames = {}
    for item in pom:
        sNames[item[0]]=item[1]  
    
    return dict(projects=projects,domains=domains, statuses = sNames)

@auth.requires_login()
def editDomain():
    domain = None
    
    domainId = request.args[0]
    
    if domainId != '0':
        sql = "select domain_id, domain_name, domain_descr from domains where domain_id = '"+domainId+"'"
        domain = db.executesql(sql)[0]
    
    return dict(domain = domain,domainId = domainId)

@auth.requires_login()
def saveDomain():    
    domainData = request.post_vars

    if domainData["domainId"] == '0':
        m = hashlib.md5()
        m.update(unicode(datetime.datetime.now())+domainData["domain_name"])
        domainId = m.hexdigest()    
        sql = "insert into domains (domain_id, domain_name, domain_descr, created_user, created) values ('"+domainId+"','"+domainData["domain_name"]+"','"+domainData["domain_descr"]+"','"+auth.user.user_id+"', now()) "        
        db.executesql(sql)
        sql = "insert into domain_users values('"+domainId+"','"+auth.user.user_id+"','t')" 
        db.executesql(sql)
    else: 
        sql = "update domains set domain_name = '"+domainData["domain_name"]+"',domain_descr = '"+domainData["domain_descr"]+"' where domain_id = '"+domainData["domainId"]+"'"
        db.executesql(sql)
        domainId = domainData["domainId"]
    return domainId

@auth.requires_login()
def editProject():
    project = None
    
    domainId = request.args[0]
    projectId = request.args[1]
    mainNode = 0
    
    if projectId != '0':
        sql = "select project_id, project_name, project_descr from projects where project_id = '"+projectId+"'"
        project = db.executesql(sql)[0]
    
    sql = 'SELECT status_id, status_descr FROM status order by status_descr'
    pom = db.executesql(sql)
      
    sNames = {}
    for item in pom:
        sNames[item[0]]=item[1]

    sql = 'SELECT node_id, node_name FROM dbnodes order by node_name'
    pom = db.executesql(sql)
      
    nodes = {}
    for item in pom:
        nodes[item[0]]=item[1]    
        
    sql = "select node_id,node_type_id from project_nodes where project_id = '"+projectId+"' order by node_type_id"
    pom = db.executesql(sql)
    
    if len(pom) > 0:
        mainNode = pom[0][0]
    
    selNodes = {}
    for item in pom:
        selNodes[item[0]]=item[1]
        
    sql = "select template_id, template_name, template_descr from project_templates order by template_id"
    templates = db.executesql(sql)
        
    return dict(project = project,projectId = projectId,domainId=domainId,statuses=sNames,nodes=nodes,selNodes = selNodes,mainNode=mainNode,templates=templates)

@auth.requires_login()
def saveProject():    
    projectData = request.post_vars

    if projectData["projectId"] == '0':
        project_id = "pj_" + hashlib.md5(unicode(datetime.datetime.now())+projectData["project_name"]).hexdigest()

        sql = "insert into projects (project_id, project_name, project_descr, created_user, created) values ('"+project_id+"','"+projectData["project_name"]+"','"+projectData["project_descr"]+"','"+auth.user.user_id+"', now()) "        
        db.executesql(sql)
        sql = "insert into domain_projects values('"+projectData["domainId"]+"','"+project_id+"')" 
        db.executesql(sql)
        
#         # domain admin query
#         domain_admin_q = "SELECT user_id, username FROM domain_users INNER JOIN auth_user USING(user_id) \
#                         WHERE domain_id = '{domain_id}' AND domain_admin = True".format(domain_id = projectData["domainId"])
#         domain_admin = db.executesql(domain_admin_q, as_dict=True)
        
        # prida do projektu admina - domain admin je zaroven project admin a dale se s nim neoperuje
        ins_admin_q = "INSERT INTO project_users(project_id, user_id, project_admin, \
               privilege_id) VALUES ('{project_id}', '{admin_id}', True, 1);".format(
                                                                                project_id = project_id,
                                                                                admin_id = auth.user.user_id
                                                                                )
        db.executesql(ins_admin_q)
        
    else:
        sql = "update projects set project_name = '"+projectData["project_name"]+"',project_descr = '"+projectData["project_descr"]+"' where project_id = '"+projectData["projectId"]+"'"
        db.executesql(sql)
        project_id = projectData["projectId"]
        
        sql = "delete from project_nodes where project_id = '"+project_id+"'"
        db.executesql(sql)
    
    sql = "insert into project_nodes values( '"+project_id+"',"+ projectData["main_node"]+", 1)"
    db.executesql(sql)
    
    if projectData["projectNodes"] != None:
        if type(projectData["projectNodes"]) is str:        
            sql = "insert into project_nodes values( '"+project_id+"',"+projectData["projectNodes"]+", 2)"
            db.executesql(sql)
        else:
            for item in projectData["projectNodes"]:
                sql = "insert into project_nodes values( '"+project_id+"',"+ item+", 2)"
                db.executesql(sql)
    
    if projectData["projectId"] == '0':
        if projectData["dataTemplate"] == 'None':
            projectData["dataTemplate"] = '0'

        mng.createProject(project_id,projectData["dataTemplate"])        

        
    return projectData["domainId"]


@auth.requires_login()
def deleteProject():  
    project_id = request.args[1]
    
    mng.deleteProject(project_id)
    
    sql = "delete from projects where project_id = '"+project_id+"'"
    db.executesql(sql)
    
    return True

@auth.requires_login()
def groupsUserPrivileges():
    domain_id = request.args[0]
    project_id = request.args[1]
    
    sql = "select privilege_id, privilege_descr from privileges where privilege_id != -1 order by privilege_name"
    privileges = db.executesql(sql)
    
    sql = "select project_name from projects where project_id = '"+project_id+"'"
    project = db.executesql(sql)[0][0]
   
    groups = None
    users = None
    return dict(domainId=domain_id, projectId=project_id, privileges = privileges,groups=groups, users=users, project=project)

@auth.requires_login()
def getUserPrivileges():
    privilegeId = request.args[0]
    project_id = request.args[1]
    
    sql="select domain_id from domain_projects where project_id = '"+project_id+"'"
    domain_id = db.executesql(sql)[0][0]

    sql = "select du.user_id, concat(au.first_name, ' ', au.last_name), \
        case when pu.privilege_id > 0 then pu.privilege_id else 0 end from auth_user au inner \
        join domain_users du on du.user_id = au.user_id left \
        join (select user_id, privilege_id, project_admin from project_users where project_id = '"+project_id+"') \
        pu on du.user_id = pu.user_id where du.domain_id = '"+domain_id+"' and du.domain_admin = False \
        and (project_admin != True or project_admin is null)"
    users = db.executesql(sql) 
    ret = {}
    ret['users'] = json.dumps(users)
    return response.json(ret)    
    #return ret[:-1]
    
@auth.requires_login()
def getSqlInCond(input_list):
    list_a = []
    if len(input_list):
        for item in input_list:
            list_a.append("'{item}'".format(item = item))
    list_s = ','.join(list_a) if len(list_a) else ''
    return list_s

@auth.requires_login()
def setUserPrivileges():
    userId = request.args[0]
    projectId = request.args[1]
    privilegeId = request.args[2]
    
    new_users = []
    del_users = []

    prev_users_a = []
    prev_users_q = "SELECT user_id FROM project_users WHERE project_id = '{project_id}' \
                    AND project_admin = False".format(project_id = projectId)
     
    prev_users = db.executesql(prev_users_q, as_dict=True)

    for prev_user in prev_users:
        prev_users_a.append(prev_user['user_id'])

    # pokud userId = null -> vymazou se vsichni uzivatele s prislusnym privilege pro dany projekt
    # kteri nejsou soucasti skupin, tem se updatne priviliga na -1, rizeno skupinou
    if userId != 'null':
        userList = userId.split('_')
        # vytahne puvodni uzivatele - users
        new_users = list(set(userList) - set(prev_users_a))
        del_users = list(set(prev_users_a) - set(userList))
        
        #=======================================================================
        #  MAZANI UZIVATELU Z PROJEKTU
        #=======================================================================
                
        # zmeni privilege na -1 pro uzivatele, kteri jsou pridani skupinou
        if len(del_users):
            del_users_s = getSqlInCond(del_users)
            
            del_users_update_q = "UPDATE project_users SET privilege_id = -1 WHERE user_id IN ( \
                                  SELECT user_id FROM domaingroup_users dgu \
                                  INNER JOIN project_domaingroups pdg on pdg.domaingroup_id = dgu.domaingroup_id \
                                  WHERE project_id = '{project_id}' \
                                  AND user_id IN ({del_users_s}) \
                                  ) AND project_id = '{project_id}'".format(project_id = projectId,
                                                                            del_users_s = del_users_s
                                                                            )
            db.executesql(del_users_update_q)
            
            # update uzivatelu v DB projektu - update priv na -1
            upd_users_q = "SELECT user_id FROM project_users WHERE project_id = '{project_id}' \
                            AND privilege_id = -1 ".format(project_id = projectId)
            
            udp_users = db.executesql(upd_users_q, as_dict=True)
            
            if len(udp_users):
                upd_users_pj_q = "UPDATE userspace.users SET privilege_id = -1 WHERE user_id IN ({users})"
                tmp_user_list = []
                for u in udp_users:
                    tmp_user_list.append(u['user_id'])

                mng.executeRemoteSQL(projectId, upd_users_pj_q.format(users = getSqlInCond(tmp_user_list))
                                     , False, True, False)
                
            # users to delete
            users_q = "SELECT user_id FROM project_users WHERE user_id IN ({del_users_s}) \
                           AND privilege_id = {priv_id} AND project_id = '{project_id}' AND project_admin = False \
                           ".format(del_users_s = del_users_s,
                                    priv_id = privilegeId,
                                    project_id = projectId
                                    )
            
            users = db.executesql(users_q, as_dict=True)
            
            users_a = []
            
            for u in users:
                users_a.append(u['user_id'])

            # users and their items (dashs, reps, meas)
            u_items_dic = {}
            for u in users_a:
                tmp_items = users_mod.getUserItems(projectId, u)

                if tmp_items != False:
                    u_items_dic[u] = tmp_items
                    
            get_del_users_q = "SELECT user_id FROM project_users WHERE user_id IN ({del_users_s}) \
                           AND privilege_id = {priv_id} AND project_id = '{project_id}' AND project_admin = False \
                           ".format(del_users_s = del_users_s,
                                    priv_id = privilegeId,
                                    project_id = projectId
                                    )            
            del_users = db.executesql(get_del_users_q, as_dict = True)
            if len(del_users):
                del_users_s = getSqlInCond([u['user_id'] for u in del_users])
             
                del_users_q = "DELETE FROM project_users WHERE user_id IN ({del_users_s}) \
                               ".format(del_users_s = del_users_s,
                                        priv_id = privilegeId,
                                        project_id = projectId
                                        )
                db.executesql(del_users_q)
                
                # vymaze uzivatele v DB projektu
                del_users_pj_q = "DELETE FROM userspace.users WHERE user_id IN ({del_users_s}) ; \
                                  DELETE FROM auth_user WHERE user_id IN ({del_users_s});\
                               ".format(del_users_s = del_users_s,
                                        priv_id = privilegeId
                                        )
                mng.executeRemoteSQL(projectId, del_users_pj_q, False, True, False)
            
        #=======================================================================
        #  UPDATNE PRIVILEGIA U SOUCASNYCH A PRIDA NOVE DO PROJEKTU
        #=======================================================================
        # update
        upd_users_s = getSqlInCond(userList)
        upd_users_q = "UPDATE project_users SET privilege_id = {priv_id} \
                       WHERE user_id IN ({upd_users_s}) AND project_id = '{project_id}'\
                       ".format(priv_id = privilegeId,
                                upd_users_s = upd_users_s,
                                project_id = projectId
                                )
        db.executesql(upd_users_q)
        
        upd_users_pj_q = "UPDATE userspace.users SET privilege_id = {priv_id} \
                       WHERE user_id IN ({upd_users_s})".format(priv_id = privilegeId,
                                                                upd_users_s = upd_users_s
                                                                )                
        mng.executeRemoteSQL(projectId, upd_users_pj_q, False, True, False)
        
        
        
        # pridani
        if len(new_users):
            ins_user_q = "INSERT INTO project_users(project_id, user_id, privilege_id) \
                          VALUES ('{project_id}', '{uid}', {priv_id})"
                          
            ins_user_pj_q = "INSERT INTO userspace.users(user_id, privilege_id, username) \
                          VALUES ('{uid}', {priv_id}, '{username}'); \
                          INSERT INTO auth_user(first_name, last_name, email, user_id, username) \
                          VALUES ('{f_name}', '{l_name}', '{email}', '{uid}', '{username}');"        
            
            
            new_user_q = "SELECT first_name, last_name, email, user_id, username FROM auth_user \
                          WHERE user_id IN ({users})".format(users = getSqlInCond(new_users))

            new_users = db.executesql(new_user_q, as_dict=True)
            
            for user in new_users:
                db.executesql(ins_user_q.format(project_id = projectId,
                                                uid = user['user_id'],
                                                priv_id = privilegeId
                                                )
                              )
                
                mng.executeRemoteSQL(projectId, ins_user_pj_q.format(uid = user['user_id'], 
                                                                     priv_id = privilegeId, 
                                                                     username = user['username'],
                                                                     f_name = user['first_name'],
                                                                     l_name = user['last_name'],
                                                                     email = user['email']
                                                                     ),
                                     False, True, False)             
            
    else:
        # oddelan vsichni uzivatele pro dane privilegium

        prev_users_q = "SELECT user_id FROM project_users WHERE project_id = '{project_id}' \
                        AND privilege_id = {priv_id}".format(project_id = projectId,
                                                             priv_id = privilegeId
                                                             )
         
        prev_users = db.executesql(prev_users_q, as_dict=True)
        
        
        if len(prev_users):
            prev_users_a = []
            for user in prev_users:
                prev_users_a.append(user['user_id'])
            prev_users_s = getSqlInCond(prev_users_a)
        
            del_users_update_q = "UPDATE project_users SET privilege_id = -1 WHERE user_id IN ( \
                          SELECT user_id FROM domaingroup_users dgu \
                          INNER JOIN project_domaingroups pdg on pdg.domaingroup_id = dgu.domaingroup_id \
                          WHERE project_id = '{project_id}' \
                          AND user_id IN ({prev_users_s}) \
                          ) AND project_id = '{project_id}'".format(project_id = projectId,
                                                                    prev_users_s = prev_users_s
                                                                    )
        
            db.executesql(del_users_update_q)

            # update uzivatelu v DB projektu - update priv na -1
            upd_users_q = "SELECT user_id FROM project_users WHERE project_id = '{project_id}' \
                            AND privilege_id = -1 ".format(project_id = projectId)
            
            udp_users = db.executesql(upd_users_q, as_dict=True)
            
            if len(udp_users):
                upd_users_pj_q = "UPDATE userspace.users SET privilege_id = -1 WHERE user_id IN ({users})"
                tmp_user_list = []
                for u in udp_users:
                    tmp_user_list.append(u['user_id'])

                mng.executeRemoteSQL(projectId, upd_users_pj_q.format(users = getSqlInCond(tmp_user_list))
                                     , False, True, False) 

            get_del_users_q="SELECT user_id FROM project_users WHERE user_id IN ({prev_users_s}) \
                 AND project_id = '{project_id}' AND privilege_id = {priv_id} AND project_admin = False\
                 ".format(prev_users_s = prev_users_s,
                          project_id = projectId,
                          priv_id = privilegeId
                          )                
            
            del_users = db.executesql(get_del_users_q, as_dict = True)
                
            if len(del_users):
                del_users_s = getSqlInCond([u['user_id'] for u in del_users])
             
                del_users_q = "DELETE FROM project_users WHERE user_id IN ({del_users_s}) \
                               ".format(del_users_s = del_users_s,
                                        priv_id = privilegeId,
                                        project_id = projectId
                                        )
                db.executesql(del_users_q)
                
                # vymaze uzivatele v DB projektu
                del_users_pj_q = "DELETE FROM userspace.users WHERE user_id IN ({del_users_s}) ; \
                                  DELETE FROM auth_user WHERE user_id IN ({del_users_s});\
                               ".format(del_users_s = del_users_s,
                                        priv_id = privilegeId
                                        )
                mng.executeRemoteSQL(projectId, del_users_pj_q, False, True, False)            
            
    return True

@auth.requires_login()
def getGroupPrivileges():
    privilegeId = request.args[0]
    projectId = request.args[1]
    
    sql="select domain_id from domain_projects where project_id = '"+projectId+"'"
    domainId = db.executesql(sql)[0][0]
    
    #sql="select domaingroup_id from project_domaingroups where privilege_id = '"+privilegeId+"' and project_id = '"+projectId+"'"
    
    sql = "select dg.domaingroup_id, dg.domaingroup_name, case when dgp.privilege_id > 0 then dgp.privilege_id else 0 end as privilige_id from domain_groups dg \
            left join  (select domaingroup_id, privilege_id from project_domaingroups \
            where project_id = '{project_id}') dgp \
            on dg.domaingroup_id = dgp.domaingroup_id where dg.domain_id = '{domain_id}' order by dg.domaingroup_name\
            ".format(project_id = projectId, domain_id = domainId)
    
    rows = db.executesql(sql)

    ret = {}
    ret['groups'] = json.dumps(rows)
    return response.json(ret)

@auth.requires_login()
def setGroupPrivileges():
    groupId = request.args[0]
    projectId = request.args[1]
    privilegeId = request.args[2]
    
    new_groups = []
    del_groups = []
    
    # vytahne puvodni skupiny 
    prev_groups_a = []
    prev_groups_q = "SELECT domaingroup_id FROM project_domaingroups WHERE project_id = '{project_id}' \
                     AND privilege_id = {priv_id}".format(project_id = projectId,
                                                          priv_id = privilegeId
                                                          )
    prev_groups = db.executesql(prev_groups_q, as_dict=True)
    for prev_group in prev_groups:
        prev_groups_a.append(prev_group['domaingroup_id'])    
    
    prev_groups_all_a = []
    prev_groups_all_q = "SELECT domaingroup_id FROM project_domaingroups WHERE project_id = '{project_id}' \
                        ".format(project_id = projectId)
    prev_groups_all = db.executesql(prev_groups_all_q, as_dict=True)
    for prev_group in prev_groups_all:
        prev_groups_all_a.append(prev_group['domaingroup_id'])    
    
    if groupId != 'null': 
        groupList = groupId.split('_')

        new_groups = list(set(groupList) - set(prev_groups_a))
        del_groups = list(set(prev_groups_a) - set(groupList))
        cur_groups = list(set(prev_groups_all_a) - set(del_groups))

        #=======================================================================
        #  MAZANI SKUPIN PROJEKTU
        #=======================================================================
        if len(del_groups):
            del_groups_s = getSqlInCond(del_groups)
            cur_groups_s = getSqlInCond(cur_groups)

            # smaze uzivatele podle skupiny z tab project users, kteri nemaji svoje priv nebo nejsou v jine skupine
            
            del_users_q = "SELECT user_id FROM project_users WHERE user_id IN ( \
                           SELECT dgu.user_id FROM domaingroup_users dgu \
                           INNER JOIN project_domaingroups pdg on pdg.domaingroup_id = dgu.domaingroup_id \
                           INNER JOIN project_users pu on pu.project_id = pdg.project_id \
                           WHERE pdg.project_id = '{project_id}' \
                           AND pdg.domaingroup_id in ({del_groups_s}) AND pu.privilege_id = -1 \
                           ) AND project_id = '{project_id}' \
                           AND user_id NOT IN ( \
                           SELECT dgu.user_id FROM domaingroup_users dgu \
                           INNER JOIN project_domaingroups pdg on pdg.domaingroup_id = dgu.domaingroup_id \
                           INNER JOIN project_users pu on pu.project_id = pdg.project_id \
                           WHERE pdg.project_id = '{project_id}' \
                           AND pdg.domaingroup_id IN ({cur_groups_s})) \
                           ".format(project_id = projectId,
                                    del_groups_s = del_groups_s,
                                    cur_groups_s = cur_groups_s
                                    )

            del_users = db.executesql(del_users_q, as_dict=True)
            
            if len(del_users):
                del_users_a = []
                for u in del_users:
                    del_users_a.append(u['user_id'])
                del_users_s = getSqlInCond(del_users_a)
                
                del_users_q = "DELETE FROM project_users WHERE user_id IN ({del_users_s}) \
                                AND project_id = '{project_id}'".format(del_users_s = del_users_s,
                                                                        project_id = projectId
                                                                        )
                db.executesql(del_users_q)
                
                # vymaze uzvivatele v DB projektu
                del_users_pj_q = "DELETE FROM userspace.users WHERE user_id IN ({del_users_s}) \
                                  ".format(del_users_s = del_users_s)
                
                mng.executeRemoteSQL(projectId, del_users_pj_q, False, True, False)
                
            
            # smaze skupiny
            del_groups_q = "DELETE FROM project_domaingroups WHERE project_id = '{project_id}' \
                            AND domaingroup_id IN ({del_groups_s})".format(project_id = projectId,
                                                                           del_groups_s = del_groups_s
                                                                           )
            db.executesql(del_groups_q)
            
            # smaze skupiny v DB projektu
            del_groups_pj_q = "DELETE FROM userspace.usergroups WHERE usergroup_id IN ({del_groups_s}) \
                                ".format(del_groups_s = del_groups_s)
            mng.executeRemoteSQL(projectId, del_groups_pj_q, False, True, False)
            
        #=======================================================================
        #  PRIDA NOVE SKUPINY DO PROJEKTU, PRIDA UZIVATELE PODLE SKUPIN
        #=======================================================================
        if len(new_groups):
            new_groups_s = getSqlInCond(new_groups)
            # prida skupiny
            
            # nove skupiny
            new_groups_q = "SELECT domaingroup_id, domaingroup_name, domaingroup_descr FROM domain_groups \
                            WHERE domaingroup_id IN  ({new_groups_s})".format(new_groups_s = new_groups_s)
            
            new_groups = db.executesql(new_groups_q, as_dict=True)
            
            ins_group_q = "INSERT INTO project_domaingroups(domaingroup_id, project_id, privilege_id) \
                           VALUES ('{dg_id}', '{project_id}', {priv_id});"
            
            ins_group_pj_q = "INSERT INTO userspace.usergroups(usergroup_id, usergroup_name, usergroup_descr, privilege_id) \
                           VALUES ('{ug_id}', '{ug_name}', '{ug_descr}', {priv_id});"

            for group in new_groups:
                db.executesql(ins_group_q.format(dg_id = group['domaingroup_id'],
                                                 project_id = projectId,
                                                 priv_id = privilegeId
                                                 )
                              )
                mng.executeRemoteSQL(projectId, ins_group_pj_q.format(ug_id = group['domaingroup_id'],
                                                                       ug_name = group['domaingroup_name'],
                                                                       ug_descr = group['domaingroup_descr'],
                                                                       priv_id = privilegeId
                                                                       )
                                     , False, True, False)
                
            # prida uzivatele do projektu, kteri jsou novy a pridani skupinou
            new_users_q = "SELECT DISTINCT au.first_name, au.last_name, au.email, au.user_id, au.username FROM domaingroup_users \
                           INNER JOIN auth_user au USING(user_id) \
                           WHERE domaingroup_id IN ({new_groups_s}) AND au.user_id NOT IN ( \
                           SELECT user_id FROM project_users WHERE project_id = '{project_id}') \
                           ".format(new_groups_s = new_groups_s,
                                    project_id = projectId
                                    )

            new_users = db.executesql(new_users_q, as_dict=True)
            
            if len(new_users):
                ins_user_q = "INSERT INTO project_users(project_id, user_id, privilege_id) \
                                      VALUES ('{project_id}', '{uid}', -1)"
                                      
                ins_user_pj_q = "INSERT INTO userspace.users(user_id, username) \
                                VALUES ('{uid}', '{username}');\
                                INSERT INTO auth_user(first_name, last_name, email, user_id, username) \
                                VALUES ('{f_name}', '{l_name}', '{email}', '{uid}', '{username}');"
                
                for user in new_users:
                    db.executesql(ins_user_q.format(project_id = projectId,
                                                    uid = user['user_id']
                                                    )
                                  )
                    mng.executeRemoteSQL(projectId, ins_user_pj_q.format(uid = user['user_id'],
                                                                        username = user['username'],
                                                                        f_name = user['first_name'],
                                                                        l_name = user['last_name'],
                                                                        email = user['email']
                                                                        )
                                         , False, True, False)
                    
            # prida do DB projektu kombinace group - user
            new_users_groups_q = "SELECT user_id, domaingroup_id FROM domaingroup_users \
                                  WHERE domaingroup_id IN ({new_groups_s}) \
                                   ".format(new_groups_s = new_groups_s,
                                            project_id = projectId
                                            )

            new_users_groups = db.executesql(new_users_groups_q, as_dict=True)
            if len(new_users_groups):
                ins_ug_q = "INSERT INTO userspace.usergroup_users(usergroup_id, user_id) \
                            VALUES ('{gid}', '{uid}');"
                for ug in new_users_groups:
                    mng.executeRemoteSQL(projectId, ins_ug_q.format(uid = ug['user_id'],
                                                                    gid = ug['domaingroup_id']
                                                                    )
                                         , False, True, False)
                          
            
                      
    
    else:
        del_groups_q = "SELECT domaingroup_id FROM project_domaingroups WHERE project_id = '{project_id}' \
                        AND privilege_id = {priv_id}".format(project_id = projectId,
                                                             priv_id = privilegeId
                                                             )
        
        del_groups = db.executesql(del_groups_q, as_dict = True)
        if len(del_groups):
            del_groups_a = []
            for g in del_groups:
                del_groups_a.append(g['domaingroup_id'])
                
            del_groups_s = getSqlInCond(del_groups_a)
            
            # vymaze uzivatele ze skupiny, pokud jsou pouze pridani touto skupinou
            # tj. nejsou pridani jako users nebo v jine skupine v projektu
            
            del_users_q = "SELECT user_id FROM project_users WHERE user_id IN ( \
                           SELECT dgu.user_id FROM domaingroup_users dgu \
                           INNER JOIN project_domaingroups pdg on pdg.domaingroup_id = dgu.domaingroup_id \
                           INNER JOIN project_users pu on pu.project_id = pdg.project_id \
                           WHERE pdg.project_id = '{project_id}' \
                           AND pdg.domaingroup_id in ({del_groups_s}) AND pu.privilege_id = -1 \
                           ) AND project_id = '{project_id}' AND privilege_id = -1 \
                           AND user_id NOT IN ( \
                           SELECT dgu.user_id FROM domaingroup_users dgu \
                           INNER JOIN project_domaingroups pdg on pdg.domaingroup_id = dgu.domaingroup_id \
                           INNER JOIN project_users pu on pu.project_id = pdg.project_id \
                           WHERE pdg.project_id = '{project_id}' \
                           AND pdg.domaingroup_id IN ( \
                           SELECT domaingroup_id FROM project_domaingroups WHERE \
                           domaingroup_id NOT IN ({del_groups_s}) AND project_id = '{project_id}' ) ) \
                           ".format(project_id = projectId,
                                    del_groups_s = del_groups_s
                                    )
            
            del_users = db.executesql(del_users_q, as_dict=True)
            
            if len(del_users):
                del_users_a = []
                for u in del_users:
                    del_users_a.append(u['user_id'])
                    
                del_users_s = getSqlInCond(del_users_a)
                
                del_users_q = "DELETE FROM project_users WHERE user_id IN ({del_users_s}) \
                                AND project_id = '{project_id}'".format(del_users_s = del_users_s,
                                                                        project_id = projectId
                                                                        )
                db.executesql(del_users_q)
                
                # vymaze uzvivatele v DB projektu
                del_users_pj_q = "DELETE FROM userspace.users WHERE user_id IN ({del_users_s}); \
                                  DELETE FROM auth_user WHERE user_id IN ({del_users_s}); \
                                  ".format(del_users_s = del_users_s)
                
                mng.executeRemoteSQL(projectId, del_users_pj_q, False, True, False)
            
            
            
            
            
            del_group_q = "DELETE FROM project_domaingroups WHERE domaingroup_id IN ({del_groups_s}) \
                           AND project_id = '{project_id}'".format(del_groups_s = del_groups_s,
                                                                   project_id = projectId
                                                                   )
            db.executesql(del_group_q)
            
            # smaze skupiny v DB projektu
            del_groups_pj_q = "DELETE FROM userspace.usergroups WHERE usergroup_id IN ({del_groups_s}) \
                                ".format(del_groups_s = del_groups_s)
            mng.executeRemoteSQL(projectId, del_groups_pj_q, False, True, False)
            
    return True

@auth.requires_login()
# ukladanie adminov
def setProjectAdmins():
    adminsId = request.args[0]
    projectId = request.args[1]

    # uzivatele kteri byli admini (except domain admin)

    prev_admins_q = "SELECT user_id FROM project_users WHERE project_id='{project_id}' \
                        AND project_admin= True AND user_id != ( \
                        SELECT user_id FROM domain_users WHERE domain_id = ( \
                        SELECT domain_id FROM domain_projects WHERE project_id = '{project_id}' \
                        ) AND domain_admin = True )".format(project_id = projectId)
    prev_admins_a = []
    prev_admins = db.executesql(prev_admins_q, as_dict = True)
    
    if len(prev_admins):
        for admin in prev_admins:
            prev_admins_a.append(admin['user_id'])    
    
    upd_admin_q = "UPDATE project_users SET project_admin= {isAmdmin}, privilege_id = 1 \
                        WHERE project_id='{project_id}' AND user_id IN ({admins_s})"
                        
    upd_admin_pj_q = "UPDATE userspace.users SET project_admin= {isAmdmin}, privilege_id = 1 \
                        WHERE user_id IN ({admins_s})"
                        
    new_admins = []
    rem_admins = []
                        
    if adminsId != 'null': 
        adminList = adminsId.split('_')
        

        # novy admini update project_admin True
        new_admins = list(set(adminList) - set(prev_admins_a))
        
        # uz nejsou admini update project_admin False
        rem_admins = list(set(prev_admins_a) - set(adminList))


        
        new_admins_s = getSqlInCond(new_admins)
        rem_admins_s = getSqlInCond(rem_admins)
        if len(new_admins):
            db.executesql(upd_admin_q.format(project_id = projectId,
                                                 admins_s = new_admins_s,
                                                 isAmdmin = 'True'
                                                 ))
            mng.executeRemoteSQL(projectId, upd_admin_pj_q.format(admins_s = new_admins_s,
                                                                  isAmdmin = 'True'
                                                                  )
                                 , False, True, False)
        if len(rem_admins):
            db.executesql(upd_admin_q.format(project_id = projectId,
                                                 admins_s = rem_admins_s,
                                                 isAmdmin = 'False'
                                                 ))
            mng.executeRemoteSQL(projectId, upd_admin_pj_q.format(admins_s = rem_admins_s,
                                                                  isAmdmin = 'False'
                                                                  )
                                 , False, True, False)            
    else:
        if len(prev_admins_a):
            rem_admins_s = getSqlInCond(prev_admins_a)
            db.executesql(upd_admin_q.format(project_id = projectId,
                                                 admins_s = rem_admins_s,
                                                 isAmdmin = 'False'
                                                 ))
            mng.executeRemoteSQL(projectId, upd_admin_pj_q.format(admins_s = rem_admins_s,
                                                                  isAmdmin = 'False'
                                                                  )
                                 , False, True, False)
   
    return True

@auth.requires_login()
def readProjectUsers():
    domainId = request.args[0]
    projectId = request.args[1]
    
    sql = "SELECT pu.user_id, concat(first_name, ' ', last_name), pu.project_admin FROM project_users pu INNER JOIN auth_user au on pu.user_id = au.user_id \
          WHERE pu.project_id = '{project_id}' AND pu.user_id != ( \
          SELECT user_id FROM domain_users WHERE domain_id = '{domain_id}' AND domain_admin = True) \
          ".format(project_id = projectId, domain_id = domainId) 

    rows = db.executesql(sql)
    
    ret = {}
    ret['users'] = json.dumps(rows)
    return response.json(ret)


@auth.requires_login()
def deleteDomain():
    domainId = request.args[0]
    
    # smaze projekty v domene
    projects_q = "SELECT project_id FROM domain_projects WHERE domain_id = '{domain_id}'\
                    ".format(domain_id = domainId)
    projects = db.executesql(projects_q, as_dict=True)
    if len(projects):
        for project in projects:
            mng.deleteProject(project['project_id'])
    
            del_project_q = "delete from projects where project_id = '%s'"%project['project_id']
            db.executesql(del_project_q)
    
    del_domain_q = "DELETE FROM domains WHERE domain_id = '%s'"%domainId
    db.executesql(del_domain_q)
    return True

@auth.requires_login()
def lotyldaToolVerifi():
    project_id = request.get_vars['project_id']
    if not len(project_id):
        return False 
    pj_q = "SELECT 1 FROM projects WHERE project_id = '%s'"%project_id
    pj_exists = db.executesql(pj_q)

    if len(pj_exists):
        return True
    else:
        return False

@auth.requires_login()
def tu():
    print "FU"
    return
    



