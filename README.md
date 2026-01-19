<h1>Netflix Data Analytics & Content Strategy Project</h1>

<p>This project involves a comprehensive exploratory data analysis (EDA) of Netflix’s global library. By leveraging PostgreSQL, we transform raw metadata into actionable business insights. The analysis covers content distribution, geographic dominance, talent tracking, and automated content categorization using advanced SQL techniques such as Common Table Expressions (CTEs), Window Functions, and String Manipulation.</p>

<h2>1. Database Schema and Initialization</h2> <p>The first stage requires establishing a robust table structure in PostgreSQL to house the Netflix dataset. The schema is designed to handle varying data lengths, particularly for the <code>casts</code> and <code>director</code> columns which often contain multi-valued strings.</p>

<pre> -- Initialize Netflix Project Schema CREATE TABLE netflix ( show_id VARCHAR(10), type VARCHAR(15), title VARCHAR(150), director VARCHAR(250), casts VARCHAR(1000), country VARCHAR(150), date_added VARCHAR(50), release_year INT, rating VARCHAR(10), duration VARCHAR(15), listed_in VARCHAR(100), description VARCHAR(300) );

-- Data Verification SELECT * FROM netflix; </pre>

<h2>2. Core Business Problems & Analytical Solutions</h2>

<p>The following 15 business problems represent critical questions a data analyst would answer to help stakeholders understand content performance and regional trends.</p>

<h3>Q1. Quantitative Analysis: Movies vs. TV Shows</h3> <p>Understanding the volume of each content format is essential for inventory management.</p> <pre> SELECT type, COUNT(show_id) as total_content FROM netflix GROUP BY type; </pre>

<h3>Q2. Most Common Ratings per Content Type</h3> <p>By using the <code>RANK()</code> window function, we identify which maturity rating is most frequently applied to Movies and TV Shows respectively.</p> <pre> SELECT type, rating FROM ( SELECT type, rating, COUNT(show_id), RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as Ranking FROM netflix GROUP BY 1, 2 ) as t1 WHERE ranking = 1; </pre>

<h3>Q3. Target Filtering: Content Released in 2020</h3> <pre> SELECT * FROM netflix WHERE release_year = 2020 AND type = 'Movie'; </pre>

<h3>Q4. Regional Dominance: Top 5 Content-Producing Countries</h3> <p>Since the country column is often a comma-separated string, we use <code>string_to_array</code> and <code>UNNEST</code> to isolate each nation.</p> <pre> SELECT UNNEST(string_to_array(country, ',')) AS new_country, COUNT(show_id) as content_from_country FROM netflix GROUP BY new_country ORDER BY 2 DESC LIMIT 5; </pre>

<h3>Q5. Duration Metrics: Identifying the Longest Feature Film</h3> <p>We use <code>REPLACE</code> and type casting (<code>::INT</code>) to convert the "min" string into a numeric value for accurate sorting.</p> <pre> WITH movietable AS ( SELECT title, REPLACE(duration, ' min', '')::INT AS duration_minutes FROM netflix WHERE type = 'Movie' AND duration IS NOT NULL ) SELECT title, duration_minutes FROM movietable ORDER BY duration_minutes DESC LIMIT 1; </pre>

<h3>Q6. Growth Trends: Content Added in the Last 5 Years</h3> <p>The <code>TO_DATE</code> function transforms raw text into a standard date format to enable chronological filtering.</p> <pre> SELECT title, date_added FROM netflix WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'; </pre>

<h3>Q7. Directory Search: Portfolio of 'Rajiv Chilaka'</h3> <p>Using the <code>ILIKE</code> operator allows for case-insensitive pattern matching across the director list.</p> <pre> SELECT title, director FROM netflix WHERE director ILIKE '%Rajiv Chilaka%'; </pre>

<h3>Q8. Episodic Depth: TV Shows Exceeding 5 Seasons</h3> <p>We utilize <code>SPLIT_PART</code> to isolate the number of seasons from the "Season" suffix for numerical comparison.</p> <pre> SELECT title, duration FROM netflix WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric > 5; </pre>

<h3>Q9. Categorical Analysis: Content Count per Genre</h3> <pre> SELECT UNNEST(string_to_array(listed_in, ',')) AS genre_name, COUNT(show_id) AS content_count FROM netflix GROUP BY 1; </pre>

<h3>Q10. Regional Focus: Yearly Indian Content Release Trends</h3> <p>This reveals Netflix's acquisition and production trajectory in the Indian market.</p> <pre> SELECT release_year, COUNT(*) as total_releases FROM netflix WHERE country LIKE '%India%' GROUP BY release_year ORDER BY release_year DESC; </pre>

<h3>Q11. Specific Interest: Listing Documentaries</h3> <pre> SELECT * FROM netflix WHERE listed_in ILIKE '%Documentaries%'; </pre>

<h3>Q12. Data Quality Audit: Content Missing Director Information</h3> <pre> SELECT * FROM netflix WHERE director IS NULL; </pre>

<h3>Q13. Talent Analysis: Recent Portfolio of 'Salman Khan'</h3> <p>Filtering by both a specific cast member and a 10-year rolling window from the current date.</p> <pre> SELECT * FROM netflix WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10; </pre>

<h3>Q14. Prolific Actors: Top 10 Indian Movie Cast Members</h3> <p>Expansion of the comma-separated cast lists allows us to identify the most recurring actors in Indian cinema on the platform.</p> <pre> SELECT UNNEST(string_to_array(casts, ',')) AS actor_name, COUNT(*) AS Total_movies FROM netflix WHERE country LIKE '%India%' AND type = 'Movie' GROUP BY actor_name ORDER BY total_movies DESC LIMIT 10; </pre>

<h3>Q15. Automated Content Categorization (Sentiment/Theme Labeling)</h3> <p>By analyzing descriptions for specific keywords like "Kill" and "Violence," we use <code>CASE</code> statements to label content, aiding in internal auditing or parent-control classifications.</p> <pre> WITH content_categorizer AS ( SELECT , CASE WHEN description ILIKE '%Kill%' OR description ILIKE '%Violence%' THEN 'Bad_Content' ELSE 'Good_Content' END category FROM netflix ) SELECT category, COUNT() AS total_content FROM content_categorizer GROUP BY 1; </pre>

<h2>3. Project Conclusion</h2> <p>The insights generated through these SQL queries provide a multi-dimensional view of Netflix’s business operations. From identifying the most prolific actors to analyzing seasonal release trends, these data-driven outputs empower stakeholders to make informed decisions regarding licensing, original content production, and regional marketing strategies.</p>
