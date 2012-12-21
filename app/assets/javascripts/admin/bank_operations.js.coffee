# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.addOperation = (id, name, cash = 1) ->
  tmpl = $('.operation.template').clone()
  tmpl.removeClass 'template'
  removeLink = $('.removeLink.template').clone()
  removeLink.removeClass 'template'
  removeLink.click -> $(@).closest('.control-group').remove()
  tmpl.find('label').html(name)
  tmpl.find('label').append removeLink
  tmpl.find('input').attr 'name', "client[operations][#{id}]"
  tmpl.find('input').val cash
  $('.operations').append tmpl
initClients = ->
  $('#addOperation').on 'change', (e) ->
    itemId = e.val
    itemName = $(e.target).find('option:selected').text()
    addOperation itemId, itemName
    $(e.target).select2('val', '')

  if window.ops?
    addOperation op.id, op.name, op.cash for op in window.ops

$(document).ready initClients
$(window).on 'page:change', initClients
