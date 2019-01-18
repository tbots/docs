# -*- coding: utf-8 -*-
from gluon import current
import os
import errno
import psycopg2.extras
import subprocess
import sys, traceback

def executeRemoteSQL(project_id, query, isSelect, main_node, part_nodes):
    '''funkce spusti pozadovane sql na hlavnim nodu jine DB, podle nastaveni projektu
       isSelect - pokud je select vrati se hodnota
       main_node - spustit na hlavnim nodu
       part_nodes - spustit na dilcich nodech
    '''
    db = current.db
    db_set = current.dbData_settings
    db_name = 'db_' + project_id.replace('pj_','')
    node_cond = ''
    return_val = None
    
    if main_node and part_nodes:
        node_cond = ''
    elif main_node and not part_nodes:
        node_cond = ' pn.node_type_id = 1  and '
    elif not main_node and part_nodes:
        node_cond = ' pn.node_type_id != 1  and '
    else:
        print "SPATNE ZADANE PODMINKY PRO NODY"
        return False
    
    # ziska ip, port pozdaovane db
    pj_set_q = "select n.ip_address, n.ip_port, pn.node_type_id, p.project_name from dbnodes n \
                   inner join project_nodes pn on pn.node_id = n.node_id \
                   inner join projects p on p.project_id = pn.project_id \
                   where {node_cond} pn.project_id = '{project_id}'".format(project_id = project_id,
                                                                            node_cond = node_cond
                                                                            )    
    pj_db_set = db.executesql(pj_set_q, as_dict=True)
    
    if len(pj_db_set):
        for p in pj_db_set:
            con = psycopg2.connect(host=p['ip_address'],port=p['ip_port'],database=db_name, user=db_set['DBuser'], password=db_set['DBpassword'])
            cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
            if isSelect:
                cur.execute(query)
                return_val = cur.fetchall()
            else:
                cur.execute(query)
                con.commit()
                return_val = True
            con.close()
            
        return return_val
    else:
        return [] if isSelect else True


def insertAdminUser(db_host, db_port, db_name, db_user, db_user_pwd, admin_id, admin_name):
    con = psycopg2.connect(host=db_host,port=db_port,database=db_name, user=db_user, password=db_user_pwd)
    cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
    ins_admin_q = "INSERT INTO userspace.users(user_id, privilege_id, project_admin, username) \
                    VALUES ('{admin_id}', 1, True, '{admin_name}')".format(admin_id = admin_id,
                                                                           admin_name = admin_name
                                                                           )
    cur.execute(ins_admin_q)
    con.commit()
    con.close()
    
def createDB(db_host, db_port, db_name, db_user, db_user_pwd):
    '''vytvori db'''
#     print "db_host, db_port, db_name, db_user, db_user_pwd"
#     print "%s  %s %s %s %s"%(db_host, db_port, db_name, db_user, db_user_pwd)
    try:
        con = psycopg2.connect(host=db_host,port=db_port,database='template1', user=db_user, password=db_user_pwd)
        cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
        con.set_isolation_level(0)
        cur.execute('create database {db_name}'.format(db_name = db_name))
        con.set_isolation_level(1)
        con.close()
        return True
    except:
        print "Database create error." + traceback.format_exc()
        return "Database create error. \n" +traceback.format_exc()

def deleteDB(db_host, db_port, db_name, db_user, db_user_pwd):
    '''deletion of project database'''
    try:
        con = psycopg2.connect(host=db_host,port=db_port,database='template1', user=db_user, password=db_user_pwd)
        cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)
        # kill all sessions on database
        db_sessions_q = "SELECT * FROM pg_stat_activity WHERE datname = '{db_name}'".format(db_name = db_name)
        cur.execute(db_sessions_q)
        db_sessions = cur.fetchall()
        if len(db_sessions):
            for s in db_sessions:
                kill_session_q = "SELECT pg_terminate_backend({pid}) FROM pg_stat_activity WHERE datname = '{db_name}'"
                cur.execute(kill_session_q.format(pid = s['pid'], db_name = db_name))
                con.commit()
                
        con.set_isolation_level(0)
        cur.execute('drop database {db_name}'.format(db_name = db_name))
        con.commit()
        con.set_isolation_level(1)
        con.close()
    except:
        print "Database delete error." + traceback.format_exc()
        return "Database delete error. \n" +traceback.format_exc()
        

