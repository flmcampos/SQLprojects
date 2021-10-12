Select *
From PortfolioSQL..Nashville

--Standarize Date Format

Select SaleDate, Cast(SaleDate as Date)
From PortfolioSQL..Nashville


Alter Table PortfolioSQL..Nashville
Alter Column SaleDate Date Not Null


--Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioSQL..Nashville a
Join PortfolioSQL..Nashville b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioSQL..Nashville a
Join PortfolioSQL..Nashville b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Select PropertyAddress
From PortfolioSQL..Nashville
--Where PropertyAddress is Null



--Breaking Out Address Into Individual Columns (Address, City, State)

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioSQL..Nashville



Alter Table PortfolioSQL..Nashville
Add p_Address Nvarchar(255)

Update PortfolioSQL..Nashville
Set p_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

Select p_Address
From PortfolioSQL..Nashville



Alter Table PortfolioSQL..Nashville
Add p_City Nvarchar(255)

Update PortfolioSQL..Nashville
Set p_City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioSQL..Nashville

--Change Y and N to Yes or No in "Sold as Vacant" field

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From PortfolioSQL..Nashville
Group by SoldAsVacant
Order by 2

Select
CASE When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	Else SoldAsVacant
	End
From PortfolioSQL..Nashville

Update Nashville
Set SoldAsVacant = 
CASE When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	Else SoldAsVacant
	End
From PortfolioSQL..Nashville



--Remove duplicates

WITH CTE_Row AS (
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate
				 Order by 
					UniqueID
					) row_num
From PortfolioSQL..Nashville
)

Select *
From CTE_Row
Where row_num > 1


--Delete unused columns

Select *
From PortfolioSQL..Nashville


Alter Table PortfolioSQL..Nashville
Drop Column OwnerAddress, TaxDistrict, PropertyAddress