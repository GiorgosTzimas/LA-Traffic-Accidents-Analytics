# Traffic Accident Analysis

The project was developed as part of academic coursework for the course *Business Data Processing and Business Intelligence* (MSc. in Business Administration and Data Science).

The goal is to analyze traffic accident patterns in Los Angeles and identify how factors such as time, weather, and road infrastructure relate to accident frequency and severity.

# **Link**
View the LA Traffic Accident Dashboard <a href="https://public.tableau.com/app/profile/giorgos.tzimas7837/viz/LosAngelesTrafficAccidentsDashboard/DashboardMain" style="text-decoration: underline;">**here**</a>

## Project Background

Traffic accidents represent a major public safety issue. Understanding when and under which conditions accidents occur most frequently and severely is important for effective traffic management.

This project focuses on Los Angeles and examines:

- Temporal patterns  
- Environmental conditions  
- Road infrastructure features  

The objective is to support data-driven insights that can help improve traffic safety and resource allocation.


## Dataset

The dataset used in this project can be found <a href="https://www.kaggle.com/datasets/sobhanmoosavi/us-accidents" style="text-decoration: underline;">**here**</a>

- Source: Kaggle  
- Initial Size: ~7.7 million rows x 46 columns
- Size (processed): 156,491 rows, 27 columns  

**Features include:**
- Numerical variables such as severity, temperature, humidity, wind speed, precipitation
- Categorical variables such as weather, road features, location  
- Temporal variables such as date and time  

The dataset was cleaned, transformed, and structured for analysis.



The project has the following analytical workflow:

- Data filtering and selection of relevant variables  
- Exploratory data analysis
- Data standardization and handling of missing values  
- Feature transformation and grouping of similar conditions  
- Data modeling using a star schema  
- Dashboard development for visualization and analysis


## Dashboard Overview





## Results

- **December** shows the highest number of accidents (**15,538**), while **July** has the lowest (**10,349**)  
- Months from March to August consistently show above-average severity, with **July** having the **highest average severity** (~2.3 out of 4)  
- The highest accident **frequency** occurs between **4:00 AM** and **8:00 AM**, although severity during these hours is **below average**  
- **Higher severity** incidents are observed during hours with **lower** accident frequency  
- **Cloudy**, **fog** or **mist** conditions are associated with **higher** average severity compared to clear conditions  
- **Most accidents** occur during **clear** conditions and daylight, but these are generally **less** severe  
- Road segments with **exit** features have the **highest** accident frequency, while combinations of exit, railway, and station features are associated with the **highest** severity  
- The dashboard enables interactive exploration of these spatial, temporal, environmental, and infrastructural patterns


## Limitations

- The dataset includes only reported accidents  
- Some missing values may affect analysis quality  
- Results are limited to Los Angeles and may not generalize to other regions  
- Findings are based on descriptive analysis and visual exploration


## Practical Implications

- Helps understand patterns behind traffic accidents  
- Supports decision-making in road safety  
- Provides insights for infrastructure and policy improvements  
- Can assist in risk assessment and prevention strategies  

## Notes

This project focuses on:

- Identifying patterns in traffic accidents  
- Exploring relationships between key variables  
- Interpreting findings through visual analytics

This project is conducted for academic purposes. The results represent analytical observations and should be considered as insights and suggestions rather than direct recommendations for implementation.

The full methodology and detailed analysis are documented in: `traffic_accident_report.pdf`
