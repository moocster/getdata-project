# getdata-project
Final project for "Getting and Cleaning Data" MOOC from Johns Hopkins

## Overview

This directory contains an R script run_analysis.R which creates a "tidy" dataset based on ...

## Step-by-Step Instruction

The run_analysis.R script assumes that you have downloaded the raw-ish data
and unzipped it in the directory that contains run_analysis.R


1. Download the raw-ish input data from here using your favorite tool:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

1. Unzip it in the directory that contains run_analysis.R
This will create a directory called 'UCI HAR Dataset'

1. Run run_analysis.R to generate tidy-data.csv

From the command line, this looks something like:

`$ R -f run_analysis.R`

## What's in tidy-data.csv

See Codebook.md for details
