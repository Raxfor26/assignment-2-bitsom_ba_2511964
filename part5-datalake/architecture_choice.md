# Architecture Choice – Data Lake & DuckDB

## Overview

This project ingests raw data from three heterogeneous sources — a CSV file (`customers.csv`), a JSON file (`orders.json`), and a Parquet file (`products.parquet`) — and queries them using DuckDB without any pre-loading or transformation into tables. This document justifies the architectural choices made.

---

## Why a Data Lake Architecture?

A **Data Lake** stores raw data in its native format (CSV, JSON, Parquet, etc.) in a central repository, without enforcing a fixed schema upfront. This is ideal for the order management system because:

- The three source files come in different formats produced by different systems (CRM, order service, product catalog).
- A traditional RDBMS would require ETL pipelines to normalize and load all data before any query could run, adding latency and maintenance overhead.
- A data lake preserves the raw files as the source of truth, allowing flexible schema-on-read querying at any time.

---

## Why DuckDB?

DuckDB is an in-process analytical database engine that can query files directly — CSV, JSON, Parquet — without loading them into tables first. It was chosen for this project because:

| Feature | Benefit |
|---|---|
| **Multi-format support** | Natively reads CSV, JSON, and Parquet via `read_csv_auto()`, `read_json_auto()`, `read_parquet()` |
| **No server required** | Runs entirely in-process — no database server to install or manage |
| **SQL interface** | Standard SQL syntax with full JOIN, GROUP BY, aggregation support |
| **Columnar execution** | Parquet files are read efficiently using columnar projection pushdown |
| **Zero data movement** | Files are queried in place — no ETL, no staging tables |
| **Lightweight** | Ideal for local development, notebooks, and small-to-medium datasets |

---

## Alternative Architectures Considered

### Option 1: Traditional RDBMS (e.g., PostgreSQL)
Loading all three files into a relational database would enable fast indexed queries, but requires a running database server, schema definition and data loading scripts, and re-loading whenever source files are updated. This adds unnecessary complexity for analytical workloads over relatively static files.

### Option 2: Apache Spark + HDFS
Spark with a distributed file system would scale to petabytes, but is heavily over-engineered for a dataset of this size. Setup complexity, cluster management, and resource overhead make it impractical here.

### Option 3: Pandas (Python only)
Pandas can read all three formats and perform joins, but it loads entire files into memory, lacks a SQL interface, and cannot leverage Parquet columnar optimizations the way DuckDB can.

---

## Schema Summary (Inferred from Files)

### customers.csv
| Column | Type |
|---|---|
| customer_id | string |
| name | string |
| city | string |
| signup_date | string |
| email | string |

### orders.json
| Column | Type |
|---|---|
| order_id | string |
| customer_id | string |
| order_date | string |
| status | string |
| total_amount | integer |
| num_items | integer |

### products.parquet
| Column | Type |
|---|---|
| line_item_id | string |
| order_id | string |
| product_id | string |
| product_name | string |
| category | string |
| quantity | integer |
| unit_price | integer |
| total_price | integer |

---

## Join Strategy

The three files are linked as follows:
```
customers.csv  ──(customer_id)──►  orders.json  ──(order_id)──►  products.parquet
```

- `customers` → `orders` : one-to-many (one customer can have many orders)
- `orders` → `products`  : one-to-many (one order can have many line items)

---

## Architecture Recommendation

For a fast-growing food delivery startup collecting GPS location logs, customer text reviews, payment transactions, and restaurant menu images, a **Data Lakehouse** architecture is the strongest recommendation.

A pure **Data Warehouse** is ruled out immediately — it only handles structured, pre-modelled data. GPS logs, text reviews, and images are unstructured or semi-structured, and forcing them through rigid ETL pipelines into a warehouse would discard valuable raw signal and slow down ingestion significantly as data volumes scale.

A pure **Data Lake** would store everything flexibly, but lacks the governance, query performance, and ACID transaction support needed for payment data — where consistency and auditability are legally required.

A **Data Lakehouse** combines the best of both. Three specific reasons make it the right fit:

1. **Multi-modal data support:** GPS logs (time-series), reviews (text/NLP), payments (structured transactions), and menu images (binary/unstructured) all coexist in a single storage layer without format constraints. The lakehouse ingests all of them natively.

2. **ACID transactions on payment data:** Frameworks like Delta Lake or Apache Iceberg bring transactional guarantees to the lake layer, ensuring payment records are never partially written or duplicated — a critical compliance requirement.

3. **Unified analytics and AI:** Data scientists can run ML models on raw reviews and GPS data while analysts query structured payment tables using standard SQL — all from the same platform, eliminating costly data duplication across separate systems.

As the startup scales, a lakehouse avoids the architectural debt of maintaining a warehouse and a lake in parallel.