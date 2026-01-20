import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  
  connect() {
    this.timeout = null
  }

  submit(event) {
    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
