select * 
from DataCleaning..Data 

-- Standardizing data format

alter table Data
add fixedsaledate date;
update Data
set fixedsaledate = convert(date, SaleDate)
alter table data
drop column Saledate;
exec sp_rename 'Data.fixedsaledate', 'Saledate', 'column';

-- Filling the missing values

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from DataCleaning..Data a
join DataCleaning..Data b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from DataCleaning..Data a
join DataCleaning..Data b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Cleaning Address (PropertyAddress)

select
parsename(replace(PropertyAddress, ',','.'), 2),
parsename(replace(PropertyAddress, ',','.'), 1)
from Data

alter table Data
add fixedPropertyAddress nvarchar(255);
update DataCleaning..Data
set fixedPropertyAddress = parsename(replace(PropertyAddress, ',','.'), 2)

alter table Data
add PropertyAddressCity nvarchar(255);
update DataCleaning..Data
set PropertyAddressCity = parsename(replace(PropertyAddress, ',','.'), 1)

alter table data
drop column PropertyAddress;
exec sp_rename 'Data.fixedPropertyAddress', 'PropertyAddress', 'column';

-- Cleaning Address part 2 (OwnerAddress)

select *
from Data
order by ParcelID

select
parsename(replace(OwnerAddress, ',','.'), 3),
parsename(replace(OwnerAddress, ',','.'), 2),
parsename(replace(OwnerAddress, ',','.'), 1)
from Data
order by ParcelID

alter table Data
add fixedOwnerAddress nvarchar(255);
update DataCleaning..Data
set fixedOwnerAddress = parsename(replace(OwnerAddress, ',','.'), 3)

alter table Data
add OwnerAddressCity nvarchar(255);
update DataCleaning..Data
set OwnerAddressCity = parsename(replace(OwnerAddress, ',','.'), 2)

alter table Data
add OwnerAddressState nvarchar(255);
update DataCleaning..Data
set OwnerAddressState = parsename(replace(OwnerAddress, ',','.'), 1)

alter table data
drop column OwnerAddress;
exec sp_rename 'Data.fixedOwnerAddress', 'OwnerAddress', 'column';

-- Fixing you're hot then you're cold you're yes then you're no you're in then.. cough cough i mean fixing y and n

select distinct(SoldAsVacant), count(SoldAsVacant)
from Data
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from Data

update Data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

-- Excel is best for removing duplicates