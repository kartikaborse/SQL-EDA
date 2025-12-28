update portfolio_project.coviddeaths
set continent= NULL
WHERE continent='';


select * from coviddeaths
where continent is not null
order by 3,4;

select * from covidvaccination;

select Location,date,total_cases,new_cases,total_deaths,population
from portfolio_project.coviddeaths
order by 1,2;

-- Total cases vs Total Deaths --
#shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from portfolio_project.coviddeaths
where location like '%India%'
order by 1,2;

#total cases vs population
#percentage of population got covid
select Location,date,total_cases,population, (total_cases/population)*100 as CasesPercentage
from portfolio_project.coviddeaths
where location like '%India%'
order by 1,2;

#looking at countries with highest infection rate compared to population
select Location,MAX(total_cases) AS HighestInfectionCount,population, MAX((total_cases)/population)*100 as CasesPercentage
from portfolio_project.coviddeaths
GROUP BY Location,Population
order by CasesPercentage DESC;

select total_deaths
from coviddeaths;

ALTER TABLE coviddeaths 
MODIFY COLUMN total_deaths int;

#showing countries with highest death count per population
select Location,MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolio_project.coviddeaths
where continent is not null
GROUP BY Location
order by TotalDeathCount DESC;

#breaking things by continent
select continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolio_project.coviddeaths
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC;

# showing continents with highest death count
select continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
from portfolio_project.coviddeaths
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC;

# global numbers
select date,sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from portfolio_project.coviddeaths
-- where location like '%India%'
where continent is not null
group by date
order by 1,2;

-- Total poopulation vs vaccinations
WITH deaths_agg AS (
    SELECT
        continent,
        location,
        MAX(population) AS population
    FROM portfolio_project.coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
)
SELECT
    d.continent,
    d.location,
    d.population,
    CAST(v.total_vaccinations AS UNSIGNED) AS total_vaccinations,
    CAST(v.people_vaccinated AS UNSIGNED) AS people_vaccinated,
    CAST(v.new_vaccinations AS UNSIGNED) AS new_vaccinations
FROM deaths_agg d
JOIN portfolio_project.covidvaccination v
    ON d.location = v.location
ORDER BY d.continent, d.location;

-- creating view
CREATE OR REPLACE VIEW portfolio_project.covid_vaccination_view AS
WITH deaths_agg AS (
    SELECT
        continent,
        location,
        MAX(population) AS population
    FROM portfolio_project.coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location
)
SELECT
    d.continent,
    d.location,
    d.population,
    CAST(v.total_vaccinations AS UNSIGNED) AS total_vaccinations,
    CAST(v.people_vaccinated AS UNSIGNED) AS people_vaccinated,
    CAST(v.people_fully_vaccinated AS UNSIGNED) AS people_fully_vaccinated,
    CAST(v.new_vaccinations AS UNSIGNED) AS new_vaccinations
FROM deaths_agg d
JOIN portfolio_project.covidvaccination v
    ON d.location = v.location;

