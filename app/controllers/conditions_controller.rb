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
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @drug }
      format.js
    end
  end
end


## Hoi's defined method goes below
def effectiveness_count
  @drug = Drug.find(params[:id])
  @lessthan1=@drug.reviews.count(:conditions => "effectiveness =1")
  @lessthan2=@drug.reviews.count(:conditions => "effectiveness =2")
  @lessthan3=@drug.reviews.count(:conditions => "effectiveness =3")
  @lessthan4=@drug.reviews.count(:conditions => "effectiveness =4")
  @lessthan5=@drug.reviews.count(:conditions => "effectiveness =5")

  respond_to do |format|
    format.js
  end
end