module ApplicationHelper
  def title
    base_title="Drugs comparison web site 1.0!"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
end
