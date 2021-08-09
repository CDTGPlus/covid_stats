select * 
from Neo_project..['cavid_casualties']
order by 3,4

--select * 
--from Neo_project..['cavid_vaccinations']
--order by 3,4

--Select the data that will be utylized 
select location,date, total_cases, new_cases, total_deaths, population
from Neo_project..['cavid_casualties']
order by 1,2

--Analyze total cases vs total deaths 

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality_percentage
from Neo_project..['cavid_casualties']
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows percentage of the population that has had covid

select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from Neo_project..['cavid_casualties']
where location like '%states%'
order by 1,2

--Get the countries with the highest infection rate frompared to population

select location, population, max(total_cases) as highest_infect_count, max((total_cases/population))*100 as infection_percentage
from Neo_project..['cavid_casualties']
group by location, population
order by infection_percentage desc

--show the countries with the highest mortality rate

select location, max(cast(total_deaths as int)) as total_mortality_count
from Neo_project..['cavid_casualties']
where continent is not null
group by location
order by total_mortality_count desc

--break stats by continent 

select continent, max(cast(total_deaths as int)) as total_mortality_count
from Neo_project..['cavid_casualties']
where continent is not null
group by continent
order by total_mortality_count desc


--Global metrics 

select date, sum(total_cases) as total_cases, sum(cast(new_deaths as int)) as total_casualties,
	sum(cast(new_deaths as int))/sum(new_cases) * 100 as mortality_percentage
from Neo_project..['cavid_casualties']
where continent is not null
group by date
order by 1,2


--analyze total population vs vaccination 

select * 
from Neo_project..['cavid_casualties'] dea
join Neo_project..['cavid_vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date


--use CTE 

with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccination)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination
from Neo_project..['cavid_casualties'] dea
join Neo_project..['cavid_vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, (rolling_vaccination/population)*100
from pop_vs_vac

--temp table
drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
rolling_pop_vaccinated numeric
)


insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination
from Neo_project..['cavid_casualties'] dea
join Neo_project..['cavid_vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (rolling_pop_vaccinated/population)*100
from #percent_population_vaccinated


--create view 

create view percent_pop_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccination
from Neo_project..['cavid_casualties'] dea
join Neo_project..['cavid_vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

