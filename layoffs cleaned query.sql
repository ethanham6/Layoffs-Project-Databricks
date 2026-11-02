-- Databricks notebook source
select count(*)
from layoffs_raw
;

create table layoffs_staging
like layoffs_raw
;

insert into table layoffs_staging
select *
from layoffs_raw
;

select *
from layoffs_staging
;

select *, row_number() over(partition by company, 'location', industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions order by funds_raised_millions) as row_num
from layoffs_staging
;

with duplicate_cte as (select *, row_number() over(partition by company, 'location', industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions order by funds_raised_millions) as row_num
from layoffs_staging)
select * from duplicate_cte
where row_num > 1
;

create table layoffs_staging2 (company
string,
location
string,
industry
string,
total_laid_off
string,
percentage_laid_off
string,
`date`
string,
stage
string,
country
string,
funds_raised_millions
string,
row_num int)
;

select *
from layoffs_staging2
;

insert into layoffs_staging2
select *, row_number() over(partition by company, 'location', industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions order by funds_raised_millions) as row_num
from layoffs_staging
;

delete 
from layoffs_staging2
where row_num > 1
;

select distinct row_num
from layoffs_staging2
;

select distinct company
from layoffs_staging2
order by company
;

update layoffs_staging2
set company = 'AppGate'
where company = 'Appgate'
;

select distinct company, trim(company)
from layoffs_staging2
order by company
;

update layoffs_staging2
set company = trim(company)
;

select distinct location
from layoffs_staging2
order by location
;

update layoffs_staging2
set location = trim(location)
;

select distinct industry
from layoffs_staging2
order by 1
;

update layoffs_staging2
set industry = 'Crypto'
where industry = 'Crypto Currency'
or industry = 'CryptoCurrency'
;

select *
from layoffs_staging2
where industry = 'Null'
;

update layoffs_staging2
set industry = null
where industry = 'NULL'
;

select *
from layoffs_staging2
where industry is null
;

update layoffs_staging2
set total_laid_off = null
where total_laid_off = 'NULL'
;

select *
from layoffs_staging2
where total_laid_off is null
and company = `Bally's Interactive`
;

select distinct company
from layoffs_staging2
order by 1
;

select *
from layoffs_staging2
where company like 'Bally%'
;

select distinct percentage_laid_off
from layoffs_staging2
order by 1
;

select *
from layoffs_staging2
;

update layoffs_staging2
set industry = trim(industry)
;

select distinct total_laid_off
from layoffs_staging2
;

CREATE OR REPLACE TABLE layoffs_staging3 AS
SELECT
  * EXCEPT (total_laid_off, percentage_laid_off,funds_raised_millions), 
  try_cast(total_laid_off AS double) AS total_laid_off,
 try_cast(percentage_laid_off AS double) AS percentage_laid_off,
 try_cast(funds_raised_millions AS double) AS funds_raised_millions
FROM layoffs_staging2
;

select distinct try_to_date (`date`, 'M/d/yyyy') as `date`
from layoffs_staging3
;

select distinct `date`
from layoffs_staging3
order by 1
;

create or replace table layoffs_staging4 as 
select * except (`date`),
try_to_date(`date`, 'M/d/yyyy') as `date`
from layoffs_staging3
;

select distinct total_laid_off
from layoffs_staging4
order by 1 desc
;

select  distinct total_laid_off
from layoffs_raw
order by 1 
;

select distinct country
from layoffs_staging4
order by 1
;

update layoffs_staging4
set country = 'United States'
where country = 'United States.'
;

ALTER TABLE layoffs_staging4 SET TBLPROPERTIES (
  'delta.columnMapping.mode' = 'name',
  'delta.minReaderVersion' = '2',
  'delta.minWriterVersion' = '5'
);

ALTER TABLE layoffs_staging4
DROP COLUMN row_num;

select *
from layoffs_staging4
;

delete
from layoffs_staging4
where total_laid_off is null
and percentage_laid_off is null
;

select distinct company
from layoffs_staging4
order by 1
;

select *
from layoffs_staging4 t1
join layoffs_staging4 t2
on t1.company = t2.company
where t1.industry is null
and t2.industry is not null
;

update layoffs_staging4
set industry = null
where industry = 'NULL'
or industry = ''
;

MERGE INTO layoffs_staging4 t1
USING (
  SELECT company, MAX(industry) AS industry
  FROM layoffs_staging4
  WHERE industry IS NOT NULL
  GROUP BY company
) t2
ON t1.company = t2.company
WHEN MATCHED AND t1.industry IS NULL THEN
  UPDATE SET t1.industry = t2.industry
  ;

select *
from layoffs_staging4
where company = 'Airbnb'
;

select * 
from layoffs_staging4
order by 1
;