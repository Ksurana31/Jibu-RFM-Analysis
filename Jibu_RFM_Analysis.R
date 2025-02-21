# ==============================================================================
# Script Name: Marketing Analytics Project
# Purpose: 
# Author: Mabisa Chhetry, Khushboo Surana, Payal Jain, Soumya Mohan
# Date: 03-07-2024
# ==============================================================================
# Load necessary libraries
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidyverse)
library(caret)
library(janitor)
library(MASS)
library(tm)
library(arules)
library(arulesViz)
library(stats)
library(factoextra)
library(zoo)


# Data Loading -----------------------------------------------------------------
mydata<-as.data.frame(Monthly_Meter_Readings_Global_2)
mydata<-clean_names(mydata)
rolling_period <- 36


# Data Structure Exploring/ Cleaning -------------------------------------------
str(mydata)
summary(mydata)
sum(is.na(mydata$liters_produced))
colnames(mydata)
mydata2<-mydata[,c("franchise_name","franchise_id","country_id","launch_year",
                   "year","mm_yy","liters_produced","liters_produced_per_day")]
mydata2$mm_yy <- as.Date(mydata2$mm_yy)

# Changing all dates to 25
mydata2$mm_yy[mydata2$mm_yy == "2022-09-29"] <- "2022-09-25"
mydata2$mm_yy[mydata2$mm_yy == "2022-09-28"] <- "2022-09-25"
mydata2$mm_yy[mydata2$mm_yy == "2022-09-27"] <- "2022-09-25"
mydata2$mm_yy[mydata2$mm_yy == "2022-09-26"] <- "2022-09-25"
mydata2$mm_yy[mydata2$mm_yy == "2022-08-26"] <- "2022-09-25"
mydata2$mm_yy[mydata2$mm_yy == "2021-03-26"] <- "2022-09-25"





#mydata2 <- mydata2[!is.na(mydata2$mm_yy), ]
present <- as.Date("2023-11-25")
end_date <- present - months(36)
#mydata2 <- na.omit(mydata2)
mydata2<- mydata2%>%filter(liters_produced_per_day > 0,
                           liters_produced > 0,
                           year %in% c(2020, 2021, 2022, 2023),
                           (mm_yy <= present & mm_yy >= end_date),
                           country_id %in% c('KE','RW','UG','DRCG')
) 
sum(is.na(mydata2))
summary(mydata2)
max(mydata2$mm_yy)
min(mydata2$mm_yy)
# Data Transformation-----------------------------------------------------------


rfm <- mydata2 %>%
  group_by(franchise_id) %>%
  summarise(Recency = as.numeric(interval(max(mm_yy), present) / months(1)),
            Frequency = n(), 
            MonetaryValue = sum(liters_produced))

# Tested recency, max occuring date for franchise in 12-2020


rfm$MonetaryValue <- as.integer(rfm$MonetaryValue)
head(rfm)
summary(rfm)
number_of_unique_customers <- n_distinct(rfm$franchise_id)
print(number_of_unique_customers)

rfm_numeric <- sapply(rfm, as.numeric)
cor_matrix <- cor(rfm_numeric)
cor_matrix <- cor_matrix[-1, -1]
cor_df <- as.data.frame(cor_matrix) %>%
  rownames_to_column("Variable1") %>%
  pivot_longer(cols = -Variable1, names_to = "Variable2", 
               values_to = "Correlation")

cor_df
ggplot(cor_df, aes(x = Variable1, y = Variable2, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                       midpoint = 0) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Correlation for RFM Data", x = "", y = "", fill = "Correlation")


# Data Visualization -----------------------------------------------------------
check_skew <- function(df, column) {
  options(scipen = 999)
  skew_value <- sum((df[[column]] - mean(df[[column]], na.rm = TRUE))^3, 
                    na.rm = TRUE) / 
    (length(df[[column]][!is.na(df[[column]])]) * sd(df[[column]], 
                                                     na.rm = TRUE)^3)
  # Create the distribution plot with ggplot2
  p <- ggplot(df, aes(x = .data[[column]])) +
    geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", 
                   color = "black") +
    geom_density(color = "red", size = 1) +
    labs(title = paste('Distribution of', column)) +
    theme_minimal()
  print(p)
  # Print skewness value
  message(sprintf("%s's Skew: %.2f", column, skew_value))
}

check_skew(rfm, "Recency")
check_skew(rfm, "Frequency")
check_skew(rfm, "MonetaryValue")

df_rfm_log <- rfm %>%
  mutate(Recency = log(Recency),
         Frequency = log(Frequency),
         MonetaryValue = log(MonetaryValue))


