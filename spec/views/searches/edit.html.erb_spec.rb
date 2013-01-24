require 'spec_helper'

describe "searches/edit.html.erb" do
  before(:each) do
    @search = assign(:search, stub_model(Search,
      :new_record? => false,
      :keyword => "MyString",
      :gender => "MyString",
      :age => "MyString",
      :location => "MyString",
      :ethnicity => "MyString",
      :weight => 1,
      :smoking_status => "MyString",
      :new => "MyString",
      :show => "MyString"
    ))
  end

  it "renders the edit search form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => search_path(@search), :method => "post" do
      assert_select "input#search_keyword", :name => "search[keyword]"
      assert_select "input#search_gender", :name => "search[gender]"
      assert_select "input#search_age", :name => "search[age]"
      assert_select "input#search_location", :name => "search[location]"
      assert_select "input#search_ethnicity", :name => "search[ethnicity]"
      assert_select "input#search_weight", :name => "search[weight]"
      assert_select "input#search_smoking_status", :name => "search[smoking_status]"
      assert_select "input#search_new", :name => "search[new]"
      assert_select "input#search_show", :name => "search[show]"
    end
  end
end
