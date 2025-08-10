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
      format_type = params[:format_type] || session[:selected_format]

      if format_type == "pdf"
        client_name = params[:client_name] # recogido directamente, no desde invoice[:client_name]
        client = Client.find_or_create_by(name: client_name) if client_name.present?

        @invoice = current_user.invoices.build(invoice_params)
        @invoice.client = client if client
        @invoice.status = "pending"
        @invoice.format ||= format_type

        # Calcular total sumando los detalles
        total = 0
        if @invoice.invoice_details.present?
          total = @invoice.invoice_details.sum do |detail|
            detail.quantity.to_f * detail.unit_price.to_f + (detail.quantity.to_f * detail.unit_price.to_f * (detail.tax_rate.to_f / 100))
          rescue StandardError => e
            Rails.logger.error("Error calculating invoice total: #{e.message}")
            0
          end
        end
        @invoice.total = total

        # setting invoice detail qty correctly
        @invoice.invoice_details.each do |detail|
          detail.quantity = detail.quantity.to_i
        end

        if @invoice.save
          redirect_to root_path, notice: "Invoice successfully created"
        else
          flash.now[:alert] = "Error creating the invoice: #{@invoice.errors.full_messages.join(", ")}"
          render :new, status: :unprocessable_entity
        end

      elsif format_type == "facturae"
        # Lógica para generar factura Facturae

      elsif format_type == "facturx"
        # Lógica para generar factura Factur-X

      elsif format_type == "ubl"
        # Lógica para generar factura UBL

      else
        # Lógica para otros formatos o caso por defecto
      end
    end

    # GET /invoices/:id
    def show
      # Displays the invoice data
    end

    # GET /invoices/:id/export/:format_type
  def export
    format = params[:format_type]

    if format == "pdf"
      pdf_data = InvoiceExporter.to_simple_pdf(@invoice)
      send_data pdf_data,
                filename: "invoice_#{@invoice.id}.pdf",
                type: "application/pdf",
                disposition: "attachment" # descarga directa
    else
      redirect_to invoice_path(@invoice), alert: "Formato desconocido"
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
      :format,
      invoice_details_attributes: [:id, :description, :product_code, :quantity, :unit_price, :tax_rate, :_destroy]
    )
  end
    def require_login
      redirect_to login_path, alert: "You must be logged in" unless current_user
    end
  end
