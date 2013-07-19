class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_menu_list ,:side_widget, :store_history

  def get_menu_list
    @common_condition=Array.new
    @day2day_condition=Array.new
    if Rails.env.development?
      common_condition_array=[67, #diarrhea
                              32, #Type 2 Diabetes Mellitus
                              670, #malaria
                              17,#depression
                              80, #Rheumatoid Arthritis
                              110 #overweight
      ]
      day_to_day_condition_array=[136, #Cold Symptoms
                                  370, #Strep Throat
                                  49, #Fever
                                  31, #Acne
                                  35, #Asthma
                                  129 #Runny nose
      ]
      drugs_top_picks_array=[1239,747,729,1132,39]
    else
      common_condition_array=[639, 240,946,239,305,465]
      day_to_day_condition_array=[352,497,835,322,270,349]
      drugs_top_picks_array=[1430,169,487,1286,1489]
    end

    @day2day_condition=Condition.find(day_to_day_condition_array)
    @common_condition=Condition.find(common_condition_array)
    @drugs_top_picks=Drug.find(drugs_top_picks_array)

  end

  def side_widget

    @common=[]
    @day2day_condition=[]
    @elderly_condition=[]
    @kids_condition=[]
    @mental_condition=[]
    Commoncondition.all.each do |condition|
      @common << condition if condition.category== "Common Health Conditions"
      @day2day_condition << condition if condition.category== "Day To Day Health"
      @elderly_condition << condition if condition.category== "Elderly Related Conditions"
      @kids_condition << condition if condition.category== "Kids Related Conditions"
      @mental_condition << condition if condition.category== "Mental Conditions"
    end

    @commondrugs=Commondrug.all
    @size= @commondrugs.count
    @sizefirsthalf= (@size / 3.0).ceil     # cause we wan to split it into three columns
    @sizesecondhalf=@sizefirsthalf+@sizefirsthalf
  end

  private

  def store_history
    session[:history] ||= []
    if ! request.xml_http_request?    # we do not store ajax request into the session
    url=Rails.application.routes.recognize_path(request.url)
    if url[:id] || url[:drug_id] # only add if it is a drug id or condition id
    session[:history].delete_at(0) if session[:history].size >= 5
    session[:history] << url
      end
    end
  end
end
