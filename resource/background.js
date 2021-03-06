// Generated by CoffeeScript 1.7.1
(function() {
  var addToCart, xhrdoc, xhrpost,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  xhrdoc = function(url) {
    return new Promise(function(resolve, reject) {
      var xhr;
      xhr = new XMLHttpRequest();
      xhr.open('GET', url, true);
      xhr.responseType = 'document';
      xhr.onload = function() {
        return resolve(xhr.response);
      };
      xhr.onerror = function() {
        return reject();
      };
      return xhr.send();
    });
  };

  xhrpost = function(url, param) {
    return new Promise(function(resolve, reject) {
      var xhr;
      xhr = new XMLHttpRequest();
      xhr.open('POST', url, true);
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
      xhr.onload = function() {
        return resolve(xhr.response);
      };
      xhr.onerror = function() {
        return reject();
      };
      return xhr.send(param);
    });
  };

  addToCart = function(_arg) {
    var amount, lotId, storeId, url;
    storeId = _arg.storeId, lotId = _arg.lotId, amount = _arg.amount;
    url = 'http://www.bricklink.com/storeDetail.asp' + ("?b=0&h=" + storeId + "&itemID=" + lotId);
    return xhrdoc(url).then(function(doc) {
      var name, param, step, value, _i, _len, _ref, _ref1;
      step = +doc.getElementsByName('RD')[0].value;
      amount = step * Math.ceil(amount / step);
      url = doc.forms[0].action;
      param = "qd" + lotId + "=" + amount;
      _ref = doc.querySelectorAll('input[type=hidden]');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], name = _ref1.name, value = _ref1.value;
        param += "&" + name + "=" + value;
      }
      return xhrpost(url, param);
    });
  };

  chrome.runtime.onMessage.addListener(function(request, sender, callback) {
    var storeIds;
    switch (request.type) {
      case 'addToCart':
        storeIds = request.solution.reduce(function(a, p) {
          var _ref;
          if (_ref = p.storeId, __indexOf.call(a, _ref) < 0) {
            a.push(p.storeId);
          }
          return a;
        }, []);
        return Promise.all(request.solution.map(addToCart)).then(function() {
          var storeId, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = storeIds.length; _i < _len; _i++) {
            storeId = storeIds[_i];
            _results.push(chrome.tabs.create({
              url: "http://www.bricklink.com/store.asp?sID=" + storeId,
              active: false,
              openerTabId: sender.tab.id
            }));
          }
          return _results;
        });
    }
  });

}).call(this);
