SELECT * FROM CovidDeaths 
order by 3,4

--SELECT * FROM CovidVaccinations order by 3,4

select location, date, total_cases, total_deaths,population from CovidDeaths order by 1,2

-- Looking at the total cases vs total deaths
-- shows the likelihood of dying if you contact covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_Cases)*100 
as DeathPercentage
from CovidDeaths 
where location like '%Kenya%'
order by 1,2

--looking at the total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/ population)*100 AS CasePercentage from CovidDeaths
where location like '%Kenya%'
order by 4,3

-- looking at countries with highest inffection rate compared to pupulation

select Location, Max(total_cases), Population, Max((total_cases/Population))*100 AS HighestCasePercentage from PortfolioProject..CovidDeaths
GROUP BY location, population
order by HighestCasePercentage DESC

-- looking at countries with highest death rate compared to pupulation
select location, MAX(cast(total_deaths as int)) as TotalDeaths from CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

-- looking at the continent with highest death rate compared to pupulation
select continent, MAX(cast(total_deaths as int)) as totalDeaths from CovidDeaths
where continent is  not null
group by continent
order by totalDeaths desc

--showing the continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as totalDeaths from CovidDeaths
where continent is  not null
group by continent
order by totalDeaths desc

--Total Global numbers
select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths,
SUM(cast(New_deaths as int))/SUM(New_cases)*100 as TotalDeathPercentage
from CovidDeaths 
WHERE continent is not null
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION with CTE
WITH POPVSVAC (Continent, Location, Date, Population,new_vaccinations, peopleVaccinated)
AS(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.Location,dea.Date  ROWS UNBOUNDED PRECEDING )as peopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (peopleVaccinated/Population)*100 from POPVSVAC


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
peopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.Location,dea.Date  ROWS UNBOUNDED PRECEDING )as peopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (peopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.Location,dea.Date  ROWS UNBOUNDED PRECEDING )as peopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null