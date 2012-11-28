initItems = ->
  if window.location.pathname.match /\/admin\/items\/(!?.*)(edit|new)/
    console.log 'items'
    window.addItemReq = (id, name, count = 1) ->
      tmpl = $('.itemRequirement.template').clone()
      tmpl.removeClass 'template'
      removeLink = $('.removeLink.template').clone()
      removeLink.removeClass 'template'
      removeLink.click -> $(@).closest('.control-group').remove()
      tmpl.find('label').html(name)
      tmpl.find('label').append removeLink
      tmpl.find('input').attr 'name', "item[requirements][items][#{id}]"
      tmpl.find('input').val count
      $('.itemRequirements').append tmpl
      $("#requireItem option[value='#{id}']").attr('disabled', true)

    $('#requireItem').on 'change', (e) ->
      itemId = e.val
      itemName = $(e.target).find('option:selected').text()
      addItemReq itemId, itemName
      $(e.target).select2('val', '')
    for item in req_items
      addItemReq item.id, item.name, item.count

$(document).ready initItems
$(window).on 'page:change', initItems
