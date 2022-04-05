class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  attachment :profile_image, destroy: false
  has_many :books
  has_many :favorites
  has_many :book_comments
  validates :name, presence: true, length: {maximum: 10, minimum: 2}
  validates :introduction, length: {maximum: 50}

   # フォローしている側のUserから見て、フォローされている側のUserを(中間テーブルを介して)集める。参照するカラムは 'follower_id(フォローする側)
  has_many :relationships, class_name: 'Relationship',foreign_key: "follower_id"
   #一覧画面で使う中間テーブル(relationships)を介して「followee」モデルのUser(フォローされた側)「follow_id」を集めることを「followings」と定義
  has_many :followings, through: :relationships, source: :followee

  # フォローされている側のUserから見て、フォローしてくる側のUserを(中間テーブルを介して)集める。参照するカラムは’followee_id’(フォローされる側)
  has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'followee_id'
  #一覧画面で使う中間テーブル(relationships)を介して「user」モデルのUser(フォローする側)「follower_id」を集めることを「followers」と定義
  has_many :followers, through: :reverse_of_relationships, source: :follower

 #フォローしているか判定
  def following?(another_user)
    self.followings.include?(another_user)
  end

 #フォローしたときの処理
  def follow(another_user)
    unless self == another_user
      self.relationships.find_or_create_by(followee_id: another_user.id)
    end
  end

  #フォローを外すときの処理
  def unfollow(another_user)
    unless self == another_user
      relationship = self.relationships.find_by(followee_id: another_user.id)
      relationship.destroy
    end
  end

end