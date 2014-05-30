class ThreadController < ApplicationController

  def show
    @thread = Post.threads.find_by(id: params[:id]) || not_found
    page = params[:page]
    @replies = @thread.replies.page(page).per(REPLY_PER_THREAD_PAGE)
    @thread = nil unless page.nil? || page == 1
    
    @reply_form = Post.new
    @reply_form.parent_post_id = params[:id]
  end

end
