#!/usr/bin/env fish

###############################################################
# Display the help text

function HelpMsg

echo "Make tailored grading markdown files

Run from the Grading directory

Process

Options
  -c, --config : override configuration file name
                 default: ./GradingConfig.sh
  --clear : Recreate all from scratch deleting contents
  --late : Mark the assignments late
  -h : Display this help message
"

end

###############################################################
# Mainline

# Parse the command line

argparse 'h/help' 'clear' 'late' 'c/config=' -- $argv
or begin
    HelpMsg 
    exit
end

if set -q _flag_help
    HelpMsg
    exit
end

# Find and source the configuration file

if set -q _flag_config
    set configFile $_flag_config
else
    set configFile ./GradingConfig.sh
end

set scriptFile (status filename)
echo  $scriptFile "starting at" (date)
echo "Loading configuration file: $configFile"
source $configFile

if set -q _flag_late
    set late '--late'
end

echo "Late: <$late>"


# Loop through the student directories

set pydir (pushd (dirname $scriptFile); pwd; popd)

for studentDir in (find Working -maxdepth 1 -type d)

    # Change into the student directory and source the info file.

    pushd $studentDir
    or begin
        echo "Unable to change directory to $studentDir"
        exit 1
    end

    if not test -f Info.sh
        echo "Info.sh file not found in " (pwd)
        popd
        continue
    end
    source Info.sh

    # Tailor the grading file

    set gradeFile "$StudentCode - $StudentLastName, $StudentFirstName.md"

    if test -f $gradeFile
        if not set -q _flag_clear
            echo "Grading file <$gradeFile> exists but clear not specified"
            popd 
            continue
        end
        echo "Deleting grading file <$gradeFile>"
        rm $gradeFile
    end

    $pydir/MakeGradingFile.py $late ../../GradingTemplate.md $gradeFile

    popd

end