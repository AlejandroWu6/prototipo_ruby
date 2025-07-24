class InvoicesController < ApplicationController
  before_action :require_login
  before_action :set_invoice, only: [:show, :export]

  # GET /invoices/new
  def new
    # Only shows the invoice type selector
  end

  # POST /invoices/select_format
  def select_format
    @format = params[:format_type]

    unless %w[ubl facturae facturx pdf].include?(@format)
      redirect_to new_invoice_path, alert: "Invalid format" and return
    end

    # Prepare an empty object with the necessary data for the form
    @invoice = Invoice.new(format: @format)
    render :form # custom view
  end

  # POST /invoices
  def create
    @invoice = current_user.invoices.build(invoice_params)

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: "Invoice successfully created"
    else
      flash.now[:alert] = "Error creating the invoice"
      render :form
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
    params.require(:invoice).permit(:client_name, :date, :format, :total, :other_fields_here)
    # Add the fields you are using in the form
  end

  def require_login
    redirect_to login_path, alert: "You must be logged in" unless current_user
  end
end
