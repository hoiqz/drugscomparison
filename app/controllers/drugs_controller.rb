class DrugsController < ApplicationController
  before_filter :get_average, :only=>:show
  layout "drug_index_layout"
  def get_average
    @drug = Drug.find(params[:id])
    @avg_effectivness=@drug.avg_eff
    @avg_ease_of_use=@drug.avg_eou
    @avg_satisfactory=@drug.avg_sat
  end
  # GET /drugs
  # GET /drugs.json
  def index
    @alphabetical=("A".."Z").to_a
    @alphabetical<<"#"
    if params[:letter]
      params[:letter]=="#" ?  @drugs=Drug.by_non_letter(params[:letter]) : @drugs=Drug.by_letter(params[:letter])
      @drugs.sort_by!{ |ele| ele.brand_name.downcase }
    else
      @drugs= Drug.by_letter("a")
      @drugs.sort_by!{ |ele| ele.brand_name.downcase }
    end
    @size= @drugs.count
    @sizehalf= (@size / 2.0).ceil

    @drugsarr = Array.new
    Mostcommondrug.scoped.each do |common|
      @drugsarr<<common.drug_id
      if @drugsarr.size >9
        break
      end
    end
    @Mostrevieweddrugs=Drug.find(@drugsarr)


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
def search
    @drug = Drug.find(params[:id])
    @review_options=params
    @review_options[:for_drug_id]=params[:id]
     @reviews=@drug.get_all_reviews(@review_options).order("created_at DESC").page(params[:page]).per(5)
    @for_counts=@reviews.count
  respond_to do |format|
    format.js
  end
end

end
