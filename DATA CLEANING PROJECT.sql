--  DATA CLEANING PROJECT

SELECT * 
FROM layoffs;
-------------------------------------------------------------------------------------------------

-- 1. REMOVE DUPLICATES 
-- 2. STANDARDIZE THE DATA
-- 3. NULL VALUES OR BLANK VALUES 
-- 4. REMOVE ANY COLUMNS 

-------------------------------------------------------------------------------------------------
# Made a copy of the layoffs table so we dont mess with the orignal raw data table  

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-------------------------------------------------------------------------------------------------
# Removing duplicates from the data 

-- THIS QUERY BASICALLY HELPS US TO FIND DUPLICATES BY ASSIGNING row_num TO ALL THE ROWS 

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

# Identifying the duplicates using CTE 

WITH duplicate_cte AS 
(
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY 
		company, 
        location,
		industry, 
		total_laid_off, 
		percentage_laid_off, 
		`date`, 
		stage, 
		country, 
		funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-------------------------------------------------------------------------------------------------
# Now we know what data to get rid off so we make a new table similar to our identification table and simple use the DELETE function

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY 
		company, 
        location,
		industry, 
		total_laid_off, 
		percentage_laid_off, 
		`date`, 
		stage, 
		country, 
		funds_raised_millions) AS row_num
	FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-------------------------------------------------------------------------------------------------
# Standardizing Data


#-- COMPANY DATA (NAMES) --#

-- old company data(names) without a trim 
SELECT DISTINCT(company)
FROM layoffs_staging;

-- new company data(names) with trim
SELECT DISTINCT(TRIM(company))
FROM layoffs_staging2;

-- UPDATED DATA 
UPDATE layoffs_staging2
SET company = (TRIM(company));

#--

#-- INDUSTRY DATA --#

SELECT DISTINCT industry 
FROM layoffs_staging2
ORDER BY 1;
    
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
    
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
    
#--

#-- COUNTRY DATA --#

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

#--

#-- DATE DATA --#

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

#--

#-- DEALING WITH NULL VALUES --#

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE '----- can check custom values -----';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    SET t1.industry = t2.industry 
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

## Removing rows with null values for (total_laid_off and percentage_laid_off)
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

## Dropping the row_num column from the table

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

#--

-- DONE --

SELECT *
FROM layoffs_staging2;