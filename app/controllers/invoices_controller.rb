  require 'builder'

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
        client_name = params[:client_name] 
       
        client = Client.find_or_create_by(name: client_name) if client_name.present?


        @invoice = current_user.invoices.build(invoice_params)
        @invoice.client = client if client
        @invoice.status = "pending"
        @invoice.format ||= format_type
        @invoice.created_at = Time.current

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
        # === EXTRA DATA ===
        extra_data = params.require(:invoice).to_unsafe_h.slice(
          "schema_version", "modality", "invoice_issuer_type", "issuer_person_type_code",
          "issuer_residence_type_code", "issuer_tax_id_number", "issuer_corporate_name",
          "issuer_address", "issuer_post_code", "issuer_town", "issuer_province",
          "issuer_country_code", "batch_identifier", "invoices_count",
          "total_invoices_amount", "issue_date", "due_date", "seller_person_type_code",
          "seller_residence_type_code", "seller_tax_id_number", "seller_name",
          "seller_first_surname", "seller_address", "seller_post_code", "seller_town",
          "seller_province", "seller_country_code", "seller_email", "buyer_person_type_code",
          "buyer_residence_type_code", "buyer_tax_id_number", "buyer_corporate_name",
          "buyer_address", "buyer_post_code", "buyer_town", "buyer_province", "buyer_country_code",
          "buyer_email", "currency", "terms"
        )

        # === DEBUG PARAMS FACTURAE ===
        puts "========== DEBUG FACTURAE =========="
        puts "params.inspect:"
        pp params.to_unsafe_h

        puts "-----------------------------------"
        puts "Nivel 1 (params directos):"
        puts "  format_type: #{params[:format_type].inspect}"
        puts "  commit: #{params[:commit].inspect}"

        puts "-----------------------------------"
        puts "Nivel 2 (params[:invoice]):"
        if params[:invoice].present?
          params[:invoice].each do |k, v|
            puts "  #{k}: #{v.inspect}"
          end
        else
          puts "  params[:invoice] => NIL"
        end

        puts "-----------------------------------"
        puts "Extracción individual de campos clave:"
        puts "  schema_version: #{params.dig(:invoice, :schema_version).inspect}"
        puts "  modality: #{params.dig(:invoice, :modality).inspect}"
        puts "  invoice_issuer_type: #{params.dig(:invoice, :invoice_issuer_type).inspect}"
        puts "  issuer_corporate_name: #{params.dig(:invoice, :issuer_corporate_name).inspect}"
        puts "  batch_identifier: #{params.dig(:invoice, :batch_identifier).inspect}"
        puts "  seller_name: #{params.dig(:invoice, :seller_name).inspect}"
        puts "  buyer_corporate_name: #{params.dig(:invoice, :buyer_corporate_name).inspect}"
        puts "  issue_date: #{params.dig(:invoice, :issue_date).inspect}"
        puts "  due_date: #{params.dig(:invoice, :due_date).inspect}"
        puts "  currency: #{params.dig(:invoice, :currency).inspect}"

        puts "-----------------------------------"
        puts "Invoice details:"
        if params.dig(:invoice, :invoice_details_attributes).present?
          params[:invoice][:invoice_details_attributes].each do |idx, detail|
            puts "  Line #{idx}: #{detail.inspect}"
          end
        else
          puts "  No invoice_details_attributes"
        end

        puts "-----------------------------------"
        puts "Desde strong params (invoice_params):"
        begin
          puts invoice_params.inspect
        rescue => e
          puts "  ERROR obteniendo invoice_params: #{e.message}"
        end
        puts "========== END DEBUG FACTURAE =========="

        # === CLIENTE: BUSCAR O CREAR ===
        buyer_name = params.dig(:invoice, :buyer_corporate_name)
        if buyer_name.present?
          client = Client.find_or_create_by(name: buyer_name) do |c|
            c.tax_id = params.dig(:invoice, :buyer_tax_id_number)
            c.address = params.dig(:invoice, :buyer_address)
            c.zip_code = params.dig(:invoice, :buyer_post_code)
            c.city = params.dig(:invoice, :buyer_town)
            c.country_code = params.dig(:invoice, :buyer_country_code)
            c.email = params.dig(:invoice, :buyer_email)
            c.client_code = params.dig(:invoice, :buyer_client_code)
            c.contact_person = params.dig(:invoice, :buyer_contact_person)
            c.phone = params.dig(:invoice, :buyer_phone)
          end
        end

        # === CREAR FACTURA ===
        @invoice = current_user.invoices.build(invoice_params)
        @invoice.from = params[:invoice][:from_address] if params[:invoice][:from_address].present?
        @invoice.client = client if client
        @invoice.status = "pending"
        @invoice.format = "facturae"
        @invoice.created_at = Time.current
        @invoice.number = params[:invoice][:batch_identifier] if params[:invoice][:batch_identifier].present?

        # === CALCULAR TOTALES ===
        total = 0
        if @invoice.invoice_details.present?
          total = @invoice.invoice_details.sum do |detail|
            detail.quantity.to_f * detail.unit_price.to_f * (1 + (detail.tax_rate.to_f / 100))
          rescue
            0
          end
        end
        @invoice.total = total

        # === PREPARAR XML ===
        # @invoice.xml = build_facturae_xml(@invoice, extra_data)

        # === GUARDAR FACTURA ===
        if @invoice.save
          redirect_to root_path, notice: "Facturae creada con éxito"
        else
          flash.now[:alert] = "Error creando la factura: #{@invoice.errors.full_messages.join(', ')}"
          render :new, status: :unprocessable_entity
        end

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
    :number,
    :issue_date,
    :from,
    :due_date, 
    :currency,
    :payment_method,
    :payment_terms,
    :status,
    :subtotal,
    :tax_total,
    :total,
    :format,
    :file,
    :order_reference,
    :legal_reference,
    :notes,
    :terms,
    :from_address, 
    :bill_to_address, 
    :logo_url,
    :signature_base64,
    :user_id,
    :client_id,
    :xml,
    invoice_details_attributes: [
      :product_code,
      :description,
      :quantity,
      :unit_price,
      :tax_rate,
      :_destroy,
      :id
    ]
  )
