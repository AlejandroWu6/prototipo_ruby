import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    console.log("invoice_details_controller.js controller connected.");
    if (!this.hasContainerTarget) {
      console.error("invoice_details_controller.js: container target not found.");
    }
  }

  addDetail(event) {
    if (event) event.preventDefault();
    console.log("addDetail s'executa");

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

    // Buscar el botó amb id 'add-line-btn' per inserir abans d'ell
    const addButton = this.containerTarget.querySelector("#add-line-btn");
    if (addButton) {
      this.containerTarget.insertBefore(newDetail, addButton);
    } else {
      this.containerTarget.appendChild(newDetail); // Si no es troba el botó, s'afegeix al final
    }

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
