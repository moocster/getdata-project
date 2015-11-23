# getdata-project
Final project for "Getting and Cleaning Data" MOOC from Johns Hopkins

## Overview

This directory contains an R script `run_analysis.R` which creates a
*tidy* dataset based on the principles described in Hadley Wickham's
"Tidy Data" paper published in *Journal of Statistical Software*,
[August 2014, Vol 59, Issue 10], available at
http://www.jstatsoft.org/article/view/v059i10/v59i10.pdf

Per Wickham, in **tidy data**:

1. Each variable forms a column.
2. Each observation forms a row.
3. Each type of observational unit forms a table.

The input to this process is a data set originally from the UCI Machine
Learning Repository,
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


The output is a tidy data set written to a file `avg_mean_std.txt`.
The output data set can be read in to R using:

```R
avg_mean_std <- read.table("avg_mean_std.txt", header=TRUE)
```

## Instructions on how to run run_analysis.R

The `run_analysis.R` script assumes that you have downloaded the raw-ish data
and unzipped it in the directory that contains run_analysis.R

1. Download the raw-ish input data from here using your favorite tool:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

1. Unzip it in the directory that contains run_analysis.R
This will create a directory called `UCI HAR Dataset`

1. Source `run_analysis.R` to generate `avg_mean_std.txt`.

The resulting file can be read into R like this:

```R
avg_mean_std <- read.table("avg_mean_std.txt", header=TRUE)
```

## What's in the output file?

The output file is a tidy data set that contains the averages of 66
specific features for all combinations of Subject and Activity.

Details of the data set can be found in `Codebook.md` found in this
directory.

## What does run_analysis.R do?
