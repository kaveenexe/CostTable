import '../models/menu_item.dart';
import '../models/recipe_ingredient.dart';
import '../models/ingredient.dart';
import '../models/cost_component.dart';

class CostCalculator {
  // 1. Raw Food Cost (Per Serving)
  static double calculateRawFoodCost(
    MenuItem menuItem,
    List<RecipeIngredient> recipeIngredients,
    List<Ingredient> allIngredients,
  ) {
    double totalRecipeCost = 0;

    for (var recipeIngredient in recipeIngredients) {
      final ingredient = allIngredients.firstWhere(
        (i) => i.id == recipeIngredient.ingredientId,
        orElse: () => Ingredient(
          id: -1,
          name: '',
          baseUnit: '',
          currentPrice: 0,
          lastUpdated: 0,
          createdAt: 0,
        ),
      );

      if (ingredient.id != -1) {
        // Simple calculation assuming units match or are handled. 
        // In a real app, unit conversion logic is needed.
        // For MVP, we assume the quantity is in the base unit of the ingredient 
        // OR the user manually handles the conversion in the quantity input.
        // The guide says: "unit TEXT NOT NULL -- 'kg', 'L', 'piece', 'gram' (can differ from ingredient's base unit)"
        // But for MVP simplicity and without a conversion table, we'll assume direct multiplication 
        // or that the user enters the quantity relative to the price unit.
        // However, the guide example shows: Noodles 0.1 kg * 250 = 25. 
        // So price is per base unit. Quantity should be in base unit.
        
        // If units differ, we'd need a converter. For now, we'll assume they match or user converts.
        totalRecipeCost += recipeIngredient.quantity * ingredient.currentPrice;
      }
    }

    if (menuItem.servingsPerRecipe == 0) return 0;
    return totalRecipeCost / menuItem.servingsPerRecipe;
  }

  // 2. Direct Costs (Per Serving)
  static double calculateDirectCosts(
    double rawFoodCost,
    List<CostComponent> costComponents,
  ) {
    double totalDirectCost = 0;

    for (var component in costComponents) {
      if (component.category == 'DIRECT' && component.isActive == 1) {
        if (component.isPercentage == 1) {
          totalDirectCost += (rawFoodCost * component.amount) / 100;
        } else {
          totalDirectCost += component.amount;
        }
      }
    }

    return totalDirectCost;
  }

  // 3. Indirect Costs (Per Serving)
  static double calculateIndirectCosts(
    double rawFoodCost,
    double directCosts,
    List<CostComponent> costComponents,
  ) {
    double totalIndirectCost = 0;
    double baseCost = rawFoodCost + directCosts;

    for (var component in costComponents) {
      if (component.category == 'INDIRECT' && component.isActive == 1) {
        if (component.isPercentage == 1) {
          totalIndirectCost += (baseCost * component.amount) / 100;
        } else {
          totalIndirectCost += component.amount;
        }
      }
    }

    return totalIndirectCost;
  }

  // 4. Total Cost Per Serving
  static double calculateTotalCost(
    double rawFoodCost,
    double directCosts,
    double indirectCosts,
  ) {
    return rawFoodCost + directCosts + indirectCosts;
  }

  // 5. Selling Price (Based on Desired Profit Margin)
  static double calculateSellingPrice(
    double totalCost,
    double desiredMarginPercentage, // e.g., 60 for 60%
  ) {
    if (desiredMarginPercentage >= 100) return 0; // Avoid division by zero or negative
    return totalCost / (1 - (desiredMarginPercentage / 100));
  }

  // 6. Contribution Margin
  static double calculateContributionMargin(
    double sellingPrice,
    double rawFoodCost,
    double directCosts,
  ) {
    if (sellingPrice == 0) return 0;
    return ((sellingPrice - rawFoodCost - directCosts) / sellingPrice) * 100;
  }
}
