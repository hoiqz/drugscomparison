require "spec_helper"

describe DruginfographsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/druginfographs" }.should route_to(:controller => "druginfographs", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/druginfographs/new" }.should route_to(:controller => "druginfographs", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/druginfographs/1" }.should route_to(:controller => "druginfographs", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/druginfographs/1/edit" }.should route_to(:controller => "druginfographs", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/druginfographs" }.should route_to(:controller => "druginfographs", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/druginfographs/1" }.should route_to(:controller => "druginfographs", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/druginfographs/1" }.should route_to(:controller => "druginfographs", :action => "destroy", :id => "1")
    end

  end
end