check_skew(df_rfm_log, "Recency")
check_skew(df_rfm_log, "Frequency")
check_skew(df_rfm_log, "MonetaryValue")


head(df_rfm_log)
summary(df_rfm_log)


# Check optimal # of clusters --------------------------------------------------
#mydata3<-df_rfm_log[c(2:4)]
mydata3<-scale(df_rfm_log[c(2:4)])
summary(mydata3)
fviz_nbclust(mydata3,kmeans,method="silhouette")
fviz_nbclust(mydata3,kmeans,method="wss")


# K-means analysis -------------------------------------------------------------
set.seed(123)
mydata3_k3<-kmeans(mydata3,8,nstart=20)
# Extract cluster labels
cluster_labels <- mydata3_k3$cluster
# Create a cluster label column in the original dataset
rfm_clust <- cbind(rfm, Cluster = cluster_labels)
#assess how much it explains 
mydata3_k3$betweenss/mydata3_k3$totss
#looking at the center of the variables
mydata3_k3$centers
data_centers<-as.data.frame(mydata3_k3$centers)
data_centers$cluster<-c(0,1,2,3,4,5,6,7)
#visualizing clusters
fviz_cluster(mydata3_k3,mydata3)
fviz_cluster(mydata3_k3, mydata3, ggtheme = theme_minimal() + theme(panel.background = element_rect(fill = "white")))



# Average values RFM -----------------------------------------------------------
rfm_clust_summary <- rfm_clust %>%
  group_by(Cluster) %>%
  summarise(
    Avg_Recency = mean(Recency, na.rm = TRUE),
    Avg_Frequency = mean(Frequency, na.rm = TRUE),
    Avg_MonetaryValue = mean(MonetaryValue, na.rm = TRUE),
    count = n()
  ) %>%
  ungroup() # Ungroup the data frame after summarising


#  Add cluster labels to original data -----------------------------------------
df_rfm_log$Cluster <- cluster_labels
df_final <- merge(mydata, df_rfm_log[, c("franchise_id", "Cluster")], 
                  by = "franchise_id", all.x = TRUE)


# #  Customer Lifetime Value ---------------------------------------------------
# First, ensure mydata2 is sorted by mm_yy
mydata2 <- mydata2 %>% 
  arrange(mm_yy)
# Create a sequence for MonthPresent assuming mm_yy is already sorted and starts from January 2018
start_date <- as.Date("2020-11-25")
mydata2$MonthPresent <- as.numeric(interval(start_date, mydata2$mm_yy) / months(1) +1)


# Define your interest rates as a named vector
interest_rates <- c(
  '2020-11-25' = 0.09, '2020-12-25' = 0.09, '2021-01-25' = 0.09, '2021-02-25' = 0.08, 
  '2021-03-25' = 0.07, '2021-04-25' = 0.07, '2021-05-25' = 0.06, '2021-06-25' = 0.08,
  '2021-07-25' = 0.1, '2021-08-25' = 0.09, '2021-09-25' = 0.08, '2021-10-25' = 0.08,
  '2021-11-25' = 0.08, '2021-12-25' = 0.08, '2022-01-25' = 0.08, '2022-02-25' = 0.08,
  '2022-03-25' = 0.2, '2022-04-25' = 0.33, '2022-05-25' = 0.77, '2022-06-25' = 1.21,
  '2022-07-25' = 1.68,'2022-08-25' = 2.33, '2022-09-25' = 2.56, '2022-10-25' = 3.08,
  '2022-11-25' = 3.78, '2022-12-25' = 4.1, '2023-01-25' = 4.33, '2023-02-25' = 4.57,
  '2023-03-25' = 4.65, '2023-04-25' = 4.83, '2023-05-25' = 4.83, '2023-06-25' = 5.08,
  '2023-07-25' = 5.12,  '2023-08-25' = 5.33, '2023-09-25' = 5.33, '2023-10-25' = 5.33
) / 100


# Map the interest rates to mm_yy dates in mydata2

mydata2$USInterestRate <- interest_rates[as.character(mydata2$mm_yy)]

# Assuming MonthPresent is already calculated
# Now calculate the CLV using the interest rates
mydata2$CLV <- mydata2$liters_produced / ((1 + mydata2$USInterestRate) ^ 
                                            mydata2$MonthPresent)



clv_totals <- mydata2 %>%
  group_by(franchise_id) %>%
  summarise(TotalCLV = sum(CLV),
            count = n())
#, .groups = 'drop') 
# Compute TotalCLV for each franchise_id



# Join the TotalCLV back onto the original mydata2 
#to get a TotalCLV column with all other original columns
mydata2 <- mydata2 %>%
  left_join(clv_totals, by = "franchise_id")

# Now, if you want the final dataframe to have unique franchise_ids, 
#we need to remove duplicates
#df_clv <- mydata2 %>%
#  arrange(franchise_id, MonthPresent) %>%
#  group_by(franchise_id) %>%
#  slice(1) %>%
#  ungroup()


#  Add cluster labels to original data -----------------------------------------
df_rfm_log$Cluster <- cluster_labels
df_final <- merge(df_clv, rfm_clust[, c("franchise_id", "Cluster")], 
                  by = "franchise_id", all.x = TRUE)
# Calculate the average TotalCLV for each Cluster
average_clv_by_cluster <- df_final %>%
  group_by(Cluster) %>%
  summarise(Avg_TotalCLV = mean(TotalCLV, na.rm = TRUE)) %>%
  ungroup() # To remove the grouping from the resulting data frame

# Merge the average TotalCLV with the average RFM values
final_cluster_summary <- merge(average_clv_by_cluster, rfm_clust_summary, by = "Cluster")

# Display the final summary
print(final_cluster_summary)

#-------------------------------------------------------------------------------
health<-as.data.frame(Health)
health<-clean_names(health)
colnames(health)
health<-health[,c("franchise_id","country","hygiene_audit_score","p_q_audit_score","full_time_staff",
                  "part_time_staff","retailer_satisfaction_score","retailer_branding_score",
                  "total_sales","total_expenses")]
health$staff <- health$full_time_staff + (health$part_time_staff * 0.5)

health <- health %>%
  filter(hygiene_audit_score <= 100 & p_q_audit_score <= 100 & retailer_satisfaction_score <= 100 & 
           retailer_branding_score <= 100)

health_summary <- health %>%
  group_by(franchise_id) %>%
  summarise(
    hygiene_audit_score = mean(hygiene_audit_score, na.rm = TRUE),
    p_q_audit_score = mean(p_q_audit_score, na.rm = TRUE),
    retailer_satisfaction_score = mean(retailer_satisfaction_score, na.rm = TRUE),
    retailer_branding_score = mean(retailer_branding_score, na.rm = TRUE),
    total_sales = sum(total_sales, na.rm = TRUE),
    total_expenses = sum(total_expenses, na.rm = TRUE),
    staff = mean(staff, na.rm = TRUE),
    country = first(country),
    adjusted_sales = case_when(
      country == "DRC Goma" ~ total_sales * 0.00036,
      country == "Kenya" ~ total_sales * 0.007,
      country == "Rwanda" ~ total_sales * 0.0078,
      country == "Uganda" ~ total_sales * 0.0026,
      TRUE ~ total_sales
    ),
    adjusted_expenses = case_when(
      country == "DRC Goma" ~ total_expenses * 0.00036,
      country == "Kenya" ~ total_expenses * 0.007,
      country == "Rwanda" ~ total_expenses * 0.0078,
      country == "Uganda" ~ total_expenses * 0.0026,
      TRUE ~ total_expenses
    )
  )


merged<- mydata2 %>%
  left_join(health_summary, by = "franchise_id")
merged$avgCLV<- merged$TotalCLV/merged$count

merged <- merged[!is.na(merged$staff), ]

colnames(merged)
merged_final<-merged[,c("franchise_id","franchise_name","country_id","mm_yy","liters_produced",
                        "hygiene_audit_score","p_q_audit_score","staff","retailer_satisfaction_score",
                        "retailer_branding_score","adjusted_sales","adjusted_expenses","avgCLV")]

head(merged_final)
colnames(merged_final)
sum(is.na(merged_final))
length(unique(merged_final$franchise_id))

summary(merged_final[,c("mm_yy","liters_produced","hygiene_audit_score","p_q_audit_score","staff","retailer_satisfaction_score",
                        "retailer_branding_score","adjusted_sales","adjusted_expenses","avgCLV")])

# Prepare the data
#data <- merged_final[, c("avgCLV", "liters_produced", "hygiene_audit_score", 
#                   "p_q_audit_score", "staff", "retailer_satisfaction_score", 
#                   "retailer_branding_score", "adjusted_sales", "adjusted_expenses")]

#data <- merged_final[, c("avgCLV", "liters_produced", "hygiene_audit_score", 
#                         "p_q_audit_score", "staff", "retailer_satisfaction_score", 
#                         "retailer_branding_score", "adjusted_sales")]

data <- merged_final[, c("avgCLV", "liters_produced", "hygiene_audit_score", 
                         "p_q_audit_score", "staff", "retailer_satisfaction_score", "adjusted_sales")]

# Run linear regression
lm_model <- lm(avgCLV ~ ., data = data)
summary(lm_model)

