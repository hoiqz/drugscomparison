class SearchesController < ApplicationController
  # GET /searches
  # GET /searches.json
  def index
    @searches = Sunspot.search(Drug, Review, Condition) do
      fulltext params[:search]
    end
    @results=@searches.results
    @drugresults=Array.new
    @conditionresults=Array.new
    @reviewresults=Array.new
    @results.each do |result|
      if result.instance_of?Drug
        @drugresults.push(result)
      elsif result.instance_of?Condition
        @conditionresults.push(result)
      else
        @reviewresults.push(result)
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @searches }
    end
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
    @search_object = Search.find(params[:id])
    @review_options=params
    @review_options[:gender]=@search_object[:gender] unless @search_object[:gender].blank?
    @review_options[:age]=@search_object[:age] unless @search_object[:age].blank?
    @review_options[:location]=@search_object[:location] unless @search_object[:location].blank?
    @review_options[:ethnicity]=@search_object[:ethnicity] unless @search_object[:ethnicity].blank?
    @review_options[:keyword]=@search_object[:keyword] unless @search_object[:keyword].blank?
    @review_options[:smoking_status]=@search_object[:smoking_status] unless @search_object[:smoking_status].blank?
    @review_options[:weight]=@search_object[:weight] unless @search_object[:weight].blank?

    if params[:drug_name] != 'all'
       @drug=Drug.find_by_brand_name(@search_object.drug_name)
       @review_options[:for_drug_id]=@drug.id
      @type=@drug.brand_name
    else
      @type="All Drugs"
    end
    @total_results=@search_object.get_all_reviews(@review_options).count
    @reviews = @search_object.get_all_reviews(@review_options).order("created_at DESC").page(params[:page]).per(5)


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @search }
    end
  end

  def non_form_search
    #@search_object = Search.find(params[:id])
    @review_options=params

    if params[:drug_name] != 'all'
      @drug=Drug.find_by_brand_name(params[:drug_name])
      @review_options[:for_drug_id]=@drug.id
      @type=@drug.brand_name
    else
      @type="All Drugs"
    end
    @newsearch=Search.new
    @for_counts=@newsearch.get_all_reviews(@review_options).count
    @reviews = @newsearch.get_all_reviews(@review_options).order("created_at DESC").page(params[:page]).per(5)


    respond_to do |format|
      format.html # show.html.erb
     # format.json { render json: @search }
     # format.js
    end
  end

  # GET /searches/new
  # GET /searches/new.json
  def new
    @search = Search.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @search }
    end
  end

  # GET /searches/1/edit
  def edit
    @search = Search.find(params[:id])
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = Search.new(params[:search])

    respond_to do |format|
      if @search.save
        format.html { redirect_to @search, notice: 'Search was successfully created.' }
        format.json { render json: @search, status: :created, location: @search }
      else
        format.html { render action: "new" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /searches/1
  # PUT /searches/1.json
  def update
    @search = Search.find(params[:id])

    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search = Search.find(params[:id])
    @search.destroy

    respond_to do |format|
      format.html { redirect_to searches_url }
      format.json { head :no_content }
    end
  end
end
