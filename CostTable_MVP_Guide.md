# CostTable - MVP Development Guide

## Project Overview

**CostTable** is an open-source Flutter app for restaurant/food business costing. It helps users calculate recipe costs, manage ingredient prices, apply profit margins, and generate cost reports—all locally without requiring a backend.

---

## SQLite Database Schema

### Table 1: Ingredients

```sql
CREATE TABLE ingredients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  base_unit TEXT NOT NULL, -- 'kg', 'L', 'piece', 'gram'
  current_price REAL NOT NULL, -- price per unit
  last_updated INTEGER NOT NULL, -- timestamp in milliseconds
  supplier TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL
);
```

**Example Data:**
- Noodles | kg | 250 | 1732358400000 | Supplier A
- Salt | kg | 150 | 1732358400000 | Supplier B
- Pepper | gram | 1.50 | 1732358400000 | Supplier C

---

### Table 2: MenuItems

```sql
CREATE TABLE menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  servings_per_recipe INTEGER DEFAULT 1, -- portions recipe makes
  base_selling_price REAL,
  is_active INTEGER DEFAULT 1, -- 1=active, 0=inactive
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Example Data:**
- Chicken Noodles | Spicy chicken noodles | 2 | 300
- Vegetable Soup | Mixed vegetable soup | 4 | 150

---

### Table 3: RecipeIngredients (Junction Table)

```sql
CREATE TABLE recipe_ingredients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  menu_item_id INTEGER NOT NULL,
  ingredient_id INTEGER NOT NULL,
  quantity REAL NOT NULL, -- amount of ingredient
  unit TEXT NOT NULL, -- 'kg', 'L', 'piece', 'gram' (can differ from ingredient's base unit)
  notes TEXT,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id),
  UNIQUE(menu_item_id, ingredient_id)
);
```

**Example Data:**
- Menu Item: Chicken Noodles | Ingredient: Noodles | Quantity: 0.1 | Unit: kg
- Menu Item: Chicken Noodles | Ingredient: Salt | Quantity: 2 | Unit: gram
- Menu Item: Chicken Noodles | Ingredient: Pepper | Quantity: 0.5 | Unit: gram

---

### Table 4: CostComponents

```sql
CREATE TABLE cost_components (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL, -- 'Packaging', 'Labor', 'Rent', 'Utilities'
  category TEXT NOT NULL, -- 'DIRECT' or 'INDIRECT'
  amount REAL NOT NULL, -- cost value
  is_percentage INTEGER DEFAULT 0, -- 1=percentage of raw cost, 0=fixed amount
  is_active INTEGER DEFAULT 1, -- 1=applied, 0=not applied
  applies_to TEXT DEFAULT 'ALL', -- 'ALL' or specific menu_item_id
  notes TEXT,
  created_at INTEGER NOT NULL
);
```

**Example Data:**
- Packaging | DIRECT | 5 | 0 | 1 | ALL | Cost per item
- Labor | DIRECT | 20 | 0 | 1 | ALL | Per item labor
- Rent Allocation | INDIRECT | 10 | 1 | 1 | ALL | 10% of raw cost
- Utilities | INDIRECT | 8 | 1 | 1 | ALL | 8% of raw cost

---

### Table 5: PriceHistory (For tracking price changes)

```sql
CREATE TABLE price_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ingredient_id INTEGER NOT NULL,
  old_price REAL NOT NULL,
  new_price REAL NOT NULL,
  changed_at INTEGER NOT NULL, -- timestamp
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);
```

---

## Core Calculations

### 1. Raw Food Cost (Per Serving)

```
Raw Food Cost = SUM(ingredient_quantity × price_per_unit) / servings_per_recipe

Example for Chicken Noodles (makes 2 servings):
- Noodles: 0.1 kg × 250 = 25
- Salt: 0.002 kg × 150 = 0.30
- Pepper: 0.0005 kg × 1500 = 0.75
- Chicken: 0.15 kg × 400 = 60
- Total Raw Cost: 85.05 ÷ 2 = 42.525 per serving
```

### 2. Direct Costs (Per Serving)

```
Direct Costs = SUM(direct_cost_components)

If cost is percentage-based:
  Direct Cost = (Raw Food Cost × percentage) / 100

Example:
- Packaging: 5 (fixed)
- Labor: 20 (fixed)
- Total Direct Costs: 25 per serving
```

### 3. Indirect Costs (Per Serving)

```
Indirect Costs = SUM(indirect_cost_components)

If cost is percentage-based:
  Indirect Cost = ((Raw Food Cost + Direct Costs) × percentage) / 100

Example:
- Rent: ((42.525 + 25) × 10) / 100 = 6.75
- Utilities: ((42.525 + 25) × 8) / 100 = 5.40
- Total Indirect Costs: 12.15 per serving
```

### 4. Total Cost Per Serving

```
Total Cost = Raw Food Cost + Direct Costs + Indirect Costs

Example:
Total Cost = 42.525 + 25 + 12.15 = 79.675 per serving
```

### 5. Selling Price (Based on Desired Profit Margin)

```
Selling Price = Total Cost / (1 - Desired_Profit_Margin)

Where Desired_Profit_Margin is expressed as decimal (0.60 = 60%)

Example (60% margin):
Selling Price = 79.675 / (1 - 0.60) = 79.675 / 0.40 = 199.19 ≈ 200

