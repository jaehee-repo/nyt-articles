# ELT pipelines with New York Times (NYT) Articles dataset

## Background

This project demonstrates a core architectural shift I implemented in a previous role: transitioning from an ETL to an ELT framework. To respect the NDA from my previous workplace, I have applied these same principles to the public New York Times Articles dataset.

Previously, workflows relied on extracting data from Snowflake for transformation via PySpark before re-uploading. By shifting to an ELT approach—leveraging Snowflake’s native compute—I reduced query times from over 60 minutes to under 10 seconds. 

Given that Snowflake does not have a permanent free tier and due to the lack of access to the datasets used at work, I use the following tech stack:

* `DuckDB` (instead of Snowflake)
* `dbt`
* `SQL` and `Python`
* Medallion architecture (Bronze/Silver/Gold)
  
The dataset is drawn from the following Kaggle website: https://www.kaggle.com/datasets/aryansingh0909/nyt-articles-21m-2000-present/data

Also, data orchestration tools like Dagster are not used in this demonstration, as the project is designed to be orchestration ready. However, upon request, I can demonstrate the use of modern orchestration tools to streamline the development of complex data pipelines.

## Getting Started

To set up the following project:

1. Install the required dependencies

```
pip install duckdb dbt-core dbt-duckdb pandas matplotlib
```

2. Set up the dbt project

```
dbt init nyt_articles_project
```

and choose `duckdb` as the database.

3. Create a `profiles.yml` under the project folder
4. Ensure that the CSV file (`nyt-metadata.csv`) is downloaded
5. Create the medallion models by creating three sql files
* `models/bronze_nyt_articles.sql` : stores raw data with minimal schema enforcement
* `models/silver_nyt_articles.sql` : stores cleaned data including data type casting, deduplication, and categorical standardization
* `models/gold_nyt_articles.sql` : stores aggregated data for reporting

6. Create `models/schema.yml`, which is used to check whether the tables conform to the specific schema we define

7. Install dependencies listed in `packages.yml`

```
dbt deps
```
 
8. Run the dbt ELT pipeline to populate database accordingly

```
dbt run --profiles-dir .
```

9. Test against the schema

```
dbt test --profiles-dir .
```

## Extra: querying and analyzing using silver and gold layers with Python

1. Make a connection

```
import duckdb
con = duckdb.connect('nyt.duckdb')
```

2. Query the silver layer and extract useful statistics

```
trend_query = """
SELECT 
    date_trunc('month', published_at) as month,
    count(*) as article_count
FROM silver_nyt_articles
GROUP BY 1
ORDER BY 1
"""

df_trend = con.execute(trend_query).df()
df_trend.plot(x='month', y='article_count', title='NYT Article Volume Over Time')
```

3. Query over aggregated data using the gold layer

```
query = """
SELECT 
    news_desk, 
    total_articles, 
    round(avg_word_count, 2) as avg_words
FROM gold_nyt_articles
ORDER BY total_articles DESC
LIMIT 10
"""

df_stats = con.execute(query).df()
display(df_stats)
```

4. Close the connection

```
try:
    con.close()
except:
    print("No active connection found.")
```
