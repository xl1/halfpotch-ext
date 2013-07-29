optimizer = ->
  makeButton = (solution) ->
    elem = document.createElement 'input'
    elem.addEventListener 'click', ->
      chrome.runtime.sendMessage { solution, type: 'addToCart' }
    , false
    elem.type = 'input'
    elem.setAttribute 'type', 'button'
    elem.className = 'button'
    elem.style.float = 'right'
    elem.value = 'カートに入れる'
    elem

  
  new MutationObserver((mutations) ->
    table = mutations.pop().addedNodes[0]
    return unless table
    solution = []

    # tr = | 0:部品 | 1:店名 | 2:単価 | 3:個数 | 4:小計 |
    for tr in table.firstChild.children
      if tr.firstChild.tagName.toUpperCase() is 'TH'
        solution = []
      else if tr.firstChild.getAttribute('colspan')
        tr.firstChild.appendChild makeButton(solution)
      else
        url = tr.querySelector('a[href*="store.asp"]').href
        solution.push {
          storeId: /sID=(\w+)/.exec(url)[1]
          lotId:   /itemID=(\w+)/.exec(url)[1]
          amount:  tr.children[3].textContent |0
        }

  ).observe document.getElementById('result'), childList: true


do ->
  routes = [
    [/optimizer/, optimizer]
  ]
  for [re, handler] in routes when re.test(location.pathname)
    handler()