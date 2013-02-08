require "spec_helper"

describe ConditioninfographsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/conditioninfographs" }.should route_to(:controller => "conditioninfographs", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/conditioninfographs/new" }.should route_to(:controller => "conditioninfographs", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/conditioninfographs/1" }.should route_to(:controller => "conditioninfographs", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/conditioninfographs/1/edit" }.should route_to(:controller => "conditioninfographs", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/conditioninfographs" }.should route_to(:controller => "conditioninfographs", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/conditioninfographs/1" }.should route_to(:controller => "conditioninfographs", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/conditioninfographs/1" }.should route_to(:controller => "conditioninfographs", :action => "destroy", :id => "1")
    end

  end
end
