/*!  */

/*$('#tabbasics a').click(function (e) {
  e.preventDefault()
  $(this).tab('show')
});*/
$('#tabparts a').click(function (e) {
  e.preventDefault()
  $(this).tab('show')
});
$('#tabwhy a').click(function (e) {
  e.preventDefault()
  $(this).tab('show')
});

/*$('#tabbasics a[href="#basics"]').tab('show')*/
$('#tabparts a[href="#parts"]').tab('show')
$('#tabwhy a[href="#why"]').tab('show')

$('.result-btn button').on('click', function () {
  /*var $btn = $(this).button('loading')*/
  /* Whenever a result-btn is pressed, use toggleClass to highlight the element with the @id matching @data-target. */
  var $tgt = $(this).button.getAttribute('data-target')
  document.getElementById(tgt).toggleClass('highlight')
  $(this).button('&lt;')
})
