module ConditionHelper
  def get1(condition,drugid,gender)
    condition.get_male_reviews(drugid).count.round

  end

  def display_hits condition
      link_to condition.name, condition_path(condition.condition_id)
  end

  def display_condition_info(desc)
    return_str="<p>"
    return_str=return_str+desc+"</p>"
    return return_str
  end

end
