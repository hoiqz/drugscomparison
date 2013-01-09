module ConditionHelper
  def get1(condition,drugid,gender)
    condition.get_male_reviews(drugid).count.round

  end
end
