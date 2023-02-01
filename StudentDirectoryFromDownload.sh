#!/usr/bin/env fish

###############################################################
# Display the help text

function HelpMsg

echo "Create a directory for a downloaded student compressed file:

Run from the Grading directory

Parameters

  -c, --config : override configuration file name
                 default: ./GradingConfig.sh
  --clear : Recreate all from scratch deleting contents
  -h : Display this help message

  LastName FirstName CompressedFileName

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

if test (count $argv) -ne 3
    echo (count $argv)
    echo "Incorrect parameters"
    HelpMsg
    exit
end

set lastname $argv[1]
set firstname $argv[2]
set inputFile $argv[3]

if not test -f $inputFile
    echo "Input file not found"
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

# Copy the zip file to the current directory and setup student directory

set zipName (basename $inputFile)[1]
set studentDir "Working/$lastname, $firstname"

echo "Zip file name: <$zipName>"
echo "Student directory name: <$studentDir>"

# If clear was specified delete the old download file and student directory

if test -f "$zipName"
    if set -q _flag_clear
        echo "Deleting existing zip file and student directory"
        rm $zipName
        rm -rf $studentDir
    else    
        echo "Zip file exists and clear not specified"
        exit 1
    end
end

cp $inputFile .

# Create the student directory and expand their zip file into it

mkdir "$studentDir"

set filetype (string split -r -m1 . $zipName)[2]

switch $filetype
    case 'zip'
        echo ".zip file found"
        unzip -d "$studentDir" $zipName
    case 'tar'
        echo ".tar file found"
        pushd "$studentDir"
        tar -xf ../../$zipName
        popd
    case '*'
        echo "Uncompressed file found, copying"
        cp $zipName $studentDir

end

# Create a file of environment information for the student

set timeStamp (stat -c %x $inputFile)

echo "
set -x StudentCode \"0-0\"
set -x StudentFirstName \"$firstname\"
set -x StudentLastName \"$lastname\"
set -x StudentTimestamp \"$timeStamp\"
set -x StudentSubmissionFile \"$zipName\"
" > $studentDir/Info.sh
