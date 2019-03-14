document.addEventListener "turbolinks:load", ->

  $('#contas_tabs a').on 'click', (e) ->
    e.preventDefault()
    $(this).tab('show')
