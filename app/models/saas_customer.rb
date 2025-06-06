class SaasCustomer < SaasRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :plan, presence: true, inclusion: { in: ['basic', 'premium', 'enterprise'] }
end
