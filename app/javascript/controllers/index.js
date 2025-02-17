import { Application } from "@hotwired/stimulus"
import ScrollController from "./scroll_controller"
import FlashController from "./flash_controller"

// Créer une fonction personnalisée de chargement des contrôleurs
function eagerLoadControllersFrom(directory, application) {
  const context = require.context(
    directory,
    true,
    /\.js$/
  )

  context.keys().forEach(key => {
    const controllerModule = context(key)

    // Convertir le nom du fichier en identifiant Stimulus
    const identifier = key
      .replace(/^\.\//, '')
      .replace(/\.js$/, '')
      .replace(/_controller$/, '')
      .replace(/_/g, '-')

    // Enregistrer le contrôleur
    application.register(identifier, controllerModule.default)
  })
}

// Initialiser Stimulus
const application = Application.start()
application.debug = true

// Enregistrer manuellement le contrôleur scroll
application.register("scroll", ScrollController)
application.register("flash", FlashController)

// Charger automatiquement tous les contrôleurs du dossier
eagerLoadControllersFrom("controllers", application)

export { application }
