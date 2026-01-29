use netflix


SELECT
    date_added,
    TRY_CONVERT(date, date_added) AS clean_date
FROM netflix;

--1. Count the number of Movies vs TV Shows

select 
     type,count(*) total 
from netflix 
group by type;

--2. Find the most common rating for movies and TV shows

with cte as (
select 
      type,rating,count(*) rating_count
from netflix 
group by type,rating
),
cte1 as (
select type,rating,rating_count,rank()over(partition by type order by rating_count desc) rk
from cte
)
select type,rating frequent_rating,rating_count from cte1 where rk=1

--3. List all movies released in a specific year (e.g., 2020)

select * from netflix where type='movie' and year(date_added)='2020'

--4. Find the top 5 countries with the most content on Netflix

select 
      top 5 country,count(*) total_content 
from netflix 
group by country 
order by total_content desc

select top 5 * from (
select 
       country,count(*) total_content 
from netflix 
group by country )t
order by total_content desc


--5. Identify the longest movie

SELECT top 1  *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;

--6. Find content added in the last 5 years

select *
from netflix
where cast(date_added as date) between '2017-01-01' and '2021-12-31'

select 
      * 
from netflix 
where 
     cast(date_added as date)>=
	 dateadd(
	        year,
			-5,
			(select max(cast(date_added as date)) from netflix)
);

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select 
     type,count(*) total_list
from netflix 
where director='rajiv chilaka' 
group by type


--8. List all TV shows with more than 5 seasons

select 
      * 
from netflix 
where type='tv show' and duration >='5seasons'

--9. Count the number of content items in each genre

select 
      listed_in,count(*) total_items
from netflix 
group by listed_in

--10.Find each year and the average numbers of content release in India on netflix
--return top 5 year with highest avg content release. 

WITH yearly_content AS (
    SELECT
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country LIKE '%India%'
    GROUP BY release_year
)
SELECT top 5
    release_year,
    total_content,
    AVG(total_content * 1.0) OVER () AS avg_content_per_year
FROM yearly_content
ORDER BY release_year desc;

--11. List all movies that are documentaries

select * 
from netflix 
where listed_in like '%documentaries' 

--12. Find All Content Without a Director

select * from netflix where director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select 
     type,cast,count(*) total
from netflix 
where type='movie' 
  and cast like '%salman khan%' 
  and release_year>=(select max(release_year)-10 from netflix)
group by type,cast

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

sELECT
    LTRIM(RTRIM(value)) AS actor,
    COUNT(*) AS movie_count
FROM netflix
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE type = 'Movie'
  AND country LIKE '%India%'
  AND cast IS NOT NULL
GROUP BY LTRIM(RTRIM(value))
ORDER BY movie_count DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

select case 
           when description like '%kill%'
		   or description like '%violence%'
		   then 'bad'
		   else 'good'
		   end as category,
	count(*) total_count
from netflix
where description is not null
group by case 
           when description like '%kill%'
		   or description like '%violence%'
		   then 'bad'
		   else 'good'
		   end;
           
