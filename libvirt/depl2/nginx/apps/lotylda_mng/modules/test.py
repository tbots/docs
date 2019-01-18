 
for idx in range(1,9):
     
    fs_nodes_q = "CREATE SERVER fs_node{idx} FOREIGN DATA WRAPPER postgres_fdw \
                  OPTIONS (host '{db_host}', port '{db_port}', dbname '{db_name}'); \
                  CREATE USER MAPPING FOR {db_user} SERVER fs_node{idx} \
                  OPTIONS (user '{db_user}', password '{db_user_pwd}');".format(
                                                                              idx = idx,
                                                                              db_host = '172.20.10.72',
                                                                              db_port = '545%s'%idx,
                                                                              db_name = 'db_abb66c48fb339b00d3323432a368778b',
                                                                              db_user = 'lotylda_admin',
                                                                              db_user_pwd = 'lotylda'
                                                                              )
                   
                   
    print fs_nodes_q

for idx in range(1,5):
     
    fs_nodes_q = "CREATE SERVER fs_node{idx} FOREIGN DATA WRAPPER postgres_fdw \
                  OPTIONS (host '{db_host}', port '{db_port}', dbname '{db_name}'); \
                  CREATE USER MAPPING FOR {db_user} SERVER fs_node{idx} \
                  OPTIONS (user '{db_user}', password '{db_user_pwd}');".format(
                                                                              idx = idx,
                                                                              db_host = '192.168.133.11',
                                                                              db_port = '544%s'%idx,
                                                                              db_name = 'db_c57deaedc97344a96553447235ccb023',
                                                                              db_user = 'lotylda_admin',
                                                                              db_user_pwd = 'lotylda'
                                                                              )
                   
                   
#     print fs_nodes_q
