class UploadsController < ApplicationController
  def new
  end

  def create
    upload_file = params[:room_image]
    base64_image = Base64.strict_encode64(upload_file.read)
    redirect_to '/uploads/show'
  end

  def show
  end
end
