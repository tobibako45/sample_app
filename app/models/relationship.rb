class Relationship < ApplicationRecord

  # リレーションシップ/フォロワーに対してbelongs_toの関連付けを追加
  # has_manyの逆
  # class_nameでUserクラスを指定。Userと関連付け
  #
  #
  # 参考
  #
  #  外部キーとしてfollower_idとfollowed_idを使いたいがために、belongs_to :follwer(followed)と宣言していますね。ただし、FollowerモデルもFollowedモデルも実際していないのでこれらはUserモデルのことを指しているよとオプションで伝えています（ちなみにfollowed_idは（仮想の）passive_relationshipsテーブルで使われます）。
  #
  #
  belongs_to :follower, class_name: "User" # Userのfollower_id(外部キー)が使いたい
  belongs_to :followed, class_name: "User" # Userのfollowed_id(外部キー)が使いたい

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
