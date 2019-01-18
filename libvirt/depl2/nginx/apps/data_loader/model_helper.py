# -*- coding: utf-8 -*-

import psycopg2.extras

db_name = 'trw_eolt_test'
db_host = '10.140.48.102'
db_port = "544"
nodes_len = 8

nodes_conns = []
for i in range(1,nodes_len + 1):
    port = db_port+str(i)
    nodes_conns.append([db_host,port,'fs_node%s'%i,db_name,'lotylda_admin','lotylda'])
    
# print nodes_conns
#  
sql = """
drop schema datastore cascade;create schema datastore;
drop schema attrcache cascade; create schema attrcache;
drop schema repcache cascade; create schema repcache;
    """
  
# sql = """
# create schema datastore;
# create schema attrcache;
# create schema repcache;
#     """
  



for idx, node in enumerate(nodes_conns):
    print idx
    node_con = psycopg2.connect(host=node[0],port=node[1],database=node[3], user=node[4], password=node[5])
    node_cur = node_con.cursor(cursor_factory=psycopg2.extras.DictCursor)
    node_con.set_isolation_level(0)
    node_cur.execute(sql)
    node_con.set_isolation_level(1)
    node_con.commit()
    node_con.close() 
 
# sql = 'select count(*) from datastore.tbl_67ab9d46bdd19d32e32ea9eabf60d1bf'
#  
# for idx, node in enumerate(nodes_conns):
#      
#     node_con = psycopg2.connect(host=node[0],port=node[1],database=node[3], user=node[4], password=node[5])
#     node_cur = node_con.cursor(cursor_factory=psycopg2.extras.DictCursor)
#  
#     node_cur.execute(sql)
#     t= node_cur.fetchone()
#     print idx, t
#  
#     node_con.commit()
#     node_con.close() 
# # 


