Template.navbar.helpers
  activeRouteClass: (path)->
    route = Router.current()
    if !route?
      return
    return "active" if(route.route.name == path)
