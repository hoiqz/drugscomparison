require 'spec_helper'

describe "druginfographs/edit.html.erb" do
  before(:each) do
    @druginfograph = assign(:druginfograph, stub_model(Druginfograph,
      :new_record? => false,
      :brand_name => "MyString",
      :avg_sat_male => 1.5,
      :avg_sat_female => 1.5,
      :top_used_words => "MyString",
      :age_more_50 => 1.5,
      :age_less_18 => 1.5,
      :age_btw_18_50 => 1.5,
      :no_of_males => 1.5,
      :no_of_females => 1.5,
      :effective_over_4 => 1.5,
      :effective_less_4 => 1.5,
      :eou_over_4 => 1.5
    ))
  end

  it "renders the edit druginfograph form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => druginfograph_path(@druginfograph), :method => "post" do
      assert_select "input#druginfograph_brand_name", :name => "druginfograph[brand_name]"
      assert_select "input#druginfograph_avg_sat_male", :name => "druginfograph[avg_sat_male]"
      assert_select "input#druginfograph_avg_sat_female", :name => "druginfograph[avg_sat_female]"
      assert_select "input#druginfograph_top_used_words", :name => "druginfograph[top_used_words]"
      assert_select "input#druginfograph_age_more_50", :name => "druginfograph[age_more_50]"
      assert_select "input#druginfograph_age_less_18", :name => "druginfograph[age_less_18]"
      assert_select "input#druginfograph_age_btw_18_50", :name => "druginfograph[age_btw_18_50]"
      assert_select "input#druginfograph_no_of_males", :name => "druginfograph[no_of_males]"
      assert_select "input#druginfograph_no_of_females", :name => "druginfograph[no_of_females]"
      assert_select "input#druginfograph_effective_over_4", :name => "druginfograph[effective_over_4]"
      assert_select "input#druginfograph_effective_less_4", :name => "druginfograph[effective_less_4]"
      assert_select "input#druginfograph_eou_over_4", :name => "druginfograph[eou_over_4]"
    end
  end
end
