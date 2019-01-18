# -*- coding: utf-8 -*-
from os.path import basename
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import COMMASPACE, formatdate
from smtplib import SMTP_SSL as SMTP
import os, traceback 


def send_mail(send_from, send_to, subject, text, files=None):
    assert isinstance(send_to, list)
    server = 'mail.optisolutions.cz'
    USERNAME = "helpdesk@optisolutions.cz"
    PASSWORD = "0Opti2014"    
    try:
        msg = MIMEMultipart()
        msg['Subject'] = subject 
        msg['From'] = send_from
        msg['To'] = COMMASPACE.join(send_to)
    
    
        msg.attach(MIMEText(text, "plain", "utf-8"))
    
        for f in files or []:
            if os.path.isfile(f):
                with open(f, "rb") as fil:
                    msg.attach(MIMEApplication(
                        fil.read(),
                        Content_Disposition='attachment; filename="%s"' % basename(f),
                        Name=basename(f)
                    ))
            else:
                print "File %s doesn't exist."%f
    
        smtp = SMTP(server)
        smtp.login(USERNAME, PASSWORD)
        smtp.sendmail(send_from, send_to, msg.as_string())
        smtp.close()
    except:
        print traceback.format_exc()
    
    
# send_mail('lola@optisolutions.cz', ['ondra@optisolutions.cz'], 'HOLA LOLA', 'UZ BUDU???',['asd'] )