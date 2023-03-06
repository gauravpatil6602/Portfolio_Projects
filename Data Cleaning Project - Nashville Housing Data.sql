/* 
	DATA CLEANING IN SQL 
	NASHVILLE HOUSING DATA 
*/

----------------------------------------------------------------------------------------------------

-- Raw Data

SELECT *
FROM Nashville_Housing.dbo.Housing_Data ;

----------------------------------------------------------------------------------------------------

--	Change Data Type of SaleDate Column 

ALTER TABLE Nashville_Housing.dbo.Housing_Data
ADD SaleDateConverted Date;

UPDATE Nashville_Housing.dbo.Housing_Data
SET SaleDateConverted =  CONVERT(Date, SaleDate);

----------------------------------------------------------------------------------------------------

--	Populate PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress
FROM Nashville_Housing.dbo.Housing_Data a
JOIN Nashville_Housing.dbo.Housing_Data B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing.dbo.Housing_Data a
JOIN Nashville_Housing.dbo.Housing_Data B
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

----------------------------------------------------------------------------------------------------

-- Splitting Property Address Into Individual Columns ( Address, City)

SELECT 
PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address , 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM Nashville_Housing.dbo.Housing_Data ;

-- Add Address Column into Housing data 
ALTER TABLE Nashville_Housing.dbo.Housing_Data
ADD PropertySplitAddress NVarchar(255);

UPDATE Nashville_Housing.dbo.Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);


-- Add City Column into Housing data 
ALTER TABLE Nashville_Housing.dbo.Housing_Data
ADD PropertySplitCity NVarchar(255);

UPDATE Nashville_Housing.dbo.Housing_Data
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

-----------------------------------------------------------------------------------------------------------------


-- Splitting Owner Address Into Individual Columns ( Address, City, State)

SELECT OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville_Housing.dbo.Housing_Data ;


-- Add Owner Address Column into Housing data 
ALTER TABLE Nashville_Housing.dbo.Housing_Data
ADD OwnerSplitAddress NVarchar(255);

UPDATE Nashville_Housing.dbo.Housing_Data
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


-- Add Owner City Column into Housing data 
ALTER TABLE Nashville_Housing.dbo.Housing_Data
ADD OwnerSplitCity NVarchar(255);

UPDATE Nashville_Housing.dbo.Housing_Data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


-- Add Owner State Column into Housing data 
ALTER TABLE Nashville_Housing.dbo.Housing_Data
ADD OwnerSplitState NVarchar(255);

UPDATE Nashville_Housing.dbo.Housing_Data
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-----------------------------------------------------------------------------------------------------------------

-- Handle Redundancy Within SoldAsVacant Column

UPDATE Nashville_Housing.dbo.Housing_Data
SET SoldAsVacant = 
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------------------

-- Replace Duplicate Entries Within Landuse Column

UPDATE Nashville_Housing.dbo.Housing_Data
SET LandUse = 
	CASE WHEN LandUse = 'GREENBELT/RES GRRENBELT/RES' THEN 'GREENBELT'
		 WHEN LandUse = 'VACANT RESIENTIAL LAND'      THEN 'VACANT RESIDENTIAL LAND'
		 WHEN LandUse = 'VACANT RES LAND'             THEN 'VACANT RESIDENTIAL LAND'
		 ELSE LandUse
	END

-----------------------------------------------------------------------------------------------------------------

-- Remove duplicates

SELECT *
FROM Nashville_Housing.dbo.Housing_Data ;

WITH RowNumCTE AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) row_num
FROM Nashville_Housing.dbo.Housing_Data
)	

DELETE 
FROM RowNumCTE
WHERE row_num >1;

-----------------------------------------------------------------------------------------------------------------

-- Delete Columns that are not useful after cleaning

ALTER TABLE Nashville_Housing.dbo.Housing_Data
DROP Column SaleDate, PropertyAddress, OwnerAddress;






