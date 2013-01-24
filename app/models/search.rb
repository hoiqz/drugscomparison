class Search < ActiveRecord::Base
  attr_accessible :age, :ethnicity, :gender, :keyword, :location, :new, :show, :smoking_status, :weight, :drug_name

  def get_all_reviews (options = {})
    #options[:for_drug_id]||options[:for_drug_id]=1
    if options[:for_drug_id]
      query_record=Review.joins(:drug,:user).where(:drug_id=>options[:for_drug_id])  #always search with a drug id
    else
      query_record=Review.joins(:drug,:user)
    end
                                                                                   # add in other search conditions depending on what options were passed in
    options.each do |key,value|
      if key=="gender"
        query_record=query_record.where(:users=>{:gender=>value})
        next
      end
      if key=="age"
        query_record=query_record.where(:users=>{:age=>value})
        next
      end
      if key =="location"
        query_record=query_record.where(:users=>{:location=>value})
        next
      end
      if key =="ethnicity"
        query_record=query_record.where(:users=>{:ethnicity=>value})
        next
      end
      if key =="weight"
        query_record=query_record.where(:users=>{:weight=>value})
        next
      end
      if key =="smoking_status"
        query_record=query_record.where(:users=>{:smoking_status=>value})
        next
      end

      if key =="ease_of_use"
        query_record=query_record.where(:ease_of_use=>value)
        next
      end
      if key =="effectiveness"
        query_record=query_record.where(:effectiveness=>value)
        next
      end
      if key =="satisfactory"
        query_record=query_record.where(:satisfactory=>value)
        next
      end
    end

    return query_record
  end
end
