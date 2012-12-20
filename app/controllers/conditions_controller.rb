class ConditionsController < ApplicationController
  def index
    @conditions=Condition.all

  end

  def show
    @conditions=Condition.all
  end
end
