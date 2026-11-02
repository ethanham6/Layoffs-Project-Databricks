# Global Layoffs Data Analysis (Databricks)

An end-to-end data project using **Databricks SQL** to clean, explore, and visualize a dataset of company layoffs from 2020 to 2023.

## Project Overview

This project takes a raw layoffs dataset and walks through the full analysis workflow:

1. **Data cleaning**: remove duplicates, fix data types, and handle missing values
2. **Exploratory data analysis (EDA)**: find trends by company, industry, country, and time
3. **Visualization**: build an interactive AI/BI dashboard with a year filter

## Tools Used

- Databricks (SQL editor, Unity Catalog, Delta tables)
- Databricks SQL
- Databricks AI/BI Dashboards

## Dataset

The dataset contains one row per layoff event, with these columns:

| Column | Description |
|--------|-------------|
| `company` | Company that had layoffs |
| `location` | City or region of the company |
| `industry` | Industry the company belongs to |
| `total_laid_off` | Number of employees laid off |
| `percentage_laid_off` | Fraction of the workforce laid off |
| `date` | Date of the layoff event |
| `stage` | Funding stage of the company |
| `country` | Country of the company |
| `funds_raised_millions` | Total funds raised, in millions of USD |

**Cleaned dataset snapshot** (`Layoffs_cleaned.csv`):

| Metric | Value |
|--------|-------|
| Layoff events | 1,000 |
| Date range | March 11, 2020 to March 6, 2023 |
| Unique companies | 826 |
| Industries | 30 |
| Countries | 39 |
| Total employees laid off (where reported) | 191,579 |

Some values are legitimately unknown in the source, so they remain `NULL` after cleaning: `total_laid_off` (187 rows), `percentage_laid_off` (213), `funds_raised_millions` (90), and a handful of `industry`, `stage`, and `date` values.

## Data Cleaning

Cleaning was done in staging tables so the raw data stays untouched.

| Step | What I did |
|------|-----------|
| Staging tables | Created `layoffs_staging2`, `layoffs_staging3`, and `layoffs_staging4` to keep each cleaning step separate and reversible |
| Remove duplicates | Used `ROW_NUMBER()` with `PARTITION BY` to flag duplicate rows (`row_num`), deleted them, then dropped the helper column |
| Fix data types | Converted `total_laid_off` to `INT` and `percentage_laid_off` to `DOUBLE` using `try_cast` |
| Fix dates | Converted the `date` column from text to `DATE` using `try_to_date(`date`, 'M/d/yyyy')` |
| Handle blanks and nulls | Converted empty strings to `NULL` so they are handled consistently |
| Fill missing values | Used a `MERGE` to fill missing `industry` values from other rows of the same company |

### Example: converting data types

```sql
CREATE OR REPLACE TABLE layoffs_staging3 AS
SELECT
  * EXCEPT (total_laid_off, percentage_laid_off),
  try_cast(total_laid_off AS INT) AS total_laid_off,
  try_cast(percentage_laid_off AS DOUBLE) AS percentage_laid_off
FROM layoffs_staging2;
```

### Example: filling missing industries

```sql
MERGE INTO layoffs_staging4 t1
USING (
  SELECT company, MAX(industry) AS industry
  FROM layoffs_staging4
  WHERE industry IS NOT NULL
  GROUP BY company
) t2
ON t1.company = t2.company
WHEN MATCHED AND t1.industry IS NULL THEN
  UPDATE SET t1.industry = t2.industry;
```

## Exploratory Data Analysis

Questions explored with SQL:

- Which companies had the most layoffs overall?
- Which industries and countries were hit hardest?
- How did layoffs change by year and by month?
- Which companies laid off 100% of their workforce?
- How does funding raised relate to layoffs by industry?

### Example: average funds raised by industry and year

```sql
SELECT
  industry,
  year(`date`) AS year,
  AVG(funds_raised_millions) AS avg_funds_raised
FROM layoffs_staging4
WHERE industry IS NOT NULL
  AND `date` IS NOT NULL
GROUP BY industry, year(`date`);
```

## Dashboard

I built an interactive dashboard in Databricks AI/BI with:

- **Year filter** to focus on 2020, 2021, 2022, or 2023
- **Bar chart** of average funds raised by industry (top 10)
- **Trend line** of total layoffs by year


## Key Findings

**Layoffs over time**

| Year | Layoff events | Employees laid off |
|------|--------------:|-------------------:|
| 2020 | 267 | 36,225 |
| 2021 | 17 | 10,005 |
| 2022 | 513 | 79,963 |
| 2023 (through Mar 6) | 202 | 64,886 |

- **Layoffs surged in 2022 and early 2023.** 2022 had the most events, and 2023 reached 64,886 layoffs in just over two months.
- **January 2023 was the worst month**, with about 39,600 layoffs, followed by November 2022 (about 26,700) and February 2023 (about 23,300).
- **2021 was unusually quiet** after the early-pandemic wave in 2020, with only 17 events recorded.

**Who was hit hardest**

- **Industries:** Retail (29,995), Consumer (20,383), Hardware (13,394), Food (13,350), and Transportation (13,290) had the most layoffs overall.
- **Top industry by year:** Travel in 2020, Consumer in 2021, Retail in 2022, and Hardware in 2023.
- **Companies:** Amazon (18,150), Google (12,000), Ericsson (8,500), Dell (6,650), and Booking.com (4,601) had the largest totals.
- **Countries:** The United States accounted for 129,409 layoffs (about 68% of the total), well ahead of India (13,292), Sweden (10,124), Singapore (5,550), and Brazil (5,292).
- **Cities:** SF Bay Area (55,786), Seattle (19,876), and New York City (17,583) led.
- **Company stage:** Post-IPO companies made up 95,386 layoffs, about half of the total.

**Funding and shutdowns**

- **63 companies laid off 100% of their workforce.** Several had raised substantial funding, including Britishvolt ($2.4B), Deliveroo Australia ($1.7B), and Katerra ($1.6B).
- **High funding did not protect against layoffs.** By average funds raised, Hardware ($1.4B), Food ($1.1B), Consumer ($1.1B), and Transportation ($1.0B) ranked highest, and all four also appear among the industries with the most layoffs.



## What I Learned

- Databricks SQL differs from MySQL: no `UPDATE ... JOIN` (use `MERGE`), and changing column types on Delta tables means recreating the table.
- `try_cast` and `try_to_date` handle messy values without failing the whole query.
- Dashboard filters work best when the dataset exposes a `year` column and ranking (top 10) is done in the chart rather than the SQL.


## Acknowledgments

Dataset source: https://www.kaggle.com/datasets/vardhannharsh/world-layoffs
