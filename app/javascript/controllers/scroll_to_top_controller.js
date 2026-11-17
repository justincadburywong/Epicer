import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("turbo:frame-render", this.handleFrameRender.bind(this))
    document.addEventListener("turbo:frame-load", this.handleFrameRender.bind(this))
  }

  disconnect() {
    document.removeEventListener("turbo:frame-render", this.handleFrameRender.bind(this))
    document.removeEventListener("turbo:frame-load", this.handleFrameRender.bind(this))
  }

  handleFrameRender(event) {
    if (event.target.id === "recipes_list") {
      setTimeout(() => {
        window.scrollTo({ top: 0, behavior: "smooth" })
      }, 50)
    }
  }
}
