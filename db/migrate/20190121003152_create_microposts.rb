class CreateMicroposts < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, foreign_key: true

      t.timestamps
    end

    # インデックスの付与
    # こうすることで、user_idに関連付けられたすべてのマイクロポストを作成時刻の逆順で取り出しやすくなります。
    add_index :microposts, [:user_id, :created_at]
  end
end
