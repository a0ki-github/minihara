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
      # 検出したオブジェクト名称の配列を作成
      array_of_items = JSON.parse(response.body)['responses'][0]["localizedObjectAnnotations"].map {|i| i['name']}

      # オブジェクト名称の登録有無による仕分け
      @judged_items = []
      @unregistered_items = []
      array_of_items.each do |item|
        if Item.exists?(name: item)
          @judged_items << item
        else
          @unregistered_items << item
        end
      end
    else
      flash.now[:danger] = 'APIリクエストが失敗しています'
      render :new
    end

  end

  def show
  end

  private

  def require_image
    if params[:room_image].nil?
      flash.now[:danger] = '画像を登録してください'
      render :new
    end
  end
end
