#!/bin/bash
#
# Tomas Zubov task for the manx.com server. 
#
# Each mailbox in the domain_mail_dir directory is examined and for the character length. If the length exceeds 2 characters,
# meaning not indexed directory two more tests are applied:
#
# 1. exists corresponding index directory (abcd -> ab)
#	2. mailbox was copied under index directory (ab/abcd)
# 3. U_MailboxPath variables was set to the index directory.
#
# On success move mailbox to the backup folder, otherwise issue appropriate error.
#

source /etc/icewarp/icewarp.conf

tool=$IWS_INSTALL_DIR/tool.sh
maildir=mail
domain=manx.com

domain_mail_dir=$IWS_INSTALL_DIR/$maildir/$domain		# /opt/icewarp/mail/manx.com

backup=$HOME/processed_mailboxes

cd $domain_mail_dir			# Change to the working directory here.
for mailbox in *				# Process each mailbox in domain_mail_dir directory.
do

	# Find a directory with the name longer than two characters.
	if [ -d $mailbox -a ${#mailbox} -gt 2 ]; then

		# Debug #
		#echo "processing $mailbox"

		# Get first two characters of the mailbox name - the name of the indexed directory.
		indexed_dir=${mailbox:0:2}
	
		if 	 [ ! -d $indexed_dir ]; then
		#
		#	Check if indexed directory was created 
		#
			echo "indexed directory missing for $mailbox"

		elif [ ! -d $indexed_dir/$mailbox ]; then
		#
		#		Check if mailbox was transfered to indexed directory
		#
			echo "mailbox '$mailbox missing in indexed directory"

		else
		#
		# Directories are at place. Check for the U_MailboxPath
		#

			# Get user mailbox path.
			user_mailbox_path=`$tool get account $mailbox@$domain U_MailboxPath | awk '/U_MailboxPath/ {print $2}'`

			# Desired mailbox path.
			indexed_mailbox_path=$domain/$indexed_dir/$mailbox/		

			if [ $user_mailbox_path = $indexed_mailbox_path ] 
			then 
			# 
			# Setting match, move mailbox to $backup.
				echo -e "mailbox '$mailbox' set correctly\nmoving '$mailbox' to $backup"
			 	mv $mailbox $backup 
			fi
		fi
	fi
done
