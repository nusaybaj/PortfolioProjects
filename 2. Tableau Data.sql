-- Tableau Data

-- 1. Cumulative death percentage as of now:
Select sum(New_Cases) as Total_Cases, sum(cast(New_Deaths as int)) as Total_Deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'World'
order by 1,2


-- 2. Continents w/highest death count per population:
Select Location, max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is null -- the greatest difference is this line of code
and location not in ('World', 'European Union', 'International')
group by location, population
order by 2 desc


-- 3. Countries with the highest infection percentage:
Select Location, Population, max(Total_Cases) as HighestInfectionCount, 
max((total_cases/population))*100 as PercentInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc

-- 4. Highest Percentage of Infected People: 
Select Location, Population, Date, max(Total_Cases) as HighestInfectionCount, 
max((total_cases/population))*100 as PercentInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population, date
order by 5 desc
