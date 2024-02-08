/*
	Cleaning Data
*/
Select * From PortfolioProj..NHD

-----------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProj..NHD
/*
UPDATE NHD
SET SaleDate = CONVERT(Date,SaleDate)
	The above query did not work to convert date format
*/

-- Convert Date Format

ALTER TABLE NHD
Add SaleDateConverted Date;

UPDATE NHD
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------

--							Populate Empty Propery Address Data

-- Show Addresses with Null Values

Select *
From PortfolioProj.dbo.NHD
Where PropertyAddress is null
order by ParcelID

-- Creating column to show populated address using the ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProj.dbo.NHD a
JOIN PortfolioProj.dbo.NHD	b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Updating table to reflect satisfactory change of null values to that of ParcelID address

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProj.dbo.NHD a
JOIN PortfolioProj.dbo.NHD	b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------

-- Dividing Address into Individual Columns (i.e. Address, City, State)


Select PropertyAddress
From PortfolioProj.dbo.NHD

-- After Identifying Address and City are separated by column, using SUBSTRING & CHARINDEX to remove comma

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
From PortfolioProj.dbo.NHD


-- Create New column called PropertySplitAddress

ALTER TABLE NHD
Add PropertySplitAddress nvarchar(255);


-- Assigning newly adjusted Address values

UPDATE NHD
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


-- Creating New column called PropertySplitCity

ALTER TABLE NHD
Add PropertySplitCity nvarchar(255);


-- Assiging newly adjusted City values

UPDATE NHD
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))


-- Viewing Results

Select * 
FROM PortfolioProj.dbo.NHD






Select *
From PortfolioProj.dbo.NHD

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProj.dbo.NHD

ALTER TABLE NHD
Add OwnerSplitAddress nvarchar(255);

UPDATE NHD
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NHD
Add OwnerSplitCity nvarchar(255);

UPDATE NHD
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NHD
Add OwnerSplitState nvarchar(255);

UPDATE NHD
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


------------------------------------------------------------------------------------------------------------------------
/*
									Changing Yes and No to Y and N in 'SoldAsVacant' column
*/

-- Viewing Count of Y, N, Yes, No
Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
From PortfolioProj.dbo.NHD
Group by SoldAsVacant
order by 2

-- Changing 'Y' to 'Yes', 'N' to 'No'
Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProj.dbo.NHD

-- Update Table to reflect above changes
UPDATE NHD
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-------------------------------------------------------------------------------------------------------------------------------
/*
							Removing Duplicates
*/

WITH ROWNUMCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER By 
			UniqueID
			) row_num

FROM PortfolioProj.dbo.NHD
)
--order by ParcelID
Select *
From ROWNUMCTE
Where row_num > 1



-----------------------------------------------------------------------------------------------------------------------------------
/* 
					Remove Unused Columns
*/

Select *
From PortfolioProj.dbo.NHD

-- Converted these earlier, unusable now

ALTER TABLE PortfolioProj.dbo.NHD
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

-- *Included SaleDate Column

ALTER TABLE PortfolioProj.dbo.NHD
DROP COLUMN SaleDate