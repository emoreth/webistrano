require 'test_helper'

class RecipeTest < ActiveSupport::TestCase

  test "create" do
    assert_nothing_raised{
      recipe = Recipe.create!(
        :name => 'Copy Config files',
        :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
        :body => "set :config_files, 'database.yml' "
      )
    }
  end
  
  test "validation" do
    
    # missing name
    recipe = Recipe.new(
      :name => nil,
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => "set :config_files, 'database.yml' "
    )
    assert !recipe.valid?
    
    # missing body
    recipe = Recipe.new(
      :name => 'Copy Tasks',
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => nil
    )
    assert !recipe.valid?
    
    # name too long
    recipe = Recipe.new(
      :name => 'Copy Config files' * 100,
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => "set :config_files, 'database.yml' "
    )
    assert !recipe.valid?
    
    # fix name and save
    recipe.name = 'Copy'
    recipe.save!
    
    # name not unique
    recipe = Recipe.new(
      :name => 'Copy',
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => "set :config_files, 'database.yml' "
    )
    assert !recipe.valid?
  end

  test "validate_invalid_syntax_on_create" do
    recipe = Recipe.create(:name => "Copy Config files",
                           :description => "Recipe body intentionally erronous",
                           :body => "set config_files, database.yml'")
    assert !recipe.valid?
    assert_include "syntax error at line: 1", recipe.errors[:body]
  end
  
  test "validate_valid_syntax_on_create" do
    recipe = Recipe.create(:name => "Copy Config files",
                           :description => "Recipe body intentionally erronous",
                           :body => "set :config_files, 'database.yml'")
    assert_empty recipe.errors[:body]
  end
  
  test "validate_with_open4_error" do
    Open4.expects(:popen4).raises(RuntimeError)
    recipe = Recipe.create(:name => "Copy Config files",
                           :description => "Recipe body intentionally erronous",
                           :body => "set :config_files, 'database.yml'")
    assert_empty recipe.errors[:body]
  end
end
