class PayrollRun < ApplicationRecord
  DOWNLOAD_FILE_TIMEOUT = 30

  has_many :payments
  has_many :claims, through: :payments

  belongs_to :created_by, class_name: "DfeSignIn::User"
  belongs_to :downloaded_by, class_name: "DfeSignIn::User", optional: true
  belongs_to :confirmation_report_uploaded_by, class_name: "DfeSignIn::User", optional: true

  validate :ensure_no_payroll_run_this_month, on: :create

  scope :this_month, -> { where(created_at: DateTime.now.all_month) }

  def total_award_amount
    payments.sum(:award_amount)
  end

  def self.create_with_claims!(claims, attrs = {})
    ActiveRecord::Base.transaction do
      PayrollRun.create!(attrs).tap do |payroll_run|
        claims.group_by(&:teacher_reference_number).each_value do |grouped_claims|
          award_amount = grouped_claims.sum(&:award_amount)
          Payment.create!(payroll_run: payroll_run, claims: grouped_claims, award_amount: award_amount)
        end
      end
    end
  end

  def download_triggered?
    downloaded_at.present? && downloaded_by.present?
  end

  def download_available?
    download_triggered? && Time.zone.now - downloaded_at < DOWNLOAD_FILE_TIMEOUT.seconds
  end

  def confirmation_report_uploaded?
    confirmation_report_uploaded_by.present?
  end

  private

  def ensure_no_payroll_run_this_month
    errors.add(:base, "There has already been a payroll run for #{Date.today.strftime("%B")}") if PayrollRun.this_month.any?
  end
end
