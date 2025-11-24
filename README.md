# CostTable

CostTable is an open-source Flutter app for accurate recipe costing, ingredient price tracking, and food business pricing—100% offline, no backend required. Built for simplicity and extensibility.

## MVP Features

- Add, edit, and bulk-update ingredients with per-unit market prices
- Track price history and get "last updated" alerts
- Create menu items (recipes) with ingredients, quantities, serving size
- Add direct and indirect cost components (fixed or % of cost) and toggle ON/OFF globally
- Automatic per serving cost breakdown: raw cost, direct, indirect, total, profit margin
- Scale any recipe for batch calculations
- Quick margin calculator and contribution margin reporting
- Quick reports dashboard: cost and profit by item
- Price history log for each ingredient

## Database Base Schema

### Table: ingredients
| Column         | Type     | Notes                           |
|:---------------|:---------|:--------------------------------|
| id             | INTEGER  | PK, AUTOINCREMENT               |
| name           | TEXT     | Ingredient name, UNIQUE         |
| base_unit      | TEXT     | 'kg', 'L', 'piece', 'gram'      |
| current_price  | REAL     | Price per unit                  |
| last_updated   | INTEGER  | Timestamp ms since epoch        |
| supplier       | TEXT     | Optional                        |
| notes          | TEXT     |                                 |
| created_at     | INTEGER  | Timestamp                       |

### Table: menu_items
| Column            | Type     | Notes                    |
|:------------------|:---------|:-------------------------|
| id                | INTEGER  | PK, AUTOINCREMENT        |
| name              | TEXT     | UNIQUE                   |
| description       | TEXT     |                          |
| servings_per_recipe| INT     | How many portions        |
| base_selling_price| REAL     | Optional                 |
| is_active         | INTEGER  | 1 = active, 0 = not      |
| created_at        | INTEGER  | Timestamp                |
| updated_at        | INTEGER  | Timestamp                |

### Table: recipe_ingredients
| Column        | Type     | Notes                                    |
|:--------------|:---------|:------------------------------------------|
| id            | INTEGER  | PK, AUTOINCREMENT                        |
| menu_item_id  | INTEGER  | FK to menu_items                         |
| ingredient_id | INTEGER  | FK to ingredients                        |
| quantity      | REAL     | Amount in `unit`                         |
| unit          | TEXT     | e.g. 'kg', 'gram', etc.                  |
| notes         | TEXT     |                                          |

### Table: cost_components
| Column       | Type     | Notes                                        |
|:-------------|:---------|:---------------------------------------------|
| id           | INTEGER  | PK, AUTOINCREMENT                            |
| name         | TEXT     | Cost name                                    |
| category     | TEXT     | DIRECT or INDIRECT                           |
| amount       | REAL     | Value (fixed or %)                           |
| is_percentage| INTEGER  | 1 = percent, 0 = fixed amount                |
| is_active    | INTEGER  | 1 = ON (applied), 0 = OFF                    |
| applies_to   | TEXT     | 'ALL' or menu_item_id                        |
| notes        | TEXT     |                                              |
| created_at   | INTEGER  | Timestamp                                    |

### Table: price_history
| Column        | Type     | Notes                                |
|:--------------|:---------|:-------------------------------------|
| id            | INTEGER  | PK, AUTOINCREMENT                    |
| ingredient_id | INTEGER  | FK to ingredients                    |
| old_price     | REAL     |                                      |
| new_price     | REAL     |                                      |
| changed_at    | INTEGER  | Timestamp                            |

## Essential Calculations

- **Raw food cost**: sum(ingredient_qty × price per unit) / servings_per_recipe
- **Direct costs**: sum components (fixed or as % of raw food cost)
- **Indirect costs**: sum components (fixed or as % of raw+direct cost)
- **Total cost per serving**: raw food + direct + indirect
- **Selling price**: total cost / (1 - desired margin as decimal, e.g., 0.6)
- **Contribution margin**: (selling price - raw - direct) / selling price
- **Scaling**: multiply quantities and recalculate all costs

## Tech Stack

- Flutter (Dart) + Material 3
- SQLite (via sqflite)
- Provider/Riverpod for state management

## Quick Start

1. Clone repo & run `flutter pub get`
2. All data persisted locally; no external server required
3. Manage data using intuitive tabbed interface
4. Fork and contribute via PR

## License

MIT

***