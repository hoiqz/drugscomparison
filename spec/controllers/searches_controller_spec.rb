require 'spec_helper'

describe SearchesController do

  def mock_search(stubs={})
    (@mock_search ||= mock_model(Search).as_null_object).tap do |search|
      search.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all searches as @searches" do
      Search.stub(:all) { [mock_search] }
      get :index
      assigns(:searches).should eq([mock_search])
    end
  end

  describe "GET show" do
    it "assigns the requested search as @search" do
      Search.stub(:find).with("37") { mock_search }
      get :show, :id => "37"
      assigns(:search).should be(mock_search)
    end
  end

  describe "GET new" do
    it "assigns a new search as @search" do
      Search.stub(:new) { mock_search }
      get :new
      assigns(:search).should be(mock_search)
    end
  end

  describe "GET edit" do
    it "assigns the requested search as @search" do
      Search.stub(:find).with("37") { mock_search }
      get :edit, :id => "37"
      assigns(:search).should be(mock_search)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created search as @search" do
        Search.stub(:new).with({'these' => 'params'}) { mock_search(:save => true) }
        post :create, :search => {'these' => 'params'}
        assigns(:search).should be(mock_search)
      end

      it "redirects to the created search" do
        Search.stub(:new) { mock_search(:save => true) }
        post :create, :search => {}
        response.should redirect_to(search_url(mock_search))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved search as @search" do
        Search.stub(:new).with({'these' => 'params'}) { mock_search(:save => false) }
        post :create, :search => {'these' => 'params'}
        assigns(:search).should be(mock_search)
      end

      it "re-renders the 'new' template" do
        Search.stub(:new) { mock_search(:save => false) }
        post :create, :search => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested search" do
        Search.should_receive(:find).with("37") { mock_search }
        mock_search.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :search => {'these' => 'params'}
      end

      it "assigns the requested search as @search" do
        Search.stub(:find) { mock_search(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:search).should be(mock_search)
      end

      it "redirects to the search" do
        Search.stub(:find) { mock_search(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(search_url(mock_search))
      end
    end

    describe "with invalid params" do
      it "assigns the search as @search" do
        Search.stub(:find) { mock_search(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:search).should be(mock_search)
      end

      it "re-renders the 'edit' template" do
        Search.stub(:find) { mock_search(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested search" do
      Search.should_receive(:find).with("37") { mock_search }
      mock_search.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the searches list" do
      Search.stub(:find) { mock_search }
      delete :destroy, :id => "1"
      response.should redirect_to(searches_url)
    end
  end

end
