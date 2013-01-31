require 'spec_helper'

describe DruginfographsController do

  def mock_druginfograph(stubs={})
    (@mock_druginfograph ||= mock_model(Druginfograph).as_null_object).tap do |druginfograph|
      druginfograph.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all druginfographs as @druginfographs" do
      Druginfograph.stub(:all) { [mock_druginfograph] }
      get :index
      assigns(:druginfographs).should eq([mock_druginfograph])
    end
  end

  describe "GET show" do
    it "assigns the requested druginfograph as @druginfograph" do
      Druginfograph.stub(:find).with("37") { mock_druginfograph }
      get :show, :id => "37"
      assigns(:druginfograph).should be(mock_druginfograph)
    end
  end

  describe "GET new" do
    it "assigns a new druginfograph as @druginfograph" do
      Druginfograph.stub(:new) { mock_druginfograph }
      get :new
      assigns(:druginfograph).should be(mock_druginfograph)
    end
  end

  describe "GET edit" do
    it "assigns the requested druginfograph as @druginfograph" do
      Druginfograph.stub(:find).with("37") { mock_druginfograph }
      get :edit, :id => "37"
      assigns(:druginfograph).should be(mock_druginfograph)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created druginfograph as @druginfograph" do
        Druginfograph.stub(:new).with({'these' => 'params'}) { mock_druginfograph(:save => true) }
        post :create, :druginfograph => {'these' => 'params'}
        assigns(:druginfograph).should be(mock_druginfograph)
      end

      it "redirects to the created druginfograph" do
        Druginfograph.stub(:new) { mock_druginfograph(:save => true) }
        post :create, :druginfograph => {}
        response.should redirect_to(druginfograph_url(mock_druginfograph))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved druginfograph as @druginfograph" do
        Druginfograph.stub(:new).with({'these' => 'params'}) { mock_druginfograph(:save => false) }
        post :create, :druginfograph => {'these' => 'params'}
        assigns(:druginfograph).should be(mock_druginfograph)
      end

      it "re-renders the 'new' template" do
        Druginfograph.stub(:new) { mock_druginfograph(:save => false) }
        post :create, :druginfograph => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested druginfograph" do
        Druginfograph.should_receive(:find).with("37") { mock_druginfograph }
        mock_druginfograph.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :druginfograph => {'these' => 'params'}
      end

      it "assigns the requested druginfograph as @druginfograph" do
        Druginfograph.stub(:find) { mock_druginfograph(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:druginfograph).should be(mock_druginfograph)
      end

      it "redirects to the druginfograph" do
        Druginfograph.stub(:find) { mock_druginfograph(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(druginfograph_url(mock_druginfograph))
      end
    end

    describe "with invalid params" do
      it "assigns the druginfograph as @druginfograph" do
        Druginfograph.stub(:find) { mock_druginfograph(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:druginfograph).should be(mock_druginfograph)
      end

      it "re-renders the 'edit' template" do
        Druginfograph.stub(:find) { mock_druginfograph(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested druginfograph" do
      Druginfograph.should_receive(:find).with("37") { mock_druginfograph }
      mock_druginfograph.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the druginfographs list" do
      Druginfograph.stub(:find) { mock_druginfograph }
      delete :destroy, :id => "1"
      response.should redirect_to(druginfographs_url)
    end
  end

end
