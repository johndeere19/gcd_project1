run_analysis.R Readme
========================================================
## Getting and Cleaning Data Course Project (May 2014)

## Overview

All features with either mean or std (not case sensitive) in the text were selected for this analysis.

In order to clean up the features, all non-alphanumeric characters were removed and then each remaining string was changed to all lower-case characters.

## Code & Descriptions

Read the labels and activity labels. Ensure the column names are all correct.
```{r}
training.labels <- read.table("./train/y_train.txt")
colnames(training.labels) <- "id"
test.labels <- read.table("test/y_test.txt")
colnames(test.labels) <- "id"
activity.labels <- read.table("activity_labels.txt")
colnames(activity.labels) <- c("id", "label")
```

Read data tables
```{r}
training.data <- read.table("./train/X_train.txt")
test.data <- read.table("./test/X_test.txt")
```

Read subject tables
```{r}
training.subject <- read.table("./train/subject_train.txt")
test.subject <- read.table("./test/subject_test.txt")
```

Read and clean the features text
```{r}
features <- read.table("./features.txt")
clean.features <- gsub("[^[:alnum:]]", "", features$V2)
```

Assign the features to the columns of each data set
```{r}
colnames(training.data) <- clean.features
colnames(test.data) <- clean.features
```

Add the subject to the data sets
```{r}
training.data <- cbind(training.subject, training.data)
test.data <- cbind(test.subject, test.data)
```

Combine the activity labels to the training labels and bind the results to each of the data sets
```{r}
training.labels <- join(training.labels, activity.labels, by = "id")
test.labels <- join(test.labels, activity.labels, by = "id")
```

Bind the labels to the tables
```{r}
training.data <- cbind(training.labels, training.data)
test.data <- cbind(test.labels, test.data)
```

Merge the training and test tables together. Ensure that all colnames are lower case and then subset to be only those that contain the string "mean" or "std" then order them by subject # and activity id. Finally, remove the id column.
```{r}
merged.tables <- rbind(training.data, test.data)
colnames(merged.tables)[3] <- "subject"
colnames(merged.tables) <- tolower(colnames(merged.tables))
merged.tables <- merged.tables[,c(1:3, grep("mean", colnames(merged.tables)), grep("std", colnames(merged.tables)))]
merged.tables <- merged.tables[order(merged.tables$subject, merged.tables$id),]
merged.tables <- merged.tables[,-1]
```

create tidy data
```{r}
tidy.data <- melt(merged.tables, id = c("label", "subject"), na.rm = TRUE)
tidy.data <- dcast(tidy.data, label + subject ~ variable, mean)
colnames(tidy.data)[1] <- "activity"
```

save tidy data as a csv file and txt file to upload
```{r}
write.csv(tidy.data, "tidydata.csv", row.names = FALSE)
write.table(tidy.data, "tidydata.txt", sep = " ", row.names = FALSE)
```