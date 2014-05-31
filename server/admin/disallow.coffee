#Don't allow new accounts
Accounts.validateNewUser ->
  metric = Metrics.findOneFaster {_id: 'login'}
  !metric? || metric.enabled
