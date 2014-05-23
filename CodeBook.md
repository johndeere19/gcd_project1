run_analysis.R CodeBook
========================================================
## Getting and Cleaning Data Course Project (May 2014)

## Overview
The first and most obvious step was to read in all the data required for this project including the y_train.txt, y_test.txt, activity_labels.txt, x_train.txt, x_test.txt, subject_train.txt, subject_test.txt, features.txt.

The next step was doing some cleanup including properly labeling the column names. Once that was complete, the features were cleaned up by removing any non-alphanumerical characters from the vector, using the results to name the columns of the test and training data.

Following the above steps, the subjects were binded to the beginning front of both the training and the test data. The labels were then joined with the activities and those labels were binded to the training and test data. 

The training and test data were then merged together, ensuring that all colnames are lower case and then subset to be only those that contain the string "mean" or "std." Then order them by subject # and activity id. Finally, remove the id column so that only the necessary data remains.

The data was then "melted" and then reshaped using dcast to produce a clean and tidy data set with a single row for each subject/activity combination and the average for each measurement. Finally, column 1 was renamed to be more descriptive and then data was saved as both a csv and txt file.

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