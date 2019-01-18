# -*- coding: utf-8 -*-
import psycopg2.extras
import os
import multiprocessing
import json
import traceback
from time import sleep, time
import hashlib
import csv

from datetime import datetime
import pandas as pd


# load mode - fast_mode = True => increasing CPU usage for load 
FAST_MODE = True

db_port = 5440
db_host = "10.140.48.102"
# db_port = 5450
# db_host = "172.20.10.10"
db_name = "db_e92a8743436541f650225784ee58becb"
db_user = "lotylda_admin"
db_pass = "lotylda"

no_nodes = 8

db_main_node = {"host": db_host, "database": db_name, "port": db_port, "user": db_user, "password": db_pass}

db_nodes_conns = []
for i in range(1,no_nodes + 1):
    db_port_ = db_port + i
    nc = {"host": db_host, "database": db_name, "port": db_port_, "user": db_user, "password": db_pass}
    db_nodes_conns.append(nc)

# print db_nodes_conns

def get_up_json():
    upload_json = {
                  "upload_hash":"",
                  "upload_datasets":[],
                  "date_attr_refresh_start":"",
                  "date_attr_refresh_end":"",
                  "upload_start":"",
                  "upload_end":"",
                  "upload_status":"",
                  "upload_errors":""
                  }
    
    return upload_json

def get_file_up_json():
    file_up_json = {
          "dataset_id":"", 
          "dataset_name": "",
          "upload_cfg":{},
          "data_load_start": "",
          "data_load_end": "",
          "attr_refresh_start":"",
          "attr_refresh_end":"",
          "vacuum_start":"",
          "vacuum_end":"",
          "upload_status":"",
          "data_load_errors":"",
          "node_has_data":[]
          }
    
    return file_up_json

def ret_trace(t):
    '''prepare traceback for json'''
    if isinstance(t, list):
        t = ', '.join([str(a) for a in set(t)])
    return str(t).replace('\n', '=>').replace('"', '').replace("'", '')



def get_upload_status(upload_hash):
    load_stat = {}
    try:
        service_con = psycopg2.connect(**db_main_node)
        service_cur = service_con.cursor(cursor_factory=psycopg2.extras.DictCursor) 
        service_cur.execute("SELECT up_start, up_end, up_result, up_log FROM maintenance.data_upload WHERE up_hash = '%s'"%upload_hash)
        load_info = service_cur.fetchone()
         
        if len(load_info):
            if load_info[0]['up_end'] == None:
                load_stat['status'] = 1 # Running
            elif load_info[0]['up_result'] == True:
                load_stat['status'] = 2 # END OK
            else:
                load_stat['status'] = 3 # END KO
                load_stat['log'] = load_info[0]['up_log']
             
        else:
            load_stat['status'] = 0 # Not running
         
             
        return load_stat
    except:
        print traceback.format_exc()
        return traceback.format_exc()


def cur_query(db_cursor, sql_q, sql_q_result, idx):
    for q in sql_q:
        try:
            db_cursor.execute(q)
        except:
#             print traceback.format_exc()+ 'QUERY => ' + "\n\n\n" + q + "\n\n\n"
            sql_q_result[idx] = ret_trace(traceback.format_exc())
            return
    sql_q_result[idx] = True
                

def cur_query_old(db_cursor, sql_q, sql_q_result, idx):
    try:
        for q in sql_q:
            print q
            db_cursor.execute(q)
        sql_q_result[idx] = True
    except:
        print ret_trace(traceback.format_exc())
        sql_q_result[idx] = ret_trace(traceback.format_exc())

        
