class PostsController < ApplicationController

  def create
    @thread = Post.threads.find_by(id: params[:post][:parent_post_id])

    # check if parent post
    if @thread.nil?
      @post = Post.new(post_params)
    else
      @post = @thread.replies.new(post_params)
    end

    @post.real_ip = request.env['REMOTE_ADDR']
    @post.remote_ip = request.remote_ip
    
    @post.save

    #id = @post.parent_post.nil? ? @post.id : @post.parent_post.id
    redirect_to stream_index_path
  end

  def destroy
    if params[:del_post]
      params[:del_post].each do |pid, k|
        post = Post.find_by(id: pid.to_i)
        next if post.nil?
        next unless Digest::SHA1.base64digest(params[:pwd]).eql?(post.delete_password)

        if params[:only_delete_img]
          post.image = nil && post.save
        else
          post.destroy
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
end
