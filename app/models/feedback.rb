class Feedback < ApplicationRecord
  enum kind: { 'アプリについてのご意見やご質問': 0, '不具合・エラー報告': 1, 'その他': 2 }

  validates :kind, presence: true
  validates :content, presence: true, length: { maximum: 65535 }

  before_create -> { self.uuid = SecureRandom.uuid }
end
