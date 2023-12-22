-- Data Exploration

select * 
from deathinfo
where continent is not null;


-- select data to use

select location, date, total_cases, new_cases, total_deaths, population
from deathinfo
where continent is not null
order by 1,2;

-- looking at total cases vs total deaths
-- show the likelihood of dying if you contract covid in specific country
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as death_percentage
from deathinfo
where location like "%america%"
order by 1,2;

-- looking at total cses vs population
-- shows what % of population that got covid
select location, date, total_cases, population, round((total_cases/population)*100, 2) as spread_percentage
from deathinfo
where location like "%Africa%" and  continent is not null
order by 1,2;


-- looking at countries with highest infection rate compared to population
select location, max(total_cases) as highest_infection, population, max(round((total_cases/population)*100, 2)) as population_infected_percentage
from deathinfo
where continent is not null
group by location, population
order by population_infected_percentage desc;

-- showing countries with highest death count by population

select location, population, max(convert(total_deaths, double)) as total_death_count,  max(round((total_deaths/population)*100, 2)) as death_percentage
from deathinfo
where continent is not null
group by location
order by total_death_count desc;


-- Exploring continents
-- showing continents with highest death count

select continent, max(CAST(total_deaths AS double)) as total_death_count
from deathinfo
where continent is not null and continent != ''
group by continent
order by total_death_count desc;

select location, max(CAST(total_deaths AS double)) as total_death_count
from deathinfo
where continent is null -- and continent != ''
group by location
order by total_death_count desc;

-- Global facts

select date, total_cases, total_deaths,  round((total_deaths/population)*100, 2) as death_percentage
from deathinfo
where continent is not null
group by date
order by death_percentage desc;


select date, sum(new_cases) as global_new_cases, sum(new_deaths) as global_new_deaths , round((sum(new_deaths)/sum(new_cases))*100,2)  as death_percentage
from deathinfo
where continent is not null
group by date
order by global_new_cases desc;

-- Overall facts

select sum(new_cases) as global_new_cases, sum(new_deaths) as global_new_deaths , round((sum(new_deaths)/sum(new_cases))*100,2)  as death_percentage
from deathinfo
where continent is not null;


-- Join tables

select *
from deathinfo death
join vacinfo vac
on death.location = vac.location
and death.date = vac.date;


-- Total vaccination vs population

select death.continent, death.location, death.date, death.population, vac.new_vaccinations
from deathinfo death
join vacinfo vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
order by 2,3;


-- Cumulative count of new Vaccination per location

select death.continent, death.location, death.date, death.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by death.location, death.date) as Cumulative_total_vaccinations
from deathinfo death
join vacinfo vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
-- and new_vaccinations > 0
order by 2,3;

-- Use CTE

with population_vs_vaccination (continent, location, date, population, new_vaccinations, Cumulative_total_vaccinations)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by death.location, death.date) as Cumulative_total_vaccinations
from deathinfo death
join vacinfo vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
-- order by 2,3
)
select *,  round((Cumulative_total_vaccinations/population)*100, 3) as vaccination_percentage
from population_vs_vaccination;


-- Temp table

drop table if exists vaccinated_percentage
/*create temporary Table #vaccinated_percentage (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Cumulative_total_vaccinations numeric
)

insert into #vaccinated_percentage*/

create temporary table vaccinated_percentage as

select death.continent, death.location, death.date, death.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by death.location, death.date) as Cumulative_total_vaccinations
from deathinfo death
join vacinfo vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null;

-- analyze vaccinated_percentage;

select * from  vaccinated_percentage;


-- View (storing data for visualization)

create view vaccinated_percentage as 
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by location order by death.location, death.date) as Cumulative_total_vaccinations
from deathinfo death
join vacinfo vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null;
