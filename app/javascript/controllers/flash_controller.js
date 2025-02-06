import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    console.log("Flash controller connected!", this.element)
    console.log("Current flash message:", this.element.textContent)

    // Déclenche le minuteur à la connexion du controller
    setTimeout(() => {
      console.log("Attempting to dismiss flash...")
      this.dismiss()
    }, 6000) // Disparaît après 6 secondes
  }

  // Ajoute une transition d'opacité puis retire l'élément du DOM
  dismiss() {
    console.log("Dismissing flash...")
    this.element.classList.add('transition', 'duration-300', 'opacity-0')
    setTimeout(() => {
      console.log("Removing flash from DOM...")
      this.element.remove()
    }, 300) // Attend 300ms pour l'animation
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}
