class Post < ActiveRecord::Base

  # Image Attachment
  has_attached_file :image, :styles => { :thumb => "250x250>" }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_attachment_size :image, in: 0..5.megabytes
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
  validate :message, length: { maximum: 5000 }
  validate :title, length: { maximum: 200 }
  validate :author, length: { maximum: 200 }
  validate :email, length: { maximum: 200 }
  validate :delete_password, length: { maximum: 32 }
  validate :content_presence

  # threads
  scope :threads, -> { where(parent_post_id: nil) }
  scope :recent, -> { order(updated_at: :desc) }

  # getters
  def title
    self[:title] || "無標題"
  end

  def author
    self[:author] || "無名氏"
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
