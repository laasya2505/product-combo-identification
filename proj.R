install.packages("readxl")
library(readxl)
Online_Retail <- read_excel("/Users/Srinivas/Desktop/Online Retail.xlsx")
View(Online_Retail)


# Install required packages
install.packages("dplyr")
install.packages("stringr")
install.packages("arules")
install.packages("ggplot2")
install.packages("visdat")
install.packages("WVPlots")
# Load packages
library(visdat)
library(dplyr)
library(stringr)
library(arules)
library(ggplot2)
library(WVPlots)


#missing values identification and handling and representation
summary(Online_Retail)
sum(is.na(Online_Retail$InvoiceNo))
sum(is.na(Online_Retail$StockCode))
sum(is.na(Online_Retail$Description))
sum(is.na(Online_Retail$Quantity))
sum(is.na(Online_Retail$InvoiceDate))
sum(is.na(Online_Retail$UnitPrice))
sum(is.na(Online_Retail$CustomerID))
sum(is.na(Online_Retail$Country))
complete_data <- Online_Retail[!is.na(Online_Retail$Description), ]
complete_data <- Online_Retail[!is.na(Online_Retail$CustomerID), ]
boxplot(Online_Retail$UnitPrice)
boxplot(Online_Retail$Quantity)
boxplot(complete_data$Quantity)
boxplot(complete_data$UnitPrice,main="boxplot without missing values",xlab="unit price")
str(complete_data)
summary(complete_data)


# Downsample the dataset (e.g., 20% sample)
sample_data <- Online_Retail %>% slice_sample(prop = 0.2)
# Visualize missing values in the downsampled dataset
vis_miss(sample_data)

# Calculate the proportion of missing values for each variable
missing_proportion <- colMeans(is.na(Online_Retail))
# Create a dataframe for plotting
missing_df <- data.frame(variable = names(missing_proportion),
                         missing_proportion = missing_proportion)
# Create a bar plot using ggplot2
ggplot(missing_df, aes(x = variable, y = missing_proportion)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Proportion of Missing Values by Variable",
       x = "Variable", y = "Proportion of Missing Values") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability



#remove irrelevant features
irrelevant_vars <- c("CustomerID")
complete_data <- complete_data[, !names(complete_data) %in% irrelevant_vars]
str(complete_data)


# Convert categorical variables to factors
categorical_vars <- c("Country")
complete_data[categorical_vars] <- lapply(complete_data[categorical_vars], as.factor)
str(complete_data)


# Check for outliers in numeric columns
# Define a function to detect outliers using IQR
detect_outliers <- function(x) {
  q <- quantile(x, probs = c(0.25, 0.75))
  iqr <- q[2] - q[1]
  lower_bound <- q[1] - 1.5 * iqr
  upper_bound <- q[2] + 1.5 * iqr
  outliers <- x[x < lower_bound | x > upper_bound]
  return(outliers)
}
# Identify outliers in numeric columns
outliers_unit_price <- detect_outliers(complete_data$UnitPrice)
outliers_quantity <- detect_outliers(complete_data$Quantity)


#handling outliers through winsorization
winsorize_two_features <- function(data, feature1, feature2, pcts = c(5, 95)) {
  # Winsorize feature1
  data[, feature1] <- winsor(data[, feature1], limits = pcts)
  
  # Winsorize feature2
  data[, feature2] <- winsor(data[, feature2], limits = pcts)
  
  return(data)
}
# Winsorize feature1
quantiles_feature1 <- quantile(complete_data$Quantity, pcts = c(5,95))
complete_data$Quantity <- pmin(pmax(complete_data$Quantity, quantiles_feature1[1]), quantiles_feature1[2])
# Winsorize feature2 (repeat for each feature)
quantiles_feature2 <- quantile(complete_data$UnitPrice, pcts = c(5,95))
complete_data$UnitPrice <- pmin(pmax(complete_data$UnitPrice, quantiles_feature2[1]), quantiles_feature2[2])
# Winsorized data is now in complete_data (modified)


boxplot(complete_data$Quantity,main="boxplot after handling outliers in quantity",xlab="quantity")
boxplot(complete_data$UnitPrice,main="boxplot after handling outliers in unit price",xlab="unit price")

# Define min-max scaling function//NORMALIZATION
min_max_scaling <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}
# Apply min-max scaling to numerical variables
numerical_vars <- c("Quantity", "UnitPrice")
for (var in numerical_vars) {
  complete_data[[var]] <- min_max_scaling(complete_data[[var]])
}
# Display summary statistics after min-max scaling
summary(complete_data[numerical_vars])


