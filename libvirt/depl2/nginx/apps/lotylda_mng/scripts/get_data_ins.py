import psycopg2.extras


con = psycopg2.connect(host='192.168.133.11',port='5440',database='lotylda_template', user='lotylda_admin', password='lotylda')
cur = con.cursor(cursor_factory=psycopg2.extras.DictCursor)


table_list = {
              'engine':['col_datatype','col_type','dataset_type','time_date_definition','filter_type','object_types','attr_type'],
              'userspace':['repcache_status','status','user_filter_cache_type','privileges','module_groups']
              }


for sch in table_list:
    for tbl in table_list[sch]:
        tmp_q = "select * from {sch}.{tbl}".format(sch = sch, tbl = tbl)
        cur.execute(tmp_q)
        colnames = [desc[0] for desc in cur.description]
        data = cur.fetchall()
        print '-'*50
        print "{sch}.{tbl}\n".format(sch = sch, tbl = tbl)
        print colnames
        print data
        
        print '-'*50
        print "\n"