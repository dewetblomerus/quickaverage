// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import 'phoenix_html'
import { Socket } from 'phoenix'
import topbar from '../vendor/topbar'
import { LiveSocket } from 'phoenix_live_view'
import "../css/app.css"

let Hooks = {}
Hooks.SetStorage = {
  mounted() {
    this.handleEvent('set_storage', (data) => {
      for (const [key, value] of Object.entries(data)) {
        localStorage.setItem(key, value)
      }
    })
  },
}

Hooks.ClearNumber = {
  mounted() {
    this.handleEvent('clear_number', () => {
      document.getElementById('number').value = ''
    })
  },
}

Hooks.RestoreUser = {
  mounted() {
    this.pushEvent('restore_user', {
      admin_state: localStorage.getItem('admin_state'),
      name: localStorage.getItem('name'),
      only_viewing: localStorage.getItem('only_viewing'),
    })
  },
}

Hooks.InitiateRestoreUser = {
  mounted() {
    this.handleEvent('initiate_restore_user', () => {
      this.pushEvent('restore_user', {
        admin_state: localStorage.getItem('admin_state'),
        name: localStorage.getItem('name'),
        only_viewing: localStorage.getItem('only_viewing'),
      })
    })
  },
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content')

let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', (info) => topbar.show())
window.addEventListener('phx:page-loading-stop', (info) => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
