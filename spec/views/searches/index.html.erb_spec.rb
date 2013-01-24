require 'spec_helper'

describe "searches/index.html.erb" do
  before(:each) do
    assign(:searches, [
      stub_model(Search,
        :keyword => "Keyword",
        :gender => "Gender",
        :age => "Age",
        :location => "Location",
        :ethnicity => "Ethnicity",
        :weight => 1,
        :smoking_status => "Smoking Status",
        :new => "New",
        :show => "Show"
      ),
      stub_model(Search,
        :keyword => "Keyword",
        :gender => "Gender",
        :age => "Age",
        :location => "Location",
        :ethnicity => "Ethnicity",
        :weight => 1,
        :smoking_status => "Smoking Status",
        :new => "New",
        :show => "Show"
      )
    ])
  end

  it "renders a list of searches" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Keyword".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Gender".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Age".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Location".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Ethnicity".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Smoking Status".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "New".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Show".to_s, :count => 2
  end
end
