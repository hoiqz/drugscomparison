require 'spec_helper'

describe "conditioninfographs/show.html.erb" do
  before(:each) do
    @conditioninfograph = assign(:conditioninfograph, stub_model(Conditioninfograph,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Most Reviewed/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1.5/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Most Satisfied/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Most Kids Using/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1.5/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Top Side Effect/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Most Easy To Use/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Most Effective/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Overall Winner/)
  end
end
