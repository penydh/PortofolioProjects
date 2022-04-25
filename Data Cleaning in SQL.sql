-- CLEANING DATA USING SQL QUERIES

select * 
from PortofolioProjects..NashvilleHouse

-- Standardize Date Format
select SaleDate, convert(Date, SaleDate) 
from PortofolioProjects..NashvilleHouse

update NashvilleHouse
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHouse
add SaleDateNew Date

update NashvilleHouse
set SaleDateNew = convert(Date, SaleDate)

select SaleDateNew
from PortofolioProjects..NashvilleHouse


-- Populate Property Address 
select *
from PortofolioProjects..NashvilleHouse
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from PortofolioProjects..NashvilleHouse a
join PortofolioProjects..NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from PortofolioProjects..NashvilleHouse a
join PortofolioProjects..NashvilleHouse b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Column (Address, City, State)
select PropertyAddress
from PortofolioProjects..NashvilleHouse

select 
SUBSTRING (PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
from PortofolioProjects..NashvilleHouse

alter table NashvilleHouse
add PropertyAddressNew nvarchar(255)

update NashvilleHouse
set PropertyAddressNew = SUBSTRING (PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHouse
add PropertyCity nvarchar(255)

update NashvilleHouse
set PropertyCity = SUBSTRING (PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

--Owner Address
select OwnerAddress 
from PortofolioProjects..NashvilleHouse

select 
parsename(replace (OwnerAddress, ',', '.'), 3),
parsename(replace (OwnerAddress, ',', '.'), 2),
parsename(replace (OwnerAddress, ',', '.'), 1)
from PortofolioProjects..NashvilleHouse

alter table NashvilleHouse
add OwnerAddressNew nvarchar(255)

update NashvilleHouse
set OwnerAddressNew = parsename(replace (OwnerAddress, ',', '.'), 3)

alter table NashvilleHouse
add OwnerCity nvarchar(255)

update NashvilleHouse
set OwnerCity = parsename(replace (OwnerAddress, ',', '.'), 2)

alter table NashvilleHouse
add OwnerState nvarchar(255)

update NashvilleHouse
set OwnerState = parsename(replace (OwnerAddress, ',', '.'), 1)


--Change Y to Yes and N to No in SoldAsVacant
select distinct SoldAsVacant, count(SoldAsVacant)
from PortofolioProjects..NashvilleHouse
group by SoldAsVacant
order by 2

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortofolioProjects..NashvilleHouse

update NashvilleHouse
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


--Remove Duplicates
with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
				 ) row_num
from PortofolioProjects..NashvilleHouse
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress


--Delete Unused Columns
select * 
from PortofolioProjects..NashvilleHouse

alter table PortofolioProjects..NashvilleHouse
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate