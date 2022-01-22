# Grading Process

1. Make Directory Structures, copy file templates 
2. Tailor assignment specific grading configuration file
3. Build student directories from downloaded zip file

## Scripts

### `MakeStructure.sh`

Build the grading directory structure in an assignment directory

From the assignment directory:

`../../../Grading/MakeStructure.sh`

See `-h` output for details.

Files Used

- `../../GradingTemplate.md`
- `../../GradingConfig.md`

### `StudentDirectoriesFromZip.sh`

Process a downloaded zip file of student submissions building one directory per student. Expand the student compressed file into the directory

From the grading directory:

`../../../../Grading/StudentDirectoriesFromZip.sh <download file>`

See `-h` output for details.

### MakeGradingFiles.sh

Loop through the student directories building tailored grading files

From the grading directory

`../../../../Grading\MakeGradingFiles.sh`

See `-h` output for details.

Files Used

- `./GradingTemplate.md`
- `./GradingConfig.md`

### MakeGradingFile.py

Tailor the grading template file into the student specific file

Assumes Assign, Course, and Student environment variables are set

`MakeGradingFile.py <template> <output>`