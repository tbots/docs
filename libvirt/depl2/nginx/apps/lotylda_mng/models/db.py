# -*- coding: utf-8 -*-

if False:  # this block helps eclipse
    from gluon.sql import *  # repeat for all models
    from gluon import *

from gluon import current
from gluon.utils import *
from gluon.tools import Auth
import psycopg2
import psycopg2.extras
from gluon.tools import Mail

is_migrate = False

DBSettings = {}
DBSettings['DBhost']= '10.140.48.102'
DBSettings['DBname'] = 'lotylda_mng'
DBSettings['DBschema'] = 'engine'
DBSettings['DBport'] = '5440'
DBSettings['DBuser'] = 'lotylda_admin'
DBSettings['DBpassword'] = 'lotylda'

current.db_name = DBSettings['DBname']
current.dbData_settings = DBSettings

db = DAL('postgres://'+DBSettings['DBuser']+':'+DBSettings['DBpassword']+'@'+DBSettings['DBhost']+':'+DBSettings['DBport']+'/'+DBSettings['DBname'],migrate=is_migrate, fake_migrate=False)

auth = Auth(db)
auth.settings.extra_fields['auth_user']= [
  Field('user_id', type='string', length=32, compute=lambda r: md5_hash(r['email'])),
  Field('active', type='boolean',compute=lambda s: 0)
]
auth.define_tables(username=True)
auth.settings.registration_requires_approval = True
auth.settings.remember_me_form = False
auth.settings.allow_basic_login = True

auth.messages.reset_password = "<html>Hi %(first_name)s, <br />you have been invited to Lotylda application. <br /> \
            Your username is: <b>%(username)s</b>  <br /> \
            Use link below to set your new password. <br /><a href=\"http://" + request.env.http_host +     URL(r=request,c='default',f='user',args=['reset_password']) +     "/?key=%(key)s \">Set password</a></html>"
            
#auth.settings.actions_disabled=['register']
mail = auth.settings.mailer

mail.settings.server = 'mail.optisolutions.cz:25'
mail.settings.sender = 'lotylda@optisolutions.cz'
mail.settings.login = 'opti_service@optisolutions.cz:5V[ebu&Bx4oL'


current.db = db
#current.connection = connection
current.auth = auth 

#current.project_url = "https://portal.lotylda.com"
current.project_url = "http://10.140.48.102"