--use oliympic_history

--create database oliympic_history
--chcke the table
SELECT *
FROM athlete_events

SELECT *
FROM noc_regions

--How many Olympics games have been held?
SELECT COUNT(DISTINCT games) total_games_held
FROM athlete_events

--List down all Olympic games held so far
SELECT DISTINCT year,season,city
FROM athlete_events
ORDER BY year

--Mention the total number of nations who participated in each Olympics game and
CREATE TABLE #EmpDetails (year INT, total_distinct_regsion INT, all_season VARCHAR(255))  

INSERT INTO #EmpDetails
SELECT year,COUNT(DISTINCT region) total_distinct_regsion,season
FROM athlete_events a JOIN noc_regions n ON a.NOC = n.NOC
GROUP BY year,season

SELECT year,total_distinct_regsion,all_season 
FROM #EmpDetails
ORDER BY year

--height participated year ?
SELECT TOP 1 year,total_distinct_regsion,all_season
FROM #EmpDetails
ORDER BY total_distinct_regsion DESC

--lowest participated year ?
SELECT TOP 1 year,total_distinct_regsion,all_season
FROM #EmpDetails
ORDER BY total_distinct_regsion

--Which nation has participated in all of the Olympic games?
SELECT region, COUNT(DISTINCT games) total_games
FROM athlete_events a JOIN noc_regions n ON a.NOC = n.NOC
GROUP BY region
Having COUNT(DISTINCT games) = 51

--Identify the sport which was played in all summer Olympics.
WITH CTE_1 AS(
SELECT COUNT(DISTINCT games) total_games,sport 
FROM athlete_events
WHERE season = 'summer'
GROUP BY sport)

SELECT sport,total_games
FROM CTE_1
WHERE total_games = 29

--Which Sports were just played only once in the Olympics?
WITH CTE_2 AS(
SELECT COUNT(DISTINCT games) total_games,sport 
FROM athlete_events
GROUP BY sport) 

SELECT sport,total_games
FROM CTE_2
WHERE total_games = 1

--Fetch the total no of sports played in each Olympic game.
SELECT DISTINCT games,COUNT(DISTINCT sport) total_sport
FROM athlete_events
GROUP BY Games
ORDER BY total_sport DESC

--Fetch details of the oldest athletes to win a gold medal.
SELECT *
FROM (SELECT * ,DENSE_RANK() OVER (ORDER BY age DESC) rnk
     FROM athlete_events 
	 WHERE Medal = 'Gold') total
WHERE rnk = 1 

--Fetch the top 5 athletes who have won the most gold medals.
SELECT name,count(Medal)
FROM athlete_events
WHERE Medal = 'Gold'
GROUP BY name
ORDER BY count(medal) DESC

--fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
SELECT name,count(Medal)
FROM athlete_events
WHERE Medal in ('gold','silver','bronze')
GROUP BY name
ORDER BY count(medal) DESC

--Fetch the top 5 most successful countries in Olympics. Success is defined by no of medals won.
SELECT TOP 5 region, sum(case when medal in ('gold','silver','bronze') THEN 1 ELSE 0 END) no_model
FROM athlete_events a JOIN noc_regions n ON a.NOC = n.NOC
GROUP BY region 
ORDER BY sum(case when medal in ('gold','silver','bronze') THEN 1 ELSE 0 END) DESC

--Identify which country won the most gold, most silver, and most bronze medals in each Olympic game.
WITH CTE_2 AS(
SELECT games,region,sum(CASE WHEN medal = 'gold' THEN 1 ELSE 0 END) no_gold,
       sum(CASE WHEN medal = 'silver' THEN 1 ELSE 0 END) no_silver,
	   sum(CASE WHEN medal = 'bronze' THEN 1 ELSE 0 END) no_bronze
FROM athlete_events a JOIN noc_regions n ON a.NOC = n.NOC
GROUP BY games , region)

SELECT DISTINCT games,
      CONCAT((FIRST_VALUE(region) OVER (PARTITION BY games ORDER BY no_gold DESC)),
	  '-', FIRST_VALUE(no_gold) OVER (PARTITION BY games ORDER BY no_gold DESC)) AS max_gold,
	  CONCAT((FIRST_VALUE(region) OVER (PARTITION BY games ORDER BY no_silver DESC)),
	  '-', FIRST_VALUE(no_silver) OVER (PARTITION BY games ORDER BY no_silver DESC)) AS max_silver,
	  CONCAT((FIRST_VALUE(region) OVER (PARTITION BY games ORDER BY no_bronze DESC)),
	  '-', FIRST_VALUE(no_bronze) OVER (PARTITION BY games ORDER BY no_bronze DESC)) AS max_bronze
FROM  CTE_2
ORDER BY games