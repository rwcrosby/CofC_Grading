#!/usr/bin/env fish

###############################################################
# Display the help text

function HelpMsg

echo "Create the student directories:

Run from the Grading directory

Process

Options
  -c, --config : override configuration file name
                 default: ./GradingConfig.sh
  --clear : Recreate all from scratch deleting contents
  -h : Display this help message
"

end

###############################################################
# Parse a download file name

function ParseSubmissionName -a studentZip

    set parts (string split ' - ' $studentZip)

    set filecode $parts[1]
    set name (string split ' ' (string trim $parts[2]))
    set lastname $name[2]
    set firstname $name[1]
    set timestamp (string trim $parts[3])
    set subfile (string trim $parts[4])

    echo $filecode\n$lastname\n$firstname\n$timestamp\n$subfile
    # echo "p<$parts[1]><$parts[2]> <$parts[3]> <$parts[4]>"
    # echo "c<$filecode> l<$lastname> f<$firstname> t<$timestamp> s<$subfile>"

end

###############################################################
# Mainline

# Parse the command line

argparse 'h/help' 'clear' 'c/config=' -- $argv
or begin
    HelpMsg 
    exit
end

if set -q _flag_help
    HelpMsg
    exit
end

if set -q $argv
    echo "Zip filename required"
    exit
end

set inputZipFile $argv[1]

if not test -f $inputZipFile
    echo "Input zip file not found"
    exit 1
end

# Find and source the configuration file

if set -q _flag_config
    set configFile $_flag_config
else
    set configFile ./GradingConfig.sh
end

echo (status filename) "starting at" (date)
echo "Loading configuration file: $configFile"
source $configFile

# Copy the zip file to the current directory and expand

set zipName (basename $inputZipFile)[1]
set unzipDirName (string split -r -m1 . $zipName)[1]
# echo "Zip file name: <$zipName>"
# echo "Unzipped directory: <$unzipDirName>"

if test -f "$zipName"
    if set -q _flag_clear
        echo "Deleting existing zip file and expanded directory"
        rm $zipName
        rm -rf $unzipDirName
    else    
        echo "Zip file exists and clear not specified"
        exit 1
    end
end

cp $inputZipFile .
unzip -d $unzipDirName $zipName

# Loop through the submission zip files

for studentZip in (find $unzipDirName -type f -name '*')
    echo "Zip file: $studentZip"
    set parsedName (ParseSubmissionName (basename $studentZip))
    echo "Output <$parsedName[1]><$parsedName[2]><$parsedName[3]><$parsedName[4]><$parsedName[5]>"

    # Create student directory name

    set studentDir "$parsedName[3], $parsedName[2]"

    # See what to do if the directory exists

    if test -d "Working/$studentDir"
        if set -q _flag_clear
            echo "Deleting old student directory <$studentDir>"
            rm -rf "Working/$studentDir"
        else
            echo "Student <$studentDir> exists and clear not specifed, exiting "
            exit 1
        end
    end

    # Create the student directory and expand their zip file into it

    mkdir "Working/$studentDir"

    set filetype (string split -r -m1 . $parsedName[5])[2]

    switch $filetype
        case 'zip'
            # echo ".zip file found"
            unzip -d "Working/$studentDir" $studentZip
        case 'tar'
            echo ".tar file found"
        case '*'
            echo "Uncompressed file found, copying"
            cp $studentZip Working/$studentDir

    end

    # Create a file of environment information for the student

    echo "
set -x StudentCode \"$parsedName[1]\"
set -x StudentFirstName \"$parsedName[2]\"
set -x StudentLastName \"$parsedName[3]\"
set -x StudentTimestamp \"$parsedName[4]\"
set -x StudentSubmissionFile \"$parsedName[5]\"
" > Working/$studentDir/Info.sh

end
