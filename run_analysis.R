## Getting and Cleaning Data Course Project
 
## The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
## The goal is to prepare tidy data that can be used for later analysis. 
## You will be graded by your peers on a series of yes/no questions related to the project. 
## You will be required to submit: 
## 1) a tidy data set as described below, 
## 2) a link to a Github repository with your script for performing the analysis, and 
## 3) a code book that describes the variables, the data, and any transformations or 
## work that you performed to clean up the data called CodeBook.md. 
## You should also include a README.md in the repo with your scripts. 
## This repo explains how all of the scripts work and how they are connected.

## One of the most exciting areas in all of data science right now is wearable computing - see for example this article . 
## Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. 
## The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
## A full description is available at the site where the data was obtained:
        
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

## Here are the data for the project:
        
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  

## You should create one R script called run_analysis.R that does the following. 

## Merges the training and the test sets to create one data set.
## Extracts only the measurements on the mean and standard deviation for each measurement. 
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive variable names. 
## From the data set in step 4, creates a second, independent tidy data set with the average 
## of each variable for each activity and each subject.
## Good luck!

## Step 1: The below code checks to see if there's a "data" folder in the working directory and if there isn't one
## it creates one.

if(!file.exists("data")){
        dir.create("data")
}

## Step 2: Download the zip file to the data directory and unzip the file.
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, "./data/data.zip", method = "curl")
zipF <- "./data/data.zip"
unzippedDir <- "./data" 
unzip(zipF, exdir = unzippedDir)

## Step 3: Set working directory where the data was unzipped.
setwd("./data/UCI HAR Dataset")

## Step 4: Load dplyr and data.table packages

library(dplyr)

## R script exercise 1: Merge the training and test sets to create one data set.

## Create separate R objects for the two sets, their number labels and subjects.

testset <- read.table("./test/X_test.txt")
testlabels <- read.table("./test/y_test.txt")
trainset <- read.table("./train/X_train.txt")
trainlabels <- read.table("./train/y_train.txt")
testsubjects <- read.table("./test/subject_test.txt")
trainsubjects <- read.table("./train/subject_train.txt")

## Merge the sets, labels and subjects into 3 objects. 

mergedset <- rbind(testset, trainset)
mergedlabels <- rbind(testlabels,trainlabels)
mergedsubjects <- rbind(testsubjects, trainsubjects)

## Change the column names in the merged set using the features file

features <- read.table("./features.txt")  ## Create features as an R object
names(mergedset) <- features$V2 ## Set columns of mergeddata to be the V2 column of features

## Merge three objects from above to create one data set.

mergeddata <- cbind(mergedsubjects, mergedlabels, mergedset)

## Change column names of merged data to first column = id and 2nd column = activitynum

names(mergeddata)[1:2] <- c("id", "activitynum")


## R script exercise 2: Extracts only the measurements on the mean and standard deviation 
## for each measurement

mergeddata2 <- select(mergeddata, id, activitynum, grep("mean\\(|std\\(", colnames(mergeddata)))

## R script exercise 3: Use descriptive activity names to name the activities in the data set

## Merge the set with corresponding label numbers

## Create an R object for the activity labels file and change column names

activitylabels <- read.table("./activity_labels.txt")
colnames(activitylabels) <- c("activitynum", "activity")

## Add activity lable and remove activitynum

mdwactivity <- left_join(mergeddata2, activitylabels, by = "activitynum") ## Add activity
newmd <- select(mdwactivity, id, activity, everything(), -activitynum) ## Bring activity as second column and remove activitynum

## R script exercise 4: Appropriately labels the data set with descriptive variable names.

colnames(newmd) <- tolower(colnames(newmd)) ## Make all column names lower case
colnames(newmd) <- gsub("-", "", colnames(newmd)) ## Remove hypens ("-")
colnames(newmd) <- gsub("std", "standarddiviation", colnames(newmd)) ## change "std" to "standarddeviation"
colnames(newmd) <- gsub("\\(", "", colnames(newmd)) ## Remove "("
colnames(newmd) <- gsub("\\)", "", colnames(newmd)) ## Remove ")"
colnames(newmd) <- gsub("tbody", "timebody", colnames(newmd)) ## Rename "tbody" to "timebody"
colnames(newmd) <- gsub("acc", "acceleration", colnames(newmd)) ## Rename "acc" to "acceleration"
colnames(newmd) <- gsub("tgravity", "timegravity", colnames(newmd)) ## Rename "tgravity" to "timegravity"
colnames(newmd) <- gsub("fbody", "frequencybody", colnames(newmd)) ## Rename "fbody" to "frequencybody"
colnames(newmd) <- gsub("mag", "magnitude", colnames(newmd)) ## Rename "mag" to "magnitude"

## R script exercise 5: From the data set in step 4, create a second, independent tidy data set 
## with the average of each variable for each activity and each subject.

tidyset <- newmd %>%
        group_by(id, activity) %>%
        summarize(across(everything(), mean)) %>%
        arrange(id, activity)

## Save tidyset as a .txt file

write.table(tidyset, file = "tidyset.txt", row.names = FALSE)

