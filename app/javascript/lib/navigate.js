import '@hotwired/turbo-rails'

class Navigate {
  constructor(url) {
    this.url = url
  }

  visitAsTurbo() {
    Turbo.visit(this.url)
  }

  fetchAsTurboStream() {
    fetch(this.url, {
      headers: {
        Accept: 'text/vnd.turbo-stream.html',
      },
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html))
  }

  openInNewTab() {
    window.open(this.url, '_blank', 'noopener')
  }
}

export default Navigate
