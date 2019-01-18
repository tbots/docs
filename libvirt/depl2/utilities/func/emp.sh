#
# emp():	emperor arguments
#
function emp() {
	
	u			# uwsgi.service absolute path

	if [[ -z ${EMP_ARGS=`grep -Eo 'emperor +[^;| ]+' $UNIT_UWSGI | awk '{print $2}'`} ]]
	then
		echo -e "\e[47mEMP_ARGS\e[0m:\t \e[36mnot set\e[0m"
		exit 1
	fi
}
