# -*- coding: utf-8 -*-

from gluon import current
import mng
import copy

def getUserItems(project_id, user_id):
    '''Return dic of user's dasbhboards, reports, measures by user_id'''
    items_dic = {'dasbhboards':[],
                 'reports':[],
                 'measures':[]
                 }
    
    items_dic_empty = copy.deepcopy(items_dic)
    
    
    # get users dashboards
    dashs_q = "SELECT dashboard_id, dashboard_name FROM userspace.dashboards WHERE created_user = '%s'"%user_id
    
    dashs = mng.executeRemoteSQL(project_id, dashs_q , True, True, False)

    if len(dashs):
        for d in dashs:
            items_dic['dasbhboards'].append((d['dashboard_id'],d['dashboard_name']))
            
    # get users reports
    reps_q = "SELECT report_id, report_name FROM userspace.reports WHERE created_user = '%s'"%user_id
    
    reps = mng.executeRemoteSQL(project_id, reps_q , True, True, False)

    if len(reps):
        for r in reps:
            items_dic['reports'].append((r['report_id'],r['report_name']))            

    # get users measures
    meas_q = "SELECT measure_id, measure_name FROM engine.measures WHERE created_user = '%s'"%user_id
    
    meas = mng.executeRemoteSQL(project_id, meas_q , True, True, False)
    if len(dashs):
        for m in meas:
            items_dic['measures'].append((m['measure_id'],m['measure_name']))            
    
    
    
    if items_dic == items_dic_empty:
        return {}
    else:
        return items_dic












