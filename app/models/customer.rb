include Carmen
class Customer < ActiveRecord::Base  
  
  has_many :documents, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :sales_orders, :dependent => :restrict_with_exception
  has_many :invoices, through: :sales_orders, class_name: 'Invoice'

  belongs_to :payment_term

  self.per_page = 25

  scope :main_like, ->(search) { where("(LOWER(first_name) LIKE :search) or (LOWER(last_name) LIKE :search) or (LOWER(company_name) LIKE :search)", :search => "%#{search.downcase}%") }
  scope :name_like, ->(search) { where("(LOWER(first_name) LIKE :search) or (LOWER(last_name) LIKE :search)", :search => "%#{search.downcase}%") }
  scope :company_name_like, ->(search) { where("LOWER(company_name) LIKE ?", "%#{search.downcase}%") }
  scope :trading_name_like, ->(search) { where("LOWER(trading_name) LIKE ?", "%#{search.downcase}%") }
  scope :phone_like, ->(search) { where("phone LIKE ?", "%#{search}%") }
  scope :email_like, ->(search) { where("email LIKE ?", "%#{search}%") }
  scope :ordered, -> { order(id: :desc) }

  enum status: [:active, :inactive]

  # The name of the customer in the format of "Company (First Last)" or if they don't have
  # company specified, just "First Last".
  #
  # @return [String]
  def name
    company_name.blank? ? full_name : "#{company_name} (#{full_name})"
  end

  def company_title
    company_name.blank? ? full_name : company_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end  

  def bill_country_long
    if !self.bill_country.blank?
     Country.coded(self.bill_country).name
    else
      return ""
    end
  end

  def bill_state_long
    if !self.bill_country.blank? && !self.bill_state.blank?
      if self.bill_country == 'NZ'
       self.bill_state
      else
       Country.coded(self.bill_country).subregions.coded(self.bill_state).name
      end
    else
      return ""
    end
  end

  def ship_country_long
    if !self.ship_country.blank?
      Country.coded(self.ship_country).name
    else
      return ""
    end   
  end

  def ship_state_long
    if !self.ship_country.blank? && !self.ship_state.blank?
      if self.ship_country == 'NZ'
       self.ship_state
      else
       Country.coded(self.ship_country).subregions.coded(self.ship_state).name
      end
    else
      return ""
    end
  end

  def billing_address
    "#{bill_street} #{bill_suburb} #{bill_city} #{bill_postcode} #{bill_state_long} #{bill_country_long}"
  end

  def shipping_address
    "#{ship_street} #{ship_suburb} #{ship_city} #{ship_postcode} #{ship_state_long} #{ship_country_long}"
  end

  def orders
    self.sales_orders.count()
  end

  def receivable
    total_amount = 0
    total_paid_amount = 0
    total_credit_amount = 0
    
    if Setting.value_by('format.customer_balance').blank?
      total_amount = invoices.where.not(status: ['draft']).sum(:total)
      invoices.where.not(status: ['draft']).each do |elem|
        total_paid_amount += elem.total_paid
      end
    else
      total_amount = sales_orders.where.not(status: ['quote', 'cancelled']).sum(:total_amount)
      sales_orders.where.not(status: 'quote').each do |elem|
        total_paid_amount += elem.total_paid_amount
      end    
    end
    total_amount - total_paid_amount - total_credit_amount
  end

  def billing_street_short
    "#{bill_street} #{bill_suburb} #{bill_city}"
  end

  def billing_address_state_short
    "#{bill_state_long} #{bill_postcode}"
  end

  def shipping_street_short
    "#{ship_street} #{ship_suburb} #{ship_city}"
  end

  def shipping_address_state_short
    "#{ship_state_long} #{ship_postcode}"
  end

  def status_class
      case status
      when "active"
        "label-success"
      when "confirmed"
        "label-default"
      end
  end

end
