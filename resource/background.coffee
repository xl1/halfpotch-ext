xhrdoc = (url) ->
  new Promise (resolver) ->
    xhr = new XMLHttpRequest()
    xhr.open 'GET', url, true
    xhr.responseType = 'document'
    xhr.onload  = -> resolver.resolve(xhr.response)
    xhr.onerror = -> resolver.reject()
    xhr.send()

xhrpost = (url, param) ->
  new Promise (resolver) ->
    xhr = new XMLHttpRequest()
    xhr.open 'POST', url, true
    xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
    xhr.onload  = -> resolver.resolve(xhr.response)
    xhr.onerror = -> resolver.reject()
    xhr.send(param)

addToCart = ({ storeId, lotId, amount }) ->
  url = 'http://www.bricklink.com/storeDetail.asp' + 
    "?h=#{storeId}&itemID=#{lotId}"
  xhrdoc(url).then (doc) ->
    step = +doc.getElementsByName('RD')[0].value
    amount = step * Math.ceil(amount / step)
    doc.querySelector('[name^=qd]').value = amount
    
    url = doc.forms[0].action
    param = "qd#{lotId}=#{amount}"
    for { name, value } in doc.querySelectorAll('input[type=hidden]')
      param += "&#{name}=#{value}"
    xhrpost(url, param)


chrome.runtime.onMessage.addListener (request, sender, callback) ->
  switch request.type
    when 'addToCart'
      storeIds = request.solution.reduce (a, p) ->
        if p.storeId not in a
          a.push p.storeId
        a
      , [] 
      Promise.every(request.solution.map(addToCart)...).then ->
        for storeId in storeIds
          chrome.tabs.create {
            url: "http://www.bricklink.com/store.asp?sID=#{storeId}"
            active: false
            openerTabId: sender.tab.id
          }
