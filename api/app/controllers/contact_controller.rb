class ContactController < ApplicationController

  def create
    logger.debug "Name: #{params[:name]}"
    logger.debug "Comment: #{params[:comment]}"
    head :ok
  end

end