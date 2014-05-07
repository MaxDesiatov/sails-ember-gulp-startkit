`import Resolver from 'ember/resolver'`

`import PageableTableView from 'appkit/views/pageable-table'`

Ember.Handlebars.helper 'pageable-table', PageableTableView

Ember.Handlebars.helper 'join-models', (models, prop, separator) ->
  models.get('content').map((m) -> m.get prop).join separator

App = Ember.Application.extend
  LOG_ACTIVE_GENERATION: true
  LOG_MODULE_RESOLVER: true
  LOG_TRANSITIONS: true
  LOG_TRANSITIONS_INTERNAL: true
  LOG_VIEW_LOOKUPS: true
  modulePrefix: 'appkit'
  Resolver: Resolver.default

`export default App`
