select *
from CovidDeaths
where continent is not null
order by 3,4;

--select *
--from CovidVaccinations
--order by 3,4;
-- select data that i am going to be working
select location,date,total_cases,new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2
--looking at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%epa%'
order by 1,2

--Looking at total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as casePercentage
from PortfolioProject..CovidDeaths
where location like '%epa%'
order by 1,2
--Looking at contries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc;
--countries with the highest deaths count



select location, Max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathsCount desc;


--lETS BREAK THINGS DOWN BY CONTINENT
select location, Max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is null
group by location, population
order by TotalDeathsCount desc;

---showing  continents with the highest deaths count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc;
--GLOBAL NUMBERS
select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%epa%'
where continent is not null
group by date 
order by 1,2

--GLOBAL TOTAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%epa%'
where continent is not null 
order by 1,2


--COVID VACCINATIONS TABLE
SELECT * from PortfolioProject..CovidVaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollinigPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by  2,3






--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as
	(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollinigPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null)
--order by  2,3
Select * ,(RollingPeopleVaccinated/population)*100 from PopvsVac


--TEMP TABLE
create table #PercentPoulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPoulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollinigPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by  2,3
Select * ,(RollingPeopleVaccinated/population)*100 from #PercentPoulationVaccinated



--creating view to store data for later visualization.



create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollinigPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by  2,3
Select* from PercentPopulationVaccinated