def createProject(project_id, project_template):
    '''vytvori novy projekt z nastaveni v DB'''
    try:
        db = current.db
        auth = current.auth
        db_set = current.dbData_settings
        project_url = current.project_url.replace('/','\/')

        db_name = "db_" + project_id.replace('pj_','')
        
        w2p_path = os.getcwd() 
        
        pj_cfg_file = "{w2p_path}/applications/{project_id}/private/appconfig.ini".format(w2p_path = w2p_path,
                                                                                          project_id = project_id
                                                                                          )
        
        project_cp_script = "cp -r {w2p_path}/applications/project_template {w2p_path}/applications/{project_id}"
        
        if not os.path.exists('{w2p_path}/applications/{project_id}'): 
            try:
                subprocess.call(project_cp_script.format(w2p_path = w2p_path, project_id = project_id), shell=True)
            except OSError, e:
                if e.errno != errno.EEXIST:
                    raise e
                pass
        
        # zohledni nastaveni template projektu
        script_file = db.executesql("select scriptpath from project_templates where template_id = " + str(project_template))
            
        #===========================================================================
        # NASTAVENI DB.PY PRO NOVY PROJEKT
        #===========================================================================
        
        # dostane z DB jednotlive nody 1 - hlavni, 2 - partition
        project_nodes_q = "select n.ip_address, n.ip_port, pn.node_type_id, p.project_name from dbnodes n \
                       inner join project_nodes pn on pn.node_id = n.node_id \
                       inner join projects p on p.project_id = pn.project_id \
                       where pn.project_id = '{project_id}'  order by pn.node_type_id ".format(project_id = project_id)    
                       
        project_nodes = db.executesql(project_nodes_q,as_dict=True)
        
        db_nodes = []
        db_nodes_cfg = []
        
        # pro nahrazovani hodnot v souborech
        bash_sed = 'sed -i "s/{old}/{new}/g" ' + pj_cfg_file
            
        main_node_con = {}
        for idx, node in enumerate(project_nodes):
            
            # vytvoreni db na hlavnim nodu a nastaveni configu v aplikaci
            if node['node_type_id'] == 1:
                
                main_node_con['host'] = node['ip_address']
                main_node_con['port'] = node['ip_port']
                
                
                subprocess.call(bash_sed.format(old = 'PROJECT_ID', new = project_id), shell=True)
                subprocess.call(bash_sed.format(old = 'DB_HOST_ADDRESS', new = node['ip_address']), shell=True)
                subprocess.call(bash_sed.format(old = 'DB_NAME', new = db_name), shell=True)
                subprocess.call(bash_sed.format(old = 'DB_PORT', new = node['ip_port']), shell=True)
                subprocess.call(bash_sed.format(old = 'DB_USER_PASSWORD', new = db_set['DBpassword']), shell=True)
                subprocess.call(bash_sed.format(old = 'DB_USER', new = db_set['DBuser']), shell=True)
                subprocess.call(bash_sed.format(old = 'PROJECT_URL', new = project_url), shell=True)
                
                
                # vytvori db podle projektu -> db_name = 'db_' + project_id
                createDB(node['ip_address'], node['ip_port'], db_name, db_set['DBuser'], db_set['DBpassword'])
    
                # vytvori db struktutu na hlavnim nodu
                create_script_path = "{w2p_path}/applications/lotylda_mng/scripts/{script_file}".format(w2p_path = w2p_path,
                                                                                                        script_file = script_file[0][0]
                                                                                                        )
                #===============================================================
                # psql -h 192.168.133.11 -p 5440 -U lotylda_admin -d lotylda_template -f /home/jurkij/Documents/template_db.sql
                #===============================================================

                db_structure_cmd = "psql -U {db_user} -h {db_host} -p {db_port} -d {db_name} -f {script}".format(
                                                                                                db_user = db_set['DBuser'],
                                                                                                db_user_pwd = db_set['DBpassword'],
                                                                                                db_host = node['ip_address'],
                                                                                                db_port = node['ip_port'],
                                                                                                db_name = db_name,
                                                                                                script = create_script_path
                                                                                                )
                subprocess.call(db_structure_cmd, shell=True)       

            # vytvoreni db na datovych nodech
            else:
                node_temp = "\[fs_node{idx}\]\\nhost            = {host}\\nport            = {port}\\n\\n"

                db_nodes.append("fs_node%s"%idx)
                tmp_node = node_temp.format(host = node['ip_address'],
                                            port = node['ip_port'],
                                            idx = idx
                                         )
                db_nodes_cfg.append(tmp_node)
                createDB(node['ip_address'], node['ip_port'], db_name, db_set['DBuser'], db_set['DBpassword'])
    
                con_node = psycopg2.connect(host=node['ip_address'],port=node['ip_port'],database=db_name, user=db_set['DBuser'], password=db_set['DBpassword'])
                cur_node = con_node.cursor(cursor_factory=psycopg2.extras.DictCursor)
                
                cur_node.execute('CREATE SCHEMA attrcache;CREATE SCHEMA datetime_cols;CREATE SCHEMA repcache;CREATE SCHEMA datastore;CREATE SCHEMA temp;')
     
                con_node.commit()
                con_node.close()
                
                con_main_node = psycopg2.connect(host=main_node_con['host'],port=main_node_con['port'],database=db_name, user=db_set['DBuser'], password=db_set['DBpassword'])
                cur_main_node = con_main_node.cursor(cursor_factory=psycopg2.extras.DictCursor)            
                
                

                
                # vytvoril mapovani pro zbyle nody na hlavnim nodu
                fs_nodes_q = "CREATE SERVER fs_node{idx} FOREIGN DATA WRAPPER postgres_fdw \
                              OPTIONS (host '{db_host}', port '{db_port}', dbname '{db_name}'); \
                              CREATE USER MAPPING FOR {db_user} SERVER fs_node{idx} \
                              OPTIONS (user '{db_user}', password '{db_user_pwd}');".format(
                                                                                          idx = idx,
                                                                                          db_host = node['ip_address'],
                                                                                          db_port = node['ip_port'],
                                                                                          db_name = db_name,
                                                                                          db_user = db_set['DBuser'],
                                                                                          db_user_pwd = db_set['DBpassword']
                                                                                          )
                
                cur_main_node.execute(fs_nodes_q)
                con_main_node.commit()  
                con_main_node.close()        
        
        
        insertAdminUser(main_node_con['host'], main_node_con['port'], db_name, db_set['DBuser'], 
                        db_set['DBpassword'], auth.user.user_id, auth.user.username)
        
        # nastaveni configu v aplikaci pro datove nody
        if len(db_nodes):
            subprocess.call(bash_sed.format(old = "DB_NODES_LIST", new = ','.join(db_nodes)), shell=True)
            subprocess.call(bash_sed.format(old = "DB_NODES_CFG", new = ''.join(db_nodes_cfg)), shell=True)
        else:
            subprocess.call(bash_sed.format(old = "DB_NODES_LIST", new = ''), shell=True)
            subprocess.call(bash_sed.format(old = "DB_NODES_CFG", new = ''), shell=True)

        return True
    except:
        traceback.print_exc(file=sys.stdout)
        return False

    
