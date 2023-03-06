/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-----------------------------------------------------------------------------------------------------

-- Quering the Covid Deaths Table
SELECT *
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE continent IS NOT NULL
ORDER BY 3,4;

----------------------------------------------------------------------------------------------------

-- Select Data that we'll be working on initially

SELECT  location , date, total_cases, new_cases, total_deaths, population
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE continent IS NOT NULL
ORDER BY 1,2

----------------------------------------------------------------------------------------------------

-- Total Cases Vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

SELECT  location , date, total_cases , total_deaths, (total_deaths/ total_cases)* 100 as DeathPercentage
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE location LIKE '%India%' AND continent IS NOT NULL
ORDER BY 1,2;

----------------------------------------------------------------------------------------------------

-- Looking at total cases vs population
-- Shows what percentage of population infected with Covid

SELECT  location , date, total_cases , population,  (total_cases/ population)* 100 as CasesByPopulation
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE location LIKE '%India%'
ORDER BY 1,2;

----------------------------------------------------------------------------------------------------

-- Coutries with highest infection rate compared to population

SELECT  location , population,  max(total_cases) as HighestInfectionCount ,  max((total_cases/ population))* 100 as InfectionPercent
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE continent IS NOT NULL
GROUP BY  location , population
ORDER BY InfectionPercent DESC;

----------------------------------------------------------------------------------------------------

-- Countries with highest death per population

SELECT  location , population,   max(total_deaths) as HighestDeathCount ,  max((total_deaths/ population))* 100 as DeathsByPopulation
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE continent IS NOT NULL
GROUP BY  location , population
ORDER BY DeathsByPopulation DESC;

----------------------------------------------------------------------------------------------------

-- BREAKING THINGS DOWN BY CONTINENT

SELECT continent ,  max(cast( total_deaths as int )) as HighestDeathCount
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE continent IS NOT NULL
GROUP BY  continent 
ORDER BY HighestDeathCount DESC;

----------------------------------------------------------------------------------------------------

-- Global numbers

SELECT SUM(new_cases) as TotalCases , sum(cast(new_deaths as int)) as TotalDeaths, 
       (sum(cast(new_deaths as int))/SUM(new_cases))*100 as deathpercenttoday
FROM Covid_Portfolio_Project..['covid-deaths']
WHERE continent IS NOT NULL
ORDER BY 1 ,2;

----------------------------------------------------------------------------------------------------

-- Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
FROM Covid_Portfolio_Project..['covid-deaths'] dea
JOIN Covid_Portfolio_Project..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

----------------------------------------------------------------------------------------------------

-- Using CTE to perform Calculation on Partition By in previous query

With PopulationVsVaccinations (continent, location, date,population, new_vaccinations,SumOFVacc )
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
	   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
				  (PARTITION BY dea.location ORDER BY dea.location, dea.date) SumOFVacc
FROM Covid_Portfolio_Project..['covid-deaths'] dea
JOIN Covid_Portfolio_Project..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (SumOFVacc/ population) * 100 as PercentOfPeopleVacc
FROM PopulationVsVaccinations

----------------------------------------------------------------------------------------------------

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumOfVacc numeric
)

INSERT INTO #PercentPeopleVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
	   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
				  (PARTITION BY dea.location ORDER BY dea.location, dea.date) SumOFVacc
FROM Covid_Portfolio_Project..['covid-deaths'] dea
JOIN Covid_Portfolio_Project..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (SumOFVacc/ population) * 100 as PercentOfPeopleVacc
FROM #PercentPeopleVaccinated

----------------------------------------------------------------------------------------------------


-- Creating View to store data for further visualizations

Create view PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
	   SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
				  (PARTITION BY dea.location ORDER BY dea.location, dea.date) SumOFVacc
FROM Covid_Portfolio_Project..['covid-deaths'] dea
JOIN Covid_Portfolio_Project..['covid-vaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopVaccinated




