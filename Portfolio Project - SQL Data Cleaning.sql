--Cleaning Data In SQL Queries

Select *
From NashvilleHousing

--Standardize Date Format

Select SaleDateconverted, Convert(date,saledate)
from NashvilleHousing

update NashvilleHousing
set saledate = Convert(date,saledate)

Alter table nashvillehousing
add SaleDateConverted date


update NashvilleHousing
set saledateconverted = Convert(date,saledate)



--Populate Property Address Data

Select *
from NashvilleHousing
--where PropertyAddress is null
order by parcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null


update a
set propertyaddress=ISNULL(a.propertyaddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a. PropertyAddress is null



--Breaking out address into individual columns (address,City,State)

Select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by parcelID

Select substring(Propertyaddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(Propertyaddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))as Address

From NashvilleHousing


Alter table nashvillehousing
add PropertySplitAddress nvarchar(255);


update NashvilleHousing
set PropertySplitAddress =substring(Propertyaddress,1,charindex(',',PropertyAddress)-1)

Alter table nashvillehousing
add PropertySplitCity nvarchar(255)


update NashvilleHousing
set PropertySplitCity =substring(Propertyaddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))


Select *
From NashvilleHousing



Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
From NashvilleHousing

Alter table nashvillehousing
add OwnerSplitAddress nvarchar(255)


update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

Alter table nashvillehousing
add OwnerSplitCity nvarchar(255)


update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter table nashvillehousing
add OwnerSplitState nvarchar(255)


update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)

Select *
From NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case
	When SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End



--Remove Duplicates

With RowNumCTE as(
Select *,
ROW_NUMBER() Over (
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
Order By UniqueID
) row_num
From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress



--Delete Columns not being used

Alter table NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

Alter table NashvilleHousing
Drop Column SaleDate