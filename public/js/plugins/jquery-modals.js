/*
 *
 *  jQuery Modals by Gary Hepting
 *  
 *  Open source under the MIT License. 
 *
 *  Copyright © 2013 Gary Hepting. All rights reserved.
 *
*/


(function() {
  (function($) {
    var elems, modals;

    if ($('div#iframeModal').length < 1) {
      $('body').append('<div class="iframe modal" id="iframeModal"><iframe marginheight="0" marginwidth="0" frameborder="0"></iframe></div>');
      $('div#iframeModal').prepend('<i class="close icon-remove"></i>').prepend('<i class="fullscreen icon-resize-full"></i>');
    }
    $('a.modal').each(function() {
      $(this).attr('data-url', $(this).attr('href'));
      return $(this).attr('href', '#iframeModal');
    });
    $('a.modal').on("click", function(e) {
      $('div#iframeModal iframe').replaceWith('<iframe marginheight="0" marginwidth="0" frameborder="0" width="100%" height="100%" src="' + $(this).attr('data-url') + '"></iframe>');
      e.preventDefault();
      return false;
    });
    elems = [];
    $.fn.modal = function() {
      this.each(function() {
        var $this;

        $(this).not('#iframeModal').wrapInner('<div class="modal-content"></div>');
        $(this).prepend('<i class="close icon-remove"></i>').prepend('<i class="fullscreen icon-resize-full"></i>').appendTo('body');
        $this = $(this);
        return $('[href=#' + $(this).attr('id') + ']').on("click", function(e) {
          modals.open($(this).attr('href'), $(this).hasClass('fullscreen'));
          e.preventDefault();
          return false;
        });
      });
      $('div.modal .close').on("click", function() {
        return modals.close();
      });
      return $('div.modal .fullscreen').on("click", function() {
        return modals.fullscreen($(this).parent('div.modal'));
      });
    };
    modals = (function() {
      var close, fullscreen, open;

      $('body').addClass('modal-ready');
      if ($("#overlay").length < 1) {
        $('body').append('<div id="overlay"></div>');
      }
      $('#overlay, div.modal .close').bind("click", function(e) {
        return close();
      });
      open = function(elem, fullscreen) {
        $(window).bind("keydown", function(e) {
          var keyCode;

          keyCode = (e.which ? e.which : e.keyCode);
          if (keyCode === 27) {
            return close();
          }
        });
        $(elem).addClass("active");
        if (!$(elem).hasClass('iframe')) {
          $(elem).css({
            width: 'auto',
            height: 'auto'
          });
          $(elem).css({
            height: $(elem).outerHeight()
          });
        }
        $(elem).css({
          top: '50%',
          left: '50%',
          'margin-top': ($(elem).outerHeight() / -2) + 'px',
          'margin-left': ($(elem).outerWidth() / -2) + 'px'
        });
        setTimeout(function() {
          return $('body').addClass("modal-active");
        }, 0);
        setTimeout(function() {
          return $('body').removeClass('modal-ready');
        }, 400);
        if (fullscreen) {
          modals.fullscreen(elem);
        }
      };
      close = function() {
        var modal;

        modal = $('div.modal.active');
        $(window).unbind("keydown");
        $('body').removeClass("modal-active").addClass('modal-ready');
        if (modal.hasClass('iframe')) {
          $('div#iframeModal iframe').replaceWith('<iframe marginheight="0" marginwidth="0" frameborder="0"></iframe>');
          modal.css({
            width: '80%',
            height: '80%'
          });
        } else {
          modal.css({
            width: 'auto',
            height: 'auto'
          });
        }
        modal.css({
          top: '10%',
          left: '10%',
          'max-width': '80%',
          'max-height': '80%',
          'margin-top': 0,
          'margin-left': 0
        });
        modal.removeClass("active").removeClass("fullscreen");
        $('i.fullscreen', modal).removeClass('icon-resize-small').addClass('icon-resize-full');
      };
      fullscreen = function(elem) {
        if ($('div.modal.active').hasClass('fullscreen')) {
          $('div.modal i.fullscreen').removeClass('icon-resize-small').addClass('icon-resize-full');
          if ($('div.modal.active').hasClass('iframe')) {
            $('div.modal.active').css({
              width: '80%',
              height: '80%'
            });
          } else {
            $('div.modal.active').css({
              width: 'auto',
              height: 'auto'
            });
            $('div.modal.active').css({
              height: $('div.modal.active').outerHeight()
            });
          }
          $('div.modal.active').removeClass('fullscreen').css({
            'max-width': '80%',
            'max-height': '80%'
          });
          $('div.modal.active').delay(100).css({
            top: '50%',
            left: '50%',
            'margin-top': ($('div.modal.active').outerHeight() / -2) + 'px',
            'margin-left': ($('div.modal.active').outerWidth() / -2) + 'px'
          });
        } else {
          $('div.modal i.fullscreen').addClass('icon-resize-small').removeClass('icon-resize-full');
          $('div.modal.active').addClass('fullscreen').css({
            top: 0,
            left: 0,
            'margin-top': 0,
            'margin-left': 0,
            width: '100%',
            height: '100%',
            'max-width': '100%',
            'max-height': '100%'
          });
        }
      };
      return {
        open: open,
        close: close,
        fullscreen: fullscreen
      };
    })();
    return $(window).resize(function() {
      return $('div.modal.active').each(function() {
        if (!$(this).hasClass('fullscreen')) {
          $(this).removeClass('active').css({
            top: '50%',
            left: '50%',
            'margin-top': ($(this).outerHeight() / -2) + 'px',
            'margin-left': ($(this).outerWidth() / -2) + 'px'
          }).addClass('active');
          if (!$(this).hasClass('iframe')) {
            $(this).css({
              height: 'auto'
            });
            return $(this).css({
              height: $(this).outerHeight()
            });
          }
        }
      });
    });
  })(jQuery);

}).call(this);
