class StaticPagesController < BasePublicController
  def accessibility_statement
  end

  def contact_us
  end

  def cookies
  end

  def maths_and_physics
  end

  def privacy_notice
  end

  def terms_conditions
  end

  def maintenance
    @availability_message = Rails.configuration.maintenance_mode_availability_message
    render status: :service_unavailable
  end

  private

  def current_policy_routing_name
    super || "student-loans"
  end
end