def run_parallel_sql(node_cons = [], sql_queries = [], run_nodes = [], db_commit = False): # 
    '''
    parallel query
    '''

    if not len(sql_queries):
        return True

    procs = []
    run_nodes = run_nodes if len(run_nodes) else [True]*len(node_cons)
    
    run_nodes_c = run_nodes.count(True)

    proc_res_list = [not k for k in run_nodes]
    proc_res = multiprocessing.Manager().list(proc_res_list)
    proc_end = [False]*run_nodes_c
    
    for idx, r in enumerate(run_nodes):
        if r:
            tmp_cur = node_cons[idx].cursor()
            procs.append(multiprocessing.Process(target=cur_query, args=(tmp_cur, sql_queries, proc_res, idx)))
    
    for p in procs:
        p.start()
        
    while False in proc_end:
        for idx, p in enumerate(procs):
            if not p.is_alive():
                proc_end[idx] = True
                if proc_res[idx] != True:
                    proc_end = [True]*run_nodes_c

        if not FAST_MODE: 
            sleep(1)
            

    for p in procs:
        p.join()
        
#     print "proc_res --> ",proc_res

    if list(set(proc_res)) != [True]:
        for p in procs:
            if p.is_alive():
                p.terminate()

        for node in node_cons:
            if node.closed == 0:
                node.rollback()                

    elif db_commit:
        for idx, node in enumerate(node_cons):
            if run_nodes[idx]:
                tmp_cur = node.cursor()
                tmp_cur.execute('SELECT')
                node.commit()        

    return proc_res


def updateStatus(status, table_id):
    try:
#         print "UPDATUJU STATUS PROJEKTU"
        service_con = psycopg2.connect(**db_main_node)
        service_cur = service_con.cursor() 
        upd_sql = " UPDATE engine.data_tbls SET upload_status='{upload_status}' WHERE tbl_id='{tbl_id}';".format(upload_status=json.dumps(status), tbl_id=table_id)
        service_cur.execute(upd_sql)
        service_con.commit()
    except:
        print traceback.format_exc()
        return traceback.format_exc()
# update maintenance.data_upload table
def store_upload_stats(upload_hash, res, status):
    try:
        service_con = psycopg2.connect(**db_main_node)
        service_cur = service_con.cursor() 
        ins_stat_q = "INSERT INTO maintenance.data_upload(upload_hash, load_result, status) VALUES ('{upload_hash}', '{res}', '{status}' );"
        service_cur.executesql(ins_stat_q.format(upload_hash = upload_hash, res = res, status = status))
        service_con.commit()
    except:
        print traceback.format_exc()
        return traceback.format_exc()    


def fill_attrcache_tbls(tbl_id, dataset_id, node_has_data, is_full, paritioned):
    '''load data into attrcache tables for fact datasets'''
#     db = current.db
#     print "node_has_data =>",node_has_data, "\n"
#     print "paritioned =>",paritioned, "\n"
    
    # FIXME: tmp func
    def run_q(cur, q):
        try:
#             print q
            cur.execute(q)
        except:
            print traceback.format_exc()

    #main node
    main_node = db_main_node 
    
    main_con = psycopg2.connect(**db_main_node)
    main_cur = main_con.cursor(cursor_factory=psycopg2.extras.DictCursor)
    
    #db nodes
    nodes_conns = db_nodes_conns
    
    # delete data from attrcache table in the main node if load is full
    del_attrcache_q = 'DELETE FROM attrcache.{cache_tbl}'
    
    # fill up tmp attr cache tables
    fill_attrcache_q =  'INSERT INTO attrcache.{cache_tbl} SELECT {col_val}, {col_name}, {col_order} FROM {source_tbl} {where_cond} \
                            ON CONFLICT ON CONSTRAINT {cache_tbl}_pk DO NOTHING'

    try:
        
        get_attrs_q = "SELECT attr_id, col_val_id, col_name_id, col_order_id FROM engine.attributes \
                    INNER JOIN engine.datasets ds USING(dataset_id) WHERE dataset_type_id = 1 AND attr_type_id = 1 AND ds.dataset_id = '{ds_id}' \
            ".format(ds_id = dataset_id)

        main_cur.execute(get_attrs_q)
