#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Convert a markdown file into a .pdf
"""

__author__ = """
Ralph W. Crosby
crosbyrw@cofc.edu
College of Charleston, Charleston, SC
"""

__all__ = []

# **************************************************

import argparse
import os.path
import subprocess


# **************************************************

def parse_command_line():

    p = argparse.ArgumentParser(description=__doc__)

    p.add_argument('mdfile',
                   help="""Markdown Input File""")

    p.add_argument('pdffile',
                   help="""Output PDF Name""")

    return p.parse_args()


# **************************************************

def run(mdfile, pdffile):

    print(f"Processing <{mdfile}> generating file <{pdffile}>")

    script_dir = os.path.dirname(os.path.realpath(__file__))

    # Load course, assignment, and student environment variables
    # If any of these get key not found, the configuration is
    # incorrect

    courseNumber = os.environ["CourseNumber"]
    courseName = os.environ["CourseName"]
    assignName = os.environ["AssignName"]
    studentFirstName = os.environ["StudentFirstName"]
    studentLastName = os.environ["StudentLastName"]
    studentTimestamp = os.environ["StudentTimestamp"]
    studentSubmissionFile = os.environ["StudentSubmissionFile"]

    # Setup the latex variables requqired

    title = f'{courseNumber} - {courseName}\\\\ \\Large {assignName}'
    author = f'{studentLastName}, {studentFirstName}'
    date = f'File Submitted: {studentSubmissionFile}\\\\Submission Time: {studentTimestamp}'.replace('_', '\_')

    # Build the pdf file

    rc = subprocess.run(['pandoc',
                         '-V', f'title={title}',
                         '-V', f'author={author}',
                         '-V', f'date={date}',
                         '-s',
                         '-o', pdffile,
                         f'{script_dir}/Markdown2Pdf_PandocConfig.yaml',
                         mdfile])

    rc.check_returncode()

    print(f"Wrote PDF file {pdffile}")


# **************************************************

if __name__ == '__main__':
    opts = parse_command_line()
    run(**vars(opts))
