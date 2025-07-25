import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    console.log("InvoiceDetails controller connected.");
    if (!this.hasContainerTarget) {
      console.error("InvoiceDetails controller: container target not found.");
    }
  }

  addDetail(event) {
    if (event) event.preventDefault();
    console.log("addDetail s'executa");  
    alert("Afegint una nova línia de detall...");

    // Buscar l'última línia de detall (dins el container)
    const lastDetail = this.containerTarget.querySelector(".invoice-detail:last-of-type");
    if (!lastDetail) {
      console.error("No hi ha cap .invoice-detail per clonar.");
      return;
    }

    const newDetail = lastDetail.cloneNode(true);

    // Netejar inputs
    newDetail.querySelectorAll("input").forEach(input => {
      input.value = "";
    });
    
    this.containerTarget.appendChild(newDetail);
    this.updateIndices();
  }

  removeDetail(event) {
    event.preventDefault();

    const detailToRemove = event.target.closest(".invoice-detail");
    if (!detailToRemove) return;

    const allDetails = this.containerTarget.querySelectorAll(".invoice-detail");

    if (allDetails.length <= 1) {
      alert("Ha de quedar almenys una línia de detall.");
      return;
    }

    detailToRemove.remove();
    this.updateIndices();
  }

  updateIndices() {
    const detailDivs = this.containerTarget.querySelectorAll(".invoice-detail");
    detailDivs.forEach((div, index) => {
      div.querySelectorAll("input, label").forEach(el => {
        if (el.tagName === "INPUT") {
          if (el.name) {
            el.name = el.name.replace(/\[\d+\]/, `[${index}]`);
          }
          if (el.id) {
            el.id = el.id.replace(/\_\d+/, `_${index}`);
          }
        } else if (el.tagName === "LABEL") {
          if (el.htmlFor) {
            el.htmlFor = el.htmlFor.replace(/\_\d+/, `_${index}`);
          }
        }
      });
    });
  }
}