#------------------------------------------------------------------------------
# Load necessary libraries
library(ggplot2)

# EDA plots for numeric variables
numeric_vars <- c("liters_produced", "hygiene_audit_score", "p_q_audit_score", 
                  "staff", "retailer_satisfaction_score", "retailer_branding_score",
                  "adjusted_sales", "adjusted_expenses", "avgCLV")



cor_matrix <- cor(rfm_numeric)
cor_matrix <- cor_matrix[-1, -1]
cor_df <- as.data.frame(cor_matrix) %>%
  rownames_to_column("Variable1") %>%
  pivot_longer(cols = -Variable1, names_to = "Variable2", 
               values_to = "Correlation")



# Correlation heatmap
correlation_matrix <- cor(merged_final[, numeric_vars])
correlation_matrix <- correlation_matrix[-1, -1]

cor_df <- as.data.frame(correlation_matrix) %>%
  rownames_to_column("Variable1") %>%
  pivot_longer(cols = -Variable1, names_to = "Variable2", 
               values_to = "Correlation")

ggplot(cor_df, aes(x = Variable1, y = Variable2, fill = Correlation, label = round(Correlation, 2))) +
  geom_tile() +
  geom_text() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                       midpoint = 0) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Correlation Matrix", x = "", y = "", fill = "Correlation")

#________________________________________________________________________________


# EDA plots for categorical variables
# Assuming country_id is a categorical variable
ggplot(merged_final, aes(x = country_id)) +
  geom_bar() +
  labs(title = "Distribution of Franchises by Country", x = "Country", y = "Number of months Water Produced")+
  theme_minimal()+
  # Add labels
  geom_text(stat = "count", aes(label = ..count..), vjust = -0.5)

#------------------------------------------------------------------------------
# Additional plots and analysis as needed

# Load necessary libraries
library(ggplot2)

# Extract year from mm_yy
merged_final$quarter <- quarters(merged_final$mm_yy)
merged_final$year_quarter <- paste0(lubridate::year(merged_final$mm_yy), "-", merged_final$quarter)

ggplot(merged_final, aes(x = year_quarter, y = liters_produced)) +
  geom_bar(stat = "identity")+
  labs(title = "Total Liters Produced by Year Quarter",
       x = "Year Quarter",
       y = "Total Liters Produced") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#---------------------------------------------------------------------
# Distribution of liters produced by country
ggplot(merged_final, aes(x = country_id, y = liters_produced)) +
  geom_boxplot() +
  labs(title = "Distribution of Liters Produced by Country",
       x = "Country",
       y = "Liters Produced") +
  theme_minimal()

#------------------------------------------------------------------------------
library(ggplot2)

# Aggregate liters produced by country
aggregated_data <- merged_final %>%
  group_by(country_id) %>%
  summarise(total_liters_produced = sum(liters_produced))

ggplot(aggregated_data, aes(x = country_id, y = total_liters_produced)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Total Liters Produced by Country",
       x = "Country",
       y = "Total Liters Produced") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Distribution of hygiene audit score---------------------------------------------
# Load the ggplot2 library
library(ggplot2)

# Create a histogram of hygiene_audit_score
ggplot(merged_final, aes(x = hygiene_audit_score)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Hygiene Audit Score",
       x = "Hygiene Audit Score",
       y = "Frequency") +
  theme_minimal()

#Distribution of P&Q audit score---------------------------------------------------------------------------
# Create a histogram of P&Q_audit_score
ggplot(merged_final, aes(x = p_q_audit_score)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribution of PQ Audit Score",
       x = "Hygiene Audit Score",
       y = "Frequency") +
  theme_minimal()
#Retailer Satisfaction score---------------------------------------------------
# Create a histogram of Retailer Satisfaction score
ggplot(merged_final, aes(x = retailer_satisfaction_score)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribution of PQ Audit Score",
       x = "Retailer Satisfaction score",
       y = "Frequency") +
  theme_minimal()

#Retailer branding score------------------------------------------------------
# Create a histogram of retailer_branding_score
ggplot(merged_final, aes(x = retailer_branding_score)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black") +
  labs(title = "Distribution of PQ Audit Score",
       x = "Retailer Branding score",
       y = "Frequency") +
  theme_minimal()

#staff vs CLV-------------------------------------------------------------------
install.packages("GGally")
library(GGally)

# Create a pair plot of staff vs avgCLV using GGally
ggpairs(merged_final, columns = c("staff", "avgCLV"))
#+  theme_minimal()
#+  
#+  

# Create a pair plot of staff vs avgCLV using GGally
ggpairs(merged_final, columns = c("p_q_audit_score", "avgCLV"))
#+  theme_minimal()
