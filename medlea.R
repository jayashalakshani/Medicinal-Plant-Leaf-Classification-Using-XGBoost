# Load the required libraries
library(MedLEA)
library(nnet)
library(caret)
library(ggplot2)
library(dplyr)
library(tm)
library(wordcloud2)
library(wordcloud)
library(patchwork)
library(xgboost)

# Load the dataste from the 'MedLEA' package
data('medlea',package='MedLEA')
df <- medlea
# view the entire dataset
View(df)
# Summary of the dataset
summary(df)
# Structure of the dataset
str(df)
# Dimensions of the dataset
dim(df)
# First few rows
head(df)
# Last few rows
tail(df)
# Column names
names(df)
# Data types of columns
sapply(df, class)

# Data Preprocessing
# Check for missing values
sum(is.na(df))

# Summary of missing values by column
colSums(is.na(df))

# Summary statistics for numerical columns
summary(df %>% select_if(is.numeric))

# Frequency distribution for categorical columns
table(df$Family_Name)
table(df$Scientific_Name)
table(df$Family_Name)

# Visualizations
# Histogram for numerical features
unique(df$Shape)
ggplot(df, aes(x = Shape)) +
  geom_bar(fill = 'purple', color = 'black') +
  labs(title = "Distribution of Shapes", x = "Shape", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Extract the 'Family_Name' column
unique(df$Family_Name)
text1 <- df$Family_Name

# Create a corpus
docs <- Corpus(VectorSource(text1))

# Preprocess the text data
docs <- docs %>%
  tm_map(content_transformer(tolower)) %>% # Convert to lower case
  tm_map(removePunctuation) %>%            # Remove punctuation
  tm_map(removeNumbers) %>%                # Remove numbers
  tm_map(stripWhitespace)                  # Remove extra whitespace

# Create a term-document matrix
dtm <- TermDocumentMatrix(docs)

# Convert the matrix to a data frame
matrix <- as.matrix(dtm)
words <- sort(rowSums(matrix), decreasing = TRUE)
df_word <- data.frame(word = names(words), freq = words)

# Generate the word cloud using the wordcloud package
wordcloud(words = df_word$word, freq = df_word$freq, 
          min.freq = 1, scale = c(3, 0.5), 
          colors = brewer.pal(8, "Dark2"))
medlea <- filter(medlea, Arrangements == "Simple")

df_1 <- as.data.frame(table(df$Shape))
names(df_1) <- c('Shape_of_the_leaf', 'No_of_leaves')

p2 <- ggplot(df_1, aes(x= reorder(Shape_of_the_leaf, No_of_leaves), y=No_of_leaves)) + labs(y="Number of leaves", x="Shape of the leaf") + geom_bar(stat = "identity", width = 0.6) + ggtitle("Composition of the Sample by the Shape Label") + coord_flip()

df_2 <- as.data.frame(table(df$Edges))
names(df_2) <- c('Edges', 'No_of_leaves')
p3 <- ggplot(df_2, aes(x= reorder(Edges, No_of_leaves), y=No_of_leaves)) + labs(y="Number of leaves", x="Edge type of the leaf") + geom_bar(stat = "identity", width = 0.6) + ggtitle("Composition of the Sample by the Edge Type") + coord_flip()

p2 + p3 + plot_layout(ncol = 1)


## Preprocess the Data

# Remove the columns "ID", "Sinhala_Name", "Family_Name", and "Scientific_Name"
data_features <- df %>%
  select(-c(ID, Sinhala_Name, Family_Name, Scientific_Name))

# Convert categorical variables to numeric as required by XGBoost
for (col in colnames(data_features)) {
  data_features[[col]] <- as.numeric(as.factor(data_features[[col]]))
}

# Prepare the data for XGBoost
labels <- as.numeric(as.factor(medlea_data$Sinhala_Name)) - 1  # Labels should start from 0 for XGBoost
data_matrix <- xgb.DMatrix(data = as.matrix(data_features), label = labels)

# Set parameters for XGBoost
params <- list(
  objective = "multi:softmax",    # Multiclass classification
  num_class = length(unique(labels)), # Number of classes
  eval_metric = "mlogloss"        # Multiclass log loss
)

# Train the XGBoost model
xgb_model <- xgboost(
  params = params,
  data = data_matrix,
  nrounds = 100,           # Number of trees (adjust as necessary)
  verbose = 1
)

# Function to predict the plant name based on user input
predict_plant <- function(model, feature_names, known_plant_names, original_data) {
  user_input <- c()
  
  # Loop through each feature to collect user input
  for (feature in feature_names) {
    valid_input <- FALSE
    while (!valid_input) {
      value <- readline(prompt = paste("Enter the value for", feature, ": "))
      
      # Check if the input value is among the allowed levels
      if (value %in% levels(original_data[[feature]])) {
        valid_input <- TRUE
        user_input <- c(user_input, value)
      } else {
        cat("Invalid input for", feature, ". Please enter one of the following: \n")
        print(levels(original_data[[feature]]))
      }
    }
  }
  
  # Convert user input to a data frame
  user_input_df <- as.data.frame(t(user_input), stringsAsFactors = FALSE)
  colnames(user_input_df) <- feature_names
  
  # Ensure that the factors in user_input_df have the same levels as in original_data
  for (col in feature_names) {
    user_input_df[[col]] <- factor(user_input_df[[col]], levels = levels(original_data[[col]]))
  }
  
  # Convert factors to numeric for model input
  user_input_numeric <- user_input_df %>%
    mutate(across(everything(), as.numeric))
  
  # Make prediction using the model
  user_matrix <- xgb.DMatrix(data = as.matrix(user_input_numeric))
  prediction <- predict(model, user_matrix)
  
  # Convert prediction to plant name
  predicted_plant <- factor(prediction, levels = 0:(length(known_plant_names) - 1), labels = known_plant_names)
  
  # Return result
  if (predicted_plant %in% known_plant_names) {
    return(paste("The predicted medicinal plant is:", predicted_plant))
  } else {
    return("This is not a medicinal plant.")
  }
}

# Define feature names (excluding ID, Sinhala_Name, Family_Name, and Scientific_Name)
feature_names <- colnames(medlea_data)[!colnames(medlea_data) %in% c("ID", "Sinhala_Name", "Family_Name", "Scientific_Name")]

# Get the known plant names
known_plant_names <- levels(as.factor(medlea_data$Sinhala_Name))

# Use the function to predict
result <- predict_plant(xgb_model, feature_names, known_plant_names, medlea_data)
cat(result)

