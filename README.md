# IPL Data Analysis using SQL

![](ipl.png)

## Overview

This project involves a comprehensive analysis of **Indian Premier League (IPL)** match and ball-by-ball delivery data using SQL. The goal is to extract valuable insights and answer various analytical questions related to team performance, toss decisions, batting, bowling, player awards, venues, season-wise scoring trends, and highest team totals.

The project uses two datasets — **matches** and **deliveries** — which together provide both match-level and ball-by-ball information about IPL matches.

The following README provides a detailed account of the project's objectives, business problems, SQL solutions, findings, and conclusions.

## Objectives

* Identify the most successful IPL teams based on total wins.
* Analyze whether winning the toss increases the probability of winning the match.
* Compare the impact of choosing to bat or field first.
* Identify the top run scorers in IPL history.
* Identify the top wicket takers in IPL history.
* Find players with the most Player of the Match awards.
* Identify venues that have hosted the most IPL matches.
* Analyze season-wise total runs and scoring trends.
* Find bowlers with the best economy rate among those who have bowled at least 100 overs.
* Identify the highest team totals scored in a single innings.

## Dataset

The project uses IPL match-level and ball-by-ball delivery data.

### Datasets Used

* **matches.csv** — Contains information about IPL matches including season, teams, toss decisions, winners, venues, player of the match, and match results.
* **deliveries.csv** — Contains ball-by-ball information including batter, bowler, runs, extras, wickets, and dismissals.

## Schema

### Matches Table

```sql
CREATE TABLE matches (
    id BIGINT,
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
```

### Deliveries Table

```sql
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
```

## Business Problems and Solutions

### 1. Find the Top 5 Successful Teams by Wins

```sql
SELECT winner AS team,
       COUNT(*) AS total_wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY total_wins DESC
LIMIT 5;
```

**Objective:** Identify the five IPL teams with the highest number of match victories.

---

### 2. Does Winning the Toss Help Win the Match?

```sql
SELECT 
    COUNT(*) AS Total_matches,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS toss_winner_won,
    ROUND(
        100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS win_pct
FROM matches
WHERE winner IS NOT NULL;
```

**Objective:** Determine how frequently the team winning the toss also wins the match and calculate the winning percentage.

---

### 3. Field First or Bat First — Which Performs Better?

```sql
SELECT toss_decision,
       COUNT(*) AS times_chosen,
       SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS times_won,
       ROUND(
           100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*),
           2
       ) AS win_pct
FROM matches
WHERE winner IS NOT NULL
GROUP BY toss_decision;
```

**Objective:** Compare the success rate of teams choosing to bat first versus field first after winning the toss.

---

### 4. Find the Top 10 Run Scorers of All Time

```sql
SELECT batter,
       SUM(batsman_runs) AS total_runs,
       COUNT(DISTINCT match_id) AS matches_played,
       ROUND(AVG(batsman_runs), 2) AS avg_runs_per_ball
FROM deliveries
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;
```

**Objective:** Identify the top 10 IPL batters based on total runs scored and analyze their matches played and average runs per ball.

---

### 5. Find the Top 10 Wicket Takers of All Time

```sql
SELECT bowler,
       COUNT(*) AS total_wickets,
       COUNT(DISTINCT match_id) AS matches_bowled
FROM deliveries
WHERE is_wicket = 1
  AND dismissal_kind NOT IN (
      'run out',
      'retired hurt',
      'obstructing the field'
  )
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 10;
```

**Objective:** Identify the top 10 bowlers based on wickets taken while excluding dismissals that are not credited to the bowler.

---

### 6. Find Players with the Most Player of the Match Awards

```sql
SELECT player_of_match,
       COUNT(*) AS awards
FROM matches
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY awards DESC
LIMIT 10;
```

**Objective:** Identify the players who have received the highest number of Player of the Match awards.

---

### 7. Find the Venues that Hosted the Most IPL Matches

```sql
SELECT venue,
       city,
       COUNT(*) AS matches_hosted
FROM matches
GROUP BY venue, city
ORDER BY matches_hosted DESC
LIMIT 10;
```

**Objective:** Identify the top 10 venues that have hosted the highest number of IPL matches.

---

### 8. Analyze Season-wise Total Runs

```sql
SELECT m.season,
       SUM(d.total_runs) AS total_runs,
       COUNT(DISTINCT m.id) AS total_matches,
       ROUND(AVG(d.total_runs), 2) AS avg_runs_per_ball
FROM matches m
JOIN deliveries d
    ON m.id = d.match_id
GROUP BY m.season
ORDER BY m.season;
```

**Objective:** Analyze batting trends across IPL seasons by calculating total runs, total matches, and average runs per ball.

---

### 9. Find the Best Bowling Economy with Minimum 100 Overs

```sql
SELECT bowler,
       SUM(total_runs) AS runs_given,
       COUNT(*) / 6 AS overs_bowled,
       ROUND(SUM(total_runs) * 6.0 / COUNT(*), 2) AS economy
FROM deliveries
GROUP BY bowler
HAVING COUNT(*) >= 600
ORDER BY economy ASC
LIMIT 10;
```

**Objective:** Identify bowlers with the best economy rate among those who have bowled at least 100 overs.

---

### 10. Find the Highest Team Totals in a Single Innings

```sql
SELECT match_id,
       batting_team,
       inning,
       SUM(total_runs) AS team_total
FROM deliveries
GROUP BY match_id, batting_team, inning
ORDER BY team_total DESC
LIMIT 10;
```

**Objective:** Identify the highest team scores recorded in a single IPL innings.

## SQL Concepts Used

This project demonstrates the practical use of several SQL concepts, including:

* `CREATE DATABASE`
* `CREATE TABLE`
* `SELECT`
* `WHERE`
* `GROUP BY`
* `ORDER BY`
* `LIMIT`
* `JOIN`
* `COUNT()`
* `SUM()`
* `AVG()`
* `ROUND()`
* `COUNT(DISTINCT)`
* `CASE WHEN`
* `HAVING`
* Aggregate Functions
* Conditional Aggregation

## Findings and Conclusion

* **Team Performance:** The analysis identifies the most successful IPL teams based on their total number of wins.
* **Toss Impact:** The project evaluates whether winning the toss provides an advantage in winning the match.
* **Toss Decision:** Batting first and fielding first are compared to understand which decision produces better match outcomes.
* **Batting Performance:** The top run scorers are identified using ball-by-ball delivery data.
* **Bowling Performance:** The leading wicket takers and most economical bowlers are analyzed.
* **Player Awards:** The players with the highest number of Player of the Match awards are identified.
* **Venue Analysis:** The analysis highlights venues that have hosted the most IPL matches.
* **Season Trends:** Season-wise run scoring is analyzed to understand changes in batting trends over time.
* **Highest Scores:** The project identifies the highest team totals achieved in individual IPL innings.

This project demonstrates how SQL can be used to analyze real-world sports data and extract meaningful insights from both structured match-level and detailed ball-by-ball datasets.

## Author - Shantanu Khobragade

This project is part of my portfolio, showcasing practical **SQL and Data Analytics skills** essential for data analyst roles.

### Skills Demonstrated

* SQL
* MySQL
* Data Analysis
* Data Cleaning & Exploration
* Relational Database Analysis
* Aggregation & Filtering
* Joins
* Analytical Query Writing

Thank you for checking out this project!
