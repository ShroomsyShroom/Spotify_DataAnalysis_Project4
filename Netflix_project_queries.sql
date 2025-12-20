--  Netflix Project Yayyyyy
CREATE TABLE netflix 
(	show_id VARCHAR(10), 
	type VARCHAR(15), 
	title VARCHAR(150), 
	director VARCHAR(250), 
	casts VARCHAR(1000), 
	country VARCHAR(150), 
	date_added VARCHAR(50), 
	release_year INT, 
	rating VARCHAR(10), 
	duration VARCHAR(15), 
	listed_in VARCHAR(100), 
	description VARCHAR(300)
)

--Problem 1: Count the Number of Movies vs TV Shows

SELECT 
type,
COUNT(show_id) as total_content
FROM netflix
GROUP BY type;

--Find the Most Common Rating for Movies and TV Shows

SELECT
type, rating
FROM
(
	SELECT 
		type,
		rating,
		COUNT(show_id),
		RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as Ranking
	FROM netflix
	GROUP BY 1, 2) as t1
	WHERE ranking = 1


-- List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix;

SELECT * FROM netflix
WHERE release_year=2020 AND type='Movie';

--Find the Top 5 Countries with the Most Content on Netflix
SELECT * FROM netflix;
SELECT
	UNNEST(string_to_array(country,',')) AS new_country,
	COUNT(show_id) as content_from_country
FROM netflix
GROUP BY new_country
ORDER BY 2 DESC
LIMIT 5;

--Identify the Longest Movie

WITH movietable AS (
	SELECT 
    	title, 
    	REPLACE(duration, ' min', '')::INT AS duration_minutes
	FROM netflix
	WHERE type = 'Movie'
	AND duration IS NOT NULL
)
SELECT title, duration_minutes
FROM movietable
ORDER BY duration_minutes DESC
LIMIT 1;

--Find Content Added in the Last 5 Years

SELECT 
	title, date_added
FROM netflix
WHERE
	TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--or
WITH cleaned_netflix AS
	(
	SELECT 
		title,
		TO_DATE(date_added,'Month DD, YYYY') AS Usable_date
	FROM netflix
	WHERE date_added IS NOT NULL
	AND date_added != ''
	)
SELECT title, Usable_date
FROM cleaned_netflix
WHERE Usable_date >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY Usable_date DESC;

--Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT * FROM netflix;
SELECT title,director
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

WITH director_netflix AS
	(
	SELECT
		title,
		UNNEST(STRING_to_ARRAY(director,',')) AS director_list
	FROM netflix
	)
SELECT * FROM director_netflix
WHERE director_list = 'Rajiv Chilaka';

--List All TV Shows with More Than 5 Seasons
SELECT 
	title, duration
FROM netflix
WHERE 
type = 'TV Show'
AND
SPLIT_PART(TRIM(duration), ' ', 1)::INT > 5 
ORDER BY duration DESC
;

--or

WITH tv_seasons AS (
    SELECT 
        title,
        duration,
        SPLIT_PART(duration, ' ', 1)::INT AS total_seasons
    FROM netflix
    WHERE type = 'TV Show'
)
SELECT 
    title, 
    duration
FROM tv_seasons
WHERE total_seasons > 5
ORDER BY total_seasons DESC;

--Count the Number of Content Items in Each Genre

SELECT * FROM netflix;

WITH genre_list AS 
	(
	SELECT 
		title,
		UNNEST(string_to_array(listed_in,',')) AS genre_name
	FROM netflix
	)
SELECT genre_name, COUNT(genre_list) AS total_content
FROM genre_list
GROUP BY genre_name;

--Or

SELECT 
	UNNEST(string_to_array(listed_in,',')) AS genre_name,
	COUNT(show_id) AS content_count
FROM netflix
GROUP BY 1;

--Find each year and the average numbers of content release in India on netflix

WITH content_from_india AS
	(
	SELECT 
		release_year,
		COUNT(*) AS no_of_releases
	FROM netflix
	WHERE country LIKE '%India%'
	GROUP BY release_year
	)
SELECT 
	release_year,
	no_of_releases,
	ROUND(AVG(no_of_releases) OVER(), 2) AS overall_avg
FROM content_from_india

--List All Movies that are Documentaries

SELECT * FROM netflix;
SELECT *
FROM netflix
WHERE listed_in ILIKE '%Documentaries%'

--Find All Content Without a Director

SELECT * FROM netflix;
SELECT 
	*
FROM netflix
WHERE director IS NULL;

--Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * FROM netflix;
SELECT 
*
FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 
ORDER BY release_year;

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT * FROM netflix;

SELECT 
	UNNEST(String_to_array(casts,',')) AS actor_name,
	COUNT(*) AS Total_movies
FROM netflix
WHERE
country LIKE '%india%'
AND
type='Movie'
GROUP BY actor_name
ORDER BY total_movies DESC
LIMIT 10;

--ORRRRR

WITH actors_list AS
	(
	SELECT 
		UNNEST(string_to_array(casts,',')) AS actor_name,
		title,
		type
	FROM netflix
	WHERE country ILIKE '%India%'
	)
SELECT
	actor_name,
	COUNT(*) AS total_movies
FROM actors_list
WHERE type = 'Movie'
GROUP BY actor_name
ORDER BY total_movies DESC
LIMIT 10;

/*Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords. 
Label content w such words as bad and content w/o such words as Good. Count each items falling into these categories.*/

SELECT * FROM netflix;

WITH content_categorizer 
AS
(
SELECT 
*,
	CASE
	WHEN 
		description ILIKE '%Kill%' OR description ILIKE '%Violence%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM content_categorizer
GROUP BY 1
