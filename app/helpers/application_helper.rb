module ApplicationHelper
  def title
    base_title="Drugs comparison web site 1.0!"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def last_viewed url
    controller= url[:controller]
    action= url[:action]
    id=url[:id] if url[:id].present?
    id=url[:drug_id] if url[:drug_id].present?
    if controller == "reviews"
      drug_name=Drug.find(id).brand_name
    linkpath = link_to drug_name.capitalize, drug_reviews_path(id)
      linkpath
    else
      condition_name=Condition.find(id).name
      linkpath= link_to condition_name.capitalize, condition_path(id)
      linkpath
    end

  end
end
