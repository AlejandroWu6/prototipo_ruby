import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.container = this.containerTarget;
  }

  addDetail(event) {
    event.preventDefault();

    const detailDivs = this.container.querySelectorAll(".invoice-detail");
    if (detailDivs.length === 0) return;

    const lastDetail = detailDivs[detailDivs.length - 1];
    const newDetail = lastDetail.cloneNode(true);

    // Limpiar inputs para nueva línea
    newDetail.querySelectorAll("input").forEach(input => input.value = "");

    this.container.appendChild(newDetail);
    this.updateIndices();
  }

  removeDetail(event) {
    event.preventDefault();

    const detailDivs = this.container.querySelectorAll(".invoice-detail");
    if (detailDivs.length <= 1) {
      alert("Debe haber al menos una línea.");
      return;
    }

    const detailToRemove = event.target.closest(".invoice-detail");
    detailToRemove.remove();
    this.updateIndices();
  }

  updateIndices() {
    const detailDivs = this.container.querySelectorAll(".invoice-detail");
    detailDivs.forEach((div, index) => {
      div.querySelectorAll("input, label").forEach(el => {
        if (el.tagName === "INPUT") {
          if (!el.name) return;
          el.name = el.name.replace(/\[\d+\]/, `[${index}]`);
          if (el.id) el.id = el.id.replace(/\_\d+/, `_${index}`);
        } else if (el.tagName === "LABEL") {
          if (!el.htmlFor) return;
          el.htmlFor = el.htmlFor.replace(/\_\d+/, `_${index}`);
        }
      });
    });
  }
}
