/*
CLEANING DATA QUERIES
*/

SELECT *
FROM PortfolioProject..NashvilleHousing

-- STANDARIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT(DATE, SALEDATE)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(DATE, SALEDATE)

ALTER TABLE NashvilleHousing 
add SaleDateConverted DATE;

update NashvilleHousing
set SaleDateConverted = convert(date, saledate )



-- populate property address data

select [UniqueID ], PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null









--   Breaking out address into individual columns (Address, city, state)


select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
substring(PropertyAddress,1, charindex(',', PropertyAddress) -1) as address,
substring(PropertyAddress,charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing 
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress,1, charindex(',', propertyaddress) -1)

ALTER TABLE NashvilleHousing 
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(propertyaddress,charindex(',', propertyaddress) +1, LEN(propertyaddress))






-- Spliting ownwer address

ALTER TABLE NashvilleHousing 
add OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing 
add OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing 
add OwnerSplitState nvarchar(255);

select
PARSENAME(replace(OwnerAddress, ',','.'),3),
PARSENAME(replace(OwnerAddress, ',','.'),2),
PARSENAME(replace(OwnerAddress, ',','.'),1)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'),3)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'),2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'),1)





-- change Y and N yes and no in "sold as vacant" field
SELECT distinct(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing


SELECT SoldAsVacant
, case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   else SoldAsVacant
	   END







-- Remove duplicates 

with RowNumCTE as (
SELECT *, 
		ROW_NUMBER() over (
		partition by ParcelId,
		 PropertyAddress, 
		 SalePrice, 
		 SaleDate, 
		 LegalReference
		 order by UniqueId) row_num
FROM PortfolioProject..NashvilleHousing
--order by parcelid
)
select *
from RowNumCTE
where row_num > 1



-- Delete unused columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate