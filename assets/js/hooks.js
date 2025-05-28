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

export default Hooks