#         attrs = db.executesql(get_attrs_q, as_dict = True)

        attrs = main_cur.fetchall()

        # fact table doesn't have attributes
        if not len(attrs):
#             print "NO ATTRS"
            return True
        
        all_nodes_q = []
        main_node_q = []
        
        trunc_node_attrcache_q = []

        # to aim the update query
        isNode = paritioned > 0 and len(db_nodes_conns)

        for a in attrs:
            
            all_nodes_q_tmp = []
            main_node_q_tmp = []
            if isNode:
                trunc_node_attrcache_q.append('truncate table attrcache.' + a['attr_id'])
                if is_full:
                    main_node_q_tmp.append(del_attrcache_q.format(cache_tbl = a['attr_id']))
                    
                all_nodes_q_tmp.append(del_attrcache_q.format(cache_tbl = a['attr_id']))
                all_nodes_q_tmp.append(fill_attrcache_q.format( cache_tbl = a['attr_id'],
                                                            col_val = a['col_val_id'],
                                                            col_name = a['col_name_id'],
                                                            col_order = a['col_order_id'],
                                                            source_tbl = tbl_id,
                                                            where_cond = ' where %s is not null '%a['col_val_id']
                                                           )
                                   )
                all_nodes_q.append(';'.join(all_nodes_q_tmp))
                for idx in xrange(len(db_nodes_conns)):
                    if node_has_data[idx]:
                        main_node_q_tmp.append(fill_attrcache_q.format( cache_tbl = a['attr_id'],
                                                                    col_val = 'col_val',
                                                                    col_name = 'col_name',
                                                                    col_order = 'col_order',
                                                                    source_tbl = 'attrcache.' + a['attr_id'] + '_fs_node%s'%(idx+1),
                                                                    where_cond = ''
                                                                   )
                                           )
            else:
                if is_full:
                    main_node_q_tmp.append(del_attrcache_q.format(cache_tbl = a['attr_id']))
                    
                main_node_q_tmp.append(fill_attrcache_q.format( cache_tbl = a['attr_id'],
                                                            col_val = a['col_val_id'],
                                                            col_name = a['col_name_id'],
                                                            col_order = a['col_order_id'],
                                                            source_tbl = tbl_id,
                                                            where_cond = ' where %s is not null '%a['col_val_id']
                                                           )
                                   )
            
            main_node_q.append(';'.join(main_node_q_tmp))
        
       
        tmp_cons = []
        process = []
        if len(all_nodes_q):
            for idx, n in enumerate(node_has_data):
                if n:
                    for q in all_nodes_q:
                        tmp_con = psycopg2.connect(**nodes_conns[idx])
                        tmp_cons.append(tmp_con)
                        tmp_cur = tmp_con.cursor()
                        p = multiprocessing.Process(target=run_q, args=[tmp_cur, q])
                        process.append(p)

        for c in tmp_cons:
            tmp_cur = c.cursor()
            tmp_cur.execute('SELECT')

        for p in process:
            p.start()
        
        for p in process:
            p.join()
                    
        for c in tmp_cons:
            tmp_cur = c.cursor()
            tmp_cur.execute('SELECT')
            c.commit()
        
#         # ensure that previous connections are closed
#         for tmp_con in tmp_cons:
#             if tmp_con.closed == 0:
#                 tmp_con.close()            

        tmp_cons = []
        process = []
        if len(main_node_q):
            tmp_con = psycopg2.connect(**main_node)
            tmp_cons.append(tmp_con)

            for q in main_node_q:
                tmp_cur = tmp_con.cursor()
                p = multiprocessing.Process(target=run_q, args=[tmp_cur, q])
                process.append(p)    
        
        for c in tmp_cons:
            tmp_cur = c.cursor()
            tmp_cur.execute('SELECT')
            
        for p in process:
            p.start()
        
        for p in process:
            p.join()
                    
        for c in tmp_cons:
            tmp_cur = c.cursor()
            tmp_cur.execute('SELECT')
            c.commit()

