class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_menu_list , :store_history

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

  private

  def store_history
    session[:history] ||= []
    url=Rails.application.routes.recognize_path(request.url)
    if url[:id] || url[:drug_id]
    session[:history].delete_at(0) if session[:history].size >= 5
    session[:history] << url
    end
  end
end
