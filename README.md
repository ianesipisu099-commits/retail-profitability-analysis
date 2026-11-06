# PostgreSQL Superstore Sales and Profitability Analysis

## Project Overview

This project uses PostgreSQL to analyse retail sales, profitability, discount patterns, and recorded order returns using a Superstore-style transactional dataset.

The objective is to identify patterns affecting business performance, highlight potential profitability risks, and translate SQL analysis into actionable business insights.

The project demonstrates practical SQL skills, including data validation, aggregations, joins, common table expressions (CTEs), window functions, date filtering, and business-focused analysis.

---

## Executive Summary

This project examines the financial performance of a retail business using PostgreSQL, with particular attention to sales, profit margins, discounting, and recorded product returns.

The historical analysis covers **9,175 order-line records across 4,581 distinct orders**, from **3 January 2023 to 22 October 2026**. Future-dated records were excluded to ensure that the analysis reflects the defined historical reporting period.

### Key Business Findings

#### 1. Overall Financial Performance

The business generated:

| Financial Metric | Result |
|---|---:|
| Total Sales | $2,111,931.81 |
| Total Profit | $273,111.42 |
| Overall Profit Margin | 12.93% |
| Distinct Orders | 4,581 |
| Order-Line Records | 9,175 |

The business generated positive overall profit, although profitability varied considerably across products, categories, and discount levels.

#### 2. High Discounting Presents a Significant Profitability Risk

Transactions with discounts of **30% or higher** generated $326,750.18 in sales but recorded a loss of $117,534.16, resulting in a negative profit margin of **-35.97%**.

In comparison, transactions with discounts below 30% generated $390,645.57 in profit, with a profit margin of **21.88%**.

The same negative high-discount profitability pattern appeared across Furniture, Office Supplies, and Technology.

This indicates a strong association between higher discount levels and weaker profitability in the analysed dataset. It does not independently establish that discounting caused the losses.

#### 3. Recorded Returns Vary Across Product Categories

Technology had the highest category-level return incidence rate at **7.77%**, followed by Furniture at **7.49%** and Office Supplies at **5.98%**.

At subcategory level, Machines recorded the highest return incidence rate at **11.43%**, followed by Tables at **10.00%**.

These findings identify product areas that may warrant further investigation into product quality, fulfilment, and customer expectations.

#### 4. Customer Segments Show Relatively Similar Return Rates

Recorded order-level return rates across customer segments were:

| Customer Segment | Return Rate |
|---|---:|
| Corporate | 6.03% |
| Consumer | 5.76% |
| Home Office | 5.09% |

The differences are relatively small, suggesting that the observed return patterns are not concentrated exclusively in one customer segment.

### Business Recommendations

Based on the findings, the following actions are worth considering:

- **Review discount policies:** Introduce clearer approval controls for discounts of 30% or higher, supported by product-level profitability checks.
- **Protect product margins:** Investigate products and subcategories generating losses under heavy discounting before continuing or expanding promotional offers.
- **Investigate recorded returns:** Examine the reasons behind higher return incidence rates for Machines, Tables, and Technology products. Review product quality, descriptions, fulfilment, and customer expectations.
- **Monitor performance regularly:** Track sales, profit margins, discount levels, and return rates by category and subcategory to identify emerging risks.

### Overall Conclusion

The analysis demonstrates that strong sales performance does not necessarily translate into strong profitability.

Discount management, product-level margin monitoring, and closer investigation of recorded returns are important areas for improving retail business performance.

The findings reflect patterns in the available dataset and should be treated as analytical indicators rather than proof of causation.

---

## Business Questions

The analysis was designed to answer the following questions:

1. What are the overall sales, profit, and profit margin?
2. How do financial results vary by region, category, subcategory, customer segment, and month?
3. Which subcategories and products warrant further profitability review?
4. How are high discount levels associated with recorded profit?
5. What proportion of historical orders is listed in the returns table, and how does this vary by customer segment and product category?

---

## Data and Scope

The analysis uses two PostgreSQL tables:

| Table | Description |
|---|---|
| `public.orders` | Order-line data containing dates, customer and product attributes, sales, quantity, discount, and profit. |
| `public.returns` | Order IDs listed as returned, together with their return status. |

The primary historical cutoff is **22 October 2026, inclusive**.

All historical queries consistently apply:

```sql
WHERE order_date <= DATE '2026-10-22'
```

Records with later order dates are excluded from historical performance analysis because they fall beyond the defined reporting cutoff.

### Historical Dataset Summary

| Metric | Result |
|---|---:|
| Historical order lines | 9,175 |
| Historical distinct orders | 4,581 |
| Historical sales | $2,111,931.81 |
| Historical profit | $273,111.42 |
| Historical profit margin | 12.93% |
| Historical order-date range | 2023-01-03 to 2026-10-22 |
| Future-dated order lines excluded | 1,019 |
| Future-dated distinct orders excluded | 530 |

**Profit margin** is calculated as total profit divided by total sales. Monetary values are rounded for display.

---

## Repository Structure

