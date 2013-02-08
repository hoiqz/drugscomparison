class ConditioninfographsController < ApplicationController

  # GET /conditioninfographs/new
  # GET /conditioninfographs/new.json
  def new

    @conditions=Condition.all
    @conditions.map do |condition|
        @attributehash=get_infograph_attributes(condition)
        @conditioninfograph = Conditioninfograph.new(@attributehash)
        if @conditioninfograph.save
          next
        else
          @conditioninfograph = Conditioninfograph.find_by_condition_id(condition.id)
          @conditioninfograph.update_attributes(@attributehash)
      end

    end
  end

  # self declared methods to get the values
  def get_infograph_attributes(condition)   #condition relation object
    att_hash={}
    att_hash[:condition_id]=condition.id
    att_hash[:most_reviewed]=get_most_reviewed_drug(condition)
    #att_hash[:cheapest] not available until we have the data
    att_hash[:most_satisfied]=get_most(condition,4,"satisfactory")
    att_hash[:most_kids_using]=get_most_kids_using(condition)
    att_hash[:total_reviews] =get_all_reviews(condition)
    #att_hash[:top_side_effect]      not available until we have the data
    att_hash[:most_easy_to_use] = get_most(condition,4,"ease_of_use")
    att_hash[:most_effective] = get_most(condition,4,"effectiveness")
    att_hash[:most_bad_reviews] = get_most_bad_reviews(condition,2)
    #att_hash[:overall_winner]

    return att_hash
  end

  def get_most_bad_reviews(condition,score)
    highest_count=0.0
    total=0.0
    winner='Insufficient Data'
    condition.drugs.map do |drug|
      query_record_count=Review.joins(:drug,:user).where("drug_id=? AND effectiveness <= ? AND ease_of_use <= ? AND satisfactory <= ?",drug.id,score,score,score).count
      total=total+query_record_count
      if query_record_count > highest_count
        highest_count=query_record_count
        winner=drug.brand_name
      end
    end
    freq=highest_count/total
    return "winner=>#{winner},frequency=>#{freq.round(2)}"
  end

  def get_all_reviews(condition)
    count=0
    condition.drugs.map do |drug|
     count=count+ user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drug.id}).count
    end
    return count
  end

  def get_most_kids_using(condition)
    highest_count=0.0
    total=0.0
    winner='Insufficient Data'
    condition.drugs.map do |drug|
      user_record_count=0
      user_record=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drug.id})
      user_record_count=user_record_count+user_record.where("age=?","3-6").count
      user_record_count=user_record_count+user_record.where("age=?","7-12").count
      user_record_count=user_record_count+user_record.where("age=?","12-18").count
      total=total+user_record_count
      if user_record_count > highest_count
        highest_count=user_record_count
        winner=drug.brand_name
      end
    end
    freq=highest_count/total
    return "winner=>#{winner},frequency=>#{freq.round(2)}"
  end

  def get_most(condition,score,type)
    highest_count=0.0
    total=0.0
    winner='Insufficient Data'
    condition.drugs.map do |drug|
      query_record_count=Review.joins(:drug,:user).where("drug_id=? AND #{type} >= ?",drug.id,score).count
      total=total+query_record_count
      if query_record_count > highest_count
        highest_count=query_record_count
        winner=drug.brand_name
      end
    end
    freq=highest_count/total
    return "winner=>#{winner},frequency=>#{freq.round(2)}"
  end

  def get_most_reviewed_drug(condition)
    highest_count=0.0
    total=get_all_reviews(condition).to_f
    winner='Insufficient Data'
    ranking=""
    newhash=Hash.new
    condition.drugs.map do |drug|
      query_record_count=Review.joins(:drug,:user).where("drug_id=?",drug.id).count
      newhash[drug.brand_name]=((query_record_count/total)*10).round(2)
    end
    newhash=newhash.sort_by {|k,v| v}.reverse        #reverse sort the hash according to the hash value
    ranking=newhash.collect {|k,v| "#{k}=>#{v}"}.join(',')
    return "#{ranking}" #store as a eg       Adderall Oral=>473,Focalin Oral=>129,Ritalin Oral=>123
  end



  # POST /conditioninfographs
  # POST /conditioninfographs.json
  def create
    @conditioninfograph = Conditioninfograph.new(params[:conditioninfograph])

    respond_to do |format|
      if @conditioninfograph.save
        format.html { redirect_to @conditioninfograph, notice: 'Conditioninfograph was successfully created.' }
        format.json { render json: @conditioninfograph, status: :created, location: @conditioninfograph }
      else
        format.html { render action: "new" }
        format.json { render json: @conditioninfograph.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /conditioninfographs/1
  # PUT /conditioninfographs/1.json
  def update
    @conditioninfograph = Conditioninfograph.find(params[:id])

    respond_to do |format|
      if @conditioninfograph.update_attributes(params[:conditioninfograph])
        format.html { redirect_to @conditioninfograph, notice: 'Conditioninfograph was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @conditioninfograph.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conditioninfographs/1
  # DELETE /conditioninfographs/1.json
  def destroy
    @conditioninfograph = Conditioninfograph.find(params[:id])
    @conditioninfograph.destroy

    respond_to do |format|
      format.html { redirect_to conditioninfographs_url }
      format.json { head :no_content }
    end
  end
end
