require 'spec_helper'

describe "users/edit.html.erb" do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :new_record? => false,
      :username => "MyString",
      :age => 1,
      :ethnicity => "MyString",
      :email_address => "MyString",
      :location => "MyString",
      :gender => "MyString",
      :ip_address => "MyString",
      :genome_file => "MyString",
      :weight => 1,
      :smoking_status => "MyString",
      :allow_contact => false,
      :caregiver => false
    ))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => user_path(@user), :method => "post" do
      assert_select "input#user_username", :name => "user[username]"
      assert_select "input#user_age", :name => "user[age]"
      assert_select "input#user_ethnicity", :name => "user[ethnicity]"
      assert_select "input#user_email_address", :name => "user[email_address]"
      assert_select "input#user_location", :name => "user[location]"
      assert_select "input#user_gender", :name => "user[gender]"
      assert_select "input#user_ip_address", :name => "user[ip_address]"
      assert_select "input#user_genome_file", :name => "user[genome_file]"
      assert_select "input#user_weight", :name => "user[weight]"
      assert_select "input#user_smoking_status", :name => "user[smoking_status]"
      assert_select "input#user_allow_contact", :name => "user[allow_contact]"
      assert_select "input#user_caregiver", :name => "user[caregiver]"
    end
  end
end
