// @flow

export function initialize () {
  const tabs = document.querySelectorAll('label[for^="tab-"]')
  const inputs = document.querySelectorAll('input[name="apiap-tabs"]')

  // NodeList.foreEach not supported in IE11
  for (const i of inputs) {
    i.addEventListener('change', toggleCurrentTab)
  }

  function toggleCurrentTab () {
    for (const t of tabs) {
      t.classList.toggle('current-tab')
    }
  }
}
