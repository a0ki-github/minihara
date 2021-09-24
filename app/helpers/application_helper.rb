module ApplicationHelper
  def default_meta_tags
    {
      site: 'いらないモノ診断',
      description: 'あなたの部屋の「実はいらないモノ」が見つかるアプリ',
      charset: 'utf-8',
      reverse: true,
      og: {
        site_name: :site,
        title: :site,
        type: 'website',
        description: 'あなたの部屋の「実はいらないモノ」が見つかるアプリ',
        url: request.url,
        image: nil,
        locale: 'ja_JP'
      }
    }
  end

  def admin?
    request.url.include?('/admin')
  end
end
