module ApplicationHelper
  def title_tag
    content_for(:title).presence || Rails.application.class.module_parent_name.titleize
  end
end
