const Hooks = {}

Hooks.ScrollToBottom = {
  mounted() {
    this.scrollToBottom()
    this.handleEvent("scroll-to-bottom", () => {
      this.scrollToBottom()
    })
  },
  scrollToBottom() {
    const messagesContainer = this.el
    messagesContainer.scrollTo({
      top: messagesContainer.scrollHeight,
      behavior: 'smooth'
    })
  }
}

Hooks.LocalTime = {
  mounted() {
    this.updated()
  },
  updated() {
    const dt = new Date(this.el.textContent.trim())

    dt.setSeconds(null)

    const formatted = new Intl.DateTimeFormat("pt-BR", {
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
      timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone
    }).format(dt)

    this.el.textContent = formatted

    this.el.classList.remove('hidden')
  }
}

export default Hooks
