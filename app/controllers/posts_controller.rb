class PostsController < ApplicationController

  def create
    @thread = Post.threads.find_by_id(params[:post][:parent_post_id])

    # check if parent post
    unless @thread.nil?
      @post = @thread.replies.new(post_params)
    else
      @post = Post.new(post_params)
    end

    @post.real_ip = request.env['REMOTE_ADDR']
    @post.remote_ip = request.remote_ip
    @post.identity_hash = id_hash

    @post.save

    id = @post.parent_post.nil? ? @post.id : @post.parent_post.id
    redirect_to stream_index_path
  end

  def destory
    params[:del_post].each do |pid|
      @post = Post.find_by(id: params[:id])
      unless @post.nil?
        if params[:pwd] == @post.delete_password
          @post.destory
        end
      end
    end
    
    redirect_to stream_index_path
  end

  private

  def post_params
    params.require(
        :post
      ).permit(
        :title,
        :author,
        :email,
        :message,
        :image,
        :delete_password
    )
  end

  def id_hash
    ip = request.env['REMOTE_ADDR']
    date = Time.current.to_date.to_s

    hash = Digest::SHA1.base64digest(ip + date)
    
    return hash[0...8]
  end

end
