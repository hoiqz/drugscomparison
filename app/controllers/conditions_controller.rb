class ConditionsController < ApplicationController
  def index
    @conditions=Condition.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @drugs }
    end

  end

  def show
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @drug }
      format.js
    end
  end
end

