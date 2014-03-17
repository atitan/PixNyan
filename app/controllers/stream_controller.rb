class StreamController < ApplicationController

  def index
    @threads = Post.threads.page(params[:page]).per(10).recent

    if @threads.blank?
      raise ActionController::RoutingError.new('Not Found')
    end

  end

end
