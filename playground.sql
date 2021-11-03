
LECTURE 5
=========
SELECT * FROM countries

-- Find the name and population of all cities with a population greater than 10 Million.

SELECT name, population
FROM cities
WHERE population > 10000000;

--Find the names of all capital cities with a population of more than 10,000,000 people! Recall that a capital city is
--identifies by a value of 'primary' for attribute capital in Table Cities.
SELECT name, population
FROM cities
WHERE population > 10000000
AND capital = 'primary';

--Find the names of all countries with more than 1 official capital city!
SELECT a.name as country_name, COUNT(b.name) AS capital_count
FROM countries a, cities b
WHERE a.iso2 = b.country_iso2
AND b.capital = 'primary'
GROUP BY a.name
HAVING COUNT(b.name) > 1



-- Find the name and population of all countries in Asia and Europe with a population between 5 and 6 Million.

SELECT name, population
FROM countries
WHERE (continent = 'Asia' OR continent = 'Europe')
AND (population > 5000000 AND population < 6000000);
      
-- or
      
SELECT *
FROM countries
WHERE (continent = 'Asia' OR continent = 'Europe')
AND (population BETWEEN 5000000 AND 6000000);      
      



-- Find the name and the all of countries the GDP per capita in SGD rounded to the nearest dollar for all countries.

SELECT name, 'S$ ' || ROUND((gdp / population)*1.35) AS gdp_per_capita
FROM countries;

SELECT name , 'S$' || ROUND((gdp/population)*1.35) AS gdp_per_capita
FROM countries;


-- Find all country codes for which cities are available in the database.

-- Wrong way
SELECT country_iso2 AS code
FROM cities;
      

-- The right way
SELECT DISTINCT country_iso2 AS code
FROM cities;
-- or
SELECT DISTINCT(country_iso2) AS code
FROM cities;





-- SELECT Clause — Duplicates with NULL Values

SELECT name, capital
FROM cities;

-- vs.

SELECT DISTINCT name, capital
FROM cities;
      
      
      
      
-- Find all codes of countries that have no land border with another country.      

SELECT country1_iso2 AS code
FROM borders
WHERE country2_iso2 IS NULL;


-- WRONG BELOW
SELECT country1_iso2 AS code
FROM borders
WHERE country2_iso2 = NULL;




-- Find all cities that start with "Si" and end with "re".

SELECT name
FROM cities
WHERE name LIKE 'Si%re';





-- Find all names that refer to both a city and a country.

(SELECT name FROM cities)
INTERSECT ALL
(SELECT name FROM countries);



-- Find the codes of all the countries for which there is not city in the database.

(SELECT iso2
 FROM countries)
EXCEPT
(SELECT DISTINCT(country_iso2)
 FROM cities);

 

-- Find all airports located in cities named "Singapore" or "Perth".

SELECT *
FROM airports
WHERE city = 'Singapore'
   OR city = 'Perth';

-- or

(SELECT * FROM airports 
 WHERE city = 'Singapore')
UNION 
(SELECT * FROM airports
 WHERE city = 'Perth');
 
 
 
 
 
-- For all cities, find their names together with the names of the countries they are located in.

SELECT c.name, n.name
FROM cities AS c, countries AS n
WHERE c.country_iso2 = n.iso2;

-- or

SELECT c.name, n.name
FROM cities c INNER JOIN countries n
  ON c.country_iso2 = n.iso2;

SELECT *
FROM cities c 
INNER JOIN countries n ON c.country_iso2 = n.iso2
INNER JOIN countries n1 ON c.country_iso2 = n1.iso2;

-- or

SELECT c.name, n.name
FROM cities c JOIN countries n
  ON c.country_iso2 = n.iso2;




-- Find all names that refer to both a city and a country.

SELECT DISTINCT(name)
FROM (SELECT name FROM cities) t1
     NATURAL JOIN
     (SELECT name FROM countries) t2;
            
            
--Find the names of all countries for which we only have the capital city in the database
SELECT a.name as country_name, 
FROM countries a, cities b
WHERE a.iso2 = b.country_iso2
AND b.capital = 'primary'
 
-- Find the all the countries for which there is not city in the database.
            
SELECT n.name
FROM countries n LEFT OUTER JOIN cities c
ON n.iso2 = c.country_iso2
WHERE c.country_iso2 IS NULL;