```text
retail-profitability-analysis/
│
├── Data/
│   └── raw/
│       ├── orders.csv
│       ├── people.csv
│       └── returns.csv
│
├── results/
│   ├── discount-comparison.png
│   ├── discount-by-category.png
│   ├── returns-by-category.png
│   ├── returns-by-segment.png
│   └── returns-by-subcategory.png
│
├── sql/
│   ├── 01_data_quality.sql
│   ├── 02_sales_profitability.sql
│   ├── 03_returns_analysis.sql
│   └── 04_discount_analysis.sql
│
├── .gitignore
└── README.md
```

### SQL Script Descriptions

| SQL Script | Purpose |
|---|---|
| `01_data_quality.sql` | Examines row counts, ID uniqueness, missing and invalid values, date consistency, potential duplicates, and returns data integrity. |
| `02_sales_profitability.sql` | Analyses overall financial performance and breaks down results by region, category, subcategory, customer segment, month, and product. |
| `03_returns_analysis.sql` | Calculates the overall order-level return rate and examines recorded return incidence by customer segment, category, and subcategory. |
| `04_discount_analysis.sql` | Investigates profitability by discount group, category, subcategory, and product/discount combination, including duplicate sensitivity analysis. |

---

## Key Findings

### 1. Overall Sales and Profitability

The historical dataset contains 9,175 order lines across 4,581 distinct orders, generating approximately $2.11 million in sales and $273.1 thousand in recorded profit.

The overall profit margin is **12.93%**.

However, profitability varies substantially across product categories and subcategories.

| Category | Sales | Profit | Profit Margin |
|---|---:|---:|---:|
| Technology | $764,648.41 | $135,079.78 | 17.67% |
| Furniture | $681,580.73 | $18,170.06 | 2.67% |
| Office Supplies | $665,702.67 | $119,861.58 | 18.01% |

Furniture generates substantial sales but has a considerably lower profit margin than the other two categories.

At subcategory level, Tables recorded a loss of $15,599.77, with a margin of -8.51%. Bookcases and Supplies also recorded negative profit margins.

Copiers was among the strongest subcategories, generating $48,117.88 in profit at a 36.54% margin.

### 2. Discounts and Profitability

Discounting is one of the most significant profitability patterns identified in the analysis.

#### Overall Profitability by Discount Group

| Discount Group | Order Lines | Distinct Orders | Sales | Profit | Profit Margin |
|---|---:|---:|---:|---:|---:|
| Below 30% | 7,902 | 4,194 | $1,785,181.62 | $390,645.57 | 21.88% |
| 30% or Higher | 1,273 | 924 | $326,750.18 | -$117,534.16 | -35.97% |

The high-discount group represents a substantial profitability concern.

The same negative high-discount pattern appears across all three product categories:

| Category | High-Discount Sales | High-Discount Profit | Profit Margin |
|---|---:|---:|---:|
| Furniture | $178,064.69 | -$49,733.00 | -27.93% |
| Office Supplies | $34,300.48 | -$39,449.48 | -115.01% |
| Technology | $114,385.01 | -$28,351.67 | -24.79% |

Office Supplies recorded the most severe high-discount margin deterioration.

The results suggest that discount levels should be evaluated alongside product costs and contribution margins. Product mix, pricing rules, and other factors may also contribute to the observed losses.

The 30% threshold is an analytical comparison point, not a universal pricing recommendation.

### 3. Recorded Returns Analysis

The returns table contains **296 distinct returned order IDs**, all of which match an order in the orders table.

Within the historical reporting period, 262 of 4,581 distinct orders are listed as returned, giving an order-level return rate of **5.72%**.

#### Return Rate by Customer Segment

| Customer Segment | Total Orders | Returned Orders | Return Rate |
|---|---:|---:|---:|
| Corporate | 1,393 | 84 | 6.03% |
| Consumer | 2,344 | 135 | 5.76% |
| Home Office | 844 | 43 | 5.09% |

#### Return Incidence by Product Category

| Category | Orders Containing Category | Returned Orders | Return Incidence |
|---|---:|---:|---:|
| Technology | 1,403 | 109 | 7.77% |
| Furniture | 1,628 | 122 | 7.49% |
| Office Supplies | 3,427 | 205 | 5.98% |

#### Highest Subcategory Return Incidence

| Subcategory | Orders Containing Subcategory | Returned Orders | Return Incidence |
|---|---:|---:|---:|
| Machines | 105 | 12 | 11.43% |
| Tables | 280 | 28 | 10.00% |
| Paper | 1,089 | 92 | 8.45% |
| Chairs | 533 | 45 | 8.44% |
| Fasteners | 202 | 17 | 8.42% |

**Interpretation and limitations:**

- Return rates are calculated at order level using distinct order IDs.
- The returns table identifies returned orders, not necessarily the individual product lines returned.
- An order can contain multiple categories or subcategories. Consequently, category and subcategory denominators overlap and should not be added together.
- The absence of an order from the returns table does not prove that no return occurred.

These results identify areas for further investigation but do not establish which specific products were physically returned or why.

### 4. Data Quality and Potential Duplicates

