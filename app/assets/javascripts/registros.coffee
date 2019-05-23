$(document).on "dblclick", '[data-behavior~=toggle-pg]', (ev) ->
  target = $(ev.currentTarget)
  $.post target.data('url'), (data) ->
    $('#table-conta').replaceWith(data)