-- not so good attempt
SELECT name, (gdp/population) AS gdp_per_capita
FROM countries
ORDER BY gdp_per_capita DESC
LIMIT 5;

SELECT name
from countries
where
SELECT COUNT(*)
from borders;

SELECT t1.country, COUNT(border) as border_count
FROM (SELECT n.name AS country, c.name AS city, a.name AS airport, a.code
     FROM borders b, countries n, cities c, airports a
     WHERE  b.country1_iso2 = n.iso2
     AND n.iso2 = c.country_iso2
     AND c.name = a.city
     AND b.country2_iso2 IS NULL) t1
LEFT OUTER JOIN
    routes r
ON t1.code = r.to_code
WHERE r.to_code IS NULL;


-- Find all airports in European countries without a land border which cannot be reached by plane given the existing routes in the database.

SELECT t1.country, t1.city, t1.airport
FROM
    (SELECT n.name AS country, c.name AS city, a.name AS airport, a.code
     FROM borders b, countries n, cities c, airports a
     WHERE  b.country1_iso2 = n.iso2
     AND n.iso2 = c.country_iso2
     AND c.name = a.city
     AND b.country2_iso2 IS NULL
     AND n.continent = 'Europe') t1
LEFT OUTER JOIN
    routes r
ON t1.code = r.to_code
WHERE r.to_code IS NULL;




-- Find all names that refer to both a city and a country.

SELECT name 
FROM countries
WHERE name IN (SELECT name FROM cities);


Select code,name
FROM airports
where country_iso2 = 'AF' OR country_iso2 = 'JM';

-- Find the codes of all the countries for which there is not city in the database.

SELECT iso2 
FROM countries
WHERE iso2 NOT IN (SELECT country_iso2 FROM cities);


--Find all pairs of Asian countries that share a land border! For each pair of names, always list the country with the
--smaller population size first!
SELECT c1.name as country_name1, c2.name as country_name2
FROM countries c1, countries c2, borders b
WHERE c1.population < c2.population
AND c1.continent = 'Asia'
AND c2.continent = 'Asia'
AND c1.iso2 = b.country1_iso2
AND c2.iso2 = b.country2_iso2
;

--Find the names of all the Asian countries that neither Marie, Bill, Sam, nor Sarah have visited! They want to travel
--together to Asia and, of course, go a country that is new to all of them.
SELECT c.name as country__name
FROM countries c
WHERE c.continent = 'Asia'
AND NOT EXISTS(SELECT DISTINCT c.name
              FROM users u, visited v, countries c2
              WHERE (u.name = 'Marie' OR u.name = 'Bill' or u.name = 'Sam' or u.name = 'Sarah')
              AND v.iso2 = c.iso2
              AND v.user_id = u.user_id)


SELECT c.name AS country_name
FROM countries c
WHERE c.continent = 'Asia' EXCEPT
SELECT DISTINCT c.name as country_name
FROM users u, visited v, countries c
WHERE (u.name = 'Marie' OR u.name = 'Bill' OR u.name = 'Sam' OR u.name = 'Sarah')
AND  v.user_id = u.user_id
AND v.iso2 = c.iso2
;


--Return the name of the country and the number of domenstic connections, sorted by the number of
--domestic connections in a descending order. FUCK
SELECT DomFlightSummary.name AS country_name, COUNT(*) as domestic_connections_count
FROM ( SELECT r.from_code, r.to_code, c.name 
      FROM countries c, airports a1, airports a2, routes r
      WHERE c.iso2 = a1.country_iso2
      AND r.to_code = a1.code
      AND c.iso2 = a2.country_iso2
      AND r.from_code = a2.code
      AND a1 <> a2
      GROUP BY r.from_code, r.to_code, c.name) AS DomFlightSummary
GROUP BY DomFlightSummary.name
HAVING COUNT(*) > 100
ORDER BY COUNT(*) DESC
;


-- Find all countries in Asia and Europe with a population between 5 and 6 Million.
SELECT *
FROM countries
WHERE continent IN ('Asia', 'Europe')
  AND population BETWEEN 5000000 AND 6000000;
  
  
  
-- Find all countries with a population size smaller than any city called "London" (there are actually 4 cities called "London" on the database).

SELECT name, population 
FROM countries
WHERE population < ANY (SELECT population FROM cities WHERE name = 'London')




