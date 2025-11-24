import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ingredient.dart';
import '../models/menu_item.dart';
import '../models/recipe_ingredient.dart';
import '../models/cost_component.dart';
import '../models/price_history.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('costtable.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textNullable = 'TEXT';
    const realNullable = 'REAL';
    const integerDefault1 = 'INTEGER DEFAULT 1';
    const integerDefault0 = 'INTEGER DEFAULT 0';
    const textDefaultAll = "TEXT DEFAULT 'ALL'";

    // Table 1: Ingredients
    await db.execute('''
CREATE TABLE ingredients (
  id $idType,
  name $textType UNIQUE,
  base_unit $textType,
  current_price $realType,
  last_updated $integerType,
  supplier $textNullable,
  notes $textNullable,
  created_at $integerType
)
''');

    // Table 2: MenuItems
    await db.execute('''
CREATE TABLE menu_items (
  id $idType,
  name $textType UNIQUE,
  description $textNullable,
  servings_per_recipe $integerDefault1,
  base_selling_price $realNullable,
  is_active $integerDefault1,
  created_at $integerType,
  updated_at $integerType
)
''');

    // Table 3: RecipeIngredients
    await db.execute('''
CREATE TABLE recipe_ingredients (
  id $idType,
  menu_item_id $integerType,
  ingredient_id $integerType,
  quantity $realType,
  unit $textType,
  notes $textNullable,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id),
  UNIQUE(menu_item_id, ingredient_id)
)
''');

    // Table 4: CostComponents
    await db.execute('''
CREATE TABLE cost_components (
  id $idType,
  name $textType,
  category $textType,
  amount $realType,
  is_percentage $integerDefault0,
  is_active $integerDefault1,
  applies_to $textDefaultAll,
  notes $textNullable,
  created_at $integerType
)
''');

    // Table 5: PriceHistory
    await db.execute('''
CREATE TABLE price_history (
  id $idType,
  ingredient_id $integerType,
  old_price $realType,
  new_price $realType,
  changed_at $integerType,
  FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
)
''');
  }

  // CRUD Operations for Ingredients
  Future<int> createIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    return await db.insert('ingredients', ingredient.toMap());
  }

  Future<Ingredient?> readIngredient(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'ingredients',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Ingredient.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Ingredient>> readAllIngredients() async {
    final db = await instance.database;
    final result = await db.query('ingredients', orderBy: 'name ASC');
    return result.map((json) => Ingredient.fromMap(json)).toList();
  }

  Future<int> updateIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    return db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<int> deleteIngredient(int id) async {
    final db = await instance.database;
    return await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for MenuItems
  Future<int> createMenuItem(MenuItem menuItem) async {
    final db = await instance.database;
    return await db.insert('menu_items', menuItem.toMap());
  }

  Future<List<MenuItem>> readAllMenuItems() async {
    final db = await instance.database;
    final result = await db.query('menu_items', orderBy: 'name ASC');
    return result.map((json) => MenuItem.fromMap(json)).toList();
  }

  Future<int> updateMenuItem(MenuItem menuItem) async {
    final db = await instance.database;
    return db.update(
      'menu_items',
      menuItem.toMap(),
      where: 'id = ?',
      whereArgs: [menuItem.id],
    );
  }

  Future<int> deleteMenuItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD for RecipeIngredients
  Future<int> addRecipeIngredient(RecipeIngredient recipeIngredient) async {
    final db = await instance.database;
    return await db.insert('recipe_ingredients', recipeIngredient.toMap());
  }

  Future<List<RecipeIngredient>> getRecipeIngredients(int menuItemId) async {
    final db = await instance.database;
    final result = await db.query(
      'recipe_ingredients',
      where: 'menu_item_id = ?',
      whereArgs: [menuItemId],
    );
    return result.map((json) => RecipeIngredient.fromMap(json)).toList();
  }

  Future<int> deleteRecipeIngredient(int id) async {
    final db = await instance.database;
    return await db.delete(
      'recipe_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearRecipeIngredients(int menuItemId) async {
    final db = await instance.database;
    return await db.delete(
      'recipe_ingredients',
      where: 'menu_item_id = ?',
      whereArgs: [menuItemId],
    );
  }

  // CRUD for CostComponents
  Future<int> createCostComponent(CostComponent costComponent) async {
    final db = await instance.database;
    return await db.insert('cost_components', costComponent.toMap());
  }

  Future<List<CostComponent>> readAllCostComponents() async {
    final db = await instance.database;
    final result = await db.query('cost_components');
    return result.map((json) => CostComponent.fromMap(json)).toList();
  }

  Future<int> updateCostComponent(CostComponent costComponent) async {
    final db = await instance.database;
    return db.update(
      'cost_components',
      costComponent.toMap(),
      where: 'id = ?',
      whereArgs: [costComponent.id],
    );
  }

  Future<int> deleteCostComponent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'cost_components',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD for PriceHistory
  Future<int> addPriceHistory(PriceHistory history) async {
    final db = await instance.database;
    return await db.insert('price_history', history.toMap());
  }

  Future<List<PriceHistory>> getPriceHistory(int ingredientId) async {
    final db = await instance.database;
    final result = await db.query(
      'price_history',
      where: 'ingredient_id = ?',
      whereArgs: [ingredientId],
      orderBy: 'changed_at DESC',
    );
    return result.map((json) => PriceHistory.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
