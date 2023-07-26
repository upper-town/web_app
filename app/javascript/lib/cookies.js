class Cookies {
  set(name, value, attrs) {
    document.cookie = `${name}=${value}; ${this.#buildAttrsStr(attrs)}`
  }

  #buildAttrsStr(attrs) {
    return Object.entries(attrs)
      .map(([key, value]) => {
        if (typeof value === 'boolean') {
          return value ? key : undefined
        } else {
          return `${key}=${value}`
        }
      })
      .filter((keyValue) => keyValue !== undefined)
      .join('; ')
  }
}

export default new Cookies()