-- Find all countries with a population size smaller than all cities called "London" (there are actually 4 cities called "London" on the database)

SELECT name, population 
FROM countries
WHERE population < ALL (SELECT population FROM cities WHERE name = 'London');




-- For each continent, find the country with the highest GDP.

SELECT name, continent, gdp
FROM countries c1
WHERE gdp >= ALL (SELECT gdp FROM countries c2 WHERE c2.continent = c1.continent);

-- Find the names of all European countries that have a larger GDP per capita than Singapore
SELECT c1.name as country_name
FROM countries c1, countries c2
WHERE c1.continent = 'Europe'
AND c2.iso2 ='SG'
AND (c1.gdp/c1.population) > (c2.gdp/c2.population)
and c1.gdp <> 0

SELECT c.name AS country_name
FROM countries c
WHERE c.continent = 'Europe'
AND c.gdp <> 0
AND c.gdp / c.population > (SELECT c1.gdp/ c1.population
			 FROM countries c1 
			 WHERE c1.iso2 = 'SG')

-- Find all names that refer to both a city and a country.

SELECT name 
FROM countries n
WHERE EXISTS (SELECT c.name
              FROM cities c
              WHERE c.name = n.name);


SELECT name 
FROM countries n
WHERE EXISTS (SELECT c.name
              FROM cities c
              WHERE c.country_iso2 = n.iso2
              AND c.capital <> 'primary');

-- Find the all the countries for which there is no city in the database.

SELECT n.name
FROM countries n
WHERE NOT EXISTS (SELECT * 
                  FROM cities c
                  WHERE c.country_iso2 = n.iso2);
                  

SELECT n.name
FROM countries n
WHERE NOT EXISTS (SELECT * 
                  FROM cities c
                  WHERE c.country_iso2 = n.iso2
                  AND c.capital <> 'primary');                  
                  
-- For all cities, find their names together with the names of the countries they are located in.

SELECT name AS city,
(SELECT name AS country
FROM countries n
WHERE n.iso2 = c.country_iso2)
FROM cities c;
                 
                 
                 

-- Find all cities that are located in a country with a country population smaller than the population of all cities called "London" (there are actually 4 cities called "London" on the database).
   
SELECT c.name AS city, c.country_iso2 AS country, c.population
FROM cities c
WHERE (SELECT population 
       FROM countries n 
       WHERE n.iso2 = c.country_iso2) < ALL (SELECT population
                                             FROM cities
                                             WHERE name = 'London');
                                             



-- Find all countries with a higher population or higher gdp than France or Germany

SELECT name, population, gdp
FROM countries
WHERE ROW(population, gdp) > ANY (SELECT population, gdp 
                                  FROM countries 
                                  WHERE name IN ('Germany', 'France'));
                                  
                                  
                                  
                                  
-- Find all the airports in Denmark.

SELECT name, city
FROM airports
WHERE city IN (SELECT name
               FROM cities
               WHERE country_iso2 IN (SELECT iso2
                                      FROM countries
                                      WHERE name = 'Denmark')
              );
              
-- or

SELECT a.name, a.city
FROM airports a, cities c, countries n
WHERE a.city = c.name
AND c.country_iso2 = n.iso2
AND n.name = 'Denmark';


-- Find the GDP per capita for all countries sorted from highest to lowest.

SELECT name, (gdp/population) AS gdp_per_capita
FROM countries
ORDER BY gdp_per_capita DESC;




-- Find all cities sorted by country (ascending from A to Z) and for each country with respect to the cities' population size in descending order.

SELECT n.name AS country, c.name AS city, c.population
FROM cities c, countries n
WHERE c.country_iso2 = n.iso2
ORDER BY n.name ASC, c.population DESC;



-- Find the top-5 countries regarding their GDP per capita for all countries.

SELECT name, (gdp/population) AS gdp_per_capita
FROM countries
ORDER BY gdp_per_capita DESC
LIMIT 5;

--Find countries with most landborder
SELECT c.name, count(*) AS border_count
FROM countries c, borders
ORDER BY c, border_count DESC
LIMIT 10;


-- Find the "second" top-5 countries regarding their GDP per capita for all countries.

SELECT name, (gdp/population) AS gdp_per_capita
FROM countries
ORDER BY gdp_per_capita DESC
OFFSET 5
LIMIT 5;





-- Find all names that refer to both a city and a country.

