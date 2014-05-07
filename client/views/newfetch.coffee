Template.newFetch.rendered = ->
  $('.entryPanel').bootstrapValidator
    message: "This is not a valid entry."
    submitHandler: ->
      fetch =
        git: $('#gitUrl').val()
        ref: $('#ref').val()
        name: $("#fetchName").val()
      exist = Router.current().options.params.id
      if exist?
        Meteor.call "updateModFetch", exist, fetch, (err, res)->
          if err?
            $.pnotify
              title: "Error Updating"
              text: err.reason
              type: "error"
          else
            $.pnotify
              title: "Updated"
              type: "success"
              text: "This fetch has been updated."
            Router.go Router.routes["fetchDetail"].path({id: exist})
      else
        Meteor.call "createModFetch", fetch, (err, res)->
          if err?
            $.pnotify
              title: "Error Creating"
              text: err.reason
              type: "error"
          else
            $.pnotify
              title: "Created"
              type: "success"
              text: "This fetch has been created."
            Router.go Router.routes["fetchDetail"].path({id: res})
    feedbackIcons:
      valid: 'fa fa-check'
      invalid: 'fa fa-ban'
      validating: 'fa fa-refresh'
    fields:
      fetchName:
        message: "This name is not valid."
        validators:
          notEmpty:
            message: "Please name your fetch."
          stringLength:
            min: 4
            max: 30
            message: "Greater than 4 characters, less than 30."
          regexp:
            regexp: /^[a-zA-Z0-9_ ]+$/
            message: "You have invalid characters in the name."
      gitUrl:
        message: "This is not a valid git url."
        validators:
          notEmpty:
            message: "You need to enter a git url to fetch from."
          regexp:
            regexp: new RegExp "((git|ssh|http(s)?)|(git@[\\w.]+))(:(//)?)([\\w.@\\:/-~]+)(.git)(/)?"
      ref:
        message: "This is not a valid ref."
        validators:
          notEmpty:
            message: "You need to specify a ref (master, HEAD, commit ID)."
          stringLength:
            min: 3
            max: 25
