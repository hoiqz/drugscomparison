class DruginfographsController < ApplicationController

  # GET /druginfographs/new
  # GET /druginfographs/new.json
  def new
    @drugs=Drug.all
    @drugs.map do |drug|
      @attributehash=get_infograph_attributes(drug.brand_name)
      @druginfograph = Druginfograph.new(@attributehash)
      if @druginfograph.save
        next
      else
        @druginfograph = Druginfograph.find_by_brand_name(drug.brand_name)
        @druginfograph.update_attributes(@attributehash)
      end
    end

  end


  # POST /druginfographs
  # POST /druginfographs.json
  def create
    @druginfograph = Druginfograph.new(params[:druginfograph])

    respond_to do |format|
      if @druginfograph.save
        format.html { redirect_to @druginfograph, notice: 'Druginfograph was successfully created.' }
        format.json { render json: @druginfograph, status: :created, location: @druginfograph }
      else
        format.html { render action: "new" }
        format.json { render json: @druginfograph.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /druginfographs/1
  # PUT /druginfographs/1.json
  def update
    @druginfograph = Druginfograph.find(params[:id])

    respond_to do |format|
      if @druginfograph.update_attributes(params[:druginfograph])
        format.html { redirect_to @druginfograph, notice: 'Druginfograph was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @druginfograph.errors, status: :unprocessable_entity }
      end
    end
  end

 # self declared methods to get the values
  def get_infograph_attributes(drug) #drug is the brand_name not drug id
    att_hash={}
    att_hash[:brand_name]=drug
    att_hash[:avg_sat_male]=get_satisfactory(drug,"Male")
    att_hash[:avg_sat_female]=get_satisfactory(drug,"Female")
    att_hash[:top_used_words]=get_top_used_words(drug)

    total_reviewer_for_this= total_reviewers(drug).to_f
    count_age_group1=get_user_age_group(drug,">55")
    count_age_group2=get_user_age_group(drug,"<18")
    count_age_group3=total_reviewer_for_this - count_age_group1 - count_age_group2
    att_hash[:age_more_50]=(count_age_group1/total_reviewer_for_this) *100
    att_hash[:age_less_18]= (count_age_group2/total_reviewer_for_this) *100
    att_hash[:age_btw_18_50]= (count_age_group3/total_reviewer_for_this) *100

    att_hash[:no_of_males] =(total_reviewers(drug,"Male") /total_reviewer_for_this)*100
    att_hash[:no_of_females]=(total_reviewers(drug,"Female")/total_reviewer_for_this)*100

    total_reviews_for_this= total_reviews(drug).to_f
    eff_over_3=statistic_get_more_or_equal(drug,"effectiveness",3)
    eff_less_3=statistic_get_less(drug,"effectiveness",3)
    att_hash[:effective_over_3]=(eff_over_3/ total_reviews_for_this)*10
    att_hash[:effective_less_3]  =(eff_less_3/ total_reviews_for_this) *10

    eou_over_3=statistic_get_more_or_equal(drug,"ease_of_use",3)
    eou_less_3=statistic_get_less(drug,"ease_of_use",3)
    att_hash[:eou_over_3] =(eou_over_3/ total_reviews_for_this) *10
    att_hash[:eou_less_3]=(eou_less_3/ total_reviews_for_this) *10

    return att_hash
  end

  def total_reviews(drug)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where("drug_id=?",mydrugid).count
  end

  def statistic_get_more_or_equal(drug,type,score)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where("drug_id=? AND #{type} >= ?",mydrugid,score).count
  end

  def statistic_get_less(drug,type,score)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where("drug_id=? AND #{type} < ?",mydrugid,score).count
  end

  def total_reviewers(drug,*gender)
    drugid=Drug.find_by_brand_name(drug).id

    if gender.empty?

      user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid}).count
    else
      if gender.shift == 'Male'
        user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid},:gender=>"Male").count
      else
      #if gender.shift =='Female'
        user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid},:gender=>"Female").count
      end
    end
        return user_record_count
  end

  def get_user_age_group(drug,age_range)
    drugid=Drug.find_by_brand_name(drug).id
    user_record=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid})
    count=0
    if age_range == "<18"
      count=count+user_record.where("age=?","3-6").count
      count=count+user_record.where("age=?","7-12").count
      count=count+user_record.where("age=?","12-18").count
    end
    if age_range == ">55"
      count=count+user_record.where("age=?","55-64").count
      count=count+user_record.where("age=?","65-74").count
      count=count+user_record.where("age=?","75 or over").count
    end
    return count
  end

  def get_satisfactory(drug,gender)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where(:drug_id=>mydrugid).where(:users=>{:gender=>gender})

    score1=query_record.where("satisfactory=?",1).count
    score2=query_record.where("satisfactory=?",2).count
    score3=query_record.where("satisfactory=?",3).count
    score4=query_record.where("satisfactory=?",4).count
    score5=query_record.where("satisfactory=?",5).count
    sum=Float(query_record.count)
    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
  end

  def get_top_used_words(drug)
    @tags=Tag.find_by_brand_name(drug)
    if @tags.nil?
      string=""
      else
    @tagshash=format2hash(@tags.word_list)
    temp=@tagshash.sort_by {|k,v| v}.reverse.shift(3)
    string=''
    arr=temp.collect { |x| x[0]}
    string  =arr.join(",")
    end

  end

  def format2hash(string)
    stringhash={}
    string.split(",").map { |keyvalue|
      arr=keyvalue.split("=>",2)
      stringhash[arr[0]]=arr[1].to_i
    }
    return stringhash
  end
end
