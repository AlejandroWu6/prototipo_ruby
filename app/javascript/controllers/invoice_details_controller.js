document.addEventListener("DOMContentLoaded", () => {
  const addDetailBtn = document.getElementById("add-detail");
  const detailsDiv = document.getElementById("invoice-details");

  addDetailBtn.addEventListener("click", (e) => {
    e.preventDefault();

    // Contar cuántas líneas hay
    const count = detailsDiv.querySelectorAll(".invoice-detail").length;

    // Crear nuevo bloque con índices para el nested form
    const newDetailHTML = `
      <div class="invoice-detail mb-3 border p-2">
        <label for="invoice_invoice_details_attributes_${count}_description">Descripción</label>
        <input class="form-control" type="text" name="invoice[invoice_details_attributes][${count}][description]" id="invoice_invoice_details_attributes_${count}_description">

        <label for="invoice_invoice_details_attributes_${count}_quantity">Quantity</label>
        <input class="form-control" type="number" min="1" name="invoice[invoice_details_attributes][${count}][quantity]" id="invoice_invoice_details_attributes_${count}_quantity">

        <label for="invoice_invoice_details_attributes_${count}_unit_price">Unit price</label>
        <input class="form-control" step="0.01" type="number" name="invoice[invoice_details_attributes][${count}][unit_price]" id="invoice_invoice_details_attributes_${count}_unit_price">

        <label for="invoice_invoice_details_attributes_${count}_discount">Discount</label>
        <input class="form-control" step="0.01" type="number" name="invoice[invoice_details_attributes][${count}][discount]" id="invoice_invoice_details_attributes_${count}_discount">

        <label for="invoice_invoice_details_attributes_${count}_tax_rate">Tax rate</label>
        <input class="form-control" step="0.01" type="number" name="invoice[invoice_details_attributes][${count}][tax_rate]" id="invoice_invoice_details_attributes_${count}_tax_rate">

        <a href="#" class="remove-detail btn btn-danger mt-2">Eliminar línea</a>
      </div>`;

    detailsDiv.insertAdjacentHTML('beforeend', newDetailHTML);
  });

  detailsDiv.addEventListener("click", (e) => {
    if(e.target.classList.contains("remove-detail")){
      e.preventDefault();
      const detailDiv = e.target.closest(".invoice-detail");
      if(detailDiv){
        // Si es un detalle ya guardado, añade _destroy para eliminar
        const destroyField = detailDiv.querySelector("input[name*='_destroy']");
        if(destroyField){
          destroyField.value = "1";
          detailDiv.style.display = "none";
        } else {
          detailDiv.remove();
        }
      }
    }
  });
});
