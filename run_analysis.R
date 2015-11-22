### Wonderful comment here

library(dplyr)

# Using the dplyr library is easier
#
# You should give a look to: http://rpubs.com/justmarkham/dplyr-tutorial
#
# allData%>%
#  group_by(Subject, Label)%>%
#  summarise_each (funs(mean), contains("mean()"), contains("std()"))


## Start by ensuring that UCI dataset was unpacked in this directory

data_dir <- 'UCI HAR Dataset'
stopifnot(dir.exists(data_dir) & file.exists(file.path(data_dir, 'features.txt')))

## Feature Vector length. We're counting on this when it comes to
## assigning column names

FVEC_LEN <- 561

## -------------------------------------------------------------------------------
## We're going to merge the provided training and test sets to one tidy dataset.
## We'll be using:
##
##   data_dir/features.txt             - (561 x 2) starting place for
##                                       generating column names
##
##   data_dir/train/X_train.txt        - (m_train x 561) feature vectors
##   data_dir/train/y_train.txt        - (m_train x 1)   activity labels (integer)
##   data_dir/train/subject_train.txt  - (m_train x 1)   subject ID (integer)
##
##   data_dir/test/X_test.txt          - (m_test x 561) feature vectors
##   data_dir/test/y_test.txt          - (m_test x 1)   activity labels (integer)
##   data_dir/test/subject_test.txt    - (m_test x 1)   subject ID (integer)

## Read everything in and make sure that they are the shape we expect.

fname <- read.table(file.path(data_dir, 'features.txt'),
                    col.names=c("idx", "name"),
                    header=FALSE, stringsAsFactors=FALSE)
stopifnot(dim(fname)[1] == FVEC_LEN)

X_train <- read.table(file.path(data_dir, 'train', 'X_train.txt'))
y_train <- read.table(file.path(data_dir, 'train', 'y_train.txt'))
subject_train <- read.table(file.path(data_dir, 'train', 'subject_train.txt'))
stopifnot(dim(X_train)[1] == dim(y_train)[1] | dim(X_train)[1] != dim(subject_train))
stopifnot(dim(X_train)[2] == FVEC_LEN)


X_test <- read.table(file.path(data_dir, 'test', 'X_test.txt'))
y_test <- read.table(file.path(data_dir, 'test', 'y_test.txt'))
subject_test <- read.table(file.path(data_dir, 'test', 'subject_test.txt'))
stopifnot(dim(X_test)[1] == dim(y_test)[1] | dim(X_test)[1] != dim(subject_test))
stopifnot(dim(X_test)[2] == FVEC_LEN)

## ------------------------------------------------------------------------
## Now we start working on cleaning up the feature names so that they
## make sense and are legal column names in R

## Step 1: There are 3 sets of feature names that are identical.
##
## Since they appear contiguous in the file, and are amongst other
## features that have -X, -Y, -Z suffixes, I'm assuming that they
## are missing the appropriate suffix, and thus are making my
## best guess to disambiguate them.  The features in question
## are in [303, 344] and all contain -bandsEnergy()- in their name

## fBodyAcc-bandsEnergy-*
for (i in seq(303,      length=14)) fname$name[i] <- paste0(fname$name[i], '-X')
for (i in seq(303+1*14, length=14)) fname$name[i] <- paste0(fname$name[i], '-Y')
for (i in seq(303+2*14, length=14)) fname$name[i] <- paste0(fname$name[i], '-Z')

## fBodyAccJerk-bandsEnergy-*
for (i in seq(382,      length=14)) fname$name[i] <- paste0(fname$name[i], '-X')
for (i in seq(382+1*14, length=14)) fname$name[i] <- paste0(fname$name[i], '-Y')
for (i in seq(382+2*14, length=14)) fname$name[i] <- paste0(fname$name[i], '-Z')

## fBodyGyro-bandsEnergy-*
for (i in seq(461,      length=14)) fname$name[i] <- paste0(fname$name[i], '-X')
for (i in seq(461+1*14, length=14)) fname$name[i] <- paste0(fname$name[i], '-Y')
for (i in seq(461+2*14, length=14)) fname$name[i] <- paste0(fname$name[i], '-Z')

## Step 2: Correct typos in feature names.
##
## 555: angle(tBodyAccMean,gravity) should be angle(tbodyAccMean,gravityMean)
## to be consistent with the others, and data_set/features_info.txt
## mentions only "gravityMean", not "gravity"
fname$name[555] <- gsub("gravity", "gravityMean", fname$name[555])
fname$name[556] <- gsub("\\),", ",", fname$name[556])


## Step 3: Do the general name mangling...

demangle <- function(x) {
    x <- gsub("arCoeff\\(\\)(\\d)","arCoeff-\\1", x)
    x <- gsub("\\(\\)", "", x)
    x <- gsub("-", "_", x)
    x <- gsub("(\\d+),(\\d+)", "\\1_\\2", x)  # bandsEnergy_25_32_X
    x <- gsub(",", ".", x)
    x <- gsub("^angle\\((.*)\\)", "angle_\\1", x)
    x
}

fname <- mutate(fname, name=demangle(name))

## Confirm they're all acceptable and unique
stopifnot(all(fname$name == make.names(fname$name, unique=TRUE)))


## grep -E '_(mean|std)(_[XYZ])?$'
