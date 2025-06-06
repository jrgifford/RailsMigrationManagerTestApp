class CreateSaasCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :saas_customers do |t|
      t.string :name
      t.string :email
      t.string :plan

      t.timestamps
    end
  end
end
