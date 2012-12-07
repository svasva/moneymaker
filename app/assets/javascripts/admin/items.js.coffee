initItems = ->
  $('.sortedTable').dataTable
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    sPaginationType: "bootstrap"
    bFilter: false
    bPaginate: false
    bInfo: false

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

  window.addRoomReq = (id, name, count = 1) ->
    tmpl = $('.itemRequirement.template').clone()
    tmpl.removeClass 'template'
    removeLink = $('.removeLink.template').clone()
    removeLink.removeClass 'template'
    removeLink.click -> $(@).closest('.control-group').remove()
    tmpl.find('label').html(name)
    tmpl.find('label').append removeLink
    tmpl.find('input').attr 'name', "item[requirements][rooms][#{id}]"
    tmpl.find('input').val count
    $('.roomRequirements').append tmpl

  window.addEffect = (id, name, count = 1) ->
    tmpl = $('.itemRequirement.template').clone()
    tmpl.removeClass 'template'
    removeLink = $('.removeLink.template').clone()
    removeLink.removeClass 'template'
    removeLink.click -> $(@).closest('.control-group').remove()
    tmpl.find('label').html(name)
    tmpl.find('label').append removeLink
    tmpl.find('input').attr 'name', "item[effects][#{id}]"
    tmpl.find('input').val count
    $('.effects').append tmpl

  $('#requireItem').on 'change', (e) ->
    itemId = e.val
    itemName = $(e.target).find('option:selected').text()
    addItemReq itemId, itemName
    $(e.target).select2('val', '')
  $('#requireRoom').on 'change', (e) ->
    itemId = e.val
    itemName = $(e.target).find('option:selected').text()
    addRoomReq itemId, itemName
    $(e.target).select2('val', '')

  $('#effects').on 'change', (e) ->
    itemId = e.val
    itemName = $(e.target).find('option:selected').text()
    addEffect itemId, itemName
    $(e.target).select2('val', '')
  if req_items?
    for item in req_items
      addItemReq item.id, item.name, item.count
  if req_rooms?
    for item in req_rooms
      addRoomReq item.id, item.name, item.count
  if item_effects?
    for item in item_effects
      addEffect item.id, item.name, item.count

$(document).ready initItems
$(window).on 'page:change', initItems
