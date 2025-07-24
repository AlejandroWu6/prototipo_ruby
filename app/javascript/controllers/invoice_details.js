document.addEventListener("DOMContentLoaded", () => {
  const addDetailBtn = document.getElementById("add-detail");
  const invoiceDetailsContainer = document.getElementById("invoice-details");

  // Función para actualizar índices de los campos
  function updateIndices() {
    const detailDivs = invoiceDetailsContainer.querySelectorAll(".invoice-detail");
    detailDivs.forEach((div, index) => {
      div.querySelectorAll("input, label").forEach(el => {
        if (el.tagName === "INPUT") {
          const name = el.name;
          if (!name) return;
          // Cambia el índice dentro del name (ej: invoice[invoice_details_attributes][0][description])
          el.name = name.replace(/\[\d+\]/, `[${index}]`);
          // Borra el id para evitar duplicados o actualízalo si usas id
          if (el.id) {
            el.id = el.id.replace(/\_\d+/, `_${index}`);
          }
        } else if (el.tagName === "LABEL") {
          const htmlFor = el.htmlFor;
          if (!htmlFor) return;
          el.htmlFor = htmlFor.replace(/\_\d+/, `_${index}`);
        }
      });
    });
  }

  // Añadir nueva línea
  addDetailBtn.addEventListener("click", (e) => {
    e.preventDefault();
    const detailDivs = invoiceDetailsContainer.querySelectorAll(".invoice-detail");
    if (detailDivs.length === 0) return;

    const lastDetail = detailDivs[detailDivs.length - 1];
    const newDetail = lastDetail.cloneNode(true);

    // Limpia los inputs del nuevo detalle
    newDetail.querySelectorAll("input").forEach(input => {
      if (input.type === "number") {
        input.value = "";
      } else {
        input.value = "";
      }
    });

    invoiceDetailsContainer.appendChild(newDetail);
    updateIndices();
  });

  // Eliminar línea
  invoiceDetailsContainer.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-detail")) {
      e.preventDefault();
      const detailDivs = invoiceDetailsContainer.querySelectorAll(".invoice-detail");
      if (detailDivs.length <= 1) {
        alert("Debe haber al menos una línea.");
        return;
      }
      const detailToRemove = e.target.closest(".invoice-detail");
      detailToRemove.remove();
      updateIndices();
    }
  });

});
