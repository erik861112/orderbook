class GlobalMap < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  KEYS = %w(sales_no purchase_no package_no shipping_no invoice_no receive_no bill_no return_no)

  def self.sale_number
    order_number = GlobalMap.value_by('sales_no').to_i + 1
    GlobalMap.set_object('sales_no', order_number)
    return "SO#" + order_number.to_s.rjust(6, '0')
  end

  def self.purchase_number
    order_number = GlobalMap.value_by('purchase_no').to_i + 1
    GlobalMap.set_object('purchase_no', order_number)
    return "PO#" + order_number.to_s.rjust(6, '0')
  end

  def self.package_number
    package_number = GlobalMap.value_by('package_no').to_i + 1
    GlobalMap.set_object('package_no', package_number)
    return "PKG#" + package_number.to_s.rjust(8, '0')
  end

  def self.shipping_number
    shipping_number = GlobalMap.value_by('shipping_no').to_i + 1
    GlobalMap.set_object('shipping_no', shipping_number)
    return "SHP#" + shipping_number.to_s.rjust(8, '0')
  end

  def self.invoice_number
    invoice_number = GlobalMap.value_by('invoice_no').to_i + 1
    GlobalMap.set_object('invoice_no', invoice_number)
    return "INV#" + invoice_number.to_s.rjust(6, '0')
  end

  def self.bill_number
    bill_number = GlobalMap.value_by('bill_no').to_i + 1
    GlobalMap.set_object('bill_no', bill_number)
    return "BIL#" + bill_number.to_s.rjust(6, '0')
  end

  def self.receive_number
    receive_number = GlobalMap.value_by('receive_no').to_i + 1
    GlobalMap.set_object('receive_no', receive_number)
    return "RCV#" + receive_number.to_s.rjust(6, '0')
  end

  def self.return_number
    return_number = GlobalMap.value_by('return_no').to_i + 1
    GlobalMap.set_object('return_no', return_number)
    return "RET#" + return_number.to_s.rjust(6, '0')
  end

  def self.set_object(key, value)
    item = GlobalMap.object_by(key)
    item.value = value
    item.save
  end

  def self.value_by(key)
    GlobalMap.object_by(key).try(:value)
  end

  def self.object_by(key)
    if GlobalMap::KEYS.include? key
      return GlobalMap.find_or_create_by(key: key)
    else
      return nil
    end
  end
end
