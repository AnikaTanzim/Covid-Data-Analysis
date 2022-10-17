use CovidDatabase;

select * from dbo.covidDeaths;
select * from dbo.covidVaccinations;

-- selecting data that going to be used

select location, date, total_cases, new_cases, total_deaths, population 
from dbo.covidDeaths 
order by 1,2;

select location, date, total_cases, new_cases, total_deaths, population 
from dbo.covidDeaths 
where continent is not null
order by 1,2;

--total cases vs total deaths:

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from dbo.covidDeaths 
order by 1,2;

--likelyhood of dying by country:
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from dbo.covidDeaths 
where location like '%states%'
order by 1,2;

--total cases vs population:
--popoluation percentage got covid:
select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage 
from dbo.covidDeaths 
where location like '%states%'
order by 1,2;

--which country has the highest infection rate:
select location,  population, max(total_cases) as highestInfectionRate, max((total_cases/population))*100 as popluationInfectedPercentage 
from dbo.covidDeaths 
group by location, population
order by popluationInfectedPercentage desc;

--which country has the highest death count per population:
select location,  max(cast(total_deaths as int)) as totalDeathCount
from dbo.covidDeaths 
where continent is not null
group by location 
order by totalDeathCount desc;

-- by continent
select continent,  max(cast(total_deaths as int)) as totalDeathCount
from dbo.covidDeaths 
where continent is not null
group by continent 
order by totalDeathCount desc;

select location,  max(cast(total_deaths as int)) as totalDeathCount
from dbo.covidDeaths 
where continent is null
group by location 
order by totalDeathCount desc;

--continents with highest death count per population
select continent,  max(cast(total_deaths as int)) as totalDeathCount
from dbo.covidDeaths 
where continent is not null
group by continent 
order by totalDeathCount desc;

--global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum( cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage 
from dbo.covidDeaths 
where continent is not null
group by date
order by 1,2;

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum( cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage 
from dbo.covidDeaths 
where continent is not null
order by 1,2;


--covid vaccinations

select * from dbo.covidDeaths dea
join dbo.covidVaccinations vac
on dea.location = vac.location
and dea. date = vac.date;

--total population vs vacction

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
on dea.location = vac.location
and dea. date = vac.date
where dea.continent is not null
order by 1,2,3;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
on dea.location = vac.location
and dea. date = vac.date
where dea.continent is not null
order by 2,3;

/* With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (select * from covidDeaths);

select * from PopvsVac;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
on dea.location = vac.location
and dea. date = vac.date
where dea.continent is not null  */



WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
    (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
on dea.location = vac.location
and dea. date = vac.date
where dea.continent is not null)
    select * from PopvsVac;


--select *, (RollingPeopleVaccinated)*100 from PopvsVac;

--TEMP TABLE

create table #percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.covidDeaths dea
join dbo.covidVaccinations vac
on dea.location = vac.location
and dea. date = vac.date
where dea.continent is not null
order by 2,3;

select *, (RollingPeopleVaccinated/population)*100 
from #percentpopulationvaccinated;


