module Admin
  class ProfileSubmissionsController < ApplicationController
    layout "admin"
    before_action :require_admin

    def index
      @submissions = ProfileSubmission.includes(:user).order(created_at: :desc)
    end

    def update
      submission = ProfileSubmission.find(params[:id])
      if submission.update(params.require(:profile_submission).permit(:status))
        redirect_to admin_profile_submissions_path, notice: "Статус материала изменён.", status: :see_other
      else
        redirect_to admin_profile_submissions_path, alert: "Не удалось изменить статус.", status: :see_other
      end
    end
  end
end
