class ThreadController < ApplicationController

  def show
    @thread = Post.threads.find_by_id(params[:id])

    if @thread.nil?
      raise ActionController::RoutingError.new('Not Found')
    end

    @reply = Post.new
    @reply.parent_post_id = params[:id]

  end

end