end




  def build_facturae_xml(invoice, extra_data)
    builder = Builder::XmlMarkup.new(indent: 2)
    builder.instruct! :xml, encoding: "UTF-8"

    builder.Invoice do
      builder.FileHeader do
        builder.SchemaVersion extra_data["schema_version"] || "3.2"
        builder.Modality extra_data["modality"] || "I"
        builder.InvoiceIssuerType extra_data["invoice_issuer_type"] || "EM"
        builder.IssuerPersonTypeCode extra_data["issuer_person_type_code"] if extra_data["issuer_person_type_code"]
        builder.IssuerResidenceTypeCode extra_data["issuer_residence_type_code"] if extra_data["issuer_residence_type_code"]
        builder.IssuerTaxIdNumber extra_data["issuer_tax_id_number"] if extra_data["issuer_tax_id_number"]
        builder.IssuerCorporateName extra_data["issuer_corporate_name"] if extra_data["issuer_corporate_name"]
        builder.IssuerAddress extra_data["issuer_address"] if extra_data["issuer_address"]
        builder.IssuerPostCode extra_data["issuer_post_code"] if extra_data["issuer_post_code"]
        builder.IssuerTown extra_data["issuer_town"] if extra_data["issuer_town"]
        builder.IssuerProvince extra_data["issuer_province"] if extra_data["issuer_province"]
        builder.IssuerCountryCode extra_data["issuer_country_code"] if extra_data["issuer_country_code"]

        builder.BatchIdentifier extra_data["batch_identifier"] if extra_data["batch_identifier"]
        builder.InvoicesCount extra_data["invoices_count"] if extra_data["invoices_count"]
        builder.TotalInvoicesAmount extra_data["total_invoices_amount"] if extra_data["total_invoices_amount"]
      end

      builder.InvoiceHeader do
        builder.InvoiceNumber invoice.number
        builder.InvoiceDate invoice.issue_date.strftime("%Y-%m-%d") if invoice.issue_date
        builder.Currency invoice.currency || extra_data["currency"] || "EUR"
      end

      builder.Parties do
        builder.SellerParty do
          builder.PersonTypeCode extra_data["seller_person_type_code"] if extra_data["seller_person_type_code"]
          builder.ResidenceTypeCode extra_data["seller_residence_type_code"] if extra_data["seller_residence_type_code"]
          builder.TaxIdNumber extra_data["seller_tax_id_number"] if extra_data["seller_tax_id_number"]
          builder.Name extra_data["seller_name"] || invoice.from || ""
          builder.FirstSurname extra_data["seller_first_surname"] if extra_data["seller_first_surname"]
          builder.Address extra_data["seller_address"] || invoice.from_address || ""
          builder.PostCode extra_data["seller_post_code"] if extra_data["seller_post_code"]
          builder.Town extra_data["seller_town"] if extra_data["seller_town"]
          builder.Province extra_data["seller_province"] if extra_data["seller_province"]
          builder.CountryCode extra_data["seller_country_code"] if extra_data["seller_country_code"]
          builder.Email extra_data["seller_email"] if extra_data["seller_email"]
        end

        builder.BuyerParty do
          builder.PersonTypeCode extra_data["buyer_person_type_code"] if extra_data["buyer_person_type_code"]
          builder.ResidenceTypeCode extra_data["buyer_residence_type_code"] if extra_data["buyer_residence_type_code"]
          builder.TaxIdNumber extra_data["buyer_tax_id_number"] if extra_data["buyer_tax_id_number"]
          builder.CorporateName extra_data["buyer_corporate_name"] || invoice.client&.name || ""
          builder.Address extra_data["buyer_address"] || invoice.bill_to_address || ""
          builder.PostCode extra_data["buyer_post_code"] if extra_data["buyer_post_code"]
          builder.Town extra_data["buyer_town"] if extra_data["buyer_town"]
          builder.Province extra_data["buyer_province"] if extra_data["buyer_province"]
          builder.CountryCode extra_data["buyer_country_code"] if extra_data["buyer_country_code"]
        end
      end

      builder.InvoiceLines do
        invoice.invoice_details.each_with_index do |detail, index|
          builder.InvoiceLine do
            builder.LineNumber index + 1
            builder.ProductCode detail.product_code || ""
            builder.Description detail.description || ""
            builder.Quantity detail.quantity.to_i
            builder.UnitPrice "%.2f" % detail.unit_price.to_f
            builder.TaxRate "%.2f" % detail.tax_rate.to_f
            line_amount = detail.quantity.to_i * detail.unit_price.to_f
            builder.LineAmount "%.2f" % line_amount
          end
        end
      end

      builder.Totals do
        builder.Subtotal "%.2f" % (invoice.subtotal || 0)
        builder.TaxTotal "%.2f" % (invoice.tax_total || 0)
        builder.Total "%.2f" % (invoice.total || 0)
      end

      builder.Terms extra_data["terms"] if extra_data["terms"]
    end

    builder.target!
  end


    def require_login
      redirect_to login_path, alert: "You must be logged in" unless current_user
    end
  end
