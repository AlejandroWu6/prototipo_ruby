import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    console.log("invoice_details_controller.js controller connected.");
    if (!this.hasContainerTarget) {
      console.error("invoice_details_controller.js: container target not found.");
    }

    this.containerTarget.addEventListener("input", () => this.calculateTotals());
    this.calculateTotals();
  }

  addDetail(event) {
    if (event) event.preventDefault();
    console.log("addDetail s'executa");

    const lastDetail = this.containerTarget.querySelector(".invoice-detail:last-of-type");
    if (!lastDetail) {
      console.error("No hi ha cap .invoice-detail per clonar.");
      return;
    }

    const newDetail = lastDetail.cloneNode(true);

    newDetail.querySelectorAll("input").forEach(input => {
      input.value = "";
    });

    const addButton = this.containerTarget.querySelector("#add-line-btn");
    if (addButton) {
      this.containerTarget.insertBefore(newDetail, addButton);
    } else {
      this.containerTarget.appendChild(newDetail);
    }

    this.updateIndices();
    this.calculateTotals();
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
    this.calculateTotals();
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

  calculateTotals() {
    let subtotal = 0;
    let totalTax = 0;

    const detailDivs = this.containerTarget.querySelectorAll(".invoice-detail");

    detailDivs.forEach(div => {
      const quantity = parseFloat(div.querySelector('input[name*="[quantity]"]').value) || 0;
      const unitPrice = parseFloat(div.querySelector('input[name*="[unit_price]"]').value) || 0;
      const taxRate = parseFloat(div.querySelector('input[name*="[tax_rate]"]').value) || 0;

      const lineTotal = quantity * unitPrice;
      const lineTax = lineTotal * (taxRate / 100);

      subtotal += lineTotal;
      totalTax += lineTax;
    });

    const total = subtotal + totalTax;

    const formatEuro = amount => amount.toLocaleString("es-ES", {
      style: "currency",
      currency: "EUR"
    });

    document.getElementById("invoice-subtotal").innerText = `Subtotal: ${formatEuro(subtotal)}`;
    document.getElementById("invoice-tax").innerText = `Taxes: ${formatEuro(totalTax)}`;
    document.getElementById("invoice-total").innerText = `Total: ${formatEuro(total)}`;
  }
}
