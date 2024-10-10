Select*
from [Portfolia Project]..CovidDeaths
where continent is not null
order by 3,4


---Select*
----from [Portfolia Project]..CovidVaccinations
----order by 3,4

---- select data that we are going to be using

Select location, date , total_cases, new_cases, total_deaths,population 
from [Portfolia Project]..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths 
--- shows likelihood of dying if you contract covid in your country
Select location, date , total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from [Portfolia Project]..CovidDeaths
where location like '%canada%'
and continent is not null
order by 1,2


--- looking at total cases vs population 
--- shows what percentage of population got covid

Select location, date ,population, total_cases, (total_cases/population)*100 as Percentofpopulationinfected
from [Portfolia Project]..CovidDeaths
where location like '%canada%'
order by 1,2

----looking at countries with highest infection rate compared to population 

Select location,population,Max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as Percentofpopulationinfected
from [Portfolia Project]..CovidDeaths
----where location like '%canada%'
group by location,population
order by Percentofpopulationinfected desc


--showing countries with highest death count per population 

Select location,Max(cast(total_deaths as int)) as totaldeathcount
from [Portfolia Project]..CovidDeaths
----where location like '%canada%'
where continent is not null
group by location
order by totaldeathcount desc

Select location,Max(cast(total_deaths as int)) as totaldeathcount
from [Portfolia Project]..CovidDeaths
----where location like '%canada%'
where continent is null
group by location
order by totaldeathcount desc



---- Lets break things down by continent 

Select continent,Max(cast(total_deaths as int)) as totaldeathcount
from [Portfolia Project]..CovidDeaths
----where location like '%canada%'
where continent is not null
group by continent
order by totaldeathcount desc



--- showing continent with the highest death count per population

Select continent,Max(cast(total_deaths as int)) as totaldeathcount
from [Portfolia Project]..CovidDeaths
----where location like '%canada%'
where continent is not null
group by continent
order by totaldeathcount desc



---Global numbers 

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolia Project]..CovidDeaths
--where location like '%canada%'
where continent is not null
---group by date
order by 1,2



---- looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
---, (RollingpeopleVaccinated/population)*100
from [Portfolia Project]..CovidDeaths dea
join [Portfolia Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- use cte

with PopvsVac (continent, location , date, population, New_vaccinations, rollingpeoplevaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
---, (RollingpeopleVaccinated/population)*100
from [Portfolia Project]..CovidDeaths dea
join [Portfolia Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100
from PopvsVac




-- Temp table 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
---, (RollingpeopleVaccinated/population)*100
from [Portfolia Project]..CovidDeaths dea
join [Portfolia Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
----where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


---- Creating view to store data for later visualizations 

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
---, (RollingpeopleVaccinated/population)*100
from [Portfolia Project]..CovidDeaths dea
join [Portfolia Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3


Select* 
from PercentPopulationVaccinated