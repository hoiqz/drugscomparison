require 'spec_helper'

describe "conditioninfographs/index.html.erb" do
  before(:each) do
    assign(:conditioninfographs, [
      stub_model(Conditioninfograph,
        :condition_id => 1,
        :most_reviewed => "Most Reviewed",
        :cheapest => 1.5,
        :most_satisfied => "Most Satisfied",
        :most_kids_using => "Most Kids Using",
        :total_reviews => 1.5,
        :top_side_effect => "Top Side Effect",
        :most_easy_to_use => "Most Easy To Use",
        :most_effective => "Most Effective",
        :overall_winner => "Overall Winner"
      ),
      stub_model(Conditioninfograph,
        :condition_id => 1,
        :most_reviewed => "Most Reviewed",
        :cheapest => 1.5,
        :most_satisfied => "Most Satisfied",
        :most_kids_using => "Most Kids Using",
        :total_reviews => 1.5,
        :top_side_effect => "Top Side Effect",
        :most_easy_to_use => "Most Easy To Use",
        :most_effective => "Most Effective",
        :overall_winner => "Overall Winner"
      )
    ])
  end

  it "renders a list of conditioninfographs" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Most Reviewed".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Most Satisfied".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Most Kids Using".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Top Side Effect".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Most Easy To Use".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Most Effective".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Overall Winner".to_s, :count => 2
  end
end
