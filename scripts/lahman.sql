--1. What range of years for baseball games played does the provided database cover?

SELECT MIN(teams.yearid), MAX(teams.yearid)
FROM teams;

--1871	2016

--2.  Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT CONCAT (namefirst, ' ', namelast)
	,	MIN(height)
	,	appearances.g_all
	,	teams.name
FROM people
JOIN appearances
USING (playerid)
JOIN teams
USING (teamid)
GROUP BY namefirst, namelast, teams.name, appearances.g_all
ORDER BY MIN(height)
LIMIT 1;

--"Eddie Gaedel"	43	1	"St. Louis Browns"

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
WITH singular_player AS (
	SELECT DISTINCT playerid
	FROM collegeplaying
	WHERE schoolid = 'vandy'
	)


SELECT  namefirst
	,   namelast
	,	SUM(salary) AS total_salary
FROM singular_player
JOIN people
USING (playerid)
JOIN salaries
USING (playerid)
-- WHERE schoolname LIKE '%Vanderbilt University%'
GROUP BY namefirst, namelast, playerid	
ORDER BY total_salary DESC;

---"David"	"Price"	81851296

--4.  Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT  fielding.pos, SUM(fielding.po),
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = 'P' THEN 'Battery' 
		WHEN pos = 'C' THEN 'Battery'
		END as position
	FROM fielding
	WHERE yearid = '2016'
	GROUP BY  fielding.pos;



