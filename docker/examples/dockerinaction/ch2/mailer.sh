#!/bin/sh
printf "CH2 Example Mailer has started.\n"    # that will print by default
while true    # infinite loop
do
                                # message is read on port 33333
  MESSAGE=`nc -l -p 33333` # loop wais for an input and does not go to the next iteration each second
  printf "Sending email: %s\n" "$MESSAGE"
	sleep 1
done
