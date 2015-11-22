### Wonderful comment here

library(dplyr)

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
##   data_dir/activity_labels.txt      - (6 x 2) "WALKING", "WALKING_UPSTAIRS"...
##   data_dir/features.txt             - (561 x 2) starting place for
##                                       generating column names
##
##   data_dir/train/X_train.txt        - (m_train x 561) feature vectors
##   data_dir/train/y_train.txt        - (m_train x 1)   activity labels (integer)
##   data_dir/train/subject_train.txt  - (m_train x 1)   subject ID (integer)
##
##   data_dir/test/X_test.txt          - (m_test x 561)  feature vectors
##   data_dir/test/y_test.txt          - (m_test x 1)    activity labels (integer)
##   data_dir/test/subject_test.txt    - (m_test x 1)    subject ID (integer)

## Read everything in and make sure that they are the shape we expect.

# We want the activity labels as factors
act_labels <- read.table(file.path(data_dir, 'activity_labels.txt'),
                         col.names=c("V1", "Activity"),
                         header=FALSE, stringsAsFactors=TRUE)


fname <- read.table(file.path(data_dir, 'features.txt'),
                    col.names=c("idx", "name"),
                    header=FALSE, stringsAsFactors=FALSE)
stopifnot(dim(fname)[1] == FVEC_LEN)


X_train <- read.table(file.path(data_dir, 'train', 'X_train.txt'),
                      header=FALSE, colClasses="numeric")
y_train <- read.table(file.path(data_dir, 'train', 'y_train.txt'),
                      header=FALSE, colClasses="integer")
subject_train <- read.table(file.path(data_dir, 'train', 'subject_train.txt'),
                            header=FALSE, colClasses="integer")

stopifnot(dim(X_train)[1] == dim(y_train)[1] | dim(X_train)[1] != dim(subject_train))
stopifnot(dim(X_train)[2] == FVEC_LEN)


X_test <- read.table(file.path(data_dir, 'test', 'X_test.txt'),
                     header=FALSE, colClasses="numeric")
y_test <- read.table(file.path(data_dir, 'test', 'y_test.txt'),
                     header=FALSE, colClasses="integer")
subject_test <- read.table(file.path(data_dir, 'test', 'subject_test.txt'),
                           header=FALSE, colClasses="integer")

stopifnot(dim(X_test)[1] == dim(y_test)[1] | dim(X_test)[1] != dim(subject_test))
stopifnot(dim(X_test)[2] == FVEC_LEN)

## ------------------------------------------------------------------------
## Clean up the feature names so that they make sense and are legal
## column names in R

## (A) There are 3 sets of feature names that are identical.
##
## Since they are contiguous in features.txt, and are amongst other
## features that have -X, -Y, -Z suffixes, I'm assuming that they
## are missing the appropriate suffix and thus am making my
## best guess to disambiguate them.  The feature groups in question
## start at 303, 382, and 461 and all contain -bandsEnergy()- in their name

add_XYZ <- function(s) {
    for (i in seq(s,      length=14)) fname$name[i] <<- paste0(fname$name[i], '-X')
    for (i in seq(s+1*14, length=14)) fname$name[i] <<- paste0(fname$name[i], '-Y')
    for (i in seq(s+2*14, length=14)) fname$name[i] <<- paste0(fname$name[i], '-Z')
}

add_XYZ(303)      # fBodyAcc-bandsEnergy-*
add_XYZ(382)      # fBodyAccJerk-bandsEnergy-*
add_XYZ(461)      # fBodyGyro-bandsEnergy-*


## (B) Correct typos in feature names.
##
## 555: angle(tBodyAccMean,gravity) should be angle(tbodyAccMean,gravityMean)
## to be consistent with the others. Also data_set/features_info.txt
## mentions only "gravityMean", not "gravity"
## 556: has an extra ")" in the middle of it.

fname$name[555] <- "angle(tBodyAccMean,gravityMean)"
fname$name[556] <- "angle(tBodyAccJerkMean,gravityMean)"


## (C) Do the general name mangling...

demangle <- function(x) {
    x <- gsub("arCoeff\\(\\)(\\d)","arCoeff-\\1", x)
    x <- gsub("\\(\\)", "", x)
    x <- gsub("-", "_", x)
    x <- gsub("(\\d+),(\\d+)", "\\1_\\2", x)  # e.g., bandsEnergy_25_32_X
    x <- gsub(",", ".", x)
    x <- gsub("^angle\\((.*)\\)", "angle_\\1", x)
    x
}

fname <- mutate(fname, name=demangle(name))

## Confirm they're all acceptable and unique
stopifnot(all(fname$name == make.names(fname$name, unique=TRUE)))

## ------------------------------------------------------------------------
## rbind the training and test sets together

X_all <- rbind(X_train, X_test)
y_all <- rbind(y_train, y_test)
subject_all <- rbind(subject_train, subject_test)

names(X_all) <- fname$name     # feature names
names(subject_all) <- "Subject"

## Now prepend y_all and subject_all to X_all
df <- cbind(y_all, subject_all, X_all)

## Merge the activity labels into df.
## This reorders the df rows and adds "Activity" at the end
df2 <- merge(df, act_labels, by="V1")

## Move Activity to the front, dropping V1
len <- length(names(df2))
df3 <- df2[c(len, 2:(len-1))]


all_data <- df3                  # all_data is a (wide) tidy data set.

## Each row is an observation: all of the data for a single 50ms window
## Each column is a variable:  Activity, Subject, 561 features

## ------------------------------------------------------------------------
## Create the data set required in step 5 of the instructions:
##
## "From the data set in step 4, create a second, independent tidy data
## set with the average of each variable for each activity and each
## subject."
##
## In our implementation, we do the subsetting and averaging from all_data
## using the group_by and summarise_each methods.

avg_mean_std <- all_data %>%
    group_by(Subject, Activity) %>%
    summarise_each (funs(mean), matches("_(mean|std)(_[XYZ])?$"))

## There are 66 column names that end with mean or std
## optionally followed by _X, _Y or _Z
## dim(select(all_data, matches("_(mean|std)(_[XYZ])?$")))

## avg_mean_std is a (wide) tidy data set.
##
## In an ideal universe this would be a 3-dimensional data structure:
##  Subjects(30) x Activities(6) x Averages(66)
##
## Here in data.frame flatland, we represent this as
##   180 observations(30x6) of [Subject, Activity, Averages(66)]

write.table(avg_mean_std, "avg_mean_std.txt", row.names=FALSE)
