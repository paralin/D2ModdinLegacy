#Don't allow new accounts
Accounts.validateNewUser ->
  metric = Metrics.findOne {_id: 'login'}
  !metric? || metric.enabled
