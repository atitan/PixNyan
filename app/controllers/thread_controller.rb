class ThreadController < ApplicationController

  def show
    @thread = Post.threads.find_by(id: params[:id]) || not_found
    
    @page = params[:page]

    @reply_form = Post.new
    @reply_form.parent_post_id = params[:id]
  end

end
