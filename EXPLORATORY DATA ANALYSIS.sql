-- EXPLORATORY DATA ANALYSIS 

SELECT * 
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Which companies had 1 which is basically 100 percent of they company laid off
-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

--------------------------------------------------------------------------------------------------------------------------
#-- BY COMPANY - TOTAL LAID OFF
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

WITH CTE_TOTAL_LAID_OFF AS 
(
SELECT company, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
)
SELECT SUM(sum_total_laid_off)
FROM CTE_TOTAL_LAID_OFF
;

-------------------------------------------------------------------------------------------------------------------------
#-- BY COMPANY - TOTAL LAID OFF
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

#-- BY INDUSTRY - TOTAL LAID OFF
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

#-- BY COUNTRY - TOTAL LAID OFF
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

#-- BY YEAR(DATE) - TOTAL LAID OFF
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

#-- BY SATGE - TOTAL LAID OFF
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-------------------------------------------------------------------------------------------------------------------------

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

--------------------------------------------------------------------------------------------------------------------------
#-- ROLLING TOTAL OF TOTAL LAID OFFS BY MONTH

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;

WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT 
`MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
;

-------------------------------------------------------------------------------------------------------------------------
#-- YEAR BY YEAR SNAPSHOT OF TOTAL LAID OFFS FOR EACH COMPANY 
#-- USING CTE

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`) 
ORDER BY 3 DESC
;

WITH Company_Year (company, years, total_laid_offs) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`) 
), Company_Year_Rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_offs DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE ranking <=5 
;