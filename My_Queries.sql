--Question 1
/* How many female actors are listed in the dataset supplied? */ 
-------SOLUTION-------
SELECT sex, COUNT(*) AS NumOfFemaleActors FROM imdb_actors WHERE imdb_actors.sex = 'F';


--Question 2
/* What is the title of the earliest movie in the dataset? */ 
-------SOLUTION-------
SELECT title AS EarliestMovieTitle, year FROM imdb_movies ORDER BY year LIMIT 1;


--Question 3
/* How many movies have more than 5 directors? */ 
-------SOLUTION-------
SELECT COUNT(MoviesNew) AS NumOfMoviesWithMoreThenFiveDirectors FROM (SELECT movieid AS MoviesNew, COUNT(*) FROM imdb_movies2directors GROUP BY movieid HAVING COUNT(movieid) > 5) AS needed; 


--Question 4
/* Give the title of which movie has the most directors? */ 
-------SOLUTION-------
SELECT Weak.movieid, Strong.title, COUNT(Weak.movieid) AS NumOfDirectors  
FROM  imdb_movies2directors AS Weak, imdb_movies AS Strong
WHERE Strong.movieid = Weak.movieid
GROUP BY Weak.movieid, Strong.title
HAVING COUNT(Weak.movieid) = (SELECT Max(MoviesNew) FROM (SELECT movieid, COUNT(*) AS MoviesNew FROM imdb_movies2directors GROUP BY movieid) AS needed);


--Question 5
/* What is the total running time of all the Sci-Fi movies in the dataset? */ 
-------SOLUTION-------
SELECT DISTINCT SUM(time1) AS SciencefictionMoviesTotalRunTime 
FROM imdb_movies2directors AS Strong, imdb_runningtimes AS Weak
WHERE Strong.movieid = Weak.movieid AND Strong.genre = "Sci-Fi";


--Question 6
/* How many movies star both ‘Ewan McGregor’ and ‘Robert Carlyle’?
(i.e. both actors are starring in the same movie) */ 
-------SOLUTION-------
SELECT COUNT(MoviesLeft) AS NumOfMoviesStaredInByRequestedActors  FROM 
(SELECT movieid AS MoviesLeft, COUNT(*) 
FROM imdb_movies2actors AS Weak, imdb_actors AS Strong 
WHERE Strong.actorid = Weak.actorid
AND Strong.name IN ("McGregor, Ewan", "Carlyle, Robert (I)") 
GROUP BY movieid HAVING COUNT(movieid) > 1) AS needed;


--Question 7
/* How many actors (male / female) have worked together on 10 or more films? */ 
-------SOLUTION-------
SELECT COUNT(actorsLeft) AS NumOfActorsThatsWorkedOnMultiMoviesTogether
FROM (SELECT actorid AS actorsLeft, COUNT(*)
FROM imdb_movies2actors
WHERE movieid IN (SELECT DISTINCT movieid AS MoviesLeft FROM imdb_movies2actors AS A GROUP BY movieid HAVING COUNT(movieid) >1)
GROUP BY actorid HAVING COUNT(actorid) >= 10) AS needed;


--Question 8
/* Assign the number of movies released per decade as listed below
(1960-69, 1970-79, 1980-89,1990-99,2000-2010) */ 
-------SOLUTION-------
SELECT (FLOOR((year)/10)*10) AS decade, COUNT(*) AS NumOfMoviesPerDecade 
FROM imdb_movies 
GROUP BY decade 
ORDER BY decade;


--Question 9
/* How many movies have more female actors than male actors? */ 
-------SOLUTION-------
SELECT COUNT(MoviesLeft) AS NumOfMoviesWithMoreFemaleActorsThanMale
FROM (SELECT movieid AS MoviesLeft, 
SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) AS Female, 
SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS Male
FROM imdb_actors AS Strong JOIN imdb_movies2actors AS Weak 
ON Strong.actorid = Weak.actorid
GROUP BY movieid HAVING Female > Male) AS needed;


