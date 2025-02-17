import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    const performScroll = () => {
      this.element.scrollTop = this.element.scrollHeight
    }

    // Exécute immédiatement
    performScroll()

    // Réessaie après un court délai pour s'assurer que tout est rendu
    setTimeout(performScroll, 100)
  }

  // Écoute explicitement les mises à jour de messages
  messagesUpdated() {
    this.scrollToBottom()
  }
}