#correlation
numerical_vars <- c("Quantity","UnitPrice")
# Subset the dataframe to include only the selected numerical variables
df_numerical <- complete_data[, numerical_vars]
# Calculate the correlation matrix
correlation_matrix <- cor(df_numerical)
# Print correlation matrix
print(correlation_matrix)
# Plot correlation matrix (optional)
install.packages("corrplot")
library(corrplot)  
corrplot(correlation_matrix, method = "square", type = "lower", tl.col = "black")
corrplot(correlation_matrix, method = "color")
#Correlation including few Categorical Variables
# Selecting variables for correlation analysis
selected_vars <- c("Quantity","UnitPrice","Country")
# Subset the dataframe to include only the selected variables
df_selected <- complete_data[, selected_vars]
# One-hot encode categorical variables
encoded_categorical <- model.matrix(~ . - 1, data = df_selected[, c("Country")])
df_encoded <- as.data.frame(encoded_categorical)
# Combine numerical and encoded categorical variables
df_all <- cbind(df_selected[, c("Quantity","UnitPrice")], df_encoded)
# Calculate the correlation matrix
correlation_matrix_all <- cor(df_all)
# Print correlation matrix
print(correlation_matrix_all)
# Plot heatmap
corrplot(correlation_matrix_all, method = "color",main="correlation plot")
corrplot(correlation_matrix_all, method = "square", type = "lower", tl.col = "black", main="correlation plot")
# Visualization using ggplot2 (optional)
library(ggplot2)
install.packages("ggpubr")
library(ggpubr)
ggplot(complete_data, aes(x = Quantity, y = UnitPrice)) +
  geom_point() +
  labs(title = "Quantity vs. Unit Price", x = "Quantity", y = "Unit Price") +
  stat_cor(method = "pearson")  # Add correlation coefficient to the plot

library(plyr)
library(arules)
install.packages('arulesViz')
library(arulesViz)

sorted <- complete_data[order(complete_data$InvoiceNo),]
sorted$InvoiceNo <- as.numeric(sorted$InvoiceNo)
str(sorted)
#create a new dataframe with soreted member number and date
itemList <- ddply(sorted, c("InvoiceNo","InvoiceDate"), function(df1)paste(df1$Description,collapse = ","))

head(itemList,15)
#remove member number and date from the dataframe
itemList$InvoiceNo <- NULL
itemList$InvoiceDate <- NULL
colnames(itemList) <- c("itemList")
#write item list as a new csv file
write.csv(itemList,"ItemList.csv", quote = FALSE, row.names = TRUE)
head(itemList)
#
txn = read.transactions(file="ItemList.csv", rm.duplicates= TRUE, format="basket",sep=",",cols=1);
print(txn)
txn@itemInfo$labels <- gsub("\"","",txn@itemInfo$labels)
itemFrequencyPlot(txn, topN=15, type="absolute", col="wheat2",xlab="Item name", 
                  ylab="Frequency (absolute)", main="Absolute Item Frequency Plot")
#apply apriori algo for 2 products
basket_rules <- apriori(txn, parameter = list(minlen=2, sup = 0.006, conf = 0.1, target="rules"))
print(length(basket_rules))
summary(basket_rules)
inspect(basket_rules[1:20])
plot(basket_rules, jitter = 0)
plot(basket_rules, method = "grouped", control = list(k = 5))
plot(basket_rules[1:20], method="graph")
plot(basket_rules[1:50], method="graph")
#plot(basket_rules[1:20], method="paracoord")
itemFrequencyPlot(txn, topN = 10)
#apply apriori algo for 3 products
basket_rules2 <- apriori(txn, parameter = list(minlen=3, sup = 0.006, conf = 0.1, target="rules"))
print(length(basket_rules2))
inspect(basket_rules2)
plot(basket_rules2, method="graph")
#plot(basket_rules2, method="paracoord")
basket_rules3 <- apriori(txn, parameter = list(minlen=4, sup = 0.006, conf = 0.1, target="rules"))
print(length(basket_rules3))
inspect(basket_rules3)
plot(basket_rules3, method="graph")
#plot(basket_rules3, method="paracoord")
basket_rules4 <- apriori(txn, parameter = list(minlen=5, sup = 0.006, conf = 0.1, target="rules"))
print(basket_rules4)
inspect(basket_rules4)
plot(basket_rules4, method="graph")
summary(basket_rules)
summary(basket_rules2)
summary(basket_rules3)
summary(basket_rules4)