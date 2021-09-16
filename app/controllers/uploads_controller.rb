require 'net/http'

class UploadsController < ApplicationController
  before_action :require_image, only: :create

  def new
  end

  def create
    base64_image = Base64.strict_encode64(params[:room_image].read)
    api_key = Rails.application.credentials.gcp[:vision_api][:api_key]
    headers = { "Content-Type" => "application/json" }

    body = {
      requests: [
        {
          features: [
            {
              maxResults: 10,
              type: "OBJECT_LOCALIZATION"
            }
          ],
          image: {
            content: base64_image
          }
        }
      ]
    }.to_json

    response = Net::HTTP.post(
      URI("https://vision.googleapis.com/v1/images:annotate?key=#{api_key}"),
      body,
      headers
    )

    if response.code == '200'
      # 検出されたオブジェクトの配列を作成
      @detected_items = JSON.parse(response.body)['responses'][0]["localizedObjectAnnotations"]&.map {|i| i['name']}

      # オブジェクト名称の登録有無による仕分け
      @judged_items = []
      @unregd_items = []

      @detected_items&.each do |detected_item|
        if Item.find_by(name: detected_item)&.why_release.present?
          @judged_items << detected_item
        else
          @unregd_items << detected_item
          Item.create(name: detected_item) unless Item.exists?(name: detected_item)
        end
      end
    else
      flash.now[:danger] = 'APIリクエストが失敗しています'
      render :new
    end
  end

  private

  def require_image
    if params[:room_image].nil?
      flash.now[:danger] = '画像を登録してください'
      render :new
    end
  end
end