#         # ensure that previous connections are closed
#         for tmp_con in tmp_cons:
#             if tmp_con.closed == 0:
#                 tmp_con.close()
        
        tmp_cons = []
        process = []
        # truncate attrcache table on nodes
        if len(trunc_node_attrcache_q):
            for idx, n in enumerate(node_has_data):
                if n:
                    q = ';'.join(trunc_node_attrcache_q)
                    tmp_con = psycopg2.connect(**nodes_conns[idx])
                    tmp_cons.append(tmp_con)
                    tmp_cur = tmp_con.cursor()
                    p = multiprocessing.Process(target=run_q, args=[tmp_cur, q])
                    process.append(p)

        for c in tmp_cons:
            tmp_cur = c.cursor()
            tmp_cur.execute('SELECT')
            
        for p in process:
            p.start()
        
        for p in process:
            p.join()
                    
        for c in tmp_cons:
            tmp_cur = c.cursor()
            tmp_cur.execute('SELECT')
            c.commit()
            
#         # ensure that previous connections are closed
#         for tmp_con in tmp_cons:
#             if tmp_con.closed == 0:
#                 tmp_con.close()

    except:
        print traceback.format_exc()
        return ret_trace(traceback.format_exc())
    
    return True


def encode_list(l):
    for i, k in enumerate(l):
        if isinstance(k, unicode):
            l[i] = k.encode('utf-8')
    return l


def upload_json_ds(load_json, ds_upload_json, upload_ds_res, ds_idx):
#     print load_json
    all_nodes = None
    try:
        
        service_con = psycopg2.connect(**db_main_node)
        service_cur = service_con.cursor() 
        
        casosber = []
        
        casosber.append(" priprava cons: %s"%datetime.now())
        
        try:
            #main node
            settings = db_main_node
            main_node = psycopg2.connect(**settings)
            
            #db nodes
            nodes_conns = db_nodes_conns
            data_nodes = []
            for node in  nodes_conns:
                tmp_node = psycopg2.connect(**node)
                data_nodes.append(tmp_node)
                 
        except:
            print traceback.format_exc()
            return ret_trace(traceback.format_exc()) 
        
        tmp_main_cur = main_node.cursor(cursor_factory=psycopg2.extras.DictCursor)            
        
        casosber.append("tbl_info: %s"%datetime.now())
        # verify ds_id
        get_tbl_info_q =  "SELECT tbl_id, tbl_id as tbl_name, dataset_name, partitioned, config_json FROM engine.data_tbls, engine.datasets \
                                    WHERE split_part(dataset_id, '_', 2) = split_part(tbl_id, '_', 2) AND dataset_id = '{ds_id}' ".format(ds_id = load_json['dataset_id'])
        
        tmp_main_cur.execute(get_tbl_info_q)
        ds_res = tmp_main_cur.fetchone()
        
        casosber.append("tbl_info: %s"%datetime.now())
        
        if ds_res == None:
            ds_upload_json['upload_status'] = False
            ds_upload_json['data_load_errors'] = "Dataset with ID %s does not exist."%load_json['dataset_id']
            return
            
        ds_upload_json['dataset_name'] = ds_res['dataset_name']
        
        copy_cols = []
        date_time_cols = []
        tbl_info = ds_res['config_json']
        
        datetime_cols = []
        
        casosber.append("priprava sql dotazu: %s"%datetime.now())
        
        if load_json['full']:
            prepare_sql = "delete from %s;"%ds_res['tbl_id']
            tbl_id = ds_res['tbl_id']
        else:
            # create safe table
