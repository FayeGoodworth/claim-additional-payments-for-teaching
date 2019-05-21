require "rails_helper"

RSpec.describe "Claim session timing out", type: :request do
  let(:timeout_length_in_minutes) { ClaimsController::TIMEOUT_LENGTH_IN_MINUTES }

  context "no actions performed for more than the timeout period" do
    before { post claims_path }

    let(:current_claim) { TslrClaim.order(:created_at).last }
    let(:after_expiry) { timeout_length_in_minutes.minutes + 1.second }

    it "clears the session and redirects to the timeout page" do
      expect(session[:tslr_claim_id]).to eql current_claim.to_param

      travel after_expiry do
        put claim_path("qts-year"), params: {tslr_claim: {qts_award_year: "2014-2015"}}

        expect(response).to redirect_to(timeout_claim_path)
        expect(session[:tslr_claim_id]).to be_nil
      end
    end
  end

  context "no action performed just within the timeout period" do
    before { post claims_path }

    let(:current_claim) { TslrClaim.order(:created_at).last }
    let(:before_expiry) { timeout_length_in_minutes.minutes - 2.seconds }

    it "does not timeout the session" do
      travel before_expiry do
        put claim_path("qts-year"), params: {tslr_claim: {qts_award_year: "2014-2015"}}

        expect(response).to redirect_to(claim_path("claim-school"))
        expect(session[:tslr_claim_id]).to eql current_claim.to_param
      end
    end
  end
end