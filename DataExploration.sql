	Select *
	From PortfolioSQL..CovidDeaths
	Order by 3,4

	Select *
	From PortfolioSQL..CovidVaccinations
	Order by 3,4


	Select location, population, MAX(cast (total_cases as int)) as HighestInfectedCount
	From PortfolioSQL..CovidDeaths
	Where continent is not null
	Group by location, population
	Order by 3 Desc

	--Continents count
	Select location, population, MAX(cast (total_cases as int)) as HighestInfectedCount, MAX(CAST(total_deaths as int)) as DeathCount
	From PortfolioSQL..CovidDeaths
	Where continent is null 
	And population is not null
	Group by location, population
	Order by 3 Desc

	--Just curiosity on my country's stats
	Select location, MAx(total_cases) as TotalCases, population, Max(total_cases/population)*100 as PercPeopleInfected
	From PortfolioSQL..CovidDeaths
	Where location like 'Portugal'
	Group by location, population
	
	--Countries ordered by highest percentage of people infected
	Select location, MAx(total_cases) as TotalCases, population, Max(total_cases/population)*100 as PercPeopleInfected
	From PortfolioSQL..CovidDeaths
	Where continent is not null 
	And population is not null
	Group by location, population
	Order by PercPeopleInfected desc, population


	Select dea.location, Max(Convert(int,vac.people_vaccinated)) as TotalPeopleVaccinated
	From PortfolioSQL..CovidDeaths dea
	Join PortfolioSQL..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	Where dea.continent is not null
	Group by dea.location
	Order by 2 desc


	Select dea.location, dea.date, vac.new_vaccinations, Sum(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location Order by 
	dea.date) as SumVaccines
	From PortfolioSQL..CovidDeaths dea
	Join PortfolioSQL..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	Where dea.continent is not null
	and dea.location like 'Portugal'
	

	With PopvsVac (Location, Date, Population, New_Vaccinations, SumVaccines)
	as
	(

	Select dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by 
	dea.date) as SumVaccines
	From PortfolioSQL..CovidDeaths dea
	Join PortfolioSQL..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	Where dea.continent is not null
	)
	Select * , (SumVaccines/Population)*100 as PercentageVacc
	From PopvsVac



	--Creating a table and drop values in there
	Drop Table if exists #PercPeopleVacc
	Create Table #PercPeopleVacc
	(
	--Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	SumVaccines numeric
	)

	Insert into #PercPeopleVacc
	Select dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by 
	dea.date) as SumVaccines
	From PortfolioSQL..CovidDeaths dea
	Join PortfolioSQL..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	Where dea.continent is not null
	
	Select * ,(SumVaccines/Population)*100 as PercentageVacc
	From #PercPeopleVacc

	
	Create View PercentageofVacc as 
	Select dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by 
	dea.date) as SumVaccines
	From PortfolioSQL..CovidDeaths dea
	Join PortfolioSQL..CovidVaccinations vac
		On dea.location=vac.location
		and dea.date=vac.date
	Where dea.continent is not null
	
	Select * 
	From PercentageofVacc