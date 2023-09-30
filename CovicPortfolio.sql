--select * 
--from CovidDeaths$
--order by 3,4

--select * 
--from CovidVaccinations$
--order by 3,4

---- We get an interest below in knowing the percentage of death vs cases --- 
use PortfolioProject
select location,date,population,total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths$
where location like '%states%'
order by 1,2



---- Below we will try to calculate the percentage of cases vs population

select location,date,population,total_cases, population,(total_cases/population)*100 as deathpercentage
from CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at the country with the highest infected rate

SELECT top 20 location , MAX (total_cases/population)*100 as infection_rate
from CovidDeaths$ 
group by location,population 
order by infection_rate desc

-- Looking at the countries with the highest death number

SELECT continent,  max(cast(total_deaths as int)) as deathpercentage 
from CovidDeaths$
where continent is not null
group by location
order by deathpercentage desc

-- LET's break things down tby continents
--showing the continents with the highest death counts per popultation
SELECT continent,
max(cast(total_deaths as int)/population*100) as tot
from CovidDeaths$
where continent is not null
group by continent
order by tot desc

-- global numbers

SELECT sum(new_cases) as  total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
order by 1,2


select date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths$
where continent	is not null
order by 1,2

use PortfolioProject

-- looking for number of vaccination vs population
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM (cast(vac.new_vaccinations as int )) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with Popvsvac(continent, location, Date,Population,New_vaccinations, RollingPeaopleVacinnated) 
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM (cast(vac.new_vaccinations as int )) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from Popvsvac where location='albania'


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM (cast(vac.new_vaccinations as int )) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later_visualizations

create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM (cast(vac.new_vaccinations as int )) OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
where dea.continent is not null
--order by 2,3

SELECT * from PercentPopulationVaccinated













