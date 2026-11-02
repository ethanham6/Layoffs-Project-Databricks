-- Databricks notebook source
select industry, avg(funds_raised_millions) as avg_funds_raised, year(`date`), country
from layoffs_staging4
group by industry, year(`date`), country
having industry is not null
and country = 'United States'
;

select distinct year(`date`)
from layoffs_staging4
where `date` is not null
;

select distinct location, country
from layoffs_staging4
group by country, location
having country = 'United States'
;

select sum(total_laid_off), month(`date`), year(`date`)
from layoffs_staging4
group by month(`date`), year(`date`)
having sum(total_laid_off) is not null
and month(`date`) is not null
and year(`date`) is not null
;

select industry, sum(total_laid_off) as total_laid_off, year(`date`), country
from layoffs_staging4
group by industry, year(`date`), country
having industry is not null
and total_laid_off is not null
and year(`date`) is not null
and country = 'United States'
;


select industry, avg(percentage_laid_off) as avg_percentage_laid_off, year(`date`), country
from layoffs_staging4
group by industry, year(`date`), country
having industry is not null
and avg_percentage_laid_off is not null
and year(`date`) is not null
and country = 'United States'
;