def deleteProject(projectId):      
    db = current.db
    db_set = current.dbData_settings
    w2p_path = os.getcwd() 
    project_rm_script = "rm -r {w2p_path}/applications/{project_id}"
    
    # kill app worker if exists
    p_worker = subprocess.check_output("ps -aux | grep %s | awk '{print $2}'"%projectId, shell=True)
    p_worker_a = p_worker.split('\n')
    if len(p_worker_a):
        for pid in p_worker_a:
            subprocess.call("kill -9 %s &>/dev/null 2>&1"%pid, shell=True)
    
    db_name = "db_" + projectId.replace('pj_','')
    
    # dostane z DB jednotlive nody 1 - hlavni, 2 - partition
    project_nodes_q = "select n.ip_address, n.ip_port, pn.node_type_id, p.project_name from dbnodes n \
                   inner join project_nodes pn on pn.node_id = n.node_id \
                   inner join projects p on p.project_id = pn.project_id \
                   where pn.project_id = '{project_id}'".format(project_id = projectId)    
                   
    project_nodes = db.executesql(project_nodes_q,as_dict=True)
    
    # smaze db na jednotlivych nodech
    for node in project_nodes:
        deleteDB(node['ip_address'], node['ip_port'], db_name, db_set['DBuser'], db_set['DBpassword'])    
    
    if os.path.exists('{w2p_path}/applications/{project_id}'.format(w2p_path = w2p_path, project_id = projectId)): 
        try:
            subprocess.call(project_rm_script.format(w2p_path = w2p_path, project_id = projectId), shell=True)
        except OSError, e:
            if e.errno != errno.EEXIST:
                raise e
            pass
    else: 
        return False








