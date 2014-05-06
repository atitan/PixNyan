class StreamController < ApplicationController

  def index
    @threads = Post.threads.page(params[:page]).per(THREAD_PER_STREAM_PAGE).recent
  end

end
