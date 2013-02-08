require 'spec_helper'

describe ConditioninfographsController do

  def mock_conditioninfograph(stubs={})
    (@mock_conditioninfograph ||= mock_model(Conditioninfograph).as_null_object).tap do |conditioninfograph|
      conditioninfograph.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all conditioninfographs as @conditioninfographs" do
      Conditioninfograph.stub(:all) { [mock_conditioninfograph] }
      get :index
      assigns(:conditioninfographs).should eq([mock_conditioninfograph])
    end
  end

  describe "GET show" do
    it "assigns the requested conditioninfograph as @conditioninfograph" do
      Conditioninfograph.stub(:find).with("37") { mock_conditioninfograph }
      get :show, :id => "37"
      assigns(:conditioninfograph).should be(mock_conditioninfograph)
    end
  end

  describe "GET new" do
    it "assigns a new conditioninfograph as @conditioninfograph" do
      Conditioninfograph.stub(:new) { mock_conditioninfograph }
      get :new
      assigns(:conditioninfograph).should be(mock_conditioninfograph)
    end
  end

  describe "GET edit" do
    it "assigns the requested conditioninfograph as @conditioninfograph" do
      Conditioninfograph.stub(:find).with("37") { mock_conditioninfograph }
      get :edit, :id => "37"
      assigns(:conditioninfograph).should be(mock_conditioninfograph)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created conditioninfograph as @conditioninfograph" do
        Conditioninfograph.stub(:new).with({'these' => 'params'}) { mock_conditioninfograph(:save => true) }
        post :create, :conditioninfograph => {'these' => 'params'}
        assigns(:conditioninfograph).should be(mock_conditioninfograph)
      end

      it "redirects to the created conditioninfograph" do
        Conditioninfograph.stub(:new) { mock_conditioninfograph(:save => true) }
        post :create, :conditioninfograph => {}
        response.should redirect_to(conditioninfograph_url(mock_conditioninfograph))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved conditioninfograph as @conditioninfograph" do
        Conditioninfograph.stub(:new).with({'these' => 'params'}) { mock_conditioninfograph(:save => false) }
        post :create, :conditioninfograph => {'these' => 'params'}
        assigns(:conditioninfograph).should be(mock_conditioninfograph)
      end

      it "re-renders the 'new' template" do
        Conditioninfograph.stub(:new) { mock_conditioninfograph(:save => false) }
        post :create, :conditioninfograph => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested conditioninfograph" do
        Conditioninfograph.should_receive(:find).with("37") { mock_conditioninfograph }
        mock_conditioninfograph.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :conditioninfograph => {'these' => 'params'}
      end

      it "assigns the requested conditioninfograph as @conditioninfograph" do
        Conditioninfograph.stub(:find) { mock_conditioninfograph(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:conditioninfograph).should be(mock_conditioninfograph)
      end

      it "redirects to the conditioninfograph" do
        Conditioninfograph.stub(:find) { mock_conditioninfograph(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(conditioninfograph_url(mock_conditioninfograph))
      end
    end

    describe "with invalid params" do
      it "assigns the conditioninfograph as @conditioninfograph" do
        Conditioninfograph.stub(:find) { mock_conditioninfograph(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:conditioninfograph).should be(mock_conditioninfograph)
      end

      it "re-renders the 'edit' template" do
        Conditioninfograph.stub(:find) { mock_conditioninfograph(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested conditioninfograph" do
      Conditioninfograph.should_receive(:find).with("37") { mock_conditioninfograph }
      mock_conditioninfograph.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the conditioninfographs list" do
      Conditioninfograph.stub(:find) { mock_conditioninfograph }
      delete :destroy, :id => "1"
      response.should redirect_to(conditioninfographs_url)
    end
  end

end
