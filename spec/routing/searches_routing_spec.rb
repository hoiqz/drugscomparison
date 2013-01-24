require "spec_helper"

describe SearchesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/searches" }.should route_to(:controller => "searches", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/searches/new" }.should route_to(:controller => "searches", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/searches/1" }.should route_to(:controller => "searches", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/searches/1/edit" }.should route_to(:controller => "searches", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/searches" }.should route_to(:controller => "searches", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/searches/1" }.should route_to(:controller => "searches", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/searches/1" }.should route_to(:controller => "searches", :action => "destroy", :id => "1")
    end

  end
end
