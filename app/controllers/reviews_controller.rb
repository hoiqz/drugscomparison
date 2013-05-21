class ReviewsController < ApplicationController
  layout "drug_review_layout"
  #before_filter :get_drug, :except => :create
  before_filter :get_drug
  #before_filter :get_average, :only=>:show

  def get_drug
    @drug=Drug.find(params[:drug_id])
  end


  # GET /reviews
  # GET /reviews.json
  def index
    @for_counts=@drug.reviews.count
    @reviews = @drug.reviews.order("created_at DESC").page(params[:page]).per(5)

    ## for adding form into the page
    @review = @drug.reviews.new
    @user=User.new
    #for the tag cloud
    @edited_params=params.except(:amp,:commit,:action, :controller, :page).merge(:drug_name=>@drug.brand_name)
    @urlendcoded=@edited_params.to_query

    @tags=Tag.find_by_brand_name(@drug.brand_name)
    if @tags.nil?
      @tagshash={:key1=>"Word list not available for this drug"}
    else
      @tagshash=format2hash(@tags.word_list)
    end

    # for the infograph
    @infograph=Druginfograph.find_by_brand_name(@drug.brand_name)
    if @infograph.nil?
      @topwords=nil
    else
      @topwords=@infograph.top_used_words.split(',')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reviews }
      format.js
    end
  end

  def format2hash(string)
    stringhash={}
  string.split(",").map { |keyvalue|
    arr=keyvalue.split("=>",2)
    stringhash[arr[0]]=arr[1]
  }
    return stringhash
  end

  def list
      @reviews=@drug.reviews

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reviews }
    end
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    @review = @drug.reviews.find(params[:id])
    @avg_effectivness=@drug.avg_eff
    @avg_ease_of_use=@drug.avg_eou
    @avg_satisfactory=@drug.avg_sat

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @review }
    end
  end

  # GET /reviews/1/edit
  def edit
    @review = @drug.reviews.find(params[:id])
  end

  # GET /reviews/new
  # GET /reviews/new.json
  def new
    @review = @drug.reviews.new
    @user=User.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review }
    end
  end

  # POST /reviews
  # POST /reviews.json
  def create
    #@drug=Drug.find(params[:review][:drug_id])
    @user=User.new(params[:user])
    @user.username="guest"+"#{rand 100}"+"#{Time.now.to_i}"
    #if params[:user].blank?
    #  @review=Review.new(params[:review])
    #else
    #  @review = @user.reviews.build(params[:review])
    #end
    @review = @user.reviews.build(params[:review])
    #@review.effectiveness=params[:review][:effectiveness] ? params[:review][:effectiveness]:nil
    #@review.satisfactory=params[:review][:satisfactory] ? params[:review][:satisfactory]:nil
    #@review.ease_of_use=params[:review][:ease_of_use] ? params[:review][:ease_of_use]:nil



    @review.drug_id=params[:drug_id]

    #@for_counts=@drug.reviews.count
    @reviews = @drug.reviews.order("created_at DESC").page(params[:page]).per(5)

    respond_to do |format|
      if @review.save
        @new_id=@review.id
        flash[:notice] = "Thanks for reviewing!"
        format.html { redirect_to drug_reviews_path(@drug.id), notice: 'Review was successfully created.' }
        format.js   { render  :redirect } # JavaScript to do the redirect
      else
        format.html { render action: "new" }
        format.js

      end
    end
  end

  # PUT /reviews/1
  # PUT /reviews/1.json
  def update
    @review = @drug.reviews.find(params[:id])

    respond_to do |format|
      if @review.update_attributes(params[:review])
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review = @drug.reviews.find(params[:id])
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url }
      format.json { head :no_content }
      format.js #added for form
    end
  end





end
