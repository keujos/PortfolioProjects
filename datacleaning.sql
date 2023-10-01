-- Standardize date format

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

--Populate property adress ata

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- update
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out adress into individual columns (Adress)
SELECT PropertyAddress
FROM NashvilleHousing
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress)) as town
FROM NashvilleHousing


--CREATING THE NEW COLUMNS USED FOR SPLITTING
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress))

SELECT * from NashvilleHousing

-- Treatment with Owner address

select OwnerAddress from NashvilleHousing

--Parsename  
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),1), 
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress nvarchar(255)

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity nvarchar(255)

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER table NashvilleHousing 
ADD OwnerSplitState nvarchar(255)

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


SELECT * 
FROM NashvilleHousing

SELECT distinct(SoldAsVacant),count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

UPDATE NashvilleHousing
SET SoldAsVacant = replace(SoldAsVacant,'YES','yes')

UPDATE NashvilleHousing
SET SoldAsVacant = replace(SoldAsVacant,'NO','no')

------- Remove duplicates


with CTE as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY PARCELID,
				PropertyAddress,
				SaleDate,
				LegalReference
				ORDER BY
					UNIQUEID
					) as row_num
	from NashvilleHousing)
DELETE from cte 
where row_num>1


---Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate