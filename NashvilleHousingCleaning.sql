--So, This project involves Data cleaning on the NashvilleHousing Dataset wth the use of SQL


select * from sqlcleaning..NashvilleHousing;


--Standardizing The Date Format
select SaleDate, CONVERT(DATE, SaleDate) 
from sqlcleaning..NashvilleHousing;

ALTER table NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

SELECT * from NashvilleHousing;


--Populate the Property Address

select * from NashvilleHousing
where PropertyAddress is null ;

-- So now we can see there are null values in the property address column,what are we going to populate it with, 
--Let's explore more on the data 
select * from NashvilleHousing 
order by ParcelID;

--So thus we noticed that Duplicates  ParcelIDs shares the same property address,   Thus we proceed by populating them.

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	WHERE a.UniqueID <> b.UniqueID
	and a.PropertyAddress is null;


select * from NashvilleHousing
where PropertyAddress is null;

--Thus we can see there are no null values anymore in the PropertyAddress column.


-- Next Step will involve breaking out address into individual columns(Address, City)

select PropertyAddress
from sqlcleaning..NashvilleHousing;

--There's a delimeter, that's the comma and that will be used for separation into individual columns
--Here, we'll make use of character index, which will return the position of a character in a set of words.

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from 
sqlcleaning..NashvilleHousing;

--So thus we'll proceed by adding new columns to the table

ALTER TABLE sqlcleaning..NashvilleHousing
Add PropertyAddressNew nvarchar(255);

ALTER TABLE sqlcleaning..NashvilleHousing
Add PropertyCity nvarchar(255);

UPDATE sqlcleaning..NashvilleHousing
SET PropertyAddressNew = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


UPDATE sqlcleaning..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from sqlcleaning..NashvilleHousing

--We can also do the same for owner's Address

select OwnerAddress
from sqlcleaning..NashvilleHousing;

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)  as OwnerSplitAddress
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)  as OwnerSplitCity
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)  as OwnerSplitState

from sqlcleaning..NashvilleHousing;

ALTER TABLE sqlcleaning..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE sqlcleaning..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE sqlcleaning..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE sqlcleaning..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE sqlcleaning..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE sqlcleaning..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT 
ParcelID,
OwnerSplitAddress,
OwnerSplitCity,
OwnerSplitState

FROM
sqlcleaning..NashvilleHousing

order by ParcelID;


select * 
from sqlcleaning..NashvilleHousing;

--So we change the Y, N to Yes , No respectively in the 

select DISTINCT(SoldAsVacant),
COUNT(SoldAsVacant)
from sqlcleaning..NashvilleHousing
GROUP BY SoldAsVacant
order by 2 asc;

select 
SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

from sqlcleaning..NashvilleHousing

UPDATE sqlcleaning..NashvilleHousing
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

from sqlcleaning..NashvilleHousing;
select * from sqlcleaning..NashvilleHousing;


--REMOVE DUPLICATES

 --We'll make use of CTE's and function ROWNUMBER to remove duplicate rows in the table

 WITH ROWNUMCTE AS(

 select *, 
 ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, LegalReference
				Order by UniqueID) as row_num

from sqlcleaning..NashvilleHousing
) 


SELECT * FROM ROWNUMCTE
WHERE row_num > 1

-- thus we don't have any duplicate entries anymore

-- LAST STEP 
--DELETING UNUSED COLUMNS

SELECT * FROM sqlcleaning..NashvilleHousing;

ALTER TABLE sqlcleaning..NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress;

--We've Successfully tried as much as possible to clean this dataset.