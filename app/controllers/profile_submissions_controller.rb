class ProfileSubmissionsController < ApplicationController
  layout "profile"
  before_action :require_user

  def new
    @submission = current_user.profile_submissions.new(kind: ProfileSubmission::KINDS.key?(params[:kind]) ? params[:kind] : "route")
  end

  def create
    @submission = current_user.profile_submissions.new(params.require(:profile_submission).permit(:kind, :title, :description, :image))
    if @submission.save
      redirect_to profile_path, notice: "Материал сохранён и ожидает модерации.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end
end
