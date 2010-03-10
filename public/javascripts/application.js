// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function adjustImage(image) {
  var maxSize = parseInt(image.down('.thumbnail').getStyle('width'), 10);
  var img = image.down('img');

  img.originalHeight = img.height;
  img.originalWidth = img.width;

  if(img.height > img.width) {
    img.height = maxSize;
  } else {
    img.width = maxSize;
  }

  var size = image.down('.size');
  if(size) {
    size.innerHTML = img.originalHeight + 'x' + img.originalWidth;
  }

  var title = image.down('.title');
  if(title) {
    title.innerHTML = title.innerHTML.truncate(20);
  }

  image.style.visibility = 'visible';
}

function showMessage(kind, text) {
  var message = clearMessage();
  if(text && !text.blank()) {
    var d = document.createElement('div');
    d.className = kind;
    d.innerHTML = text;

    message.update(d);
    message.show();
    message.effect = new Effect.Fade(message, {delay: 10, duration: 5});
  }
}

function clearMessage() {
  var popup = $$('.popup').first();
  var message = popup ? popup.down('.message') : $('page-message');
  message.hide();
  return message;
}

/* TODO: maybe it should be removed */
function mainForm() {
  return $('main').down('form');
}

Event.observe(window, 'load', function() {
  $$('.plan input.radio').each(function(input) {
    Event.observe(input, 'change', function() {
      $$('.plan .plan-label').invoke('removeClassName', 'checked');
      input.next().addClassName('checked');
    });
  });
  $$('.label-input input').each(function(input) {
    Event.observe(input, 'blur', function() {
      input.addClassName('with-text');
    });
  });
  $$('.message').each(function(message) {
    Event.observe(message, 'click', function() {
      message.hide();
    });
  });
  
});

Ajax.Responders.register({
    onCreate: function() {
      showMessage('info', 'Processing request...');
    },
    onComplete: function() {
        // if ($('ajax_popup').visible()) {
        //     $('ajax_popup').scrollTo()
        // }
    }
});
