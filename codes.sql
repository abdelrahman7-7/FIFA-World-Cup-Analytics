/*=========================================================
View 1: Player Tournament History
=========================================================*/

CREATE VIEW player_tournament_history AS
SELECT DISTINCT
    p.player_id,
    p.family_name AS player_name,
    pa.team_name,
    t.tournament_name,
    t.year
FROM players p
JOIN player_appearances pa
    ON p.player_id = pa.player_id
JOIN tournaments t
    ON pa.tournament_id = t.tournament_id;
SELECT * FROM player_tournament_history ;

	/*=========================================================
View 2: Winners by Country
=========================================================*/

CREATE VIEW winners_by_country AS
SELECT
    tournament_id,
    tournament_name,
    year,
    winner AS country
FROM tournaments;
SELECT * FROM winners_by_country;


/*=========================================================
View 3: Red Card Frequency by Referee
=========================================================*/

CREATE VIEW red_card_frequency_by_referee AS
SELECT
    ra.referee_id,
    CONCAT(ra.given_name, ' ', ra.family_name) AS referee_name,
    SUM(b.red_card) AS total_red_cards
FROM referee_appearances ra
JOIN bookings b
    ON ra.match_date = b.match_date
GROUP BY
    ra.referee_id,
    ra.given_name,
    ra.family_name
ORDER BY total_red_cards DESC;

SELECT * FROM red_card_frequency_by_referee;


SELECT
    winner AS country,
    COUNT(*) AS total_titles
FROM tournaments
GROUP BY winner
ORDER BY total_titles DESC;


/*=========================================================
 Number of Matches in Each Tournament
=========================================================*/

SELECT
    t.tournament_name,
    t.year,
    COUNT(m.match_id) AS total_matches
FROM tournaments t
JOIN matches m
ON t.tournament_id = m.tournament_id
GROUP BY
    t.tournament_name,
    t.year
ORDER BY t.year;



/*=========================================================
 Players with the Most Match Appearances
=========================================================*/

SELECT
    p.family_name AS player_name,
    COUNT(pa.match_id) AS appearances
FROM players p
JOIN player_appearances pa
ON p.player_id = pa.player_id
GROUP BY
    p.family_name
ORDER BY appearances DESC
LIMIT 10;


/*=========================================================
 Teams with the Most Tournament Appearances
=========================================================*/

SELECT
    team_name,
    COUNT(DISTINCT tournament_id) AS tournaments_played
FROM team_appearances
GROUP BY team_name
ORDER BY tournaments_played DESC;


/*=========================================================
 Referees Who Officiated the Most Matches
=========================================================*/

SELECT
    ra.family_name AS referee_name,
    COUNT(ra.match_id) AS matches_officiated
FROM referee_appearances ra
GROUP BY
    ra.family_name
ORDER BY matches_officiated DESC;



/*=========================================================
 Total Yellow Cards in Each Tournament
=========================================================*/

SELECT
    t.tournament_name,
    COUNT(*) AS yellow_cards
FROM bookings b
JOIN matches m
ON b.match_id = m.match_id
JOIN tournaments t
ON m.tournament_id = t.tournament_id
WHERE b.yellow_card = 1
GROUP BY
    t.tournament_name
ORDER BY yellow_cards DESC;


/*=========================================================
 Total Goals in Each Tournament
=========================================================*/

SELECT
    t.tournament_name,
    COUNT(g.goal_id) AS total_goals
FROM tournaments t
JOIN matches m
ON t.tournament_id = m.tournament_id
JOIN goals g
ON m.match_id = g.match_id
GROUP BY
    t.tournament_name
ORDER BY total_goals DESC;



/*=========================================================
 Stadiums Hosting the Most Matches
=========================================================*/

SELECT
    s.stadium_name,
    COUNT(m.match_id) AS total_matches
FROM stadiums s
JOIN matches m
ON s.stadium_id = m.stadium_id
GROUP BY
    s.stadium_name
ORDER BY total_matches DESC;



/*=========================================================
Insight 9: Players Winning the Most Awards
=========================================================*/

SELECT
    p.family_name AS player_name,
    COUNT(aw.award_id) AS awards_won
FROM players p
JOIN award_winners aw
ON p.player_id = aw.player_id
GROUP BY
    p.family_name
ORDER BY awards_won DESC;


/*=========================================================
 Top Players by Goals per Match
=========================================================*/

SELECT
    p.family_name AS player_name,
    COUNT(DISTINCT g.goal_id) AS total_goals,
    COUNT(DISTINCT pa.match_id) AS matches_played,
    ROUND(
        COUNT(DISTINCT g.goal_id)::NUMERIC /
        COUNT(DISTINCT pa.match_id), 2
    ) AS goals_per_match
FROM players p
JOIN player_appearances pa
    ON p.player_id = pa.player_id
LEFT JOIN goals g
    ON p.player_id = g.player_id
GROUP BY
    p.player_id,
    p.family_name
HAVING COUNT(DISTINCT g.goal_id) >= 5
ORDER BY goals_per_match DESC;



/*=========================================================
 World Cups with the Highest Average Goals per Match
=========================================================*/

SELECT
    t.tournament_name,
    t.year,
    COUNT(DISTINCT m.match_id) AS total_matches,
    COUNT(g.goal_id) AS total_goals,
    ROUND(
        COUNT(g.goal_id)::NUMERIC /
        COUNT(DISTINCT m.match_id),
        2
    ) AS avg_goals_per_match
FROM tournaments t
JOIN matches m
    ON t.tournament_id = m.tournament_id
LEFT JOIN goals g
    ON m.match_id = g.match_id
GROUP BY
    t.tournament_id,
    t.tournament_name,
    t.year
ORDER BY avg_goals_per_match DESC;


