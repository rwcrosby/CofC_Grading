#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Tailor a template grade file
"""

__all__ = []

# **************************************************

import argparse
from jinja2 import Template
import os
import re


# **************************************************

def parse_command_line():

    p = argparse.ArgumentParser(description=__doc__)

    p.add_argument('--late',
                   action='store_true',
                   help="""Assignment is late""")

    p.add_argument('template',
                   help="""Grading Template File (Input)""")

    p.add_argument('gradefile',
                   help="""Student Grading File (output)""")

    return p.parse_args()


# **************************************************

def run(gradefile, template, late):

    print(f"Creating <{gradefile}> using template file <{template}>")

    # Load the template file

    with open(template, 'r') as f:
        template = Template(f.read())

    # Load course, assignment, and student environment variables

    substVars = {k: v for k, v
                 in os.environ.items()
                 if re.match(r"Assign|Course|Student", k)}
    substVars['late'] = late

    # print(substVars)

    # Tailor the grading file

    with open(gradefile, 'w') as f:
        print(template.render(substVars), file=f)

    print(f"Wrote markdown file {gradefile}")


# **************************************************

if __name__ == '__main__':
    opts = parse_command_line()
    run(**vars(opts))
