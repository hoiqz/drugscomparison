module ConditionHelper
  def get1(condition,drugid,gender)
    condition.get_male_reviews(drugid).count.round

  end

  def display_hits condition
      link_to condition.name, condition_path(condition.condition_id)
  end
end
