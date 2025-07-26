class InvoicesController < ApplicationController
  before_action :require_login
  before_action :set_invoice, only: [:show, :export]

  # GET /invoices/new
  def new
    # Only shows the invoice type selector
  end

  # POST /invoices/form
  def select_format
    @format = params[:format_type]

    unless %w[ubl facturae facturx pdf].include?(@format)
      redirect_to new_invoice_path, alert: "Invalid format" and return
    end

    session[:selected_format] = @format 

    # Prepare an empty object with the necessary data for the form
    @invoice = Invoice.new(format: @format)
    render :form # custom view
  end

  # GET /invoices/form
  def new_form
    @format = session[:selected_format]
    @invoice = Invoice.new(format: @format)

    if @format.blank?
      redirect_to new_invoice_path, alert: "Please select a format first"
    else
      render :form
    end
  end



  # POST /invoices
  def create
    invoice_data = params[:invoice].dup

    client_name = invoice_data.delete(:client_name)
    invoice_details_data = invoice_data.delete(:invoice_details)

    client = Client.find_or_create_by(name: client_name) if client_name.present?

    @invoice = current_user.invoices.build(invoice_data.permit(
      :from, :number, :date, :due_date, :terms, :currency, :format
    ))
    @invoice.format ||= session[:selected_format]
    @invoice.client = client if client

    if @invoice.save
      if invoice_details_data.present?
        @invoice.invoice_details.create(
          description: invoice_details_data[:description],
          quantity: invoice_details_data[:quantity],
          unit_price: invoice_details_data[:unit_price],
          tax_rate: invoice_details_data[:tax_rate]
        )
      end

      redirect_to root_path, notice: "Invoice successfully created"
    else
      flash.now[:alert] = "Error creating the invoice: #{@invoice.errors.full_messages.join(", ")}"
      render :form
      puts "Error creating invoice: #{@invoice.errors.full_messages.join(", ")}"
    end
  end





  # GET /invoices/:id
  def show
    # Displays the invoice data
  end

  # GET /invoices/:id/export/:format_type
  def export
    format = params[:format_type]

    case format
    when "ubl"
      data = InvoiceExporter.to_ubl(@invoice)
      send_data data, filename: "invoice_#{@invoice.id}.xml"
    when "facturae"
      data = InvoiceExporter.to_facturae(@invoice)
      send_data data, filename: "facturae_#{@invoice.id}.xml"
    when "facturx"
      data = InvoiceExporter.to_facturx(@invoice)
      send_data data, filename: "facturx_#{@invoice.id}.pdf"
    when "pdf"
      data = InvoiceExporter.to_simple_pdf(@invoice)
      send_data data, filename: "invoice_#{@invoice.id}.pdf"
    else
      redirect_to invoice_path(@invoice), alert: "Unknown format"
    end
  end

  private

  def set_invoice
    @invoice = current_user.invoices.find_by(id: params[:id])
    redirect_to invoices_path, alert: "Invoice not found" unless @invoice
  end

def invoice_params
  params.require(:invoice).permit(
    :from,
    :number,
    :date,
    :due_date,
    :terms,
    :currency,
    :format
    # ❌ No incloure :client_name ni invoice_details_attributes
  )
end



  def require_login
    redirect_to login_path, alert: "You must be logged in" unless current_user
  end
end
