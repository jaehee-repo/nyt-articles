{{ config(materialized='table') }}

WITH raw_data AS (
    SELECT * FROM {{ ref('bronze_nyt_articles') }}
)

SELECT 
    _id AS article_id,
    CAST(pub_date AS TIMESTAMP) AS published_at,
    headline,
    section_name,
    news_desk,
    type_of_material,
    word_count,
    source,
    web_url,
    COALESCE(subsection_name, 'Main') AS subsection_name
FROM raw_data
WHERE _id IS NOT NULL 
  AND headline IS NOT NULL
  AND news_desk IS NOT NULL 
  AND LOWER(news_desk) != 'none' 
  AND news_desk != ''
QUALIFY ROW_NUMBER() OVER (PARTITION BY _id ORDER BY pub_date DESC) = 1
