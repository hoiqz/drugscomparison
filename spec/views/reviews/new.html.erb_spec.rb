require 'spec_helper'

describe "reviews/new.html.erb" do
  before(:each) do
    assign(:review, stub_model(Review,
      :drug_id => 1,
      :user_id => 1,
      :condition_id => 1,
      :comments => "MyText",
      :review_url => "MyString",
      :effectiveness => 1.5,
      :ease_of_use => 1.5,
      :satisfactory => 1.5,
      :tolerability => 1.5,
      :tag_cloud_path => "MyString",
      :similar_experience => 1,
      :usage_duration_days => 1
    ).as_new_record)
  end

  it "renders new review form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => reviews_path, :method => "post" do
      assert_select "input#review_drug_id", :name => "review[drug_id]"
      assert_select "input#review_user_id", :name => "review[user_id]"
      assert_select "input#review_condition_id", :name => "review[condition_id]"
      assert_select "textarea#review_comments", :name => "review[comments]"
      assert_select "input#review_review_url", :name => "review[review_url]"
      assert_select "input#review_effectiveness", :name => "review[effectiveness]"
      assert_select "input#review_ease_of_use", :name => "review[ease_of_use]"
      assert_select "input#review_satisfactory", :name => "review[satisfactory]"
      assert_select "input#review_tolerability", :name => "review[tolerability]"
      assert_select "input#review_tag_cloud_path", :name => "review[tag_cloud_path]"
      assert_select "input#review_similar_experience", :name => "review[similar_experience]"
      assert_select "input#review_usage_duration_days", :name => "review[usage_duration_days]"
    end
  end
end
