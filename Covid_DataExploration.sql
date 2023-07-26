/*
Covid-19 Indian and Global statistics Data Exploration 
Date - 26-07-2023

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--creating database for this projects
CREATE DATABASE PortfolioProjects;


--using created databse
USE PortfolioProject;

--data is divide into two excel sheet deals with  covid death and vaccination process
--importing excel sheet and displaying whole table or sheet

SELECT * FROM covid_death;
SELECT * FROM covidvaccination;


-- Select Data that show Indian covid statistics

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_death
Where continent is not null and location='India'
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in India

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From covid_death
where continent is not null and Location ='India'
order by date desc


--average death rate in India

SELECT AVG((total_deaths/total_cases)*100) as average_deathpercentage From covid_death where Location='India'


--changing total case column fron nvarchar to float to do division

exec sp_help 'covid_death';
alter table covid_death alter column total_cases float

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in India

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as infected_percentage
From covid_death
where continent is not null and Location ='India'
order by date desc




SELECT Location, date,total_cases,population,(total_cases/population)*100 as average_deathpercentage From covid_death where Location='India'order by date desc 
select Location, date,total_cases,population from covid_death where Location='India' order by date desc 


--GLOBAL CASES

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_death
Group by Location, Population
order by PercentPopulationInfected desc


-- percentage of infected covid, with total percentage

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_death
where location='India'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, Population, MAX(cast(total_deaths as int)) as Total_Deaths,  Max((total_deaths/total_cases))*100 as PercentDeath
From covid_death
Where continent is not null 
Group by Location, Population
order by Total_Deaths desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as Total_Deaths,  Max((total_deaths/total_cases))*100 as PercentDeath
From covid_death
Where continent is not null 
Group by continent
order by Total_Deaths desc



--TOTAL DEATH , TOTAL DEATH , DEATHPERCENTAGE IN GLOBAL

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_death
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid_death dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid_death dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as persontageofvaccinated
From PopvsVac
order by Date desc



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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From covid_death dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100 as percentage_vaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations process

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_death dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


/*
END OF THE DATA EXPLORATION
DATA VISUALIZATION WILL DO ON NEXT PROJECT WITH THE HELP OF ANY VISUALIZATION TOOL
*/