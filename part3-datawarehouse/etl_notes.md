## ETL Decisions

### Decision 1 — Date Standardization and Surrogate Key Creation
**Problem:** The raw `date` column contained inconsistent formats, including `DD/MM/YYYY` (e.g., 29/08/2023), `DD-MM-YYYY` (e.g., 20-02-2023), and ISO `YYYY-MM-DD`. This inconsistency prevents standard SQL date functions and time-series analysis from working correctly.

**Resolution:** During the Transformation phase, all date strings were parsed and converted into a uniform ISO `YYYY-MM-DD` format for the `full_date` column in `dim_date`. Additionally, a numeric surrogate key `date_id` (format: `YYYYMMDD`) was created to improve join performance and allow for easy partitioning in the future.

### Decision 2 — Handling Missing Location Data (Data Imputation)
**Problem:** The `store_city` column contained NULL values for certain transactions (notably for "Mumbai Central"). In a star schema, fact records should not link to incomplete dimension attributes as it leads to "Unknown" or empty buckets in geographic reports.

**Resolution:** I implemented a lookup resolution where the `store_city` was inferred based on the `store_name`. Since "Mumbai Central" is uniquely associated with the city of Mumbai, the NULL values were replaced with "Mumbai" during the load into `dim_store`. This ensures 100% data density for regional sales reporting.

### Decision 3 — Text Normalization for Product Categories
**Problem:** The `category` column suffered from inconsistent casing and naming conventions, such as "electronics" (lowercase), "Electronics" (Proper case), and "Grocery" vs "Groceries". In an analytical query, "electronics" and "Electronics" would be treated as two different categories, leading to inaccurate revenue totals.

**Resolution:** A standardization rule was applied to convert all category strings to **Proper Case** and pluralize where necessary. For example, "electronics" was transformed to "Electronics" and "Grocery" was mapped to "Groceries". This allows for clean, aggregated reporting without the need for complex string manipulation in every analytical query.