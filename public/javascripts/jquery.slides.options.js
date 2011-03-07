$(function() {
  var startSlide = 1;
  var endSlide = $('#states .states_container').children().length;
  if (window.location.hash) {
    startSlide = window.location.hash.replace('#', '');
  }

  if (startSlide > endSlide) {
    startSlide = endSlide;
    window.location.hash.replace('#', '' + startSlide);
  }
  if (startSlide == 1) {
    $('#states .prev').css('visibility', 'hidden');
  }
  if (startSlide == endSlide) {
    $('#states .next').css('visibility', 'hidden');
  }
  $('#states .states_controls').show();
  
  $('#states').slides({
    container: 'states_container',
    effect: 'fade',
    crossfade: true,
    fadeSpeed: 200,
    // disable plugin's helpers
    generateNextPrev: false,
    generatePagination: false,
    // disable next and prev when in border states
    start: startSlide,
    animationComplete: function(current) {
      // $('#states .prev').toggle(current > startSlide)
      // $('#states .next').toggle(current != endSlide)
      if (current <= 1) {
        $('#states .prev').css('visibility', 'hidden');
      }
      else {
        $('#states .prev').css('visibility', 'visible');
      }
      if (current >= endSlide) {
        $('#states .next').css('visibility', 'hidden');
      }
      else {
        $('#states .next').css('visibility', 'visible');
      }
      window.location.hash = '#' + current;
    }
  });
});