Data validation was performed before the main analytical queries.

The checks confirmed:

- All 10,194 source rows have non-null and unique `row_id` values.
- No missing values were identified in the tested order ID, order date, sales, profit, discount, or quantity fields.
- No negative sales values were identified.
- No discounts outside the 0-to-1 range were identified.
- No nonpositive quantities were identified.
- No missing shipping dates or shipping dates earlier than order dates were identified.
- All distinct return IDs matched an order in the orders table.

#### Potential Duplicate Records

Two historical row pairs were identified as potential duplicates because their values were identical across all fields except `row_id`.

They were treated as potential duplicates rather than confirmed data-entry errors.

| Measure | Original Dataset | Excluding Extra Copies |
|---|---:|---:|
| Historical order lines | 9,175 | 9,173 |
| Sales | $2,111,931.81 | $2,111,551.31 |
| Profit | $273,111.42 | $273,088.06 |
| Profit Margin | 12.93% | 12.93% |

The two extra copies account for **$380.50 in sales** and **$23.36 in profit**.

The original records were retained in the primary analysis. A sensitivity query is included in `04_discount_analysis.sql` to demonstrate the effect of excluding the extra copies.

Source verification would be required before removing either record.

---

## Selected SQL Results

The following visualisations provide supporting evidence for the main findings.

### Discount Analysis

**Overall Profitability by Discount Group**

![Overall discount comparison](results/discount-comparison.png)

**Profitability by Category and Discount Group**

![Discount profitability by category](results/discount-by-category.png)

### Returns Analysis

**Recorded Return Incidence by Product Category**

![Return rates by category](results/returns-by-category.png)

**Recorded Return Rates by Customer Segment**

![Return rates by segment](results/returns-by-segment.png)

**Recorded Return Incidence by Product Subcategory**

![Return rates by subcategory](results/returns-by-subcategory.png)

---

## Methodology and Limitations

The project applies the following analytical principles:

1. **Historical scope:** Historical analyses consistently use `order_date <= DATE '2026-10-22'`.
2. **Order-level counting:** `COUNT(DISTINCT order_id)` is used where an order-level count is required because the underlying orders table contains individual order lines.
3. **Profit margin:** Calculated as `SUM(profit) / SUM(sales)`, rather than averaging individual line-level margins.
4. **Returns analysis:** Return IDs are deduplicated and joined at order level to avoid multiplying order-line totals.
5. **Discount comparisons:** Discount groups are descriptive comparisons. The 30% threshold is not presented as a universal policy recommendation.
6. **Data integrity:** Potential duplicate records are retained until they can be verified against the original source.
7. **Interpretation:** Observed relationships do not establish causation.
8. **Source profit measure:** The dataset's `profit` field is treated as the recorded profit measure. The project does not independently validate how source costs, refunds, or return adjustments were calculated.

The analysis is limited to the fields and records available in the supplied dataset. Additional operational information would be needed to establish the causes of product returns or the precise reasons behind individual profitability outcomes.

---

## How to Run

1. Install PostgreSQL and load the supplied CSV files into a database.
2. Create and populate the `public.orders` and `public.returns` tables using the appropriate column definitions.
3. Open the SQL files in pgAdmin or another PostgreSQL-compatible client.
4. Execute `01_data_quality.sql` first and review the data validation results.
5. Execute the remaining scripts:
   - `02_sales_profitability.sql`
   - `03_returns_analysis.sql`
   - `04_discount_analysis.sql`
6. Review the query outputs and compare them with the selected results presented in this repository.

The `people.csv` file is included in the source dataset but was not used in the four SQL analysis scripts.

---

## Dataset Source and Attribution

The project uses the **Superstore Sales** sample dataset made available through Tableau Public.

- **Source:** [Tableau Public – Sample Data](https://public.tableau.com/app/learn/sample-data)
- **Dataset:** Superstore Sales
- **Data format:** CSV
- **Tables used:** Orders and Returns
- **Additional file:** People data was included in the repository but was not used in the SQL analysis.

The dataset represents a fictitious retail business and contains information about products, sales, customers, and profitability.

The project applies a historical analysis cutoff of **22 October 2026**, excluding future-dated records from the historical analysis.

---

## Skills Demonstrated

| Technical Skills | Analytical Skills |
|---|---|
| PostgreSQL | Sales and profitability analysis |
| SQL querying | Discount and margin analysis |
| Data validation and quality checks | Returns analysis |
| Joins and CTEs | Product and category performance evaluation |
| Aggregations and conditional aggregation | Business interpretation |
| Window functions | Data-driven recommendations |
| Date filtering and data scoping | Analytical limitations and sensitivity analysis |

**Tools:** PostgreSQL, pgAdmin, Git, and GitHub.

---

## Project Outcome

This project demonstrates the use of PostgreSQL to transform raw transactional data into structured business analysis.

It combines data-quality validation, financial performance analysis, discount evaluation, and recorded returns analysis to identify business risks and areas requiring further investigation.

The final deliverable includes four documented SQL scripts, validated analytical outputs, supporting visualisations, and business recommendations.