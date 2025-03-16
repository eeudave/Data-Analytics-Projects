# Spotify Popularity Analisis

<img src="Spotify-Analysis\visualizations/preview_spotify.png" alt="Dashboard Preview" width="500"/>
<img src="Spotify-Analysis\visualizations/preview_clusters.png" alt="Dashboard Preview" width="500"/>

### **Description**: An analysis exploring the relationship between the characteristics of the most popular songs across 73 countries. The project aims to identify global and regional trends in music preferences based on audio features such as danceability, energy, and tempo.
### **Data Source**: Song data from 73 countries (csv file).
  - **Enlace**: [Top Spotify Songs in 73 Countries (Daily Updated)](https://www.kaggle.com/datasets/asaniczka/top-spotify-songs-in-73-countries-daily-updated)
### **Machine Learning**: 
  - Utilized the **K-Means clustering algorithm** to group songs based on their audio features.
  - Applied **Principal Component Analysis (PCA)** for dimensionality reduction, enabling effective visualization of song clusters.
### **Tools**: 
  - **Python**: For data analysis and machine learning.
  - **Streamlit**: To create an interactive web application for visualizing the results.
  - **Libraries**: Pandas, NumPy, Scikit-learn, Matplotlib, Seaborn, Plotly, Folium, Json.
### **Results**: 
  - Identified that some songs and artists are popular across multiple countries, indicating global trends.
  - Discovered that certain songs are popular only in specific regions, highlighting cultural preferences.
  - Found that musical characteristics such as **danceability** and **energy** are key drivers of song popularity.
### **Achievements**: 
  - This project was selected as the **<span style="color: green; text-decoration: underline;">Best Project</span>** within the Data Analytics Bootcamp, recognized for its innovative approach and impactful insights.

#### **Data Cleanup Notebook**: [Generates spotify_clean.csv file](notebooks/Cleanup_Spotify.ipynb)

#### **World Map To Highlight Countries**: [custom.geo.json] (https://geojson-maps.kyd.au/)

#### **Spotify Logo and Icon**: (https://developer.spotify.com/documentation/design#using-our-logo)

