
window.show_ajax_message = (msg, type) ->

  _type = if type == 'notice' then "success" else "danger"

  msg = """
      <div class="alert alert-dismissable alert-#{_type}">
        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
        #{msg}
      </div>
  """

  if $(".modal .flash-messages:visible").length
    $(".modal .flash-messages").html msg
  else
    $(".flash-messages").html msg

  $(".alert-#{_type}").delay(3000).slideUp 'slow'


$(document).on "ajax:complete", (event) ->

  [request, status] = event.detail
  msg = request.getResponseHeader("X-Message")
  type = request.getResponseHeader("X-Message-Type")
  window.show_ajax_message(msg, type) if msg?
