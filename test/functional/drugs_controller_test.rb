require 'test_helper'

class DrugsControllerTest < ActionController::TestCase
  setup do
    @drug = drugs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:drugs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create drug" do
    assert_difference('Drug.count') do
      post :create, drug: { brand_name: @drug.brand_name, dosage: @drug.dosage, generic_name: @drug.generic_name, manufacturer: @drug.manufacturer, precaution: @drug.precaution, side_effect: @drug.side_effect }
    end

    assert_redirected_to drug_path(assigns(:drug))
  end

  test "should show drug" do
    get :show, id: @drug
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @drug
    assert_response :success
  end

  test "should update drug" do
    put :update, id: @drug, drug: { brand_name: @drug.brand_name, dosage: @drug.dosage, generic_name: @drug.generic_name, manufacturer: @drug.manufacturer, precaution: @drug.precaution, side_effect: @drug.side_effect }
    assert_redirected_to drug_path(assigns(:drug))
  end

  test "should destroy drug" do
    assert_difference('Drug.count', -1) do
      delete :destroy, id: @drug
    end

    assert_redirected_to drugs_path
  end
end
