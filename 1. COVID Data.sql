-- COVID DEATHS

Select * from PortfolioProject..CovidDeaths
order by 3,4

-- this data has set some continents as location
-- to get rid of this, so we can look at countires only:
Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- similarly if you want to view the data by continents:
Select * from PortfolioProject..CovidDeaths
where continent is null
order by 3,4


-- Select data we're going to use:
Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Lookating at total cases vs total deaths:
Select Location, Date, Total_Cases, Total_Deaths,
(total_deaths/total_cases)*100 as Death_Percentage 
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2
-- shows the likelihood of dying friom COVID in UK 

-- Lookating at total cases vs population:
Select Location, Date, Total_Cases, Population,
(total_cases/population)*100 as Infected_Percentage 
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2
-- shows the likelihood of contracting COVID in UK

-- Countries with the highest infection count:
Select Location, Population, max(Total_Cases) as HighestInfectionCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- Countries with the highest infection rates:
Select Location, Population, max(Total_Cases) as HighestInfectionCount, 
max((total_cases/population))*100 as InfectionRate
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc

-- Countries with the highest death count:
-- total_deaths current dtype is nvarchar and needs to be convereted to an integer
Select Location, max(cast(Total_Deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 2 desc


-- Countries with the highest death % per population:
Select Location,  max((cast(total_deaths as int))/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 2 desc

-- Only European Countries:
Select Location, max(cast(Total_Deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent = 'Europe'
group by location, population
order by 2 desc

-- BY CONTININET

-- Continents w/highest death count per population:
Select Location, max(cast(Total_Deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is null -- the greatest difference is this line of code
group by location, population
order by 2 desc

-- Continents w/highest death % per population:
Create view DeathPercentage as
Select Location,  max((cast(total_deaths as int))/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is null
group by location, population


-- GLOBAL NUMBERS

-- Daily Global Death Percentage:
Select Date, Total_Cases, Total_Deaths, New_Cases, 
(cast(total_deaths as int)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'World'
order by 1,2

-- Cumulative death percentage as of now:
Select sum(Total_Cases) as Total_Cases, sum(cast(Total_Deaths as int)) as Total_Deaths,
(sum(cast(total_deaths as int))/sum(total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'World'
order by 1,2

-- Total new cases across the globe everyday:
Select Date, sum(New_Cases) as GlobalCases
from PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1,2

-- Total new cases and total deaths across the globe everyday:
Select Date, sum(New_Cases) as GlobalCases, 
sum(cast(new_deaths as int)) as GlobalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1,2

-- Death percentage per new case
Select Date, sum(New_Cases) as Sum_NewCases , sum(cast(Total_Deaths as int)) as Total_Deaths,
(sum(cast(total_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- ------------------------------------------------------------------------------------

-- COVID VACCINATIONS
Select * from PortfolioProject..CovidVaccinations

-- Joining the two tables:
Select * from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date

-- Looking at total population vs vaccinations:
-- note: people_vaccinated dtype is nvarchar
Select dea.Continent, dea.Location, dea.Date, dea.Population, cast(vac.People_Vaccinated as int), 
(cast(vac.people_vaccinated as int)/dea.population)*100 as VaccinatedPercentage
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- New Vaccinations Rollover:
-- create a CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Cummulative_New_Vaccinations)
as
(
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as Cummulative_New_Vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
-- New vaccinations Rollover and Percentage:
-- Using the CTE
Select * , (Cummulative_New_Vaccinations/Population)*100 
as VaccinatedPercentage from PopvsVac

-- Creating View for later visualisation:
Create view PercentPopulationVaccinated as 
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as Cummulative_New_Vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


-- Looking at only current vaccinated percentage:
Select dea.Location, dea.Population,
sum(convert(int, vac.new_vaccinations)) as New_Vaccinated, 
(sum(convert(int, vac.new_vaccinations))/population)*100 as Newly_Vaccinated_Percentage
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.location, dea.population
order by 1


-- TEMP Table
drop table  if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Cummulative_New_Vaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as Cummulative_New_Vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * , (Cummulative_New_Vaccinations/Population)*100 
as VaccinatedPercentage from #PercentPopulationVaccinated




