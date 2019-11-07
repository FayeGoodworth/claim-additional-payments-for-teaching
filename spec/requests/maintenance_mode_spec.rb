require "rails_helper"

RSpec.describe "Maintenance Mode", type: :request do
  context "when a policy configuration is set with maintenance mode enabled" do
    let(:policy_configuration) { policy_configurations(:student_loans) }
    before { policy_configuration.update(maintenance_mode: true) }

    it "shows the maintenance page for GET requests" do
      get new_claim_path(StudentLoans.routing_name)
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include("service is unavailable")
      expect(response.body).to include("You will be able to use the service later today.")
    end

    it "shows the maintenance page for POST requests" do
      post claims_path(StudentLoans.routing_name)
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include("service is unavailable")
    end

    it "still allows access to /admin for service operator access" do
      get admin_root_path
      expect(response).to redirect_to(admin_sign_in_path)

      get admin_sign_in_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Sign in with DfE Sign In")
    end

    context "when the availability message is set" do
      let(:availability_message) { "You will be able to use the service from 2pm today" }
      before { policy_configuration.update(maintenance_mode_availability_message: availability_message) }

      it "shows the time it will be available from" do
        get new_claim_path(StudentLoans.routing_name)
        expect(response.body).to include(availability_message)
      end
    end
  end
end
