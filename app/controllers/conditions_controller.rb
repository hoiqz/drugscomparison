class ConditionsController < ApplicationController
  layout :resolve_layout
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
    @number_of_drugs=@drugs.count
    @generate_colors=Array.new
    @drugs.each do  |drug|
      @generate_colors.push('#E238EC','#8AFB17' ,'#736AFF')    #set the colors here then pass to the javascript
    end

    if params[:conditions]
      @optionshash=params
    end
    if params[:button]
    @metric=Hash.new
    @conmetric=Conditionmetric.find_all_by_condition(@condition.name)
    @conmetric.each do |item|
      review_count=Drug.find_by_brand_name(item.drug).reviews_count.to_f
      if params[:button]=="sat-table"
        @metric[item.drug] ={
              :good=> (item.sat_good)/review_count,
              :avg=> (item.sat_avg)/review_count,
              :bad=>(item.sat_bad)/review_count,
              :counts=>review_count.to_i
      }
      elsif params[:button]=="eff-table"
        @metric[item.drug] ={
                :good=> (item.eff_good)/review_count,
                :avg=> (item.eff_avg)/review_count,
                :bad=>(item.eff_bad)/review_count,
                :counts=>review_count.to_i
        }
      elsif params[:button]=="eou-table"
        @metric[item.drug] ={
                :good=> (item.eou_good)/review_count,
                :avg=> (item.eou_avg)/review_count,
                :bad=>(item.eou_bad)/review_count,
                :counts=>review_count.to_i
        }
      end
    end
    end
    # for the infograph
    @infograph=Conditioninfograph.find_by_condition_id(@condition.id)
    @most_reviewed=format2hash_string(@infograph.most_reviewed) # returns a ranked hash  eg  Adderall Oral=>473,Focalin Oral=>129,Ritalin Oral=>123
    if(@infograph.most_reviewed=~/(.*?),/)   # get the first in the sorted
      @most_reviewed_first= $1
      @winner=@most_reviewed_first.split("=>")
      @winner[1]=((@winner[1].to_f) *10).round(2)
    else # cant be split by the comma, ie only one drug
      @most_reviewed_first=@infograph.most_reviewed
      @winner=@most_reviewed_first.split("=>")
      @winner[1]=((@winner[1].to_f) *10).round(2)
    end
    @most_satisfied =format2hash_string(@infograph.most_satisfied)
    @most_kids_using =format2hash_string(@infograph.most_kids_using)
    @most_kids_freq=@most_kids_using["frequency"].to_f * 100
    @total_reviews =@infograph.total_reviews.to_i
    @most_easy_to_use =format2hash_string(@infograph.most_easy_to_use)
    @most_effective =format2hash_string(@infograph.most_effective)
    @most_bad_reviews =format2hash_string(@infograph.most_bad_reviews)
    # end infograph stuff
    respond_to do |format|
          format.js
          format.html # show.html.erb
          format.json { render json: @drug }

      end
    #  format.js
    end

  def format2hash_string(string)
    stringhash={}
    string.split(",").map { |keyvalue|
      arr=keyvalue.split("=>",2)
      stringhash[arr[0]]=arr[1]
    }
    return stringhash
  end

  def multi_pie_view
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new

    #for the condition label
    @label='Nil'
    if params[:conditions]
      @label=''
      labels=params.except(:utf8,:amp,:commit,:action,:controller,:page,:type,:conditions,:id)
      labels.each_pair do |key,value|
        @label<< "#{key.capitalize} : #{value} , "
      end
      @label='Nil' if @label.blank?
    end

    @review_options=params
    @update_values = Hash.new{|hash, key| hash[key] = Array.new}
    @drugs.each do  |drug|
      @review_options[:for_drug_id]=drug.id
      @related_reviews=@condition.get_all_reviews(@review_options)
      @generate_colors.push('#E238EC','#8AFB17' ,'#736AFF')    #set the colors here then pass to the javascript
      (@update_values[drug]).push(@condition.avg_eff2(@related_reviews).round(2), @condition.avg_eou2(@related_reviews).round(2),@condition.avg_sat2(@related_reviews).round(2))
    end
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def effectiveness_view
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new

    #for the condition label
    @label='Nil'
    if params[:conditions]
      @label=''
      labels=params.except(:utf8,:amp,:commit,:action,:controller,:page,:type,:conditions,:id)
      labels.each_pair do |key,value|
        @label<< "#{key.capitalize} : #{value} , "
      end
      @label='Nil' if @label.blank?
    end

    @review_options=params
    @update_values = Hash.new{|hash, key| hash[key] = Array.new}
    @drugs.each do  |drug|
      @review_options[:for_drug_id]=drug.id
      @related_reviews=@condition.get_all_reviews(@review_options)
      @generate_colors.push('#C11B17','#FF9999' , '#FFCC33','#99FF33' , '#009900')     #set the colors here then pass to the javascript
      (@update_values[drug]).push(@condition.eff_score1(@related_reviews).round(2), @condition.eff_score2(@related_reviews).round(2) ,@condition.eff_score3(@related_reviews).round(2),@condition.eff_score4(@related_reviews).round(2),@condition.eff_score5(@related_reviews).round(2))
    end
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def eou_view
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new

    #for the condition label
    @label='Nil'
    if params[:conditions]
      @label=''
      labels=params.except(:utf8,:amp,:commit,:action,:controller,:page,:type,:conditions,:id)
      labels.each_pair do |key,value|
        @label<< "#{key.capitalize} : #{value} , "
      end
      @label='Nil' if @label.blank?
    end

    @review_options=params
    @update_values = Hash.new{|hash, key| hash[key] = Array.new}
    @drugs.each do  |drug|
      @review_options[:for_drug_id]=drug.id
      @related_reviews=@condition.get_all_reviews(@review_options)
      @generate_colors.push('#C11B17','#FF9999' , '#FFCC33','#99FF33' , '#009900')      #set the colors here then pass to the javascript
      (@update_values[drug]).push(@condition.eou_score1(@related_reviews).round(2), @condition.eou_score2(@related_reviews).round(2),@condition.eou_score3(@related_reviews).round(2),@condition.eou_score4(@related_reviews).round(2),@condition.eou_score5(@related_reviews).round(2))
    end
    respond_to do |format|
      #format.html
      format.js
    end
  end

  def satisfactory_view
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new

    #for the condition label
    @label='Nil'
    if params[:conditions]
      @label=''
      labels=params.except(:utf8,:amp,:commit,:action,:controller,:page,:type,:conditions,:id)
      labels.each_pair do |key,value|
        @label<< "#{key.capitalize} : #{value} , "
      end
      @label='Nil' if @label.blank?
    end

    @review_options=params
    @update_values = Hash.new{|hash, key| hash[key] = Array.new}
    @drugs.each do  |drug|
      @review_options[:for_drug_id]=drug.id
      @related_reviews=@condition.get_all_reviews(@review_options)
      @generate_colors.push('#C11B17','#FF9999' , '#FFCC33','#99FF33' , '#009900')      #set the colors here then pass to the javascript
      (@update_values[drug]).push(@condition.sat_score1(@related_reviews).round(2), @condition.sat_score2(@related_reviews).round(2),@condition.sat_score3(@related_reviews).round(2),@condition.sat_score4(@related_reviews).round(2),@condition.sat_score5(@related_reviews).round(2))
    end
    respond_to do |format|
      #format.html
      format.js
    end
  end

  ##DEPRECEATED METHODS
  def gender_distinction
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs
    respond_to do |format|
      format.js
    end
  end
  def by_gender_all_effectiveness
    @condition=Condition.find(params[:id])
    @drugs=@condition.drugs.scoped
    @generate_colors=Array.new
    @drugs.each do  |drug|
      @generate_colors.push('#C11B17','#FF9999' , '#FFCC33','#99FF33' , '#009900')      #set the colors here then pass to the javascript
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
      @generate_colors.push('#C11B17','#FF9999' , '#FFCC33','#99FF33' , '#009900')      #set the colors here then pass to the javascript
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
      @generate_colors.push('#C11B17','#FF9999' , '#FFCC33','#99FF33' , '#009900')     #set the colors here then pass to the javascript
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def resolve_layout
    case action_name
      #when "new", "create"
       # "some_layout"
      when "show"
        "condition_layout"
      else
        "drug_index_layout"
    end
  end

end

