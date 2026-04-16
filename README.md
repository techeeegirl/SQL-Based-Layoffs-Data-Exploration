# 📊 Layoffs Data Cleaning & Exploratory Data Analysis using SQL

This project demonstrates a full SQL-based data analytics workflow: starting from **cleaning raw layoff data** and ending with **exploratory data analysis (EDA)** to extract meaningful business insights. The dataset was taken from the [Alex The Analyst Data Analyst Bootcamp](https://www.youtube.com/@AlexTheAnalyst).

---

## 📁 Dataset Information

- **Name:** layoffs.csv
- **Source:** GitHub (via Alex The Analyst Bootcamp)
- **Content:** Layoffs from global tech companies during 2020–2023
- **Columns include:**
  - Company, Location, Industry
  - Total Laid Off, % Laid Off
  - Date of Layoff
  - Company Stage (e.g., Series A, Series C)
  - Country, Funding Raised

[Layoffs Dataset on GitHub](https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv)

---

## 🛠 Tools & Skills Used

| Tool | Purpose |
|------|---------|
| **MySQL** | SQL scripting, transformations, and analysis |
| **SQL Techniques** | `CTEs`, `ROW_NUMBER`, `GROUP BY`, `JOINS`, `CASE`, `TRIM`, `REPLACE`, `DATE FORMATTING`, `WINDOW FUNCTIONS`, `DENSE_RANK` |

---

## 🔧 Phase 1: Data Cleaning (`DATA_CLEANING_PROJECT.sql`)

### ✅ Cleaning Objectives:
1. **Remove duplicates** using `ROW_NUMBER()` in a CTE
2. **Standardize inconsistent entries** like:
   - Company names (trim extra spaces)
   - Industry names (e.g., 'Crypto/Blockchain' → 'Crypto')
   - Country names (e.g., remove trailing '.' in 'United States.')
3. **Fix date formatting** using `STR_TO_DATE()`
4. **Handle missing values** by:
   - Replacing empty strings with `NULL`
   - Updating NULLs using inferred data from other rows
5. **Delete irrelevant records**
   - Rows with both `total_laid_off` and `percentage_laid_off` as NULL
6. **Drop helper columns** like `row_num` after cleaning

### 🧹 Key Queries Used:
```sql
-- Assign row numbers to detect duplicates
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
)

-- Trim company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Format date column
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Drop extra column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
