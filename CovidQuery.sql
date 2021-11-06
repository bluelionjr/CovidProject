
-- Global Covid Numbers
SELECT
	SUM(new_cases) as TotalCases
	, SUM(cast(new_deaths as int)) as TotalDeaths
	, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathRate
FROM CovidProject2021..CovidDeaths
WHERE continent is not null 


-- United States Covid Numbers
SELECT
	SUM(new_cases) as TotalCases
	, SUM(cast(new_deaths as int)) as TotalDeaths
	, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathRate
FROM CovidProject2021..CovidDeaths
WHERE location = 'United States'


-- Total Deaths by Continent
SELECT Location
	, SUM(cast(new_deaths as int)) as TotalDeaths
FROM CovidProject2021..CovidDeaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY Location
ORDER BY TotalDeaths DESC


-- Percent of Population Infected
SELECT Location
	, Population
	, MAX(total_cases) as HighestInfectionCount
	,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidProject2021..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Percent of Population Infected over time
SELECT Location
	, Population
	, date, MAX(total_cases) as HighestInfectionCount
	, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject2021..CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC

