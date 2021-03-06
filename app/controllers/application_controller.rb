class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  skip_before_filter :verify_authenticity_token, :only => :create

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  layout :layout_by_resource
  
  protected
    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:first_name, :last_name, :email, :password, :password_confirmation) }
        devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:first_name, :last_name, :email, :password, :current_password, :phone_number, :role, :avatar) }
    end

  private
    def layout_by_resource
      if devise_controller?
        "devise"
      else
        if user_signed_in?
          "user_authorized"
        else          
          "user_unauthorized"
        end
      end
    end
end
