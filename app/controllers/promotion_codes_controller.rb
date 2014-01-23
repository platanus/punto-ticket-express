class PromotionCodesController < ApplicationController
  before_filter :load_promotion, only: [:new_upload, :upload]

  def upload
    response = PTE::Promotion::Xls.load_codes_into_promotion @promotion, 'xls_file'
    respond_to do |format|
      if response[:result] == :success
        format.html { redirect_to promotion_url(@promotion),
          notice: I18n.t("controller.messages.upload_success") }
      else
        @errors = response[:errors]
        format.html { render action: 'new_upload',
          alert: I18n.t("controller.messages.upload_error")   }
      end
    end
  end

  private

    def load_promotion
      @promotion = Promotion.find_by_id(params[:id])
    end
end
