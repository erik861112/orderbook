class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact = Contact.find(params[:id]);
    if @contact.customer
      @customer = Customer.find(@contact.customer.id)    
      @contact.destroy
      respond_to do |format|
        format.html { redirect_to edit_customer_path(@customer), flash: {last_action: 'delete_contact', result: 'success'} }
        format.json { head :no_content }
      end
    else
      @supplier = Supplier.find(@contact.supplier.id)    
      @contact.destroy
      respond_to do |format|
        format.html { redirect_to edit_supplier_path(@supplier), flash: {last_action: 'delete_contact', result: 'success'} }
        format.json { head :no_content }      
      end
    end
  end

  def remove
    @contact = Contact.find(params[:id]);
    @contact.destroy
    respond_to do |format|
      result = {:Result => "OK"}
      format.json { render json: result }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:first_name, :last_name, :mobile_number, :landline_number, :email, :designation)
    end
end
