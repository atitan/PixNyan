class PostsController < ApplicationController

  before_action :create_protection, only: :create

  def create
    # check if parent post
    if @thread = Post.threads.find_by(id: params[:post][:parent_post_id])
      @post = @thread.replies.new(post_params)
    else
      @post = Post.new(post_params)
    end

    @post.remote_ip = request.ip
    @post.save

    #id = @post.parent_post.nil? ? @post.id : @post.parent_post.id
    redirect_to stream_index_path
  end

  def destroy
    if params[:del_post]
      passwd_hash = Digest::SHA1.base64digest(params[:pwd])
      del_post = params[:del_post].split(',')

      posts = Post.where(id: del_post).where(delete_password: passwd_hash)
      if params[:only_delete_img]
        posts.each{ |post| post.image.destroy && post.save }
      else
        posts.destroy_all
      end
    end
    
    redirect_to stream_index_path
  end

  private

  def create_protection
    return go_back unless verify_recaptcha
    return flash[:warning] = "IP not allowed" && go_back if blocked_ip?
  end

  def go_back
    redirect_to request.referer || stream_index_path
  end

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
