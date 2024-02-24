SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Deaths Percentage in Argentina
SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Argentina%'
and continent is not null
order by 1,2

--Infection Percentage in Argentina
SELECT Location, date, Population, total_cases, (cast(total_cases as float)/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Argentina%'
and continent is not null
order by 1,2

--Countries with highest infection rate
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by Location, Population
order by InfectedPercentage desc

--Countries with highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by Location
order by TotalDeathsCount desc

--Deaths per continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--Global numbers
Select SUM(CAST(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(New_cases)*100,0) as DeathPercentage 
FROM PortfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2 

--Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Percentage of vaccinated people
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
FROM PopvsVac

--Percentage of vaccinated people with temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
FROM #PercentPopulationVaccinated

--Visualizations data
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
