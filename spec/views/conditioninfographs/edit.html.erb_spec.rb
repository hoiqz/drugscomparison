require 'spec_helper'

describe "conditioninfographs/edit.html.erb" do
  before(:each) do
    @conditioninfograph = assign(:conditioninfograph, stub_model(Conditioninfograph,
      :new_record? => false,
      :condition_id => 1,
      :most_reviewed => "MyString",
      :cheapest => 1.5,
      :most_satisfied => "MyString",
      :most_kids_using => "MyString",
      :total_reviews => 1.5,
      :top_side_effect => "MyString",
      :most_easy_to_use => "MyString",
      :most_effective => "MyString",
      :overall_winner => "MyString"
    ))
  end

  it "renders the edit conditioninfograph form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => conditioninfograph_path(@conditioninfograph), :method => "post" do
      assert_select "input#conditioninfograph_condition_id", :name => "conditioninfograph[condition_id]"
      assert_select "input#conditioninfograph_most_reviewed", :name => "conditioninfograph[most_reviewed]"
      assert_select "input#conditioninfograph_cheapest", :name => "conditioninfograph[cheapest]"
      assert_select "input#conditioninfograph_most_satisfied", :name => "conditioninfograph[most_satisfied]"
      assert_select "input#conditioninfograph_most_kids_using", :name => "conditioninfograph[most_kids_using]"
      assert_select "input#conditioninfograph_total_reviews", :name => "conditioninfograph[total_reviews]"
      assert_select "input#conditioninfograph_top_side_effect", :name => "conditioninfograph[top_side_effect]"
      assert_select "input#conditioninfograph_most_easy_to_use", :name => "conditioninfograph[most_easy_to_use]"
      assert_select "input#conditioninfograph_most_effective", :name => "conditioninfograph[most_effective]"
      assert_select "input#conditioninfograph_overall_winner", :name => "conditioninfograph[overall_winner]"
    end
  end
end
