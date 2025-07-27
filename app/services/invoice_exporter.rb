class InvoiceExporter
  def self.to_simple_pdf(invoice)
    pdf_html = ApplicationController.render(
    template: "invoices/pdf_templates/simple",
    layout: "pdf",
    locals: { invoice: invoice }
    )
    WickedPdf.new.pdf_from_string(pdf_html)
  end
end
