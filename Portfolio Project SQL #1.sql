Select *
From CovidDeaths
where continent is not null
order by 3,4

select *
From CovidVaccinations

--Select Data that I am using

Select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states'
order by 1,2


--Looking at Total Cases vs Population
--shows what percentage of population contracted covid

Select location,date,population,total_cases,(total_cases/population)*100 as CovidPositivePercentage
from CovidDeaths
--where location like '%states'
order by 1,2

--Looking at highest infection rate for different countries

Select location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as CovidPositivePercentage
from CovidDeaths
Group by location,population
order by CovidPositivePercentage desc


--Showing countries with highest death count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


--Break down by Continent
--showing continents with highest death count per population

Select location ,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
and location like '%a'
or location like 'Europe'
Group by location
order by TotalDeathCount desc



--Global Numbers by Date

Select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where Continent is not null
group by date
order by 1,2


--Total Global numbers as of 6/22/22

Select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where Continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.Continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccineTotal
--,(rollingvaccinetotal/population)*100
From CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac (continent, Location, Date, Population,new_vaccinations, RollingVaccineTotal)
as 
(
Select dea.Continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccineTotal
--,(rollingvaccinetotal/population)*100
From CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccineTotal/Population)*100
From PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccineTotal numeric
)

Insert into #PercentPopulationVaccinated
Select dea.Continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccineTotal
--,(rollingvaccinetotal/population)*100
From CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingVaccineTotal/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.Continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccineTotal
--,(rollingvaccinetotal/population)*100
From CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


create view CountryDeathRate as
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths

create view CountryInfectionRate as
Select location,date,population,total_cases,(total_cases/population)*100 as CovidPositivePercentage
from CovidDeaths
--where location like '%states'
--order by 1,2

create view CountryDeathCount as
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
--order by TotalDeathCount desc

create view ContinentDeathCount as
Select location ,MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
and location like '%a'
or location like 'Europe'
Group by location
--order by TotalDeathCount desc