-- WITH fielding_types AS (
	SELECT SUM(fielding.po),
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = 'P' THEN 'Battery' 
		WHEN pos = 'C' THEN 'Battery'
		END as position
	FROM fielding
	WHERE yearid = '2016'
	GROUP BY  position

	--41424	"Battery"
-- 58934	"Infield"
-- 29560	"Outfield"
--WHEN pos IN ('SS', '1B',etc) THEN 'infield'

-- SELECT DISTINCT position, SUM(fielding.po) 
-- FROM fielding_types
-- JOIN fielding
-- ON fielding.po = fielding.po
-- GROUP BY position;

--"Battery"	22816766
--"Infield"	45633532
--"Outfield"	11408383

SELECT SUM(fielding.po),
CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = 'P' THEN 'Battery' 
		WHEN pos = 'C' THEN 'Battery'
		END as position
FROM fielding
WHERE yearid = '2016'
GROUP BY position;

41424	"Battery"
58934	"Infield"
29560	"Outfield"
--5.  Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT (yearid / 10) * 10 AS decade
	,	ROUND (SUM (so) * 1.0 / SUM (g), 2) AS avg_strikeouts
	,	ROUND (SUM (hr) * 1.0 / SUM (g), 2) AS hr_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

--1920	2.81	0.40
--1930	3.32	0.55
--1940	3.55	0.52
--1950	4.40	0.84
--1960	5.72	0.82
--1970	5.14	0.75
--1980	5.36	0.81
--1990	6.15	0.96
--2000	6.56	1.07
--2010	7.52	0.98

-- Strikeouts increased per decade.  Homeruns increased in 2000s, which were the steroids era.  

--6.  Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

-- WITH batting AS successful_stolen (
-- 	WHERE SUM (batting.SB + batting.CS)
-- )

SELECT people.nameFirst, people.nameLast, ROUND((batting.SB * 1.0 /(batting.SB + batting.CS) * 100),2) AS percentage
FROM batting
JOIN people
USING (playerID)
WHERE yearid = '2016' AND (batting.SB + batting.CS) >= 20
ORDER BY percentage DESC;

--"Chris"	"Owings"	91.30

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

WITH most_wins AS (
	SELECT yearid, MAX(w) AS most_wins
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016 AND yearid!=1981
	GROUP BY yearid)

SELECT COUNT(CASE WHEN w = most_wins THEN 1 END) AS ws_and_most_wins,
       CONCAT(ROUND(AVG(CASE WHEN w = most_wins THEN 1 ELSE 0 END) * 100, 2)::text,'','%') AS pct_ws_most_wins
FROM most_wins INNER JOIN teams USING (yearid)
WHERE wswin = 'Y';

SELECT name,yearid,MAX(w)
FROM teams
WHERE wswin = 'N' AND yearid BETWEEN 1970 AND 2016
GROUP BY name,yearid
ORDER BY MAX(w) DESC;

--------------------Smallest win but with world series win to exclude the problem year---------------
SELECT name,yearid,MIN(w)
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
GROUP BY name,yearid
ORDER BY MIN(w);

--looks like the problem year is 1981

---------Final Query -----------
WITH most_wins AS (
	SELECT yearid, MAX(w) AS most_wins
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016 AND yearid!=1981
	GROUP BY yearid)

SELECT COUNT(CASE WHEN w = most_wins THEN 1 END) AS ws_and_most_wins,
      CONCAT(ROUND(AVG(CASE WHEN w = most_wins THEN 1 ELSE 0 END) * 100, 2)::text,'','%') AS pct_ws_most_wins
FROM most_wins INNER JOIN teams USING (yearid)
 WHERE wswin = 'Y';

--8.  Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT park_name, team, SUM(attendance)/games AS AVG
FROM parks
JOIN homegames
USING (park)
WHERE year = 2016 AND games >= 10
GROUP BY park_name, team, games
ORDER by AVG DESC;

--"Dodger Stadium"	"LAN"	45719
--Busch Stadium III"	"SLN"	42524
--"Rogers Centre"	"TOR"	41877
--"AT&T Park"	"SFN"	41546
--"Wrigley Field"	"CHN"	39906

SELECT park_name, team, SUM(attendance)/games AS AVG
FROM parks
JOIN homegames
USING (park)
WHERE year = 2016 AND games >= 10
GROUP BY park_name, team, games
ORDER by AVG;

--"Tropicana Field"	"TBA"	15878
--"Oakland-Alameda County Coliseum"	"OAK"	18784
--"Progressive Field"	"CLE"	19650
--"Marlins Park"	"MIA"	21405
--"U.S. Cellular Field"	"CHA"	21559

(SELECT
	park_name,
	teams.name,
    homegames.attendance/games AS avg
FROM parks
INNER JOIN homegames
USING (park)
INNER JOIN teams
ON homegames.year = teams.yearid AND homegames.team = teams.teamid
WHERE year = 2016 AND games >=10
ORDER BY avg DESC
LIMIT 5
)
UNION
(SELECT
	park_name,
	teams.name,
    homegames.attendance/games AS avg
FROM parks
INNER JOIN homegames
USING (park)
INNER JOIN teams
ON homegames.year = teams.yearid AND homegames.team = teams.teamid
WHERE year = 2016 AND games >=10
ORDER BY avg
LIMIT 5
)

--9.  Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- SELECT CONCAT (p.namefirst, ' ', p.namelast) AS full_name
-- 	,	t.name AS team_name
-- 	,	am.awardid
-- 	,	am.lgid
-- 	,	am.yearid
-- FROM awardsmanagers am
-- 	JOIN people p USING (playerid)
-- 	JOIN managers m USING (playerid, yearid, lgid)
-- 	JOIN teams t USING (yearid, teamid, lgid)
-- WHERE (am.playerid, am.awardid) IN (
-- 							SELECT playerid
-- 								, awardid
-- 							FROM awardsmanagers
-- 							WHERE awardid LIKE 'TSN Manager%'
-- 							AND lgid IN ('NL','AL')
-- 					GROUP BY playerid,awardid
-- 					HAVING COUNT(DISTINCT lgid) = 2
-- )	
-- ORDER BY 1, 5;


-- AND lgid = 'AL' AND lgid = 'NL'

SELECT CONCAT(p.namefirst,' ',p.namelast) AS full_name ,
	    t.name AS team_name
	  , am.awardid
	  , am.lgid
	  , am.yearid
FROM awardsmanagers am 
		INNER JOIN people p USING (playerid)
		INNER JOIN managers m USING (playerid,yearid,lgid)
		INNER JOIN teams t USING (yearid,teamid,lgid)
WHERE (am.playerid,am.awardid) IN (
					 SELECT playerid
					 	  , awardid
					 FROM awardsmanagers 
					 WHERE awardid LIKE 'TSN Manager%'
							AND lgid IN ('NL','AL')
					GROUP BY playerid,awardid
					HAVING COUNT(DISTINCT lgid) = 2
								)
ORDER BY 1,5 ;

--10.  Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

-- Sunitha

WITH BattingPre2016 AS  (
	SELECT * 
	FROM (
	SELECT DISTINCT(playerid)
		   , SUM(hr) hrPre2016
		   , RANK() OVER (PARTITION BY playerid ORDER BY SUM(hr) DESC) hr_rank
	FROM batting 
	WHERE yearid< 2016 
	GROUP BY playerid, yearid
	HAVING SUM(hr) >= 0 
	) WHERE hr_rank = 1
),
 Batting2016 AS (
	SELECT 
		   DISTINCT(b.playerid)
		   ,CONCAT(p.namefirst,' ',p.namelast) AS full_name
		  ,SUM( b.hr) hr2016
	FROM  batting b
	INNER JOIN people p USING (playerid)
	WHERE  b.yearid = 2016 AND (b.yearid-EXTRACT(YEAR FROM p.debut::date) >= 9) AND b.hr > 0
	GROUP BY  playerid,p.namefirst,p.namelast
	)

 SELECT * 
 FROM  BattingPre2016 
  INNER JOIN Batting2016 
 ON  (BattingPre2016.playerid = Batting2016.playerid AND Batting2016.hr2016 >= BattingPre2016.hrPre2016 )
 ORDER BY full_name ;