## Anomaly Analysis

### 1. Insert Anomaly
An insert anomaly occurs when certain attributes cannot be inserted into the database without the presence of other attributes. 

 **Example from Data:** Suppose the company hires a new Sales Representative (`sales_rep_id` = "SR04", `sales_rep_name` = "Amit Singh", `office_address` = "Pune"). In this flat structure, we cannot add Amit Singh to the database until he makes his first sale because a valid `order_id` is required to create a new row. If we try to insert him without an order, the `order_id` (which acts as the primary key for the table) would be NULL, violating entity integrity.

### 2. Update Anomaly
An update anomaly occurs when updating a single piece of data requires modifying multiple rows. If all rows are not updated simultaneously, the database becomes inconsistent.

 **Example from Data:** Look at the Sales Representative Deepak Joshi (`sales_rep_id`: SR01). His information is repeated across multiple orders, such as row 3 (`order_id`: ORD1114) and row 4 (`order_id`: ORD1153). If Deepak's office address changes from "Mumbai HQ, Nariman Point, Mumbai - 400021" to a new location, the database administrator must find and update every single row where `sales_rep_id` is SR01. If the system updates ORD1114 but fails to update ORD1153, the database will contain conflicting addresses for the same employee.

### 3. Delete Anomaly
A delete anomaly occurs when deleting a row to remove one specific fact inadvertently deletes another completely independent and important fact.

 **Example from Data:** Look at row 5 (`order_id`: ORD1002), where Priya Sharma (`customer_id`: C002) purchased Headphones (`product_id`: P005). If the customer cancels this order and we delete the row for `ORD1002` from the database, we don't just lose the order record—we completely lose the existence of the product itself. The system will no longer know that product P005 is "Headphones", belongs to the "Electronics" category, and has a `unit_price` of 3200, simply because its only associated order was deleted.


## Normalization Justification

While keeping all data in a single flat table might seem simpler for generating quick reports, it is a dangerous anti-pattern for an operational database (OLTP). I must respectfully refute the idea that normalization is over-engineering, as the current flat structure actively damages our data integrity.

First, the flat structure guarantees data inconsistency through **Update Anomalies**. For example, look at the data for Sales Rep SR01 (Deepak Joshi). In our flat file, his office address is entered as "Mumbai HQ, Nariman Point, Mumbai - 400021" in some orders, but abbreviated as "Mumbai HQ, Nariman Pt, Mumbai - 400021" in others. If Deepak moves to a new office, the system must search and update hundreds of individual order rows. If even one row is missed, the database produces conflicting truths. By normalizing into 3NF, we store his address exactly once, making updates instantaneous and error-free.

Second, the flat structure risks catastrophic data loss via **Delete Anomalies**. Consider order ORD1002, where Priya Sharma purchased product P005 (Headphones). Because product details are tied directly to order events, if Priya cancels this order and we delete the row, we completely erase the existence of product P005 from our system. We would forget that it belongs to the 'Electronics' category and costs 3200.

Normalization is not over-engineering; it is foundational data protection. While a flat, denormalized schema is perfectly acceptable later in the data pipeline (like in a Data Warehouse for analytics), our core transactional system must be normalized to Third Normal Form (3NF) to ensure accuracy, eliminate redundancy, and protect core business records.

