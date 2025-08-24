SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECTING DATA FOR USECASE

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date

--TOTAL CASES Vs TOTAL DEATHS
--CALCULATING DEATH PERCENTAGE

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
AND continent IS NOT NULL
ORDER BY location,date

--TOTAL CASES Vs POPULATION

SELECT location, date, total_cases, population, (total_cases / population) * 100 AS Infected_PopulationPercent
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
ORDER BY location,date

--Countries with highest Infection rate against Population
SELECT location, population, MAX(total_cases) AS highest_infectionCount, MAX((total_cases / population)) * 100 AS Infected_PopulationPercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_PopulationPercent DESC


--Countries with Highest death Count against population

SELECT location, MAX(cast(total_deaths AS INT)) AS Total_DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_DeathCount DESC


-- CONTINENT WISE DRILLDOWN
--Highest Death Toll per Continent against population 
SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_DeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_DeathCount DESC


--Global Wise Drilldown

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS total_deathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
--, (People_Vaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3


--Aggregate SUM of People vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3


-- USING CTE 

with PopvsVac (Continent, location, date, population, new_vaccinations, People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
--, (People_Vaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *,  (People_Vaccinated / population) * 100
	FROM PopvsVac



--USING TEMP TABLE

DROP TABLE IF EXISTS #Vaccinated_PopulationPercentage

CREATE TABLE #Vaccinated_PopulationPercentage(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
People_Vaccinated numeric
)
INSERT INTO #Vaccinated_PopulationPercentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
--, (People_Vaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *,  (People_Vaccinated / population) * 100
	FROM #Vaccinated_PopulationPercentage


-- Creating View for Visualization

CREATE VIEW Vaccinated_PopulationPercentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated
--, (People_Vaccinated / population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT * FROM Vaccinated_PopulationPercentage;