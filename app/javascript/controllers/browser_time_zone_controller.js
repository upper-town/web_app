import { Controller } from '@hotwired/stimulus'
import Cookies from 'lib/cookies'

export default class extends Controller {
  connect() {
    Cookies.set(this.#cookieName, this.#cookieValue(), this.#cookieAttrs())
  }

  #cookieName = 'browser_time_zone'
  #cookieValue() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone
  }
  #cookieAttrs() {
    return {
      'Max-Age': 31536000, // One year in seconds
      Path: '/',
      SameSite: 'Lax',
      Secure: window.location.protocol === 'https:',
    }
  }
}
