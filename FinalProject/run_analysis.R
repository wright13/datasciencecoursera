#Load packages
library(plyr)
library(dplyr)

## Get raw datasets

# Subjects - each row corresponds to one sample and indicates which subject performed the activity.
subject_train <- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/train/subject_train.txt",sep = "",header=FALSE)
subject_test<- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/test/subject_test.txt",sep = "",header=FALSE)

# Time and frequency domain data - one row per sample.
x_train <- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/train/X_train.txt",sep = "",header=FALSE)
x_test <- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/test/X_test.txt",sep = "",header=FALSE)

# Integer corresponding to the activity performed. One row per sample.
y_train <- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/train/y_train.txt",sep = "",header=FALSE)
y_test <- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/test/y_test.txt",sep = "",header=FALSE)

# Table matching activity labels (integer) with the activity name
activitylookup <- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/activity_labels.txt",sep = "",header=FALSE)

# All features. These are the headers for x_train and x_test.
features <- read.delim("C:/Users/sewright/Documents/R/UCI HAR Dataset/features.txt",sep = "",header=FALSE,as.is = TRUE)

## Basic data cleanup

# Assign names to columns
names(subject_train) <- "subjectid"
names(subject_test) <- "subjectid"
names(y_train) <- "activityid"
names(y_test) <- "activityid"
names(features) <- c("featureid","featurename")

# Assign feature ids as column names for x_train and x_test. Feature names would be better but they are not unique. We'll fix this later.
names(x_train) <- features$featureid
names(x_test) <- features$featureid

names(activitylookup) <- c("activityid","activityname")

# Merge training and test sets
smartphoneSensorData <- rbind(x_train,x_test)
subject <- rbind(subject_train,subject_test)
activity <- rbind(y_train,y_test)

# Get rid of columns that are not a mean or standard deviation
meanstd <- grepl("mean\\(\\)|std\\(\\)",features$featurename)
smartphoneSensorData <- smartphoneSensorData[,meanstd]
names(smartphoneSensorData) <- features$featurename[meanstd]

# Combine activity, subject, and sensor data into one dataframe
smartphoneSensorData <- cbind(activity,subject,smartphoneSensorData)

# Merge with the activity lookup to get descriptive activity names instead of integer IDs
smartphoneSensorData <- merge(activitylookup,smartphoneSensorData, by.x = "activityid",by.y = "activityid",sort = FALSE)
smartphoneSensorData <- select(smartphoneSensorData,-activityid)

# Use melt() to get a long dataset with one row per activity, subject, and variable.
#smartphoneSensorData <- melt(smartphoneSensorData,id=c("activityname","subjectid"),measure.vars = names(smartphoneSensorData)[-(1:2)])

# There is a lot of information contained in the variable names: 
# domain (time or freq), signal source (accelerometer or gyroscope), signal component (body or gravity), 
# type of measurement (linear acc, angular velocity, jerk), direction (X,Y,Z,mag), and summary statistic (mean, stdev).


#Create second dataset with average of each variable for each activity and each subject.
