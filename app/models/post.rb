class Post < ActiveRecord::Base

  # Image Attachment
  has_attached_file :image, {
    styles: { thumb: ["250x250>", :jpg] },
    convert_options: { thumb: "-quality 80 -interlace Plane" }
  }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :image, in: 0..MAX_IMAGE_KB_SIZE.kilobytes
  serialize :image_dimensions

  has_many :replies, class_name: "Post",
    foreign_key: "parent_post_id", dependent: :destroy
  belongs_to :parent_post, class_name: "Post",
    foreign_key: "parent_post_id"

  # convert empty string to nil
  NULL_ATTRS = %w( title author email delete_password )
  before_validation :nil_if_blank
  # inform the parent about the child
  before_save :touch_parent
  before_save :avoid_locked_record
  before_save :extract_image_dimensions

  # validates data
  validates :message, length: { maximum: MAX_POST_MESSAGE_WORDCOUNT }
  validates :title, length: { maximum: 200 }
  validates :author, length: { maximum: 200 }
  validates :email, length: { maximum: 200 }
  validates :delete_password, length: { maximum: 8 }
  validate :content_presence

  # threads
  scope :threads, -> { where(parent_post_id: nil) }
  scope :recent, -> { order(updated_at: :desc) }
  scope :whole_thread, ->(id) { where(id: id).or_where(parent_post_id: id) }

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
  
  protected

  def nil_if_blank
    NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end

  def touch_parent
    # touch parent if sage presents on create
    parent_post.touch if parent_post && new_record? && "sage".casecmp(email.to_s) != 0
  end

  def avoid_locked_record
    raise ActiveRecord::Rollback, "Record locked!" if self[:locked]
  end

  def content_presence
    if message.blank? && image.blank?
      return false
    end
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
