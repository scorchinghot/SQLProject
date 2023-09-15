select * 
from SQLproject..CovidDeaths
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from SQLproject..CovidDeaths
where continent is not null
order by 1,2

-- Death rate (total cases vs total deaths)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from SQLproject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Total covid spread (total cases vs population)

select location, date, population, total_cases, (total_cases/population)*100 as Spread
from SQLproject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Countries with hightest total cases vs population

select location, population, max(total_cases) as HighestSpreadCount, max((total_cases/population))*100 as HighestSpread
from SQLproject..CovidDeaths
where continent is not null
group by location, population
order by HighestSpread desc

-- Countries with highest death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

-- Countries with highest death count BY CONTINENT

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Countries with hightest death count vs population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Deaths

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathRate
from SQLproject..CovidDeaths
where continent is not null
order by 1,2

-- Total Vaccinated (total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from SQLproject..CovidDeaths dea
join SQLproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from SQLproject..CovidDeaths dea
join SQLproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table

drop table if exists #PopulationVaccinated
create table #PopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from SQLproject..CovidDeaths dea
join SQLproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PopulationVaccinated

-- View creation for data visualization

create view PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location,
dea.date) as RollingPeopleVaccinated
from SQLproject..CovidDeaths dea
join SQLproject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

create view GlobalDeathRate as
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathRate
from SQLproject..CovidDeaths
where continent is not null

create view TotalDeathCount as
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from SQLproject..CovidDeaths
where continent is not null
group by continent






