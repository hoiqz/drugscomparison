require 'spec_helper'

describe "druginfographs/index.html.erb" do
  before(:each) do
    assign(:druginfographs, [
      stub_model(Druginfograph,
        :brand_name => "Brand Name",
        :avg_sat_male => 1.5,
        :avg_sat_female => 1.5,
        :top_used_words => "Top Used Words",
        :age_more_50 => 1.5,
        :age_less_18 => 1.5,
        :age_btw_18_50 => 1.5,
        :no_of_males => 1.5,
        :no_of_females => 1.5,
        :effective_over_4 => 1.5,
        :effective_less_4 => 1.5,
        :eou_over_4 => 1.5
      ),
      stub_model(Druginfograph,
        :brand_name => "Brand Name",
        :avg_sat_male => 1.5,
        :avg_sat_female => 1.5,
        :top_used_words => "Top Used Words",
        :age_more_50 => 1.5,
        :age_less_18 => 1.5,
        :age_btw_18_50 => 1.5,
        :no_of_males => 1.5,
        :no_of_females => 1.5,
        :effective_over_4 => 1.5,
        :effective_less_4 => 1.5,
        :eou_over_4 => 1.5
      )
    ])
  end

  it "renders a list of druginfographs" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Brand Name".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Top Used Words".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
