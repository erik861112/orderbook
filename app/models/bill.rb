class Bill < ActiveRecord::Base
    has_many :bill_items, class_name: 'BillItem'
    has_many :payments, class_name: 'BillPayment'

    belongs_to :purchase_order, class_name: 'PurchaseOrder'
    
    enum status: [:draft, :confirmed, :sent, :partial, :paid, :credit_note]

    scope :ordered, -> { order({token: :desc}) }
    scope :draft, -> { where(:status => "draft") }
    scope :confirmed, -> { where(:status => "confirmed") }
    scope :sent, -> { where(:status => "sent") }
    scope :partial, -> { where(:status => "partial") }
    scope :paid, -> { where(:status => "paid") }

    def file_name_path
        '/bills/' + file_name
    end

    def is_updated_pdf
        updated_at = self.updated_at.to_i.to_s + ".pdf"
        ori_filename = (self.file_name.blank?) ? "" : self.file_name
        pdf_updated_at = ori_filename[11..-1]
        return updated_at == pdf_updated_at
    end    

    def status_class
        case status
        when "draft"
          "label-default"
        when "confirmed"
          "label-info"
        when "sent"
          "label-primary"
        when "partial"
          "label-warning"
        when "paid"
          "label-success"
        when "credit_note"
          "label-danger"
        end
    end

    def status_text
        case status
        when "draft"
          "Draft"
        when "confirmed"
          "Approved"
        when "sent"
          "Not Paid"
        when "partial"
          "Partial Paid"
        when "paid"
          "Paid"
        when "credit_note"
          "Credit Note"
        end
    end

    def payment_date
        if self.purchase_order.payment_term.after_days?
            self.purchase_order.order_date.next_day(self.purchase_order.payment_term.days)
        else
            due_date = self.purchase_order.order_date.change({ day: self.purchase_order.payment_term.days })
            due_date.next_month(1) if due_date < self.purchase_order.order_date
            due_date
        end
    end

    def total_paid
        payments.sum(:amount)
    end

    def add_payment!
        if self.total_paid >= self.total
            self.status = 'paid'
        else
            self.status = 'partial'
        end
        save!
        self.purchase_order.bill!
    end

    def remove_payment!
        if self.total_paid >= self.total
            self.status = 'paid'
        elsif self.total_paid == 0
            self.status = 'sent'
        else
            self.status = 'partial'
        end
        save!
        self.purchase_order.bill!
    end
end