--Question 10
/* Based ratings with 10,000 or more votes, what is the top movie genre using the
average rank per movie genre as the metric?
(Note: where a higher value for rank is considered a better movie) */ 
-------SOLUTION-------
SELECT Genre, Max(Average) 
FROM (SELECT Weak.genre AS Genre, AVG(Strong.rank) AS Average
FROM imdb_ratings AS Strong, imdb_movies2directors AS Weak
WHERE Strong.movieid IN (SELECT DISTINCT Strong.movieid FROM imdb_ratings AS Strong, imdb_movies2directors AS Weak WHERE Strong.movieid = Weak.movieid)
AND Strong.movieid = Weak.movieid 
GROUP BY Weak.genre) AS needed
GROUP BY Genre ORDER BY Max(Average) DESC LIMIT 1;


--Question 11
/* List any actors (male/female) that have starred in 10 or more different film genres */ 
-------SOLUTION-------
SELECT NumOfGenres, name  
FROM(SELECT actorid as actor, COUNT(DISTINCT(genre)) AS NumOfGenres 
    FROM imdb_movies2directors, imdb_movies2actors 
    WHERE imdb_movies2directors.movieid = imdb_movies2actors.movieid
    GROUP BY actorid) AS needed, imdb_actors 
WHERE actor = actorid 
AND NumOfGenres >= 10;


--Question 12
/* How many movies have an actor/actress that also wrote and directed the movie? */ 
-------SOLUTION-------
SELECT COUNT(MoviesLeft) AS NumOfMoviesWroteAndDirectedByActor
FROM (SELECT DISTINCT imdb_movies2actors.movieid AS MoviesLeft
FROM imdb_actors, imdb_directors, imdb_writers, imdb_movies2actors, imdb_movies2directors, imdb_movies2writers
WHERE imdb_actors.actorid = imdb_movies2actors.actorid 
AND imdb_directors.directorid = imdb_movies2directors.directorid
AND imdb_writers.writerid = imdb_movies2writers.writerid
AND imdb_movies2actors.movieid = imdb_movies2directors.movieid
AND imdb_movies2directors.movieid = imdb_movies2writers.movieid
AND imdb_actors.name = imdb_directors.name
AND imdb_directors.name = imdb_writers.name) AS needed;


--Question 13
/* Which decade has the highest average ranked movies?
(put the first year from the decade, so for 1900-1909 you would put 1900) */ 
-------SOLUTION-------
SELECT decade, Max(Maxx) FROM (SELECT (FLOOR((year)/10)*10) AS decade, AVG(Strong2.rank) AS Maxx
FROM imdb_movies AS Strong1 JOIN imdb_ratings AS Strong2
ON Strong1.movieid = Strong2.movieid
GROUP BY decade) AS needed
GROUP BY decade ORDER BY Max(Maxx) DESC LIMIT 1;


--Question 14
/* How many movies are missing a genre in the dataset? */ 
-------SOLUTION-------
SELECT COUNT(MoviesLeft) AS NumOfMoviesWithNullGenre
FROM (SELECT movieid AS MoviesLeft, COUNT(*) 
FROM imdb_movies2directors
WHERE genre is NULL
GROUP BY movieid) AS needed;


--Question 15
/* how many movies have an actor/actress written and directed but not starred in?
 (i.e. the person that wrote and directed the movie is an actor/actress but they didn't star in their own movie) */ 
-------SOLUTION-------
SELECT COUNT(MoviesLeft) AS NumOfMoviesWroteAndDirectedButNotStarredByActor
FROM (SELECT DISTINCT imdb_movies2actors.movieid AS MoviesLeft
FROM imdb_actors, imdb_directors, imdb_writers, imdb_movies2actors, imdb_movies2directors, imdb_movies2writers
WHERE imdb_actors.actorid = imdb_movies2actors.actorid
AND imdb_writers.writerid = imdb_movies2writers.writerid 
AND imdb_directors.directorid = imdb_movies2directors.directorid
AND imdb_movies2actors.movieid = imdb_movies2directors.movieid
AND imdb_movies2directors.movieid = imdb_movies2writers.movieid
AND imdb_actors.name <> imdb_directors.name
AND imdb_directors.name = imdb_writers.name) AS needed;