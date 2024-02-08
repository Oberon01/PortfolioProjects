Select 
location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows chances of dying if contracting Covid in country

Select 
location, date, total_cases, total_deaths, (convert(decimal(15,3),total_deaths)/convert(decimal(15,3),total_cases))*100 as DeathPercentage
from PortfolioProj..CovidDeaths 
where location like '%states'
order by 1,2


--Total Cases vs Population
--Shows percentage that has contracted Covid

Select 
location, date, population, total_cases, (total_cases/population)*100 as PercentageContracted
from PortfolioProj..CovidDeaths where location like '%states'
order by 1,2


-- View Countries with Highest Infection Rate Compared to Population

Select 
location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentageInfected
from PortfolioProj..CovidDeaths 
--where location like '%states'
Group by location, population
order by PercentageInfected desc


-- View Countries with Highest DeathRate per pop.

Select 
location, MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProj..CovidDeaths 
--where location like '%states'
where continent is not null
Group by location
order by TotalDeaths desc


--Continent View

Select 
location, MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProj..CovidDeaths 
--where location like '%states'
where continent is null
Group by location
order by TotalDeaths desc

-- Show continent with Highest DeathCount
Select 
location, MAX(cast(total_deaths as int)) as TotalDeaths
from PortfolioProj..CovidDeaths 
--where location like '%states'
where continent is null
Group by location
order by TotalDeaths desc


-- Global Data

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from PortfolioProj..CovidDeaths
--where continent is null
where new_cases != 0
--group by date
order by 1,2


---- Total Pop vs Vaccinations

Select DISTINCT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(convert(int, vax.new_vaccinations / 2)) over (PARTITION BY deaths.location order by deaths.location
, deaths.date) as RollingVaxCount
, (RollingVaxCount/population)*100
from PortfolioProj..CovidDeaths deaths
join PortfolioProj..CovidVaccincations vax
	on deaths.location = vax.location
	and deaths.date = vax.date
	WHERE new_vaccinations is NOT NULL
		and deaths.continent is not null
order by 2,3


-- Same as above but as a CTE
With PopvsVax (Continent, Location, Date, Pop, New_Vax, RollingVax)
as (
Select DISTINCT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(convert(bigint, vax.new_vaccinations/2)) over (PARTITION BY deaths.location order by deaths.location, deaths.date) as RollingVaxCount
from PortfolioProj..CovidDeaths deaths
join PortfolioProj..CovidVaccincations vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
--order by 2,3
)
Select *, (RollingVax/Pop)*100 as TotalPopVax
from PopvsVax
--where Location = 'United States'
order by 2,3



-- Temp Table

Drop Table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopVaccinated
Select DISTINCT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(convert(int, vax.new_vaccinations / 2)) over (PARTITION BY deaths.location order by deaths.location
, deaths.date) as RollingPeopleVaccinated
--, (RollingVaxCount/population)*100
from PortfolioProj..CovidDeaths deaths
join PortfolioProj..CovidVaccincations vax
	on deaths.location = vax.location
	and deaths.date = vax.date
	WHERE new_vaccinations is NOT NULL
		and deaths.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopVaccinated



-- Create View to store data for visualizations

Create View PercentPopulationVaccinated as
Select DISTINCT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(convert(int, vax.new_vaccinations / 2)) over (PARTITION BY deaths.location order by deaths.location
, deaths.date) as RollingPeopleVaccinated
--, (RollingVaxCount/population)*100
from PortfolioProj..CovidDeaths deaths
join PortfolioProj..CovidVaccincations vax
	on deaths.location = vax.location
	and deaths.date = vax.date
	WHERE new_vaccinations is NOT NULL
		and deaths.continent is not null
--order by 2,3

--Accessing View
Select *
From PercentPopulationVaccinated