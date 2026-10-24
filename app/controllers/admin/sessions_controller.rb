module Admin
  class SessionsController < ApplicationController
    layout "admin"
    rate_limit to: 10, within: 3.minutes, only: :create,
      with: -> { redirect_to admin_login_path, alert: "Слишком много попыток. Попробуйте через несколько минут." }

    def new
      if !AdminUser.exists? && local_setup_allowed?
        redirect_to admin_setup_path
      elsif admin_signed_in?
        redirect_to admin_places_path
      end
    end

    def create
      admin = AdminUser.authenticate_by(email: params[:email].to_s.strip.downcase, password: params[:password].to_s)
      if admin
        reset_session
        session[:admin_user_id] = admin.id
        session[:admin_authenticated_at] = Time.current.to_i
        redirect_to admin_places_path, status: :see_other
      else
        flash.now[:alert] = "Неверная почта или пароль."
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      reset_session
      redirect_to admin_login_path, status: :see_other
    end

    def setup
      head :not_found unless local_setup_allowed? && !AdminUser.exists?
    end

    def create_owner
      return head :not_found unless local_setup_allowed? && !AdminUser.exists?
      @admin = AdminUser.new(params.require(:admin_user).permit(:email, :password, :password_confirmation))
      if @admin.save
        reset_session
        session[:admin_user_id] = @admin.id
        session[:admin_authenticated_at] = Time.current.to_i
        redirect_to admin_places_path, status: :see_other
      else
        render :setup, status: :unprocessable_content
      end
    rescue ActiveRecord::RecordNotUnique
      redirect_to admin_login_path, alert: "Аккаунт автора уже создан."
    end

    private

    def local_setup_allowed?
      (Rails.env.development? || Rails.env.test?) && request.local?
    end
  end
end
