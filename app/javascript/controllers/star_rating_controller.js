import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "star"]
  static values = { rating: Number }

  connect() {
    this.ratingValue = parseInt(this.inputTarget.value) || 0
    this.render()
  }

  select(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.ratingValue = rating
    this.inputTarget.value = rating
    this.render()
  }

  hover(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.highlight(rating)
  }

  reset() {
    this.render()
  }

  highlight(rating) {
    this.starTargets.forEach((star, index) => {
      if (index < rating) {
        star.classList.remove("text-gray-300")
        star.classList.add("text-yellow-400")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }

  render() {
    this.highlight(this.ratingValue)
  }
}
