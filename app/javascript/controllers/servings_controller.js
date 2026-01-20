import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "quantity"]
  static values = { 
    original: Number,
    ingredients: Array
  }

  connect() {
    this.originalServings = this.originalValue
  }

  adjust() {
    const newServings = parseInt(this.inputTarget.value) || this.originalServings
    const ratio = newServings / this.originalServings

    this.quantityTargets.forEach((el) => {
      const originalQty = parseFloat(el.dataset.originalQuantity)
      if (originalQty && !isNaN(originalQty)) {
        const newQty = (originalQty * ratio)
        el.textContent = this.formatQuantity(newQty)
      }
    })
  }

  reset() {
    this.inputTarget.value = this.originalServings
    this.adjust()
  }

  increment() {
    const current = parseInt(this.inputTarget.value) || this.originalServings
    this.inputTarget.value = current + 1
    this.adjust()
  }

  decrement() {
    const current = parseInt(this.inputTarget.value) || this.originalServings
    if (current > 1) {
      this.inputTarget.value = current - 1
      this.adjust()
    }
  }

  formatQuantity(num) {
    if (num === 0) return ""
    
    const rounded = Math.round(num * 100) / 100
    
    if (rounded === Math.floor(rounded)) {
      return rounded.toString()
    }
    
    const fractions = [
      { decimal: 0.125, display: "⅛" },
      { decimal: 0.25, display: "¼" },
      { decimal: 0.333, display: "⅓" },
      { decimal: 0.375, display: "⅜" },
      { decimal: 0.5, display: "½" },
      { decimal: 0.625, display: "⅝" },
      { decimal: 0.666, display: "⅔" },
      { decimal: 0.75, display: "¾" },
      { decimal: 0.875, display: "⅞" }
    ]
    
    const whole = Math.floor(rounded)
    const decimal = rounded - whole
    
    for (const frac of fractions) {
      if (Math.abs(decimal - frac.decimal) < 0.05) {
        return whole > 0 ? `${whole} ${frac.display}` : frac.display
      }
    }
    
    return rounded.toString()
  }
}