Verification:
- Profit = 200 - 79.675 = 120.325
- Profit Margin % = (120.325 / 200) × 100 = 60.16% ✓
```

### 6. Contribution Margin (Margin after direct costs only)

```
Contribution Margin = (Selling Price - Raw Food Cost - Direct Costs) / Selling Price

Contribution Margin = (200 - 42.525 - 25) / 200 = 66.34%

(This shows revenue available to cover indirect costs and profit)
```

### 7. Recipe Scaling

```
Scaled_Ingredient_Quantity = Original_Quantity × Scale_Factor

Example: Scale Chicken Noodles recipe to make 4 servings (originally makes 2):
Scale Factor = 4 / 2 = 2
- Noodles: 0.1 kg × 2 = 0.2 kg
- Salt: 0.002 kg × 2 = 0.004 kg
- All other ingredients scaled by 2

New Raw Food Cost = (sum of scaled ingredients)
Note: Total cost per serving remains the same
```

---

## MVP Features

### 1. Ingredient Management
- Add/Edit/Delete ingredients with base unit and price
- Display "Last Updated" date with visual alerts (red if >7 days old)
- Bulk price update feature
- Quick % adjustment for all ingredients in a category
- View price history

### 2. Menu Item Management
- Add/Edit/Delete menu items
- Define servings per recipe (e.g., recipe makes 2 portions)
- Add ingredients with quantities
- View raw food cost calculation in real-time

### 3. Cost Components (Global Settings)
- Add direct costs (packaging, labor, delivery)
- Add indirect costs (rent, utilities, misc overhead)
- Toggle costs ON/OFF with checkbox
- Set as fixed amount or percentage-based
- Apply globally to all items or specific items
- Cost components persist and auto-apply when toggled on

### 4. Cost Breakdown Report (Per Menu Item)
- Display raw food cost per serving
- Show direct costs breakdown
- Show indirect costs breakdown
- Display total cost per serving
- Show selling price with profit margin selector
- Display profit amount and margin %
- Show contribution margin %

### 5. Quick Reports Dashboard
- List all menu items with:
  - Cost per serving
  - Recommended selling price (at 50%, 60%, 70% margins)
  - Estimated profit at each margin
- Filter active/inactive items
- Sort by cost or profit margin

### 6. Recipe Scaling
- Input desired servings
- Auto-calculate scaled quantities for all ingredients
- Display new raw cost and total cost for scaled recipe
- Option to view cost breakdown for scaled recipe

### 7. Price History Tracking
- View old and new prices for each ingredient
- See when prices changed
- Optional: Compare cost impact on menu items when prices changed

---

## Implementation Order (MVP)

**Phase 1 (Essential):**
1. Database setup with all 5 tables
2. Ingredients screen (CRUD operations)
3. Menu Items screen (with basic recipe ingredients)
4. Cost calculation engine
5. Cost breakdown view per menu item

**Phase 2 (Core Features):**
6. Cost Components management (direct + indirect)
7. Cost breakdown report with multiple margin calculations
8. Quick reports dashboard
9. Recipe scaling feature

**Phase 3 (Polish):**
10. Price history tracking and visualization
11. Bulk price updates
12. Data export (CSV)
13. Dark theme support

---

## Key Decisions for Simplicity

✅ **Local SQLite only** - No backend, offline-first architecture
✅ **No user authentication** - Single device, single user
✅ **Simple UI** - Tab-based navigation: Ingredients | Recipes | Costs | Reports
✅ **Automatic calculations** - User inputs data, app calculates costs
✅ **Toggle-based cost application** - Costs ON/OFF with checkbox, not per-item selection
✅ **Fixed serving base** - All costs calculated per serving, scaling multiplies from this base
✅ **Percentage or fixed costs** - Users choose which works best for their business

---

## Technology Stack

- **Framework:** Flutter 3.x+
- **Database:** SQLite (sqflite package)
- **State Management:** Provider or Riverpod
- **UI Components:** Material 3
- **Date/Time:** intl package
- **Export:** csv package (future feature)

---

## File Structure (Flutter)

```
lib/
├── models/
│   ├── ingredient.dart
│   ├── menu_item.dart
│   ├── recipe_ingredient.dart
│   ├── cost_component.dart
│   └── price_history.dart
├── database/
│   └── database_helper.dart
├── screens/
│   ├── ingredients/
│   ├── recipes/
│   ├── costs/
│   └── reports/
├── services/
│   └── cost_calculator.dart
├── widgets/
│   └── [reusable components]
├── constants/
│   └── app_constants.dart
└── main.dart
```

---

## GitHub Repository Setup

```
Repository Name: CostTable
Description: Open-source Flutter app for restaurant recipe costing

Key Files:
- README.md (setup instructions, features, screenshots)
- CONTRIBUTING.md (contribution guidelines)
- LICENSE (MIT or Apache 2.0)
- pubspec.yaml (dependencies)
- docs/
  - DATABASE_SCHEMA.md
  - CALCULATION_FORMULAS.md
  - FEATURE_ROADMAP.md
```

---

## Next Steps

1. Create Flutter project: `flutter create cost_table`
2. Add dependencies (sqflite, provider, intl)
3. Implement DatabaseHelper with all 5 tables
4. Build CostCalculator service with all formulas
5. Create UI screens starting with ingredients management
6. Test calculations with real data

This MVP is designed to be lean, focused, and easy to extend with future features like multi-user support, cloud sync, or advanced reporting.
