select * 
from CovidProject2021..CovidDeaths
--WHERE continent is not null
order by 3,4

--select * 
--from CovidProject2021..CovidVaccinations
--order by 3,4

-- Select Data that I'm going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject2021..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths and calculating Death Rate
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM CovidProject2021..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--not to self, look at total death rate by month - something like new deaths/ new cases
--this calculation is not right, don't use this
SELECT location, date, new_cases, new_cases_smoothed, (new_deaths/new_cases)*100 as DailyDeathRate
FROM CovidProject2021..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Total Cases vs Population
-- Percentage of population that have been diagnosed with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PositivePercentage
FROM CovidProject2021..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as MaxInfectionCount, MAX((total_cases/population))*100 as PositivePercentage
FROM CovidProject2021..CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY PositivePercentage DESC


--Countries with highest death count
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidProject2021..CovidDeaths
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--BY CONTINENT

--Correct numbers, highest death count by continent / world
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidProject2021..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Wrong numbers by continent
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidProject2021..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

-- Global numbers by date
--had to cast new_deaths since they were nvarchar
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, 
 SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject2021..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global numbers, total, no date
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, 
 SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject2021..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- VACCINATIONS

--Total Population vs Those Vaccinated
--Assigned alias to CovidDeaths = dea
--Assigned alias to CovidVaccinations = vax

SELECT  dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
FROM CovidProject2021..CovidDeaths dea
JOIN CovidProject2021..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
ORDER BY 1,2,3


--Rolling Vaccination Count per day, per location

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
	, SUM(CAST(vax.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaxCount
FROM CovidProject2021..CovidDeaths dea
JOIN CovidProject2021..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Create CTE

WITH PopvsVax (continent, location, date, population, new_vaccinations, RollingVaxCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
	, SUM(CAST(vax.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaxCount
FROM CovidProject2021..CovidDeaths dea
JOIN CovidProject2021..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null
)

SELECT *, (RollingVaxCount/population)*100
FROM PopvsVax



-- CREATE TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaxCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
	, SUM(CAST(vax.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaxCount
FROM CovidProject2021..CovidDeaths dea
JOIN CovidProject2021..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null

SELECT *
FROM #PercentPopulationVaccinated

--Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinatedView as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
	, SUM(CAST(vax.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaxCount
FROM CovidProject2021..CovidDeaths dea
JOIN CovidProject2021..CovidVaccinations vax
	ON dea.location = vax.location
	and dea.date = vax.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinatedView


