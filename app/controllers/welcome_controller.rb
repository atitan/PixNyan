class WelcomeController < ApplicationController

  def index
    redirect_to stream_index_path
  end

end
