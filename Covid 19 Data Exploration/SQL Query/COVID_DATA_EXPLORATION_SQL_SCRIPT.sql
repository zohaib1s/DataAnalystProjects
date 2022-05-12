 
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


 select location, date, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths$
 order by 1,2;



 -- Checking Total cases vs Total Deaths
 -- %Population contracted covid
 select location, date, total_cases, population, (total_cases/population)*100 as ContractedCovidPercentage
 from PortfolioProject..CovidDeaths$
 where location like '%States%'
 order by 1,2 desc;    


 -- Contries with highest infection rate compared to population

  select location, MAX(total_cases) as HighestInfectionCount, population, max(total_cases/population)*100 as ContractedCovidPercentage
 from PortfolioProject..CovidDeaths$
 --where location like '%pak%'
 group by location,population
 order by ContractedCovidPercentage desc;
 

 -- Death Count by Continent

 select location, MAX(cast (total_deaths as bigint)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 where continent is  null
 --where location like '%pak%'
 group by location
 order by TotalDeathCount desc;



 -- Death count by country --

  select continent, MAX(cast (total_deaths as bigint)) as TotalDeathCount
 from PortfolioProject..CovidDeaths$
 where continent is not null
 --where location like '%pak%'
 group by continent
 order by TotalDeathCount desc, 1;  


 -- World Numbers --

 select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by date
 order by 1 desc, 2;    
  


  -- COVID VACCINATIONS TABLE --


  -- Total Population vs Vaccination

  -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 