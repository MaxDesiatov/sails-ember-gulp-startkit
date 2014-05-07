PageableMixin = Ember.Mixin.create
  actions:
    clearInput: ->
      @set 'rawQuery', ''

    setModel: ->
      @queryData().then (res) =>
        @set 'model', res

    setSort: (newSort) ->
      sort = @get 'sort'
      dir = @get 'sortDirection'
      if sort is newSort
        if dir is 'ASC'
          @set 'sortDirection', 'DESC'
        else
          @set 'sortDirection', 'ASC'
      else
        @set 'sort', newSort
      @send 'setModel'

    goToPage: (page) ->
      if (page >= 0) and (page < @get 'totalPages')
        @set 'currentPage', page
        @send 'setModel'

    dropDown: -> console.log 'dropDown'

  metadata: null

  queryRunner: (-> @send 'setModel').observes 'where'

  queryData: ->
    q =
      limit: @get 'limit'
      skip: @get 'skip'
      sort: "#{@get 'sort'} #{@get 'sortDirection'}"
      where: @get 'where'
    @store.find(@get('modelName'), q).then (res) =>
      m = @store.metadataFor @modelName
      @set 'metadata', Ember.copy m
      if @get('currentPage') > @get('totalPages')
        @set 'currentPage', 0
      res

  skip:
    Em.computed ->
      m = @get 'metadata'
      if m?
        m.limit * @get 'currentPage'
      else
        0
    .property 'metadata', 'currentPage'

  pages:
    Em.computed ->
      p = @get 'currentPage'
      result = [sym: '&laquo;', page: p - 1, disabled: p is 0]
      totalPages = @get 'totalPages'
      gap = 2
      start = if p < (gap + 3) then 0 else p - gap
      end = if p > totalPages - (gap + 3) then totalPages else p + gap + 1

      dropdown = sym: '...', dropdown: true
      if start isnt 0
        result.push sym: 1, page: 0
        result.push dropdown
      [0..(totalPages - 1)].slice(start, end).forEach (i) =>
        result.push sym: i + 1, page: i, active: i is p
      if end isnt totalPages
        result.push dropdown
        result.push sym: totalPages, page: totalPages - 1

      result.push sym: '&raquo;', page: p + 1, disabled: p is (totalPages - 1)
      result
    .property 'metadata', 'currentPage'

  totalPages:
    Em.computed ->
      m = @get 'metadata'
      Math.ceil(m.total / m.limit)
    .property 'metadata'

  currentPage: 0
  limit: 20

`export default PageableMixin`
