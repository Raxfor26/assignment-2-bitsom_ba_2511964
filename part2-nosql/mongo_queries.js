// Note: To run this in the MongoDB Shell, switch to your database first
// use ecommerce_catalog;

// OP1: insertMany() — insert all 3 documents from sample_documents.json
db.products.insertMany([
  {
    "product_id": "PROD-ELEC-001",
    "name": "Quantum 65-inch 4K Smart TV",
    "category": "Electronics",
    "base_price": 799.99,
    "stock_available": 45,
    "technical_specs": {
      "voltage": "110-240V",
      "power_consumption_watts": 150,
      "warranty_months": 24,
      "screen_type": "OLED"
    },
    "features": ["Smart TV OS", "HDR10+ Support", "Voice Control Integration"],
    "reviews": [
      {"user": "C001", "rating": 5, "comment": "Amazing picture quality."},
      {"user": "C045", "rating": 4, "comment": "Great, but the remote is clunky."}
    ]
  },
  {
    "product_id": "PROD-CLOT-002",
    "name": "Classic Denim Jacket",
    "category": "Clothing",
    "base_price": 59.99,
    "stock_available": 120,
    "clothing_details": {
      "material": "100% Cotton",
      "fit": "Regular",
      "care_instructions": "Machine wash cold, tumble dry low"
    },
    "available_sizes": ["S", "M", "L", "XL"],
    "available_colors": ["Vintage Wash Blue", "Midnight Black"]
  },
  {
    "product_id": "PROD-GROC-003",
    "name": "Organic Unsweetened Almond Milk",
    "category": "Groceries",
    "base_price": 4.49,
    "stock_available": 300,
    "grocery_details": {
      "is_organic": true,
      "is_vegan": true,
      "expiry_date": "2024-11-15",
      "storage_requirement": "Refrigerate after opening"
    },
    "nutritional_info": {
      "serving_size": "1 cup (240ml)",
      "calories": 40,
      "protein_grams": 1,
      "sugar_grams": 0,
      "allergens": ["Tree Nuts (Almonds)"]
    }
  }
]);

// OP2: find() — retrieve all Electronics products with price > 20000
db.products.find({
  category: "Electronics",
  base_price: { $gt: 20000 }
});

// OP3: find() — retrieve all Groceries expiring before 2025-01-01
db.products.find({
  category: "Groceries",
  "grocery_details.expiry_date": { $lt: "2025-01-01" }
});

// OP4: updateOne() — add a "discount_percent" field to a specific product
db.products.updateOne(
  { product_id: "PROD-ELEC-001" },
  { $set: { discount_percent: 15 } }
);

// OP5: createIndex() — create an index on category field and explain why
db.products.createIndex({ category: 1 });

/* EXPLANATION FOR INDEXING THE 'CATEGORY' FIELD:
In an e-commerce platform, users almost always browse products by category (e.g., clicking on the "Electronics" or "Clothing" tabs). 
If we do not have an index on 'category', MongoDB must perform a "Collection Scan" — reading every single document in the database to see if it matches the category. 
By creating an ascending index ({ category: 1 }), MongoDB builds a specialized B-Tree data structure. This allows the database to jump directly to the requested category and retrieve the results almost instantly, drastically reducing read latency and saving computational resources on read-heavy operations.
*/