(SELECT name FROM cities)
INTERSECT ALL
(SELECT name FROM countries);

-- or

SELECT DISTINCT(name)
FROM (SELECT name FROM cities) t1
     NATURAL JOIN
     (SELECT name FROM countries) t2;
     
-- or

SELECT n.name 
FROM countries n
WHERE EXISTS (SELECT c.name
              FROM cities c
              WHERE c.name = n.name);
              
-- or

SELECT name 
FROM countries
WHERE name IN (SELECT name
               FROM cities);



 
                  

LECTURE 6
=========


-- Find find the lowest and highest population sizes among all countries, as well as the global population size (= sum over all countries).

SELECT MIN(population) AS lowest, 
       MAX(population) AS highest, 
       SUM(population) AS global
FROM countries;



-- Find the first last city in the United States with respect to their lexicographic sorting.

SELECT MIN(name) AS lexi_first, MAX(name) AS lexi_last
FROM cities
WHERE country_iso2 = 'US';



-- Find the number countries with at least 10% of the population compared to the country with the largest population size.

SELECT COUNT(*) AS num_big_countries
FROM countries
WHERE population >= 0.1 * (SELECT MAX(population) FROM countries);




-- For each continent, find find the lowest and highest population sizes among all countries, as well as the overall population size for that continent.

SELECT continent,
       COUNT(SELECT ) AS country_count
FROM countries
GROUP BY continent;




-- For each route, find the number of airlines that serve that route.

SELECT from_code, to_code, COUNT(*) AS num_airlines
FROM routes
GROUP BY from_code, to_code;




-- Find all routes that are served by more than 12 airlines.

SELECT from_code, to_code, COUNT(*) AS num_airlines
FROM routes
GROUP BY from_code, to_code
HAVING COUNT(*) > 12;

-- Find all count of countries with no airpots, group by continent
SELECT co.continent, COUNT(*)
FROM Countries co
WHERE NOT EXISTS(
  SELECT 1
  FROM Airports a
  WHERE a.country_iso2 = co.iso2
)
GROUP BY co.continent
;

--Find the name of the top 10 countries with tthe msot land borders and the numbers of land borders they have!
SELECT c.name AS country_name, Count(*) as border_count
FROM borders b JOIN countries c ON c.iso2 = b.country1_iso2
GROUP BY c.name
ORDER by border_count DESC
LIMIT 10

-- Find all pairs of name of countries that share a common land boarder where you can cross from Europe into Asia!
Select c1.name, c2.name
FROM countries c1, borders b, countries c2
WHERE c1.iso2 = b.country1_iso2
AND c2.iso2 = b.country2_iso2
AND c1.continent = 'Europe'
AND c2.continent = 'Asia'

-- Find all countries that have at least one city with a population size large than the average population size of all European countries

SELECT n.name, n.continent
FROM cities c, countries n
WHERE c.country_iso2 = n.iso2
GROUP BY n.name, n.continent
HAVING MAX(c.population) > (SELECT AVG(population)
                            FROM countries 
                            WHERE continent = 'Europe');
                            
                            
-- Find the names of all asian countries to which singapore airlines does not fly! Include the countreies that do not have any airport
SELECT n.name
FROM countries n
WHERE n.continent = 'Asia' AND n.iso2 NOT IN
    (SELECT c.iso2
    FROM routes r, airports a, countries c
    WHERE r.airline_code = 'SQ'
    AND c.continent = 'Asia'
    AND r.to_code = a.code
    AND c.iso2 = a.country_iso2)

-- Find the names of all asian countries to which singapore airlines fly!
SELECT DISTINCT c.iso2
    FROM routes r, airports a, countries c
    WHERE r.airline_code = 'SQ'
    AND c.continent = 'Asia'
    AND r.to_code = a.code
    AND c.iso2 = a.country_iso2

--Find the names of all cities in the US (country code: ‘US’) that can be reached from Changi Airport (airport code:
--SIN) exclusively with Singapore Airlines 

SELECT a.city AS city_name
FROM airports a, routes r
WHERE a.country_iso2 = 'US'
AND r.airline_code = 'SQ'
AND r.from_code = 'SIN'
AND r.to_code = a.code
UNION
SELECT DISTINCT a2.city AS city_name
FROM airports a1, airports a2, routes r1, routes r2, countries c1
WHERE c1.continent = 'Europe'
AND r1.airline_code = 'SQ'
AND r2.airline_code = 'SQ'
AND a2.country_iso2 = 'US'
AND r1.from_code = 'SIN'
AND r2.from_code = r1.to_code
AND a2.code = r2.to_code
AND c1.iso2 = a1.country_iso2
AND a1.code = r1.to_code
;






