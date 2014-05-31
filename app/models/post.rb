class Post < ActiveRecord::Base

  # image Attachment
  has_attached_file :image, {
    styles: { small: ["125x125>", :jpg], medium: ["250x250>", :jpg], original: "" },
    convert_options: { 
      small: "-quality 80 -interlace Plane -strip",
      medium: "-quality 80 -interlace Plane -strip",
      original: "-strip"
    }
  }
  validates_attachment_content_type :image, content_type: /\Aimage\/(png|gif|jpeg|pjpeg)\z/
  validates_attachment_size :image, in: 0..MAX_IMAGE_KB_SIZE.kilobytes
  serialize :image_dimensions
  before_save :extract_image_dimensions

  # association
  has_many :replies, class_name: "Post",
    foreign_key: "parent_post_id", dependent: :destroy
  belongs_to :parent_post, class_name: "Post",
    foreign_key: "parent_post_id"

  # convert empty string to nil
  NULL_ATTRS = %w( title author email message )
  before_validation :nullify_blank_value

  # checks before saving
  before_save :avoid_locked_record
  before_save :generate_id_hash
  before_save :touch_parent
  
  # validates data
  validates :message, length: { maximum: MAX_POST_MESSAGE_WORDCOUNT }
  validates :title, length: { maximum: 200 }
  validates :author, length: { maximum: 200 }
  validates :email, length: { maximum: 200 }
  validate :content_presence

  # threads
  scope :threads, -> { where(parent_post_id: nil) }
  scope :recent, -> { order(updated_at: :desc) }
  
  # getters
  def title
    self[:title] || DEFAULT_POST_TITLE
  end

  def author
    self[:author] || DEFAULT_POST_AUTHOR
  end

  def message
    self[:message] || DEFAULT_POST_MESSAGE
  end

  # generating hash for password
  def delete_password=(passwd)
    self[:delete_password] = if passwd.blank? then nil else Digest::SHA1.base64digest(passwd) end
  end
  
  protected

  def nullify_blank_value
    NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end

  def touch_parent
    # touch parent on create if sage presents in email field
    parent_post.touch if parent_post && new_record? && "sage".casecmp(self[:email].to_s) != 0
  end

  def generate_id_hash
    ip = self[:remote_ip]
    date = Time.current.to_date.to_s
    hash = Digest::SHA1.base64digest(ip + date + ID_SALT)
    
    self[:identity_hash] = hash[0..8]
  end

  def avoid_locked_record
    raise ActiveRecord::Rollback, "Record locked!" if self[:locked]
  end

  def content_presence
    return false if message.blank? && image.blank?
    return true
  end

  def extract_image_dimensions
    return if image_content_type.nil?

    tempfile = image.queued_for_write[:original]
    unless tempfile.nil?
      geometry = Paperclip::Geometry.from_file(tempfile)
      self[:image_dimensions] = [geometry.width.to_i, geometry.height.to_i]
    end
  end

end
