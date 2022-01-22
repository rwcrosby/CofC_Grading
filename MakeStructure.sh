#!/usr/bin/env fish

###############################################################
# Display the help text

function help_msg

echo "Create the base directories:
  ./Grading
  ./ReferenceSolution

Copy template files
  ../../GradingTemplate.md -> ./GradingTemplate.md
  ../../GradingConfig.sh -> ./GradingConfig.sh

  Note: the GradingConfig file will also be used to configure this script

Options
  -c, --config : override configuration file name
                 default: ../../GradingConfig.sh
  --clear : Recreate all from scratch deleting contents
  -h : Display this help message
"

end

###############################################################
# Optionally create a directory

function CreateDir -a dirName clearFlag

    if test -d $dirName

        echo "$dirName exists"

        if test -n "$clearFlag"
            echo "Deleting existing $dirName"
            rm -rf $dirName
        else
            echo "Not deleting existing $dirName"
        end
    end
    if not test -d $dirName

        echo "Creating $dirName"
        mkdir $dirName
    end

end

###############################################################
# Mainline

# Parse the command line

argparse 'h/help' 'clear' 'c/config=' -- $argv
or begin
    help_msg 
    exit
end

if set -q _flag_help
    help_msg
    exit
end

# Find and source the configuration file

if set -q _flag_config
    set configFile $_flag_config
else
    set configFile '../../GradingConfig.sh'
end


if not test -f $configFile
    echo "Coniguration file $configFile not found" 1>&2
    exit
end

echo (status filename) "starting at" (date)
echo "Loading configuration file: $configFile"
source $configFile

# Create (or recreate) the directories

set gradingDir "./Grading"
set workingDir "./Grading/Working"
set feedbackDir "./Grading/Feedback"
set solutionDir "./ReferenceSolution"

CreateDir $gradingDir $_flag_clear
CreateDir $workingDir $_flag_clear
CreateDir $feedbackDir $_flag_clear
CreateDir $solutionDir $_flag_clear

# Copy assignment configuration template

cp $configFile $gradingDir/GradingConfig.sh

# Copy grading template file

cp $GradingTemplate $gradingDir 

echo (status filename) "finished at" (date)

# echo "Dirname" (status dirname) 
# echo "Filename" (status filename) 
# echo "Basename" (status basename) 