-- Find the number of all cities regarding the classification (defined by a cities population size).

SELECT class, COUNT(*) AS city_count
FROM 
(SELECT name, CASE
         WHEN population > 10000000 THEN 'Super City'
         WHEN population > 5000000 THEN 'Mega City'
         WHEN population > 1000000 THEN 'Large City'
         WHEN population > 500000 THEN 'Medium City'
         ELSE 'Small City' END AS class
 FROM cities) t
GROUP BY class;



-- Find all countries and return the continent in Tamil.

SELECT name, CASE continent
     WHEN 'Africa' THEN 'ஆப்பிரிக்கா'
     WHEN 'Asia' THEN 'ஆசியா'
     WHEN 'Europe' THEN 'ஐரோப்பா'
     WHEN 'North America' THEN 'வட அமெரிக்கா'
     WHEN 'South America' THEN 'தென் அமெரிக்கா'
     WHEN 'Oceania' THEN 'ஓசியானியா'
        ELSE NULL END AS continent
FROM countries;



-- Find the number of cities for each city type; consider cities with NULL for column "capital" as "other".

SELECT capital, COUNT(*) AS city_count
FROM (SELECT COALESCE(capital, 'other') AS capital 
      FROM cities) t
GROUP BY capital;

SELECT continent, COUNT(*) AS city_count
FROM (SELECT COALESCE(continent, 'other') AS continent 
      FROM countries) t
GROUP BY continent;
    

-- Find the minimum and average GDP across all countries (unknown GDP values are represented by 0)

SELECT MIN(NULLIF(gdp, 0)) AS min_gdp, 
       ROUND(AVG(NULLIF(gdp, 0))) AS avg_gdp
FROM countries;

SELECT c.name, count(*) AS border_count
FROM countries c, borders
ORDER BY c, border_count DESC
LIMIT 10;


-- Find all airports in European countries without a land border which cannot be reached by plane given the existing routes in the database.

SELECT t1.country, t1.city, t1.airport
FROM
    (SELECT n.name AS country, c.name AS city, a.name AS airport, a.code
     FROM borders b, countries n, cities c, airports a
     WHERE  b.country1_iso2 = n.iso2
     AND n.iso2 = c.country_iso2
     AND c.name = a.city
     AND b.country2_iso2 IS NULL
     AND n.continent = 'Europe') t1
LEFT OUTER JOIN
    routes r
ON t1.code = r.to_code
WHERE r.to_code IS NULL;

-- or with CTE

WITH AirportsInIsolatedEuropeanCountries AS (
      SELECT n.name AS country, c.name AS city, a.name AS airport, a.code
      FROM borders b, countries n, cities c, airports a
      WHERE  b.country1_iso2 = n.iso2
      AND n.iso2 = c.country_iso2
      AND c.name = a.city
      AND b.country2_iso2 IS NULL
      AND n.continent = 'Europe')
SELECT i.country, i.city, i.airport
FROM AirportsInIsolatedEuropeanCountries i LEFT OUTER JOIN routes r
     ON i.code = r.to_code
WHERE r.to_code IS NULL;

-- or

WITH IsolatedEuropeanCountries AS (
         SELECT n.iso2, n.name AS country
         FROM borders b, countries n
         WHERE  b.country1_iso2 = n.iso2
         AND b.country2_iso2 IS NULL
         AND n.continent = 'Europe'),
     AirportsInIsolatedEuropeanCountries AS (
         SELECT n.country, c.name AS city, a.code, a.name AS airport
         FROM IsolatedEuropeanCountries n, cities c, airports a
         WHERE n.iso2 = c.country_iso2
         AND c.name = a.city),
     UnusedJustForFun AS (
         SELECT COUNT(*)
         FROM IsolatedEuropeanCountries)
SELECT i.country, i.city, i.airport
FROM AirportsInIsolatedEuropeanCountries i LEFT OUTER JOIN routes r
  ON i.code = r.to_code
WHERE r.to_code IS NULL;




