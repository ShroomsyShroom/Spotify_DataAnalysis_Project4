# Spotify_DataAnalysis_Project4
--SPOTIFY project--
1. Create a database in SQL name it wtv you want
2. Create a table in this database.
Code: 
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

3. Upon creating the table import the data. If you're getting errors such as:
--delimeter based error change it from sql itself while importing
--Fix the data types or limits based on the datasets

4. Now lets perform some easy operations on the dataset i.e EDA

Problem 1. Retrieve the names of all tracks that have more than 1 billion streams.
Code:

--Retrieve the names of all tracks that have more than 1 billion streams.
--SELECT * FROM spotify;
SELECT track,stream FROM spotify WHERE
stream >  1000000000;

Problem 2. List all albums along with their respective artists.
Code:

--List all albums along with their respective artists.
SELECT DISTINCT album, artist
FROM spotify;

Problem 3. Get the total number of comments for tracks where licensed = TRUE.
Code:

--Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) as total_comments 
FROM spotify
WHERE licensed = 'true';

Problem 4. Find all tracks that belong to the album type single
Code:

--Find all tracks that belong to the album type single
SELECT track FROM spotify
WHERE album_type LIKE 'single';

Problem 5. Count the total number of tracks by each artist.
Code:

--Count the total number of tracks by each artist.
SELECT 
	artist, 
	COUNT(track) AS total_tracks
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
;

5. Now that we're done with EASY EDA exercises;-; Lets now move to some intermediate ones.

Problem 6. Calculate the average danceability of tracks in each album.
Code:

--Calculate the average danceability of tracks in each album.

SELECT album, AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1;

Problem 7. Find the top 5 tracks with the highest energy values.
Code:

--Find the top 5 tracks with the highest energy values.
Code:

SELECT * FROM spotify;
SELECT track, MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2
LIMIT 5;


Problem 8. List all tracks along with their views and likes where official_video = TRUE.
Code:

--List all tracks along with their views and likes where official_video = TRUE.

SELECT * FROM spotify;
SELECT track, views, likes
FROM spotify
WHERE official_video = 'true';

Problem 9. For each album, calculate the total views of all associated tracks.
Code:

--For each album, calculate the total views of all associated tracks.

SELECT * FROM spotify;
SELECT 
	album,
	track,
	SUM(views) as Total_views
FROM spotify
GROUP BY 1, 2;

Problem 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
Code:
--CTE method

WITH platform_streams AS 
	(
	SELECT
		track,
		SUM(CASE WHEN most_played_on ILIKE 'Spotify' THEN stream ELSE 0 END) AS spotify_streams,
		SUM(CASE WHEN most_played_on ILIKE 'Youtube' THEN stream ELSE 0 END) AS youtube_streams
	FROM spotify
	GROUP BY track
	)
SELECT track FROM platform_streams
WHERE spotify_streams > youtube_streams;

--OR (using the aggregate function in HAVING clauses AND CASE function in the SUM to make it conditional)

SELECT 
	track
FROM spotify
GROUP BY track
HAVING 
	SUM(CASE WHEN most_played_on ILIKE 'Spotify' THEN stream ELSE 0 END) > SUM(CASE WHEN most_played_on ILIKE 'Youtube' THEN stream ELSE 0 END);

--OR(using self joining and creating 2 of same table to extract both youtube and spotify info from each and comparing.)

SELECT s.track 
FROM spotify AS s
INNER JOIN spotify AS y
ON s.track = y.track
WHERE 
	s.most_played_on ILIKE 'spotify'
 	AND
	y.most_played_on ILIKE 'youtube'
	AND
	s.stream > y.stream;

6. Hoof, OKAY we're done w the intermediate ones. Now lets do the SPICY ones. The advanced queries.

Problem 11. Find the top 3 most-viewed tracks for each artist using window functions.
Code:

-- first we find out the track with highest view for each artist we can do it using rank and partition thereby getting ALL the rankings for that artist
--We use DENSE_RANK as an artist may have multiple HIGH ranked songs and it may be same 
--We add this entire rank data into a CTE and extract info outta it using a simple WHERE command


WITH ranking_artist
AS
	(
	SELECT
		artist,
		track,
		SUM(views) as total_views,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS ranking
	FROM spotify
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC
	)
SELECT * FROM ranking_artist
WHERE ranking <=3;

Problem 12. Write a query to find tracks where the liveness score is above the average.
Code:

SELECT 
	* FROM spotify
WHERE liveness > 0.19;

--SELECT AVG(liveness) FROM spotify;

--BUT IF THE DATA IS CHANGED THE FUNCTION BECOMES UN-USABLE so to avoid that we get a SOFT coded function.

SELECT 
	* FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

Problem 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Code:

WITH energy_difference
AS
(
SELECT 
	album,
	MAX(energy) AS max_energy,
	MIN(energy) AS min_energy
FROM spotify
GROUP BY 1
)
SELECT album, (max_energy - min_energy) AS energy_dif
FROM energy_difference;

Problem 14. Find tracks where the energy-to-liveness ratio is greater than 1.2. (ITS NOT EVEN ADVANCED BTW;-;)
Code:

SELECT 
	track,
	energy_liveness
FROM spotify
WHERE energy_liveness > 1.2;

Problem 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
Code:

SELECT 
	track,
	views,
	likes,
	SUM(likes) OVER (ORDER BY views, track) AS cumulative_sum_of_likes
FROM spotify;

7. With that we're done w this project! It was a tad bit easy ngl.
