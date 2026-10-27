class UserAccountsController < ApplicationController
  layout "profile"
  before_action :require_user, only: [ :show, :update ]
  rate_limit to: 10, within: 3.minutes, only: [ :create, :login ], with: -> { redirect_to user_login_path, alert: "Слишком много попыток. Попробуйте позже." }

  def new
    return redirect_to profile_path if current_user
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :username, :email, :password, :password_confirmation))
    if @user.save
      sign_in(@user)
      redirect_to profile_path, status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    @user.errors.add(:base, "Почта или ник уже заняты.")
    render :new, status: :unprocessable_content
  end

  def login_form
    redirect_to profile_path if current_user
  end

  def login
    user = User.authenticate_by(email: params[:email].to_s.strip.downcase, password: params[:password].to_s)
    if user
      sign_in(user)
      redirect_to profile_path, status: :see_other
    else
      flash.now[:alert] = "Неверная почта или пароль."
      render :login_form, status: :unprocessable_content
    end
  end

  def logout
    session.delete(:user_id)
    session.delete(:user_session_version)
    redirect_to user_login_path, status: :see_other
  end

  def show
    @submissions = current_user.profile_submissions.order(created_at: :desc)
  end

  def update
    @user = current_user
    unless @user.authenticate(params[:current_password].to_s)
      redirect_to profile_path(anchor: "profile-settings"), alert: "Для сохранения введите текущий пароль.", status: :see_other
      return
    end
    attributes = params.require(:user).permit(:name, :username, :email, :password, :password_confirmation, notification_preferences: [ :forum, :moderation, :articles, :routes, :markers ])
    attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?
    if @user.update(attributes)
      @user.increment!(:session_version)
      session[:user_session_version] = @user.session_version
      redirect_to profile_path(anchor: "profile-settings"), notice: "Настройки сохранены.", status: :see_other
    else
      @submissions = @user.profile_submissions.order(created_at: :desc)
      render :show, status: :unprocessable_content
    end
  end

  private

  def sign_in(user)
    admin_session = session.to_hash.slice("admin_user_id", "admin_authenticated_at")
    reset_session
    session.update(admin_session)
    session[:tab_login_role] = "user"
    session[:user_id] = user.id
    session[:user_session_version] = user.session_version
  end
end