-- Find all airports in European countries without a land border which cannot be reached by plane given the existing routes in the database.

CREATE VIEW IsolatedEuropeanCountries2 AS
SELECT n.iso2, n.name AS country
FROM borders b, countries n
WHERE b.country1_iso2 = n.iso2
AND b.country2_iso2 IS NULL
AND n.continent = 'Europe';

WITH AirportsInIsolatedEuropeanCountries2 AS (
       SELECT n.country, c.name AS city, a.code, a.name AS airport
       FROM IsolatedEuropeanCountries n, cities c, airports a
       WHERE n.iso2 = c.country_iso2
       AND c.name = a.city)
SELECT i.country, i.city, i.airport
FROM AirportsInIsolatedEuropeanCountries2 i LEFT OUTER JOIN routes r
  ON i.code = r.to_code
WHERE r.to_code IS NULL;



-- Find all countries with a urbanization rate below 10%

CREATE VIEW CountryUrbanizationStats AS
SELECT n.iso2, n.name, n.population AS overall_population, SUM(c.population) AS city_population, 
       SUM(c.population) / CAST(n.population AS NUMERIC) AS urbanization_rate
FROM cities c, countries n
WHERE c.country_iso2 = n.iso2
GROUP BY n.iso2;

SELECT name, urbanization_rate
FROM CountryUrbanizationStats
WHERE urbanization_rate < 0.1
ORDER BY urbanization_rate ASC;




-- Find the names of all users that have visited all countries.

SELECT user_id, name
FROM users u
WHERE NOT EXISTS (SELECT n.iso2
                  FROM countries n
                  WHERE NOT EXISTS (SELECT 1
                                    FROM visited v
                                    WHERE v.iso2 = n.iso2
                                    AND v.user_id = u.user_id)
                 );


-- Find the names of all users that have visited all countries.

SELECT u.user_id, u.name
FROM users u, visited v
WHERE u.user_id = v.user_id
GROUP BY u.user_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM countries);


-- Find all airports that can be reached from SIN non-stop.

SELECT to_code
FROM connections
WHERE from_code = 'SIN';

SELECT *
FROM connections;



-- Find all airports that can be reached from SIN with 1 stop.

SELECT DISTINCT(c2.to_code) AS to_code
FROM 
    connections c1, 
    connections c2
WHERE c1.to_code = c2.from_code
  AND c1.from_code = 'SIN';
  
  
  
-- Find all airports that can be reached from SIN with 2 stop.

SELECT DISTINCT(c3.to_code) AS to_code
FROM
    connections c1,
    connections c2,
    connections c3
WHERE c1.to_code = c2.from_code
  AND c2.to_code = c3.from_code
  AND c1.from_code = 'SIN';



--Find the names of all African countries that can be reached starting from Malaysia (country code ‘MY’) with no more
--than 10 land border crossings. Note that the same country can be reached with different number of crossings. In this
---case, report the smallest number of crossings!
WITH RECURSIVE crossing_path AS(
  SELECT b1.country2_iso2, 1 AS cross_count
  FROM borders b1
  WHERE b1.country1_iso2 = 'MY'
  UNION
  SELECT b2.country2_iso2, cp.cross_count+1
  FROM borders b2, crossing_path cp
  WHERE cp.country2_iso2 = b2.country1_iso2
  AND cp.cross_count < 10
)
SELECT c.name AS country_name, MIN(cross_count) as crossing_count
FROM countries c, crossing_path cp
WHERE c.continent = 'Africa'
AND c.iso2 = cp.country2_iso2
GROUP by c.name
;


CREATE OR REPLACE VIEW v9 (country_name, crossing_count) AS
    WITH RECURSIVE border_path AS (
        SELECT country2_iso2, 1 AS stops
        FROM borders
        WHERE country1_iso2 = 'MY'
        UNION
        SELECT b.country2_iso2, p.stops + 1
        FROM border_path p, borders b
        WHERE p.country2_iso2 = b.country1_iso2
            AND p.stops < 10
    )

    SELECT n.name AS country_name, MIN(stops) AS crossing_count
    FROM border_path p, countries n
    WHERE p.country2_iso2 = n.iso2
        AND n.continent = 'Africa'
    GROUP BY n.name


-- Find all airports that can be reached from SIN with 0..2 stops. for loop

