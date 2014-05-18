Template.about.rendered = ->
  $_t = this
  previewParClosedHeight = 25
  jQuery("div.toggle.active > p").addClass "preview-active"
  jQuery("div.toggle.active > div.toggle-content").slideDown 400
  jQuery("div.toggle > label").click (e) ->
    parentSection = jQuery(this).parent()
    parentWrapper = jQuery(this).parents("div.toogle")
    previewPar = false
    isAccordion = parentWrapper.hasClass("toogle-accordion")
    parentWrapper.find("div.toggle.active > label").trigger "click"  if isAccordion and typeof (e.originalEvent) isnt "undefined"
    parentSection.toggleClass "active"
    if parentSection.find("> p").get(0)
      previewPar = parentSection.find("> p")
      previewParCurrentHeight = previewPar.css("height")
      previewParAnimateHeight = previewPar.css("height")
      previewPar.css "height", "auto"
      previewPar.css "height", previewParCurrentHeight
    toggleContent = parentSection.find("> div.toggle-content")
    if parentSection.hasClass("active")
      jQuery(previewPar).animate
        height: previewParAnimateHeight
      , 350, ->
        jQuery(this).addClass "preview-active"
      toggleContent.slideDown 350
    else
      jQuery(previewPar).animate
        height: previewParClosedHeight
      , 350, ->
        jQuery(this).removeClass "preview-active"
      toggleContent.slideUp 350
