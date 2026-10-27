// sessionStorage survives reloads, but belongs to the current browser tab.
const keyFor = role => `moscow-memory:${role}:signed-in`

function checkTabSession() {
  const login = document.querySelector('meta[name="tab-login-role"]')
  try {
    if (login) {
      sessionStorage.setItem(keyFor(login.content), "yes")
      login.remove()
    }
    const account = document.querySelector("[data-account-role]")
    if (!account) return
    const role = account.dataset.accountRole
    if (sessionStorage.getItem(keyFor(role)) === "yes") {
      account.style.visibility = "visible"
      return
    }
    // A fresh tab must sign in again; never log out on unload/pagehide,
    // because those events also run on refresh and navigation.
    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    fetch("/tab_session", {
      method: "DELETE", credentials: "same-origin",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf || "" },
      body: JSON.stringify({ role })
    }).then(response => {
      if (!response.ok) throw new Error("Session cleanup failed")
      location.replace(role === "admin" ? "/admin/login" : "/login")
    }).catch(() => {
      account.replaceChildren(Object.assign(document.createElement("p"), { textContent: "Не удалось проверить вход. Обновите страницу." }))
      account.style.visibility = "visible"
    })
  } catch (_) {
    const account = document.querySelector("[data-account-role]")
    if (account) {
      account.replaceChildren(Object.assign(document.createElement("p"), { textContent: "Разрешите хранение данных сайта в браузере и войдите снова." }))
      account.style.visibility = "visible"
    }
  }
}

document.addEventListener("turbo:load", checkTabSession)
document.addEventListener("turbo:submit-start", event => {
  const path = new URL(event.target.action, location.origin).pathname
  const role = path === "/admin/logout" ? "admin" : path === "/logout" ? "user" : null
  if (role) sessionStorage.removeItem(keyFor(role))
})
