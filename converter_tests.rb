require 'minitest'
require 'minitest/autorun'
require 'converter'

# run with ruby -I . converter_tests.rb

class TestIngredient < MiniTest::Test
  def test_cups_per_gr_returns_whatever_for_blackberries
    ingredient = Ingredient.new('blackberries', '100 g', '1 cup')
    assert_equal 0.01, ingredient.us_per_metric
  end

  def test_cups_per_gr_returns_whatever_for_millet
    ingredient = Ingredient.new('millet', '100 g', '1/2 cup')
    assert_equal 0.005, ingredient.us_per_metric
  end

  def test_that_ingredients_works_with_one
    ingredient = Ingredient.new('foo', '120 ml', '1 cup')
    assert_equal 1, ingredient.us
  end

  def test_that_ingredients_works_with_one_forth_with_cup
    ingredient = Ingredient.new('foo', '120 ml', '1/4 cup')
    assert_equal 0.25, ingredient.us
  end

  def test_that_ingredients_works_with_one_forth_with_cups
    ingredient = Ingredient.new('foo', '120 ml', '1/4 cups')
    assert_equal 0.25, ingredient.us
  end

  def test_that_ingredients_works_with_one_and_a_half
    ingredient = Ingredient.new('foo', '120 ml', '1 1/2 cups')
    assert_equal 1.5, ingredient.us
  end

  def test_that_ingredients_works_with_tbsp
    ingredient = Ingredient.new('foo', '120 ml', '1 1/2 tbsp')
    assert_equal 1.5, ingredient.us
  end

  def test_that_ingredients_works_with_oz
    ingredient = Ingredient.new('foo', '120 ml', '1 1/2 oz')
    assert_equal 1.5, ingredient.us
  end
end


class TestIngredientCsvStore < MiniTest::Test
  def test_reads_ingredients
    store = IngredientCsvStore.new('ingredients.csv')
    ingredients = store.all
    assert ingredients.first.is_a?(Ingredient)
  end
end

class TestParser < MiniTest::Test
  def test_parses_number_and_unit
    value, unit, comment = Parser.new('237 ml').parse
    assert_equal 237.0, value
    assert_equal 'ml', unit
  end
 
  def test_parses_number_with_digit_and_unit
    value, unit, comment = Parser.new('0.2 l').parse
    assert_equal 0.2, value
    assert_equal 'l', unit
  end
 
  def test_parses_number_unit_and_comment
    value, unit, comment = Parser.new('1 cup, firmly packed').parse
    assert_equal 1.0, value
    assert_equal 'cup', unit
    assert_equal 'firmly packed', comment
  end
 
  def test_parses_quotient_unit_and_comment
    value, unit, comment = Parser.new('1/2 cup, firmly packed').parse
    assert_equal 0.5, value
    assert_equal 'cup', unit
    assert_equal 'firmly packed', comment
  end
 
  def test_parses_number_with_quotient_unit_and_comment
    value, unit, comment = Parser.new('1 1/2 cup, firmly packed').parse
    assert_equal 1.5, value
    assert_equal 'cup', unit
    assert_equal 'firmly packed', comment
  end
end