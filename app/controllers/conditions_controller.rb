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

  def gender_distinction
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs
    respond_to do |format|
      format.js
    end
  end

  def multi_pie_view
  @condition=Condition.find(params[:id])
  @drugs=@condition.drugs.scoped
  @generate_colors=Array.new
      @drugs.each do  |drug|
        @generate_colors.push('#E238EC','#8AFB17' ,'#736AFF')    #set the colors here then pass to the javascript
      end
  respond_to do |format|
    format.js
  end
  end

  def by_gender_all_effectiveness
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new
    @drugs.each do  |drug|
      @generate_colors.push('#C11B17','#EE9A4D' , '#DDDF00','#CCFB5D' , '#5EFB6E')    #set the colors here then pass to the javascript
    end
    respond_to do |format|
      format.js
    end
  end

  def by_gender_male_effectiveness
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new
    @drugs.each do  |drug|
      @generate_colors.push('#C11B17','#EE9A4D' , '#DDDF00','#CCFB5D' , '#5EFB6E')    #set the colors here then pass to the javascript
    end
    respond_to do |format|
      format.js
    end
  end

  def by_gender_female_effectiveness
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new
    @drugs.each do  |drug|
      @generate_colors.push('#C11B17','#EE9A4D' , '#DDDF00','#CCFB5D' , '#5EFB6E')    #set the colors here then pass to the javascript
    end
    respond_to do |format|
      format.js
    end
  end
end

