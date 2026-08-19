-- IPL Data Analysis

CREATE DATABASE IPL_Analysis;

USE IPL_Analysis;

CREATE TABLE matches (
	id BIGINT ,
	season VARCHAR(10),
	city VARCHAR(15),
	date DATE,
	match_type VARCHAR(20),
	player_of_match VARCHAR(20),
	venue VARCHAR(75),
	team1 VARCHAR(30),
	team2 VARCHAR(30),
	toss_winner VARCHAR(30),
	toss_decision VARCHAR(10),
	winner VARCHAR(30),
	result VARCHAR(10),
	result_margin INT,
	target_runs INT,
	target_overs INT,
	super_over VARCHAR(5),
	umpire1 VARCHAR(30),
	umpire2 VARCHAR(30)
);

SELECT * FROM matches;

CREATE TABLE deliveries (
    match_id INT,
    inning INT,
    batting_team VARCHAR(50),
    bowling_team VARCHAR(50),
    overs INT,
    ball INT,
    batter VARCHAR(50),
    bowler VARCHAR(50),
    non_striker VARCHAR(50),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    extras_type VARCHAR(30),
    is_wicket INT,
    player_dismissed VARCHAR(50),
    dismissal_kind VARCHAR(50),
    fielder VARCHAR(50)
);
SELECT * FROM deliveries;

SELECT count(*) FROM deliveries;

-- Q1: Top 5 successful teams by wins
SELECT winner AS team,
       COUNT(*) AS total_wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY total_wins DESC LIMIT 5;

-- Q2: Does winning toss help win the match?
SELECT 
	COUNT(*) AS Total_matches,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS toss_winner_won,
  ROUND(100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM matches
WHERE winner IS NOT NULL;

-- Q3: Field first or bat first — which wins more?
SELECT toss_decision,
       COUNT(*) AS times_chosen,
       SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS times_won,
       ROUND(100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct
FROM matches
WHERE winner IS NOT NULL
GROUP BY toss_decision;

-- Q4: Top 10 run scorers of all time
SELECT batter,
       SUM(batsman_runs) AS total_runs,
       COUNT(DISTINCT match_id) AS matches_played,
       ROUND(AVG(batsman_runs), 2) AS avg_runs_per_ball
FROM deliveries
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;

-- Q5: Top 10 wicket takers of all time
SELECT bowler,
       COUNT(*) AS total_wickets,
       COUNT(DISTINCT match_id) AS matches_bowled
FROM deliveries
WHERE is_wicket = 1
  AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 10;

-- Q6: Most Player of the Match awards
SELECT player_of_match,
       COUNT(*) AS awards
FROM matches
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY awards DESC
LIMIT 10;

-- Q7: Most matches hosted by venue
SELECT venue, city, COUNT(*) AS matches_hosted
FROM matches
GROUP BY venue, city
ORDER BY matches_hosted DESC
LIMIT 10;

-- Q8: Season-wise total runs scored (batting trends over years)
SELECT m.season,
       SUM(d.total_runs) AS total_runs,
       COUNT(DISTINCT m.id) AS total_matches,
       ROUND(AVG(d.total_runs), 2) AS avg_runs_per_ball
FROM matches m
JOIN deliveries d ON m.id = d.match_id
GROUP BY m.season
ORDER BY m.season;

-- Q9: Best bowling economy (min 100 overs bowled)
SELECT bowler,
       SUM(total_runs) AS runs_given,
       COUNT(*) / 6 AS overs_bowled,
       ROUND(SUM(total_runs) * 6.0 / COUNT(*), 2) AS economy
FROM deliveries
GROUP BY bowler
HAVING COUNT(*) >= 600  -- 100 overs = 600 balls
ORDER BY economy ASC
LIMIT 10;

-- Q10: Highest team totals in a single innings
SELECT match_id, batting_team, inning,
       SUM(total_runs) AS team_total
FROM deliveries
GROUP BY match_id, batting_team, inning
ORDER BY team_total DESC
LIMIT 10;