WITH RECURSIVE flight_path AS (
  SELECT from_code, to_code, 0 AS stops
  FROM connections
  WHERE from_code = 'SIN'
 UNION ALL
  SELECT c.from_code, c.to_code, p.stops+1
  FROM flight_path p, connections c
  WHERE p.to_code = c.from_code
  AND p.stops <= 2
)
SELECT DISTINCT to_code, stops
FROM flight_path
ORDER BY stops ASC;

-- or

WITH RECURSIVE flight_path (airport_codes, stops, is_visited) AS (
  SELECT
        ARRAY[from_code, to_code],
        0 AS stops,
        from_code = to_code
  FROM connections
  WHERE from_code = 'SIN'
 UNION ALL
  SELECT
        (airport_codes || to_code)::char(3)[],
        p.stops + 1,
        c.to_code = ANY(p.airport_codes)
  FROM
      connections c,
      flight_path p
  WHERE p.airport_codes[ARRAY_LENGTH(airport_codes, 1)] = c.from_code
  AND NOT p.is_visited
  AND p.stops < 2
)
SELECT DISTINCT airport_codes, stops
FROM flight_path
ORDER BY stops;




--Find the names of all airports from which you can reach all continents with only non-stop connections (independent
--from the airline). For example, there is no non-stop connection from Changi Airport to both North and South America in
--the database. So Changi Airport is not in the result set.

SELECT a1.name AS airport_name
FROM airports a1, routes r, airports a2, countries n
WHERE r.from_code = a1.code
AND n.continent = 'Africa'
AND r.to_code = a2.code
AND a2.country_iso2 = n.iso2

INTERSECT

SELECT a1.name AS airport_name
FROM airports a1, routes r, airports a2, countries n
WHERE r.from_code = a1.code
AND n.continent = 'Asia'
AND r.to_code = a2.code
AND a2.country_iso2 = n.iso2

INTERSECT

SELECT a1.name AS airport_name
FROM airports a1, routes r, airports a2, countries n
WHERE r.from_code = a1.code
AND n.continent = 'Europe'
AND r.to_code = a2.code
AND a2.country_iso2 = n.iso2

INTERSECT

SELECT a1.name AS airport_name
FROM airports a1, routes r, airports a2, countries n
WHERE r.from_code = a1.code
AND n.continent = 'Oceania'
AND r.to_code = a2.code
AND a2.country_iso2 = n.iso2

INTERSECT

SELECT a1.name AS airport_name
FROM airports a1, routes r, airports a2, countries n
WHERE r.from_code = a1.code
AND n.continent = 'North America'
AND r.to_code = a2.code
AND a2.country_iso2 = n.iso2

INTERSECT

SELECT a1.name AS airport_name
FROM airports a1, routes r, airports a2, countries n
WHERE r.from_code = a1.code
AND n.continent = 'South America'
AND r.to_code = a2.code
AND a2.country_iso2 = n.iso2



SELECT name AS airport_name
FROM airports u
WHERE u.code IN (SELECT from_code
		 			FROM routes r1, airports a1, countries c1
		 			WHERE c1.continent = 'Asia'
		 			AND a1.country_iso2 = c1.iso2
		 			AND a1.code = r1.to_code)
AND u.code IN (SELECT from_code
		 			FROM routes r1, airports a1, countries c1
		 			WHERE c1.continent = 'Africa'
		 			AND a1.country_iso2 = c1.iso2
		 			AND a1.code = r1.to_code)
AND u.code IN (SELECT from_code
		 			FROM routes r1, airports a1, countries c1
		 			WHERE c1.continent = 'Europe'
		 			AND a1.country_iso2 = c1.iso2
		 			AND a1.code = r1.to_code)
AND u.code IN (SELECT from_code
		 			FROM routes r1, airports a1, countries c1
		 			WHERE c1.continent = 'Oceania'
		 			AND a1.country_iso2 = c1.iso2
		 			AND a1.code = r1.to_code)
AND u.code IN (SELECT from_code
		 			FROM routes r1, airports a1, countries c1
		 			WHERE c1.continent = 'North America'
		 			AND a1.country_iso2 = c1.iso2
		 			AND a1.code = r1.to_code)
AND u.code IN (SELECT from_code
		 			FROM routes r1, airports a1, countries c1
		 			WHERE c1.continent = 'South America'
		 			AND a1.country_iso2 = c1.iso2
		 			AND a1.code = r1.to_code)
;

