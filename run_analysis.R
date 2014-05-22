# read labels, activity labels and ensure the column names are all correct
training.labels <- read.table("./train/y_train.txt")
colnames(training.labels) <- "id"
test.labels <- read.table("test/y_test.txt")
colnames(test.labels) <- "id"
activity.labels <- read.table("activity_labels.txt")
colnames(activity.labels) <- c("id", "label")

# read data tables
training.data <- read.table("./train/X_train.txt")
test.data <- read.table("./test/X_test.txt")

# read subject tables
training.subject <- read.table("./train/subject_train.txt")
test.subject <- read.table("./test/subject_test.txt")

# read and clean the features text
features <- read.table("./features.txt")
clean.features <- gsub("[^[:alnum:]]", "", features$V2)

# assign names to the columns of each data set
colnames(training.data) <- clean.features
colnames(test.data) <- clean.features

# add the subject to the data sets
training.data <- cbind(training.subject, training.data)
test.data <- cbind(test.subject, test.data)

# combine the activity labels to the training labels and bind the results to each of the data sets
training.labels <- join(training.labels, activity.labels, by = "id")
test.labels <- join(test.labels, activity.labels, by = "id")

# bind the labels to the tables
training.data <- cbind(training.labels, training.data)
test.data <- cbind(test.labels, test.data)

# merge tables together, ensure that all colnames are lower case and then subset to be only those that contain
# the string "mean" or "std" including the identification rows
merged.tables <- rbind(training.data, test.data)
colnames(merged.tables)[3] <- "subject"
colnames(merged.tables) <- tolower(colnames(merged.tables))
merged.tables <- merged.tables[,c(1:3, grep("mean", colnames(merged.tables)), grep("std", colnames(merged.tables)))]
merged.tables <- merged.tables[order(merged.tables$subject, merged.tables$id),]
merged.tables <- merged.tables[,-1]

# create tidy data
tidy.data <- melt(merged.tables, id = c("label", "subject"), na.rm = TRUE)
tidy.data <- dcast(tidy.data, label + subject ~ variable, mean)

# save tidy data as a csv file
write.csv(tidy.data, "tidydata.csv", row.names = FALSE)

