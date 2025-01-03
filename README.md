# product-combo-identification
This project focuses on analyzing customer purchase patterns through market basket analysis, leveraging the Apriori algorithm. The aim is to uncover relationships between products frequently purchased together, enabling actionable insights for business decision-making. The analysis is performed on an online retail dataset, which contains transactional data including product descriptions, invoice numbers, customer details, and purchase dates.

Key Steps in the Project:
Data Preparation:

The dataset is loaded and examined for missing values, which are visualized and handled effectively.
Irrelevant features such as CustomerID are removed, and categorical variables (e.g., Country) are converted to factors.
Outliers in numerical columns (Quantity, UnitPrice) are identified and addressed using winsorization.
Min-max scaling is applied to normalize numerical features.
Exploratory Data Analysis (EDA):

Missing value proportions are visualized with bar plots.
Correlation analysis is conducted to assess relationships among numerical variables and between numerical and categorical variables, supported by heatmaps and scatter plots.
A summary of the cleaned and processed data is generated to ensure data quality.
Data Transformation:

Transactions are aggregated into item lists per invoice, creating a "basket" format suitable for association rule mining.
The transformed data is saved as a CSV file and imported into the arules package for further analysis.
Association Rule Mining with Apriori:

The Apriori algorithm is applied to extract association rules with varying lengths (2, 3, 4, and 5-item combinations).
Rules are generated based on minimum support (0.006) and confidence (0.1) thresholds.
Insights such as frequently co-purchased items are derived and interpreted.
Visualization of Results:

Item frequency plots visualize the popularity of individual items.
Graphs and grouped plots illustrate association rules, helping to identify strong relationships.
The results are used to explore opportunities for cross-selling, promotions, and product bundling.
