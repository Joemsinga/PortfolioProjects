SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations

-- Total Deaths Vs Total Cases 

SELECT location, date ,total_cases , total_deaths, (CAST (total_deaths AS decimal) / CAST(total_cases AS DECIMAL))* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Zimb%'
ORDER BY 1,2

--Total Cases Vs Total Population
--Percentage of Population that contracted Covid

SELECT location, date, total_cases, population, (CAST (total_cases AS decimal) /CAST( population AS DECIMAL)) * 100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Zimb%'
ORDER BY 1,2

--Highest infection Rates By Country

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal)/CAST (population AS DECIMAL))* 100) As PopulationInfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectionRate DESC

--Highest Death Count per population

SELECT location, MAX(CAST(total_deaths AS decimal)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Highest Death Count by Continent
SELECT continent, MAX(CAST(total_deaths AS DECIMAL)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date,SUM(CAST(new_cases AS DECIMAL)) AS TotalCases, SUM(CAST(new_deaths AS DECIMAL)) AS TotalDeaths,(SUM(CAST(new_deaths AS DECIMAL))/SUM(CAST(new_cases AS DECIMAL)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND new_cases IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total Population Vs Vacination
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations AS DECIMAL)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)* 100
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 1,2,3

--USE CTE

WITH PopVsVac (continent, location, date, population,New_Vaccinations,  RollingPeopleVaccinated)
As
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations AS DECIMAL)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)* 100
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)* 100
FROM PopVsVac


--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

INSERT INTO #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CAST(Vac.new_vaccinations AS DECIMAL)) OVER (PARTITION BY Dea.location ORDER BY Dea.location,Dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)* 100
FROM PortfolioProject..CovidDeaths AS Dea
JOIN PortfolioProject..CovidVaccinations AS Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 1,2,3

Select *, (RollingPeopleVaccinated/Population)* 100
FROM #PercentPopulationVaccinated