#             tbl_id = '%s_%s_safe_load'%(ds_res['tbl_id'], int(time()))
            tbl_id = 'tbl_' + os.urandom(16).encode('hex')
            prepare_sql = 'DROP TABLE IF EXISTS {safe_tbl}; SELECT * INTO {safe_tbl} FROM {tbl} WHERE 1 = 2;'.format(tbl = ds_res['tbl_id'],
                                                                                                                          safe_tbl = tbl_id
                                                                                                                          )
            

        insert_sql = "INSERT INTO %s VALUES "%tbl_id
        
        if ds_res['partitioned'] > -1 and len(data_nodes) > 0:
            all_nodes = data_nodes
            split_col_type = tbl_info['columns'][ds_res['partitioned']]['col_datatype']
        else:
            all_nodes = data_nodes + [main_node]
            split_col_type = None
        
        for idx, col  in enumerate(tbl_info['columns']):
            # TODO: IGNORE COLUMN
            col_id = 'col_' + hashlib.md5('{tbl_name}_{col_name}'.format(
                                                                         tbl_name = tbl_info['tbl_name'],
                                                                         col_name = col['col_name'])
                                          ).hexdigest()
            copy_cols.append(col_id)
            
            if col['col_type'] == "datetime" and col['col_datatype'] == "timestamp":
                date_time_cols.append(col_id + "_date")
                date_time_cols.append(col_id + "_time")
                datetime_cols.append([idx, "timestamp"])
                
            elif col['col_type'] == "datetime" and col['col_datatype'] == "date":
                date_time_cols.append(col_id + "_date")
                datetime_cols.append([idx, "date"])
            elif col['col_type'] == "datetime" and col['col_datatype'] == "time":
                date_time_cols.append(col_id + "_time")
                datetime_cols.append([idx, "time"])
        
        def get_int_date(td):
            if not len(td):
                return '19000101'
            # get just date in case if timestamp
            return td.split(' ')[0].replace('-','')
            
        def get_int_time(td):
            # for timestamp
            if '-' in td:
                try:
                    return '1' + td.split(' ')[1].replace(':','')
                except:
                    return None
            else:
                if len(td):
                    return '1' + td.replace(':','')
            return None
        
        data_df = pd.DataFrame(load_json['data'])
        data_df.columns = copy_cols
        
        datetime_cols_names = []
        if len(datetime_cols):
#             print "SLOUPECKY => \n"
            for c_ in datetime_cols:
                if c_[1] == 'timestamp':
                    data_df[copy_cols[c_[0]]+ "_date"] = data_df.apply(lambda row: get_int_date(row[copy_cols[c_[0]]]) , axis=1)
                    datetime_cols_names.append(copy_cols[c_[0]]+ "_date")
                    data_df[copy_cols[c_[0]]+ "_time"] = data_df.apply(lambda row: get_int_time(row[copy_cols[c_[0]]]) , axis=1)
                    datetime_cols_names.append(copy_cols[c_[0]]+ "_time")
                elif c_[1] == 'date':
                    data_df[copy_cols[c_[0]]+ "_date"] = data_df.apply(lambda row: get_int_date(row[copy_cols[c_[0]]]) , axis=1)
                    datetime_cols_names.append(copy_cols[c_[0]]+ "_date")
                elif c_[1] == 'time':
                    data_df[copy_cols[c_[0]]+ "_time"] = data_df.apply(lambda row: get_int_time(row[copy_cols[c_[0]]]) , axis=1)
                    datetime_cols_names.append(copy_cols[c_[0]]+ "_time")
                    
        def get_split_node(split_col, split_col_type):
            if split_col_type == "timestamp":
                split_time = datetime.strptime(split_col, "%Y-%m-%d %H:%M:%S")
                return (split_time - datetime(1970,1,1)).days % len(data_nodes)
            elif split_col_type == "date":
                split_time = datetime.strptime(split_col, "%Y-%m-%d")
                return (split_time - datetime(1970,1,1)).days % len(data_nodes)


        procs = []
        # if exists data for particular node
        node_has_data = [False]*len(all_nodes)
        
        casosber.append("nahravani dat safe tabulky: %s"%datetime.now())
        
        all_ins_cols = copy_cols + datetime_cols_names
        value_list = "(" + ','.join(['%s'] * len(all_ins_cols)) + ")"        

        # load data into db
        if ds_res['partitioned'] > 0 and len(data_nodes) != 0:
            split_col = copy_cols[ds_res['partitioned']]
            
            # add split col to dataframe
            data_df['split_col'] = data_df.apply(lambda row: get_split_node(row[split_col],split_col_type) , axis=1)
            
            loaded_nodes = data_df.split_col.unique()
            proc_res = multiprocessing.Manager().list([False]*len(loaded_nodes))
            proc_idx = 0
            
            for n_idx in loaded_nodes:
                tmp_cur = all_nodes[n_idx].cursor()
                insert_vals = ','.join(service_cur.mogrify(value_list, x) for x in data_df[data_df['split_col'] == n_idx][copy_cols + datetime_cols_names].values.tolist())
                p = multiprocessing.Process(target=cur_query, args=[tmp_cur, [prepare_sql, insert_sql + insert_vals], proc_res, proc_idx])
                procs.append(p)
                proc_idx += 1
                node_has_data[n_idx] = True
        
        else:

            proc_res = multiprocessing.Manager().list([False]*len(all_nodes))
            insert_sql += ','.join(service_cur.mogrify(value_list, x) for x in data_df[copy_cols + datetime_cols_names].values.tolist())
            
            for idx, node in enumerate(all_nodes):
                tmp_cur = node.cursor()
                
                p = multiprocessing.Process(target=cur_query, args=[tmp_cur, [prepare_sql, insert_sql], proc_res, idx])
                procs.append(p)
                
            node_has_data = [True]*len(all_nodes)
        
        for p in procs:
            p.start()
            
        proc_end = [False]*len(procs)
         
        # check for proc results
        while False in proc_end:          
            for idx, p in enumerate(procs):
                if not p.is_alive():
                    proc_end[idx] = True
                    if proc_res[idx] != True:
                        proc_end = [True]*len(procs)
                     
            if not FAST_MODE:
                sleep(1)
        
        for p in procs:
            p.join()
        
#         print "proc_res => " ,proc_res
        
        if list(set(proc_res)) != [True]:
            for p in procs:
                if p.is_alive():
                    p.terminate()

            for node in all_nodes:
                if node.closed == 0:
                    node.rollback()
                    node.close()
                    
            updateVal = {"message":"upload error", "status":-2}
            updateStatus(updateVal, ds_res['tbl_id'])
            ds_upload_json['upload_status'] = False
            ds_upload_json['data_load_errors'] = ret_trace(proc_res)
            return
        else:
            casosber.append(" commiting data %s  "%datetime.now())
            for idx, node in enumerate(all_nodes):
                if node_has_data[idx]:
                    tmp_cur = node.cursor()
                    tmp_cur.execute('SELECT')
                    node.commit()
            casosber.append("konec nahravani dat safe tabulky: %s"%datetime.now())
            casosber.append("nahravani dat orig tabulky: %s"%datetime.now())
                            
            if not load_json['full']:
                
                dups = ''
                if 'skip_duplications' in load_json and load_json['skip_duplications']:
                # ignore duplications in incremental data ON CONFLICT ON CONSTRAINT {cache_tbl}_pk DO NOTHING
                    dups = ' ON CONFLICT ON CONSTRAINT pk_%s DO NOTHING'%ds_res['tbl_id'].replace('.','')
                                            
                
                ins_query = 'INSERT INTO {tbl} SELECT * FROM {safe_tbl} {dups};'.format(
                                                                                             tbl = ds_res['tbl_id'],
                                                                                             safe_tbl = tbl_id,
                                                                                             dups = dups
                                                                                             )
                
                res = run_parallel_sql(node_cons = all_nodes, sql_queries=[ins_query], run_nodes=node_has_data, db_commit = True)
                
