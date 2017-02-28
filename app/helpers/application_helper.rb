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
    id = "No.#{post.id}"
    qtag = "q#{post.id}"
    thread = post.parent_post.nil? ? post : post.parent_post

    link_to id, thread_path(thread, anchor: qtag), class: "qlink"
  end

  def text_parser(text)
    text = simple_format(text)

    return text
  end

  def url_parser(text)
    regexp = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
    
    text.scan(regexp).each do |s|
      
    end
  end
end
