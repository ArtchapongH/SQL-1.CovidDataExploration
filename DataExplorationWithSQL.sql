-- select all columns and sort by 3rd and 4th columns
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4



-- select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- look at total casese vs total deaths of Thailand
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPct
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Thai%' AND continent IS NOT NULL
ORDER BY 1,2



-- look at Total Casese vs Population of Thailand
SELECT location, date, total_cases, population, (total_deaths/population)*100 AS PopInfectPct
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Thai%' AND continent IS NOT NULL
ORDER BY 1,2



-- look at countries with highest infection rate compared to population
SELECT location,  population, MAX(total_cases) AS HightestInfectionCount, MAX((total_cases/population))*100 AS PopInfectPct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,  population
ORDER BY PopInfectPct DESC



-- show countries with the highest death count per population
SELECT location,  MAX(CAST(total_deaths AS INT)) AS TotDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotDeathsCount DESC



-- GLOBAL NUMBERS
SELECT  SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS INT)) AS total_death , (SUM(new_cases) /SUM(CAST(new_deaths AS INT)))*100 AS DeathPct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NUll
ORDER BY 1,2

SELECT  date, SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS INT)) AS total_death , (SUM(new_cases) /SUM(CAST(new_deaths AS INT)))*100 AS DeathPct
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT continent,  (SUM(CAST(total_deaths AS INT))/SUM(population))*100 AS TotDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotDeathsCount DESC



-- Looking at Total	Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVacinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3



-- To find cumulative of total vacination by location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVacinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- To find cumulative of total vacination by location as percentage
WITH PopvVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVacinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS pctPeopleVaccinated
FROM PopvVac



-- To find cumulative of total vacination by location as percentage using temp table method
DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVacinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS pctPeopleVaccinated
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVacinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated