# TODO compare to: http://www.fao.org/docrep/017/ap815e/ap815e.pdf
# 236.59 ml water == 1 cup
# GR_PER_CUPS_OF_WATER = 237
# CUPS_OF_WATER_PER_GR = 1 / 237

require 'csv'

class Ingredient
  attr_reader :name, :metric, :metric_unit, :us, :us_unit

  def initialize(name, metric, us)
    @name = name.strip
    @metric = metric.to_f
    @metric_unit = metric.gsub(/\d/, '').strip
    @us = to_frac(us.gsub(/[a-zA-Z]/, '').strip)
    @us_unit = us.gsub(/\d|\/|\./, '').strip
  end

  def us_per_metric   # i.e. cups_per_gr
    us / metric
  end

  def to_frac(string)
    right, left = string.split(' ').reverse
    numerator, denominator = right.split('/').map(&:to_f)
    denominator ||= 1
    left.to_i + numerator / denominator
  end
end

class IngredientCsvStore
  def initialize(filename)
    @filename = filename
    @ingredients = []
    parse
  end

  def [](name)
    all.detect { |ingredient| ingredient.name == name }
  end

  def all
    @ingredients
  end

  def parse
    CSV.new(csv, :col_sep => ';', :headers => true).each do |row|
      next unless valid_row?(row)
      @ingredients << Ingredient.new(row['ingredient'], row['metric'], row['us'])
    end
  end

  def csv
    File.read(@filename)
  end

  def valid_row?(row)
    metric, us = row.values_at('metric', 'us')
    metric && (gram?(metric) || ml?(metric)) && us && (cup?(us) || tbsp?(us) || oz?(us))
  end

  def gram?(string)
    string[-1] == 'g'
  end

  def ml?(string)
    string[-2..-1] == 'ml'
  end

  def cup?(string)
    string.include?('cup')
  end

  def tbsp?(string)
    string.include?('bsp')
  end

  def oz?(string)
    string.include?('oz')
  end
end

print "Ingredient: "
name = gets.chomp

store = IngredientCsvStore.new('ingredients.csv')
ingredient = store[name]

if ingredient
  print "Amount in #{ingredient.metric_unit}: "
  metric_amount = gets.chomp.to_f

  us_amount = ingredient.us_per_metric * metric_amount

  puts "#{metric_amount} #{ingredient.metric_unit} #{name} in #{ingredient.us_unit}: #{us_amount.round(2)}"
else
  puts "Sorry, this ingredient doens't exist."
end


# ingredients = store.all

# ingredients.each do |ingredient|
#   puts "#{ingredient.name}, #{ingredient.metric} #{ingredient.metric_unit}, #{ingredient.us} #{ingredient.us_unit}"
# end

