function showMessage(kind, text) {
  alert(1)
  clearMessage();
  if(text && !text.blank()) {
    var message = $(document.createElement('span'));
    message.className = 'flash_ ' + kind;
    message.innerHTML = text + "<a onclick='hideFlash(this); return false;' id='close_flash_" + kind + "' href='#' class='close'></a>"
  
    $('messages').insert({top: message });
    message.effect = new Effect.Fade(message, {delay: 10, duration: 5});
  }
}

function showBodyMessage(kind, text) {
  $('action-bar').select('.message').invoke('remove');
  if(text && !text.blank()) {
    var message = $(document.createElement('table'));
    message.className = 'message ' + kind;
    message.innerHTML = '<tr><td>' + text + '</tr></td>'
  
    $('action-bar').insert({top: message });
    message.effect = new Effect.Fade(message, {delay: 10, duration: 5});
  }
  
}

function setTitle(newValue) {
  document.title = newValue;
  $$('#main .header .title')[0].innerHTML = newValue;
}

function clearMessage() {
  getActionBar().select('.message').invoke('remove');
}

function showConfirmPopup(href, question) {
  $('popup').innerHTML = $('confirm-popup').innerHTML;
  $('popup').down('a.yes').href = href;
  if(!question.blank()) {
    $('popup').down('.text').innerHTML = question;
  }
  showPopup();
}

function clearInputMessages() {
  clearMessage();
  $$('.error').invoke('remove');
}

function showInputMessage(inputId, message) {
  var input = $(inputId);
  if(input) {
    var row = input.up('.inputs-row');
    if(row && !row.down('.error')) {
      row.select('.label-input').each(function(i) {
        appendInputError(i, ' blank', '&nbsp;');
      });
    }

    appendInputError(input.up('.label-input'), '', message);
  }
}

function appendInputError(input, blank, message) {
  input.select('.error').invoke('remove');

  var div = $(document.createElement('div'));
  div.className = 'error' + blank;
  div.innerHTML = message;

  if (input.select('input')[0]) {
    input.select('input')[0].insert({before: div});
  } else {
    input.insert({top: div});
  }

}

function showPopup() {
  window.currentScrollOffsets = document.viewport.getScrollOffsets();
  document.documentElement.style.overflow = 'hidden';
  $('popup-system').show();
}

function hidePopup() {
  document.documentElement.style.overflow = null;
  // $$('body').first().setStyle({ minHeight: "auto" });
  $('all').style.overflow = 'visible';
  $('popup-hider').up().fade({ duration: 0.2});
  $('popup').innerHTML = '';
  
  
  var left = 0;
  var top = 0;
  if(window.currentScrollOffsets != undefined) {
    left = window.currentScrollOffsets.left;
    top = window.currentScrollOffsets.top;
  }
  
  window.scrollTo(left, top);
}

function getActionBar() {
  
  var popupActionBars = $$('#popup .popup-action-bar');
  
  if(popupActionBars.size() > 1) {
    popupActionBars =  $$('#popup .active .popup-action-bar');
  }
  
  return popupActionBars.first() || $('action-bar');
}

function showProcessing(request) {
  clearMessage();
  var actionBar = getActionBar();
  if(actionBar) {
    var image = actionBar.down('.processing');
    if(image) {
      image.refCount++;
    } else {
      image = $(document.createElement('img'));
      image.refCount = 1;
      image.src = '/images/rotation.gif';
      image.className = 'processing';
      actionBar.insert({ bottom: image });
    }
    request.processing = image;
  }
}

function hideProcessing(request) {
  if(request.processing && --request.processing.refCount == 0) {
    request.processing.remove();
  }
}

// container = "div.plan-wrapper"
// element_class = "> div.plan-label"
function setElementsHeight(container, element_class ) {

  function getChildMaxHeight(element) {
    var maxHeight = 0;

    element.childElements().each(function(item) {
      var itemHeight = parseInt(item.getHeight());
      if(itemHeight > maxHeight) {maxHeight = itemHeight}
    });

    return maxHeight;
  }
  var maxHeight = getChildMaxHeight($$(container).first());

  $$(container).first().select(element_class).each(function(item) {
    item.setStyle({
      height: maxHeight + 'px'
    });
  });
}

function toggleEditor(id) {
  if (!tinyMCE.get(id)) {
    tinyMCE.execCommand('mceAddControl', false, id);
  } else {
    tinyMCE.execCommand('mceRemoveControl', false, id);
  }
}

function showCardForm() {
  if( $('billing_view') != null ) {
    $("billing_view").blindUp({ duration: 0.1 });
  }

  $("billing_inputs").blindDown({ duration: 0.1 });
  $$("#billing_inputs input").each(function(item) { $(item).enable(); })
}

function hideCardForm() {
  if( $('billing_view') != null ) {
    $("billing_view").blindDown({ duration: 0.1 });
    $('cancel_card_link').fade({ duration: 0.5 });
  }

  $$("#billing_inputs input").each(function(item) { $(item).disable(); })
  $("billing_inputs").blindUp({ duration: 0.1 });
}

function bindPlanAndCardForm() {
  
  $$('input.unpayment').each(function(item) {
    $(item).observe('change', function() { 
      hideCardForm() 
    })

    if ($(item).checked == true) {
      hideCardForm();
    }
  })
  
  if( $('billing_view') == null ) {
    $$('input.payment').each(function(item) {
      $(item).observe('change', function() { 
        showCardForm();
      })
    })
  } else {
    $$('input.payment').each(function(item) {
      $(item).observe('change', function() { 
        $('cancel_card_link').appear({ duration: 0.5 });
      })
    })
  }
  
}


Ajax.Responders.register({
  onCreate: showProcessing,

  onComplete: function(request, transport) {
    hideProcessing(request);
    bindPlanAndCardForm();

    if(transport.status == 200) {
      var loc = transport.getHeader('X-Location');
      if(loc) {
        window.location = loc;
      }
    }
  }
});

Event.observe(window, 'load', function() {
  var sourceBar = $('source-bar');
  if(sourceBar) {
    var selected = sourceBar.down('li.selected');
    if(selected) {
      sourceBar.scrollTop = selected.cumulativeOffset().top;
    }
  }
});


