module ApplicationHelper
  def author_meta(post)
    if post.email.blank?
      post.author
    else
      mail_to(post.email, post.author)
    end
  end

  def reply_button(post)
    if params[:controller] == 'stream' && post.parent_post.nil?
      link_to("回應", thread_path(post))
    end
  end

  def postid_link(post)
    id = "No." + post.id.to_s
    qtag = "q" + post.id.to_s
    thread = post.parent_post.nil? ? post : post.parent_post

    link_to id, thread_path(thread, anchor: qtag), class: "qlink"
  end
end
