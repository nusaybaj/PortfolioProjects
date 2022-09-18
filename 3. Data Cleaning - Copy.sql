-- Data Cleaning in SQL 
-- This is using a copy of the orginal data (as some rows are deleted in this code)

-- 1. Standardising the Date Format
-- SalesDate has datetime format, so we need to update it to a date format

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

-- 2. Populating Blank Property Address Data
select * 
from PortfolioProject..NashvilleHousing
where PropertyAddress  is null

-- If we have a refrence point the propery address could be populated
-- For the same ParcelID, they have the same property address 
-- (but not the same UniqueID)

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null



-- 3. Breaking out Address into Individual Columns (Address, City and State)

-- PROPERTY ADDRESS:
-- Address, City

-- The city and address in the PropertyAddress column are seperated by a comma 

-- Seperating the Property Address into Address and City 
select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)
as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))
as City
from PortfolioProject..NashvilleHousing

-- Create new columns to store this
-- ADDRESS:
alter table NashvilleHousing
add Property_Address nvarchar(225);

update NashvilleHousing
set Property_Address 
= substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

-- CITY:
alter table NashvilleHousing
add Property_City nvarchar(225);

update NashvilleHousing
set Property_City
= substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))



-- OWNER ADDRESS:
-- Address, City, State

--  Seperating the Owner Address into Address, City and State:
select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
from PortfolioProject..NashvilleHousing


-- ADDRESS:
alter table NashvilleHousing
add Owner_Address nvarchar(225);

update NashvilleHousing
set Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- CITY:
alter table NashvilleHousing
add Owner_City nvarchar(225);

update NashvilleHousing
set Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- STATE:
alter table NashvilleHousing
add Owner_State nvarchar(225);

update NashvilleHousing
set Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- 4. Chnaging Y and N into Yes and No in the 'Sold as Vacant' column

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

-- update the column
update NashvilleHousing set SoldAsVacant
= case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end


-- 5. Removing Duplicates

-- find the duplicates:
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
	order by UniqueID)
	as Row_Num			
from PortfolioProject..NashvilleHousing

-- use a CTE to delete the duplicates
with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
	order by UniqueID)
	as Row_Num			
from PortfolioProject..NashvilleHousing)

delete from RowNumCTE
where Row_Num > 1


-- 6. Deleting Unused Columns
-- unused columns: SaleDate, PropertyAddress and OwnerAddress
-- as we have created other columns to store this data in a better way

alter table PortfolioProject..NashvilleHousing
drop column SaleDate, PropertyAddress, OwnerAddress

-- to double-check
select * from PortfolioProject..NashvilleHousing


