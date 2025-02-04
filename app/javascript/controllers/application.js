import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = location.hostname.startsWith('development.') || location.hostname.startsWith('test.')
window.Stimulus = application

export { application }
