#!/usr/bin/env fish

###############################################################
# Display the help text

function HelpMsg

echo "Make tailored grading markdown files

Run from the Working directory

Process

Options
  -c, --config : override configuration file name
                 default: ./GradingConfig.sh
  --clear : Recreate all pdf files from scratch deleting originals
  -h : Display this help message
"

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

# Find and source the configuration file

if set -q _flag_config
    set configFile $_flag_config
else
    set configFile ../GradingConfig.sh
end

set scriptFile (status filename)
echo  $scriptFile "starting at" (date)
echo "Loading configuration file: $configFile"
source $configFile

# Loop through the student directories

set pydir (pushd (dirname $scriptFile); pwd; popd)

for studentDir in (find . -maxdepth 1 -type d)

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

    # Locate the grading markdown file

    set filename "$StudentCode - $StudentLastName, $StudentFirstName"
    set markdownFile "$filename.md"
    set pdfFile "$filename - Feedback.pdf"

    if not test -f $markdownFile
        echo "$markdownFile file not found in " (pwd)
        popd
        continue
    end

    if test -f $pdfFile
        if not set -q _flag_clear
            echo "Pdf file <$pdfFile> exists but clear not specified"
            popd
            continue
        end
        echo "Deleting pdf file <$pdfFile>"
        rm -f  $pdfFile
    end

    # Create the pdf

    $pydir/Markdown2Pdf.py $markdownFile $pdfFile

    popd

end