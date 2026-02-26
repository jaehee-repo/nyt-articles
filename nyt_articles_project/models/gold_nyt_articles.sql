{{ config(materialized='table') }}

SELECT 
    news_desk,
    COUNT(article_id) as total_articles,
    AVG(word_count) as avg_word_count,
    MIN(published_at) as earliest_article,
    MAX(published_at) as latest_article
FROM {{ ref('silver_nyt_articles') }}
GROUP BY 1
HAVING total_articles > 10  -- Filter out noise
ORDER BY avg_word_count DESC
