class Micropost < ApplicationRecord
  # micropostがuserに所属する (belongs_to) 関連付け
  belongs_to :user
  default_scope -> { order(created_at: :desc) }

  # CarrierWaveに画像と関連付けたモデルを伝えるためには、mount_uploaderというメソッドを使います。
  # このメソッドは、引数に属性名のシンボルと生成されたアップローダーのクラス名を取ります。
  mount_uploader :picture, PictureUploader

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size



  private

  # アップロードされた画像サイズをバリデーションする
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less 5MB 5MB以下にしてください")
    end
  end


end
