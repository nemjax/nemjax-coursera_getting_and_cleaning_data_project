
## init reshape2 library 
library(reshape2)
## download the data and store it in memory
filename <- "getdata_dataset.zip"

if (!file.exists(fName)){
  fURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fURL, fName, method="curl")
}  
## extract the files from the zipped file 
if (!file.exists("UCI HAR Dataset")) {  
  unzip(fName) 
}

## load activity labels 
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
## load features 
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## leave data on mean and standard deviation
fWanted <- grep(".*mean.*|.*std.*", features[,2])
fWanted.names <- features[fWanted,2]
fWanted.names = gsub('-mean', 'Mean', fWanted.names)
fWanted.names = gsub('-std', 'Std',fWanted.names)
fWanted.names <- gsub('[-()]', '', fWanted.names)


# load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[fWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[fWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets by row
allData <- rbind(train, test)

# add labels
colnames(allData) <- c("subject", "activity", fWanted.names)

# turn activities to factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])

#turn subjects to factors
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

## save (write) the new cleaner subversion of the data set to clean.txt file 
write.table(allData.mean, "clean.txt", row.names = FALSE, quote = FALSE)
