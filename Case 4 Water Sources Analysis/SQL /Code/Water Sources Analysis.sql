-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- Select Data that we are going to be starting with

SELECT Entity, iws.Year, iws.wat_imp AS ImprovedWaterPercentage, iws."Total population (Gapminder, HYDE & UN)" AS TotalPopulation
FROM improved_water_sources iws 
ORDER BY 3 DESC

-- Don't have access to safe Water VS Don't have access to improved water 
-- Shows Percentage by country and year

SELECT wiw.Code, 
	c.Country, 
	wiw.Year, 
	iws."Total population (Gapminder, HYDE & UN)" AS Population, 
	ROUND(wiw.Wat_imp_without, 2)  AS UnimprovedWaterPercentage,  
	ROUND((wsw.wat_sm_number_without / (iws."Total population (Gapminder, HYDE & UN)" / 100)), 2) AS NotSafeWaterPercantage
FROM without_improved_water wiw
JOIN number_without_SafeWater wsw
  ON  wsw.Entity = wiw.Entity AND wsw.Year = wiw.Year
JOIN improved_water_sources iws 
	ON iws.Entity = wiw.Entity AND iws.Year = wiw.Year
JOIN codes c 
	ON c."Alpha-3 code" = wiw.code
WHERE UnimprovedWaterPercentage IS NOT NULL AND NotSafeWaterPercantage IS NOT NULL AND c.Country LIKE '%krain%'
ORDER BY 1, 2


-- Death From Unsafe Water VS Population 
-- Shows what percentage of population die from Pure Water


SELECT c.Country, nod.Code, nod.Year,
	ROUND(nod."Deaths - Unsafe water source - Sex: Both - Age: All Ages (Number)", 2) AS DeathFromUnSafeWater,
	iws."Total population (Gapminder, HYDE & UN)" AS Population,
	(nod.'Deaths - Unsafe water source - Sex: Both - Age: All Ages (Number)' / (iws.'Total population (Gapminder, HYDE & UN)' / 100)) AS PercentageOfDeath
FROM number_of_deaths_by_risk_factor nod
JOIN improved_water_sources iws 
	USING(Entity, code)
JOIN codes c
	ON c."Alpha-3 code" = nod.Code 
WHERE nod.year = 2017
GROUP BY Code
ORDER BY 1, 2


--Countries with Highest Rate of people without access to safe water compared to Population
-- Show all data by changed year from 2000 to 2019

SELECT c.Country, wsw.Code, wsw.Year, ROUND(MAX(wat_sm_number_without), 2) AS HighestRateUnSafeWater, 
ROUND(MAX((wsw.wat_sm_number_without/iws."Total population (Gapminder, HYDE & UN)"))* 100, 2) AS PercentageOfPopulation
FROM number_without_SafeWater wsw 
JOIN codes c
	ON c."Alpha-3 code" = wsw.Code 
JOIN improved_water_sources iws 
	USING(code, year)
WHERE year = 2019
GROUP BY Country
ORDER BY 1, 2


--Countries with highest death from unsafe water by year 

SELECT c.Country, nod.Code, nod.Year, 
	ROUND(MAX(nod."Deaths - Unsafe water source - Sex: Both - Age: All Ages (Number)"), 2) AS HighestDeathRate, 
	ROUND(MAX((nod."Deaths - Unsafe water source - Sex: Both - Age: All Ages (Number)" 
				/ iws."Total population (Gapminder, HYDE & UN)"))* 100, 5) AS PercentageOfPopulation
FROM number_of_deaths_by_risk_factor nod
JOIN codes c
	ON c."Alpha-3 code" = nod.Code 
JOIN improved_water_sources iws 
	USING(code, year)
WHERE year = 2017
GROUP BY Country
ORDER BY HighestDeathRate DESC

--BRAKING THINGS DOWN BY CONTINENT 


SELECT iws.Continent, iws.Year, ROUND(MAX(nod."Deaths - Unsafe water source - Sex: Both - Age: All Ages (Number)"), 2) AS HighestDeathByUnSafeWater
FROM improved_water_sources iws 
JOIN number_of_deaths_by_risk_factor nod
	USING(entity, code, year)
WHERE Continent NOT LIKE ''
GROUP BY Continent 
ORDER BY 1


-- GLOBAL NUMBERS 

