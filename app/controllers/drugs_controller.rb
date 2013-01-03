class DrugsController < ApplicationController
  before_filter :get_average, :only=>:show

  def get_average
    @drug = Drug.find(params[:id])
    @avg_effectivness=@drug.reviews.average('effectiveness')
    @avg_ease_of_use=@drug.reviews.average('ease_of_use')
    @avg_satisfactory=@drug.reviews.average('satisfactory')
  end
  # GET /drugs
  # GET /drugs.json
  def index
    @drugs = Drug.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @drugs }
    end
  end

  # GET /drugs/1
  # GET /drugs/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @drug }
      format.js
    end
  end

  # GET /drugs/new
  # GET /drugs/new.json
  def new
    @drug = Drug.new
    3.times {@drug.reviews.build}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @drug }
    end
  end

  # GET /drugs/1/edit
  def edit
    @drug = Drug.find(params[:id])
  end

  # POST /drugs
  # POST /drugs.json
  def create
    @drug = Drug.new(params[:drug])

    respond_to do |format|
      if @drug.save
        format.html { redirect_to @drug, notice: 'Drug was successfully created.' }
        format.json { render json: @drug, status: :created, location: @drug }
      else
        format.html { render action: "new" }
        format.json { render json: @drug.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /drugs/1
  # PUT /drugs/1.json
  def update
    @drug = Drug.find(params[:id])

    respond_to do |format|
      if @drug.update_attributes(params[:drug])
        format.html { redirect_to @drug, notice: 'Drug was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @drug.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drugs/1
  # DELETE /drugs/1.json
  def destroy
    @drug = Drug.find(params[:id])
    @drug.destroy

    respond_to do |format|
      format.html { redirect_to drugs_url }
      format.json { head :no_content }
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

  def ease_of_use_count
    @drug = Drug.find(params[:id])
    @lessthan1=@drug.reviews.count(:conditions => "ease_of_use =1")
    @lessthan2=@drug.reviews.count(:conditions => "ease_of_use =2")
    @lessthan3=@drug.reviews.count(:conditions => "ease_of_use =3")
    @lessthan4=@drug.reviews.count(:conditions => "ease_of_use =4")
    @lessthan5=@drug.reviews.count(:conditions => "ease_of_use =5")

    respond_to do |format|
      format.js
    end
  end

  def satisfactory_count
    @drug = Drug.find(params[:id])
    @lessthan1=@drug.reviews.count(:conditions => "satisfactory =1")
    @lessthan2=@drug.reviews.count(:conditions => "satisfactory =2")
    @lessthan3=@drug.reviews.count(:conditions => "satisfactory =3")
    @lessthan4=@drug.reviews.count(:conditions => "satisfactory =4")
    @lessthan5=@drug.reviews.count(:conditions => "satisfactory =5")

    respond_to do |format|
      format.js
    end
  end

end