#                 print "insert in safe table \n"
#                 print res
#                 print "insert in safe table \n"
                if list(set(res)) != [True]:
#                     print "\n vracim chybu \n"
                    updateVal = {"message":"upload error", "status":-2}
                    updateStatus(updateVal, ds_res['tbl_id'])
                    ds_upload_json['upload_status'] = False
                    ds_upload_json['data_load_errors'] = ret_trace(res)
                    return
        
            casosber.append("konec commiting data %s  "%datetime.now())
#         print "UPDATE ATTR CACHE"
        ds_upload_json['attr_refresh_start'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
        fill_attrcache_tbls(tbl_id, load_json['dataset_id'], node_has_data, load_json['full'], ds_res['partitioned'])
        ds_upload_json['attr_refresh_end'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")            
        
        
        
        # drop safe table
        if not load_json['full']:
            drop_query = 'DROP TABLE IF EXISTS {safe_tbl};'.format(safe_tbl = tbl_id)
            res = run_parallel_sql(node_cons = all_nodes, sql_queries=[drop_query], db_commit = True)
        
            if list(set(res)) != [True]:
                ds_upload_json['upload_status'] = False
                ds_upload_json['data_load_errors'] = ret_trace(res)
                
        casosber.append("konec nahravani dat orig tabulky: %s"%datetime.now())

        # set last upload date
        update_sql = "update engine.data_tbls set last_upload = now() \
                where tbl_id = '{tbl_id}'".format(tbl_id = ds_res['tbl_id'])
                
        ds_upload_json['upload_status'] = True
        ds_upload_json['casosber'] = casosber
        service_cur.execute(update_sql)
        service_con.commit()
        
    except:
        print traceback.format_exc()
        ds_upload_json['upload_status'] = False
        ds_upload_json['data_load_errors'] = ret_trace(traceback.format_exc())
        
    
    finally:
        ds_upload_json['data_load_end'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
        upload_ds_res[ds_idx] = ds_upload_json
        if all_nodes != None:
            for node in all_nodes:
                if node.closed == 0:
                    node.close()


def upload_json_data(**post_data):
    
    json_data_ = post_data['data']
    upload_hash = post_data['upload_hash']
#     project_id = post_data['project_id']
    
    '''load json data into db
       json_data_ - dump of json data
       upload_hash - unique hash to identify load
    '''
    service_con = psycopg2.connect(**db_main_node)
    service_cur = service_con.cursor()
    
    
    upload_json = get_up_json()
    upload_json['upload_start'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
    upload_json['upload_status'] = True
    
    # get max upload_id from maintenance.data_upload
    service_cur.execute('select max(up_id) from maintenance.data_upload')
    up_id = service_cur.fetchone()[0]

    if up_id == None:
        up_id = 1
    else:
        up_id = up_id + 1    
    
    try:
        json_data = json.loads(json_data_)
    except:
        upload_json['upload_errors'] = ret_trace(traceback.format_exc())
        upload_json['upload_end'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
        upload_json['upload_status'] = False        

        service_cur.execute("INSERT INTO maintenance.data_upload(up_id, up_hash, up_end, up_result, up_log) \
                        VALUES({up_id}, '{upload_hash}', now(), {load_result}, '{up_log}')".format(up_id = up_id,
                                                                                                   upload_hash = upload_hash,
                                                                                                   load_result = upload_json['upload_status'],
                                                                                                   up_log = json.dumps(upload_json)
                                                                                                   )
                      )
        
        service_con.commit()
        return False
    
    
    if not isinstance(json_data, list):
        json_data = [json_data]
        
    service_cur.execute("INSERT INTO maintenance.data_upload(up_id, up_hash) VALUES(%s,'%s')"%(up_id,upload_hash))
    service_con.commit()
    
    upload_ds_res = multiprocessing.Manager().list([None]*len(json_data))
    upload_ds_proc = []
    
#     json_data = [json_data[0]]
    
    for ds_idx, load_json in enumerate(json_data):

        ds_upload_json = get_file_up_json()

        
        ds_upload_json['dataset_id'] = load_json['dataset_id']
        ds_upload_json['data_load_start'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
        
        if not len(load_json['data']):
            ds_upload_json['data_load_end'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
            upload_json['upload_datasets'].append(ds_upload_json)
            continue
        
#         ress = upload_json_ds(load_json, ds_upload_json, test_a, ds_idx)
#         
#         return ress
        
        # def upload_json_ds(load_json, ds_upload_json, upload_ds_res, ds_idx):upload_ds_proc
        p = multiprocessing.Process(target=upload_json_ds, args=(load_json, ds_upload_json, upload_ds_res, ds_idx))
        upload_ds_proc.append(p)
        
        
    for p in upload_ds_proc:
        p.start()
        
    for p in upload_ds_proc:
        p.join()
        
    for uds in upload_ds_res:
        if uds != None:
            upload_json['upload_datasets'].append(uds)

    upload_json['upload_end'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")
    
    # check upload status
    
    res_json = upload_json
    
    for uj in upload_json['upload_datasets']:
        if uj['upload_status'] == False:
            print "uj['data_load_errors'] => ", uj['data_load_errors']
            upload_json['upload_status'] = False
            break
    
    # store load info
#     print upload_json
    try:
        service_cur.execute("UPDATE maintenance.data_upload SET up_end = now(), up_result = {load_result}, \
                                    up_log = '{up_log}' WHERE up_id = {up_id}".format(up_log = json.dumps(upload_json),
                                                                                                up_id = up_id,
                                                                                                load_result = upload_json['upload_status']
                                                                                                )
                      )
        service_con.commit()
    except:
        return ret_trace(traceback.format_exc())
    
#     print upload_json['upload_status']
    
    if not upload_json['upload_status']:
        return res_json
    else:
        return True
    
    
    
def prepare_date_data(input_file):
    '''prepare data for date dataset
    '''
    try:
        output_file = os.path.join(os.path.dirname(input_file), 'new_'+os.path.basename(input_file))
        
        tmp_quarter = None
        day_of_quarter = 1
        
        with open(input_file, 'rb') as in_date_file, open(output_file, 'wb',0) as out_date_file :
            date_file_r = csv.reader(in_date_file, quotechar='"')
            
            for dt_row in date_file_r:
                dt = datetime.strptime(dt_row[0], '%Y-%m-%d')
                
                quarter = ((int(dt.strftime('%m'))-1)//3) + 1
                
                if tmp_quarter == None:
                    tmp_quarter = quarter
                else:
                    if tmp_quarter == quarter:
                        day_of_quarter =+ 1
                    else:
                        day_of_quarter = 1
    
                date_line = "{date_int};{year};{quarter};{month};{week};{day_of_year};{day_of_week};{day_of_month};{day_of_quarter};\
    {year_quarter};{year_month};{year_week}\n".format(
                                                     date_int = dt.strftime('%Y%m%d'),
                                                     year = dt.strftime('%Y'),
                                                     quarter = quarter,
                                                     month = dt.strftime('%m'),
                                                     week = dt.isocalendar()[1],
                                                     day_of_year = dt.timetuple().tm_yday,
                                                     day_of_quarter = day_of_quarter,
                                                     day_of_month = int(dt.strftime('%d')),
                                                     day_of_week = dt.isocalendar()[2],
                                                     year_quarter = "%s%s"%(dt.strftime('%Y'),quarter),
                                                     year_month = dt.strftime('%Y%m'),
                                                     year_week = "%s%s"%(dt.strftime('%Y'), dt.isocalendar()[1])
                                                     )
                out_date_file.write(date_line)
        
        return output_file
    except:
        return 'prepare_date_data_err' + ret_trace(traceback.format_exc()) 
    
    
    
    
    
