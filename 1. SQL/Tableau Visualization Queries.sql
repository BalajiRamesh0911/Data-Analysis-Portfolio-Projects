--Tableau Project Visualization queries

--1.

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--2. European Union is part of Europe
SELECT location, SUM(CAST(new_deaths AS INT)) AS Total_DeathCount FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_DeathCount DESC


--3. 
SELECT location, population, MAX(total_cases) AS highest_infectionCount, MAX((total_cases / population)) * 100 AS Infected_PopulationPercent
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Infected_PopulationPercent DESC


--4.
SELECT location, population, date, MAX(total_cases) AS highest_infectionCount, MAX((total_cases / population)) * 100 AS Infected_PopulationPercent
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY Infected_PopulationPercent DESC
