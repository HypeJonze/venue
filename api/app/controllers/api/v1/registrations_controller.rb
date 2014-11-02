class API::V1::RegistrationsController < BaseAPIController
  before_action :authenticate_user!, :only => [:destroy]
  before_action :current_user, :only => [:destroy]
  before_action :find_registration, :only => [:destroy]

  def create
    @user = User.new(user_params)
    if @user.save
      render :json => @user, :status => 201, :location => api_v1_registration_url(@user)
    else
      render :json => validation_error(@user), :status => 400 
    end
  end

  def destroy
    authorize! :destroy, @user
    @user.destroy
    head :status => 204
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def find_registration
    @user = User.find(params[:id])
  end
end
