class StaticPagesController < ApplicationController


  layout :resolve_layout
  #layout "static_pages_layout"
  def home
     @condition=Condition.first
  end

  def review
    if params[:selected_drug].present?
      @drug=Drug.find(params[:selected_drug])
      @review=@drug.reviews.new
      @user=User.new
      #drugs_arr=Drug.where("brand_name LIKE ?","#{params[:letter]}%")
      #drugs_arr.each do |drug|
      #  temp=[drug.brand_name,drug.id]
      #  @drug_list.push(temp)
      #end
    else
      @drug_list=[]
      @alphabet=("A".."Z").to_a
      @drugs=Drug.all
      @alpha_arr=Array.new

      @alphabet.each do |letter|
        temp=[letter,letter]
        @alpha_arr.push(temp)
      end
    end
    respond_to do |format|
      format.html
      format.js
    end

  end

  def create
    @user=User.new(params[:user])
    @user.username="guest"+"#{rand 100}"+"#{Time.now.to_i}"
    @review = @user.reviews.build(params[:review])
    @review.drug_id=params[:drug_id]
    @drug=Drug.find(params[:drug_id])
    @conditions=@drug.conditions

    respond_to do |format|
      if params[:sweet_honey].present?
        #format.html { render :partial => "honeypot", :layout => "static_pages_review_layout" }
        flash[:notice] = "Are you a robot?!"
        format.js {render :action => "bot_detected"}
      elsif @review.save
        @new_id=@review.id
        flash[:notice] = "Thanks for reviewing!"
        format.html
        format.js {render :action => "create_success"}
      else
        format.html { render action: "new" }
        format.js
      end
    end
  end

  def new
    @review = @drug.reviews.new
    @user=User.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review }
    end
  end

  def update_drug_list
    #@drug_list=[]
    #drug_alphabet=params[:letter]
    #drugs_arr=Drug.where("brand_name LIKE ?","#{drug_alphabet}%")
    #drugs_arr.each do |drug|
    #  temp=[drug.brand_name,drug.id]
    #  @drug_list.push(temp)
    #end
    drug_alphabet=params[:selected_letter]
    drugs_arr=Drug.where("brand_name LIKE ?","#{drug_alphabet}%")
    @drugs=drugs_arr.map{|d| [d.brand_name,d.id]}.insert(0,"Select A Drug")

    respond_to do |format|
      format.js
    end
  end



  def resolve_layout
    case action_name
      when "review"
        "static_pages_review_layout"
      else
        "static_pages_layout"
    end
  end


end
