# Medicinal-Plant-Leaf-Classification-Using-XGBoost
## Objective
This project aims to classify medicinal plant leaves into various species based on their morphological features using an XGBoost model. The MedLEA dataset, which includes detailed images and attributes of medicinal plant leaves, is used for this purpose.

## Dataset
The dataset from the MedLEA package comprises images and attributes of 471 medicinal plant leaves across 31 species. Multiple features, including leaf shape, edge type, and other morphological traits characterize each leaf image. Key columns in the dataset include ID, Sinhala_Name (the species name in Sinhala), Family_Name, Scientific_Name, Shape, and Edges.

## Data Exploration
The initial exploration involved inspecting the dataset's structure, dimensions, and summary statistics:

Dimensions: The dataset contains numerous rows and columns with categorical and numerical attributes.
Missing Values: There are no missing values, indicating a complete dataset.
Categorical Variables: Frequency distribution was examined for variables like Family_Name and Scientific_Name.
Data Preprocessing:

Column Removal: Irrelevant columns (ID, Sinhala_Name, Family_Name, Scientific_Name) were removed to focus on features relevant for classification.
Categorical to Numeric Conversion: Categorical variables were converted to numeric format, as required by the XGBoost algorithm.
Feature Matrix: The remaining features were transformed into a matrix suitable for XGBoost, with labels encoded numerically starting from 0.
Visualization:
Visualizations included:

Histograms: The distribution of leaf shapes was plotted using ggplot2 to understand the frequency of each shape.
![image](https://github.com/user-attachments/assets/7a005b9a-bdee-440f-bdc5-3cd919d01ac8)

Word Clouds: A word cloud was generated from the Family_Name column to visualize the most common family names.
Bar Charts: The distribution of leaf shapes and edges was displayed using bar charts, showing the composition by leaf shape and edge type.
Model Training:
An XGBoost model was trained to classify the plant species. The training involved:

Data Preparation: The dataset was converted into an XGBoost-compatible matrix.
Parameters: The model used parameters suitable for multiclass classification (objective = "multi:softmax" and eval_metric = "mlogloss").
Training: The model was trained with 100 boosting rounds to optimize performance.
Prediction Function:
A custom function was created to predict the species of a leaf based on user input. The process involves:

User Input: Collecting feature values from the user.
Data Transformation: Converting user inputs to the same format as the training data.
Prediction: Using the trained XGBoost model to classify the input data and return the predicted species.

## Conclusion
This project demonstrates the application of XGBoost for classifying medicinal plant leaves based on morphological features. By preprocessing the data, training an XGBoost model, and developing a prediction function, the system provides an interactive tool for identifying medicinal plant species. The approach effectively leverages machine learning techniques to handle classification tasks with real-world data, offering insights into plant species identification.
