# -*- coding: utf-8 -*-
'''
Created on Mar 3, 2014

@author: Snorlax
'''

from gluon import *
from gluon.sql import *
from gluon import current
import json,hashlib,datetime


db = current.db
auth = current.auth

def index():
    users = None
    sql = "select au.id, au.first_name, au.last_name, au.email, au.user_id, au.registration_key from auth_user au inner join auth_membership am on am.user_id = au.id where group_id = 6 order by last_name"
    users = db.executesql(sql)
    
    return dict( users=users)

def activeAccountMail():
    userId = request.args[0]
    sql = "select email,first_name,username from auth_user where user_id = '"+userId+"'"
    userAcc = db.executesql(sql)[0] 
    
    textMail = '<html>Hi {first_name}, <br />your account in Lotylda application is active. <br /> \
            Your username is: <b>{username}</b>  <br /> \
            Use link below to log in. <br /><a href="http://{URL}">Login to LOTYLDA</a><br /><br /> \
            Lotylda Team</html>'.format(first_name=userAcc[1],username=userAcc[2],URL=request.env.http_host+URL(c='default',f='index'))
        
    mail.send(userAcc[0],'LOTYLDA Account Active',textMail)
    return True