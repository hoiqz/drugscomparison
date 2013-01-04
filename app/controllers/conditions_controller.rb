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

    #@genderhash=Hash.new
    #@drugs.each do |drug|

      ###### MALES #######
      #male_reviews=drug.get_male_reviews        # get male drug review for this drug
      #male_reviews_size=male_reviews.size  # get the size and store in a hash

      # calculate effectiveness ratings by males
     # male_total_eff= Review.find(male_reviews).map {|review| review.effectiveness}
     # male_avg_eff=male_total_eff.inject(:+)/male_reviews_size # this is jus summing up and divide by total

      #do it for eou
     # male_total_eou= Review.find(male_reviews).map {|review| review.ease_of_use}
    #  male_avg_eou=male_total_eou.inject(:+)/male_reviews_size

      #do it for satisfactory
    #  male_total_sat= Review.find(male_reviews).map {|review| review.satisfactory}
    #  male_avg_sat=male_total_sat.inject(:+)/male_reviews_size

   #   @genderhash[drug.brand_name]={:Male=>{:Scores=>{:eff=>male_avg_eff, :eou=>male_avg_eou,:sat=>male_avg_sat}}}

      ######## FEMALES ######
     # female_reviews=drug.get_female_reviews
   #   female_reviews_size=female_reviews.size

      #calculate effectiveness for females
    #  female_total_eff= Review.find(female_reviews).map {|review| review.effectiveness}
    #  female_avg_eff=female_total_eff.inject(:+)/female_reviews_size
      #do it for eou
    #  female_total_eou= Review.find(female_reviews).map {|review| review.ease_of_use}
   #   female_avg_eou=male_total_eou.inject(:+)/female_reviews_size
      #do it for satisfactory
    #  female_total_sat= Review.find(female_reviews).map {|review| review.satisfactory}
    #  female_avg_sat=female_total_sat.inject(:+)/female_reviews_size

    #  @genderhash[drug.brand_name]={:Female=>{:Scores=>{:eff=>female_avg_eff, :eou=>female_avg_eou,:sat=>female_avg_sat}}}
  #  end
    respond_to do |format|
      format.js
    end
  end
end

