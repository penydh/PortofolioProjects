select * 
from PortofolioProjects..CovidDeaths
order by 3,4

--select * 
--from PortofolioProjects..CovidVaccinations
--order by 3,4

--Select Data that we are going to using
select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProjects..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProjects..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Total Cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortofolioProjects..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Countries with Highest Infection Rate Compared to Population
select 
	location, 
	population, 
	max(total_cases) as HighestInfectionCount, 
	max((total_cases/population))*100 as PercentagePopulationInfected
from PortofolioProjects..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population
select 
	location,  
	max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc
 
 --Let's Break Things Down by Continent
 --Showing Continents with the highest death count per population
select 
	continent,  
	max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 


--Looking at Total Population vs Vaccination
--use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) 
	over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortofolioProjects..CovidDeaths dea
join PortofolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) 
	over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortofolioProjects..CovidDeaths dea
join PortofolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations
create view PercentPopulationsVaccinated as
select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) 
	over (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortofolioProjects..CovidDeaths dea
join PortofolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated