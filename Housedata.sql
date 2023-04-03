Select * from House..Sheet;

--A.Standardize Date Foramt

Select SaleDate , CONVERT(date,SaleDate)
from House..Sheet;

UPDATE House..Sheet
SET SaleDate = CONVERT(date,SaleDate);
--here the update is not worked so we added a new column 

ALTER TABLE House..Sheet
ADD SaleDate_Converted date;

UPDATE House..Sheet
SET SaleDate_Converted = CONVERT(date,SaleDate);

Select SaleDate_Converted 
from House..Sheet;

-------------------------------------------------------------------------------------------------
-- B.Popoulate Property Address data(Fill up missing data)

Select PropertyAddress
from House..Sheet;

--1. checking for null data
Select PropertyAddress
from House..Sheet
WHERE PropertyAddress is NULL;

--2.fill the null column
--For that we will join same table to and with a codition

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from House..Sheet a
JOIN House..Sheet b
 ON a.ParcelID =b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null ;

 --Condition : if ParcelID of a =ParcelID of b with will copy the address of a to b

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 from House..Sheet a
JOIN House..Sheet b
 ON a.ParcelID =b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null ;

 Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from House..Sheet a
JOIN House..Sheet b
 ON a.ParcelID =b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ];

 ----------------------------------------------------------------------------------------------------------------
 --C.Breaking the address in to separate columns( Address , city ,state )

SELECT PropertyAddress
FROM House..Sheet;

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
FROM House..Sheet

ALTER TABLE House..Sheet
ADD PropertySplit_Address Nvarchar(255);

UPDATE House..Sheet
SET PropertySplit_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) ;

ALTER TABLE House..Sheet
ADD PropertySplit_City Nvarchar(255);

UPDATE House..Sheet
SET PropertySplit_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) ;

SELECT * 
FROM House..Sheet;

SELECT OwnerAddress 
FROM House..Sheet;

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM House..Sheet;

ALTER TABLE House..Sheet
ADD OwnerSplit_Address Nvarchar(255);

UPDATE House..Sheet
SET OwnerSplit_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE House..Sheet
ADD OwnerSplit_City Nvarchar(255);

UPDATE House..Sheet
SET OwnerSplit_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE House..Sheet
ADD OwnerSplit_State Nvarchar(255);

UPDATE House..Sheet
SET OwnerSplit_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--------------------------------------------------------------------------------------------------------------
---D. CHANGING Y AND N into Yes AND NO in Sold As Vacant

SELECT SoldAsVacant
FROM House..Sheet;

SELECT DISTINCT(SoldAsVacant)
FROM House..Sheet;

--Now check how many needed to change
SELECT DISTINCT(SoldAsVacant) ,Count(SoldAsVacant) 
FROM House..Sheet
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant ,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM House..Sheet;

--NOW we are adding this to the table

UPDATE House..Sheet
SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				  WHEN SoldAsVacant = 'N' THEN 'No'
			      ELSE SoldAsVacant
				  END;

-----------------------------------------------------------------------------------------------------------

--E.Remove Duplicates
SELECT *
FROM House..Sheet;

--now we will be selecting some rows find if ther are duplicate of this row 
--if there it will add up it presence value

SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
			  PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference
			  ORDER BY UniqueID
			  ) row_num
FROM House..Sheet
ORDER BY ParcelID;
--Since there are some rows(104), we need to delete it

WITH RowCTE AS (
	SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
			  PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference
			  ORDER BY UniqueID
			  ) row_num
FROM House..Sheet
)
--Select COUNT(*)
--FROM RowCTE
--WHERE row_num >1
--ORDER BY PropertyAddress;

--TO Delete 104 ROWS

DELETE
FROM RowCTE
WHERE row_num >1

--------------------------------------------------------------------------------------------------

--F. Remove Unused columns
SELECT * 
FROM House..Sheet;
--Since we have cleaned the data the way we wanted we can now delete the columns
-- we will be removing the orginal columns which we splited

ALTER TABLE House..Sheet
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict;

ALTER TABLE House..Sheet
DROP COLUMN SaleDate;

--By doing this project we have made the data more useable way.