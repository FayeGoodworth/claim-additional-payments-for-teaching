class ClaimsController < ApplicationController
  before_action :send_unstarted_claiments_to_the_start, only: [:show, :update]

  def new
  end

  def create
    claim = TslrClaim.create!
    session[:tslr_claim_id] = claim.to_param

    redirect_to claim_path("qts-year")
  end

  def show
    render claim_page_template
  end

  def update
    current_claim.attributes = claim_params
    if current_claim.save(context: params[:slug].to_sym)
      redirect_to claim_path("claim-school")
    else
      render claim_page_template
    end
  end

  private

  def claim_params
    params.require(:tslr_claim).permit(:qts_award_year)
  end

  def claim_page_template
    params[:slug].underscore
  end

  def current_claim
    @current_claim ||= TslrClaim.find(session[:tslr_claim_id]) if session.key?(:tslr_claim_id)
  end
  helper_method :current_claim

  def send_unstarted_claiments_to_the_start
    redirect_to root_url unless current_claim.present?
  end
end