SELECT DISTINCT nws.Year, 
	ROUND(nws.wat_sm_number_without, 2) AS Total_PeopleUsing_UnSafe_Water, 
	ROUND((iws."Total population (Gapminder, HYDE & UN)" /100)*wiw.wat_imp_without, 2) AS Total_PeopleUsing_Unimpoved_Water,
	ROUND(nod."Deaths - Unsafe water source - Sex: Both - Age: All Ages (Number)", 2) AS Total_Death_Unsafe_Water
FROM number_without_SafeWater nws
JOIN number_of_deaths_by_risk_factor nod
 USING(code, year)
JOIN without_improved_water wiw 
	USING(code, year)
JOIN improved_water_sources iws 
	USING(code, year)
WHERE nws.year = 2017 AND nws.Entity IN ('World') 


-- Total Population VS People Have Access to Safe Water

SELECT c.Country, iws.Year, iws."Total population (Gapminder, HYDE & UN)", ROUND(nws.wat_sm_number_without, 2),
ROUND(SUM(nws.wat_sm_number_without) OVER (PARTITION BY c.Country ORDER BY c.Country, iws.Year), 2) AS TotalPeopleUseUnsafeWater
FROM improved_water_sources iws
JOIN codes c 
	ON c."Alpha-3 code" = iws.Code 
JOIN number_without_SafeWater nws
	USING(Code, year)
WHERE Year != 2020
ORDER BY 1, 2


	
-- USE CTE 

WITH PopVSUnsafe (Country, Year, 'Total population (Gapminder, HYDE & UN)', wat_sm_number_without, TotalPeopleUseUnsafeWater)
AS 
(
SELECT c.Country, iws.Year, iws."Total population (Gapminder, HYDE & UN)", nws.wat_sm_number_without,
SUM(nws.wat_sm_number_without) OVER (PARTITION BY c.Country ORDER BY c.Country, iws.Year) AS TotalPeopleUseUnsafeWater
-- (TotalPeopleUseUnsafeWater/iws."Total population (Gapminder, HYDE & UN)")*100
FROM improved_water_sources iws
JOIN codes c 
	ON c."Alpha-3 code" = iws.Code 
JOIN number_without_SafeWater nws
	USING(Code, year)
WHERE Year != 2020
--ORDER BY 1, 2
)
SELECT *, (TotalPeopleUseUnsafeWater/"Total population (Gapminder, HYDE & UN)")*100
FROM PopVSUnsafe


-- TEMP TABLE 

DROP TABLE #PercentPopulationUseUnsafeWater 

CREATE TEMPORARY TABLE PercentPopulationUseUnsafeWater AS (Country VARCHAR(255),
Year NUMERIC, 
"Total population (Gapminder, HYDE & UN)" NUMERIC, 
wat_sm_number_without NUMERIC,
TotalPeopleUseUnsafeWater NUMERIC)

INSERT INTO PercentPopulationUseUnsafeWater
SELECT c.Country, iws.Year, iws."Total population (Gapminder, HYDE & UN)", nws.wat_sm_number_without,
SUM(nws.wat_sm_number_without) OVER (PARTITION BY c.Country ORDER BY c.Country, iws.Year) AS TotalPeopleUseUnsafeWater
FROM improved_water_sources iws
JOIN codes c 
	ON c."Alpha-3 code" = iws.Code 
JOIN number_without_SafeWater nws
	USING(Code, year)
WHERE Year != 2020
ORDER BY 1, 2

SELECT *, (TotalPeopleUseUnsafeWater/"Total population (Gapminder, HYDE & UN)")*100
FROM #PercentPopulationUseUnsafeWater



-- Creating View to store date for latter visualisations 



CREATE VIEW TotalPeopleUseUnsafeWater 
SELECT c.Country, iws.Year, iws."Total population (Gapminder, HYDE & UN)", nws.wat_sm_number_without,
SUM(nws.wat_sm_number_without) OVER (PARTITION BY c.Country ORDER BY c.Country, iws.Year) AS TotalPeopleUseUnsafeWater
FROM improved_water_sources iws
JOIN codes c 
	ON c."Alpha-3 code" = iws.Code 
JOIN number_without_SafeWater nws
	USING(Code, year)
WHERE Year != 2020


SELECT *
FROM TotalPeopleUseUnsafeWater