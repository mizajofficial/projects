--select *
--From PortfolioProject..CovidDeaths
--order by 3,4

--Select location, date,total_cases,new_cases, total_deaths,population
--From PortfolioProject..CovidDeaths
--order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths

 Where location like '%states%'
order by 1,2

--Looking at total cases vs population
-- shows what peercentage of population got covid
Select location, date,population,total_cases, total_deaths,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--countries with highest infection rate compared to population
Select location,population,MAX(total_cases) as HighestInfectionCount ,MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths

GROUP BY location,population
order by PercentPopulationInfected desc

--countries with highest Death count population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
order by TotalDeathCount desc

--Continent wise or 
--Showing the continent  with highest death count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--Global Result


Select date,SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

--looking total population vs vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 2,3



-- use CTE
with PopvsVac (continent,Location , daate, population,New_Vaccinations ,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100  as pp
from PopvsVac



--TEMP Table
Drop table if exists #PercentPopulationVaccinated
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
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVacinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100  as pp
from #PercentPopulationVaccinated


-- Creating view to store date for later visualization
create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVacinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPopulationVaccinated