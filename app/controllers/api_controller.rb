class ApiController < ApplicationController
  include ApiHelper
  authorize_resource class: false
  respond_to :json

  def blueteams
    respond_with(ApiHelper.blueteams)
  end
  def services
    respond_with(ApiHelper.services)
  end
end
