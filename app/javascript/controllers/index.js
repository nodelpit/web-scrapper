// Import and register all your controllers from the importmap via controllers/**/*_controller
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus"

const application = Application.start()
eagerLoadControllersFrom("controllers", application)

export { application }
