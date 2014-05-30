class StreamController < ApplicationController

  def index
    @threads = Post.threads.recent.page(params[:page]).per(THREAD_PER_STREAM_PAGE)

    not_found if @threads.blank? && params[:page]
  end

end
