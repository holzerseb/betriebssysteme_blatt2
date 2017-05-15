#!/bin/bash
# Sebastian Holzer
#
# Remarks: This Script will only backup files (respecting their hierarchy for sure), but it will not backup empty directories. This was not requested by the Task, and didn't seem useful to implement.


# we count the number of positional params
# basically: if number of params not equal 1, then
if [ $# -ne 1 ]
then
	printf "%b" "Error: Couldn't handle the given Arguments\n" >&2
	printf "%b" "Usage: ./my_back_up.sh backUpFolder\n" >&2
	exit 1
fi

#if the subdir doesn't exist, we create it and tell the user
if [ ! -d "$1" ]
then
	mkdir $1
	printf "Directory created at: %s/%s\n\n" "$(pwd)" "$1"
fi



#Because I really had no clue how to solve that simple issue at first (I still don't think my solution is a good one, but hell does it work), I came up with the idea to generate a file-list of all files in the current directory (and subdirs) in first place, before doing the actual copy stuff
#This was intended to make the copy-process more smoothly, since we don't have to navigate in any directory anymore :)
#Otherwise I only got complex logic, that really was ugly to read, so sit back and enjoy


FILES=$(find . -type f | grep -v "./$1") #we search all files

#next we iterate through every file
for FILE in $FILES
do
	BACKUP_FILE="$1/$FILE"
	#Because find also gave us the Backup-Folder itself, we gotta sort that out
	#Also the script itself shouldn't be backed up, should it?
	if [ $1 = $FILE ] || [ $0 = $FILE ]
	then
		continue
	fi
	
	#Note for the second condition: stat -c allows custom format, and %Y means last modified time in seconds since EPOCH
	if [ ! -e $BACKUP_FILE ] || [ $(stat -c "%Y" $FILE) -gt $(stat -c "%Y" $BACKUP_FILE) ]; #if the file doesn't exist in the backup-dir
				   #or was changed earlier then the one in the back-dir
				   #then we gonna back it up
	then
		cp -f --parents $FILE $1
		printf "Backed up file '%s'\n" "$FILE"
	else
		printf "Skipping file '%s'\n" "$FILE"
	fi
done

printf "\nSuccesfully created Backup at '%s'\n" "$1"
