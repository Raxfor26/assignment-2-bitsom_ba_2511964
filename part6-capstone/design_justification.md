# Design Justification – Hospital AI System

## Storage Systems

Each of the four goals demands a purpose-built storage system, since no single database handles real-time streaming, semantic search, ML training, and aggregated reporting equally well.

**Goal 1 – Predict patient readmission risk** uses a **Data Lake (S3 / ADLS in Parquet format)** combined with a **Data Warehouse (Snowflake / BigQuery)**. The data lake stores raw, historical EHR records — diagnoses, lab results, medications, and discharge summaries — in their original form, preserving full fidelity for feature engineering. The warehouse holds cleaned, structured feature tables that the XGBoost or LSTM model trains on. This separation ensures the raw data is never lost to transformation and the model always trains on a reproducible, versioned snapshot.

**Goal 2 – Plain-English queries over patient history** uses a **Vector Database (Pinecone / Weaviate)**. Patient records are chunked and embedded using a sentence transformer model, then stored as high-dimensional vectors. When a doctor asks "Has this patient had a cardiac event before?", the query is embedded and the vector DB retrieves semantically relevant record chunks via cosine similarity. These are passed to an LLM through a RAG pipeline to generate a grounded, factual answer. A traditional keyword search would fail here because medical records use varied terminology — "myocardial infarction", "MI", "heart attack" — that only vector similarity handles correctly.

**Goal 3 – Monthly management reports** uses the **Data Warehouse**. Aggregated metrics like bed occupancy rates, department-wise costs, and admission volumes are computed using SQL over structured, pre-modelled fact and dimension tables. The warehouse's columnar storage and query optimiser make these analytical aggregations fast and cost-efficient. A BI tool like Tableau connects directly to the warehouse to render dashboards for management.

**Goal 4 – Real-time ICU vitals streaming** uses a **Time-Series Database (InfluxDB / TimescaleDB)**, fed by **Apache Kafka**. Kafka ingests high-frequency sensor readings from ICU devices and buffers the stream, while InfluxDB stores the timestamped vitals with millisecond precision. Time-series databases are optimised for append-heavy writes and time-windowed queries — "show the last 10 minutes of heart rate" — which a general-purpose RDBMS cannot sustain at ICU sensor throughput.

## OLTP vs OLAP Boundary

The **OLTP boundary** sits at the EHR system and ICU monitoring devices — these are the operational systems that record transactions in real time: patient admissions, medication orders, vital sign readings. They are optimised for fast, single-record writes and reads.

The **OLAP boundary begins at the ingestion layer**. Once data passes through Kafka or the ETL pipeline into the data lake or warehouse, it enters the analytical tier. From this point forward, all workloads are read-heavy, batch-oriented, and aggregation-focused. The data warehouse enforces this boundary explicitly — it is populated by scheduled ETL jobs, not live application writes, ensuring that analytical queries never compete with operational transactions for resources.

## Trade-offs

The most significant trade-off in this design is **data freshness versus query performance** in the data warehouse. Because the warehouse is populated by batch ETL jobs — typically running nightly — management reports and the readmission model's training data can be up to 24 hours stale. In a hospital setting, a delayed insight about rising readmission risk in a specific ward could have real clinical consequences.

The mitigation strategy is twofold. First, adopt a **Lambda architecture pattern** for the readmission model: run a lightweight streaming inference pipeline directly on Kafka events that flags high-risk patients in near real time, while the full batch model retrains nightly on the warehouse for precision. Second, implement **incremental ETL** using tools like dbt or Spark Structured Streaming to reduce the batch window from 24 hours to 1–2 hours for critical tables, without the full cost of a real-time warehouse. This balances operational cost against clinical urgency without redesigning the entire storage layer.