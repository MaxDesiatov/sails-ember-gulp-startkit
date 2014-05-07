gulp = require 'gulp'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
transpile = require 'gulp-es6-module-transpiler'
emblem = require 'gulp-ember-emblem'
defineModule = require 'gulp-define-module'
concat = require 'gulp-concat-sourcemap'
preprocess = require 'gulp-preprocess'
usemin = require 'gulp-usemin'
livereload = require 'gulp-livereload'
nodemon = require 'gulp-nodemon'
es = require 'event-stream'
path = require 'path'
_ = require 'underscore'

dest =
  root: '.tmp/public'
dest.assets = "#{dest.root}/assets"
dest.fonts = "#{dest.root}/fonts"

src =
  templates: 'app/templates/**/*.emblem'
  scripts: 'app/**/*.{js,coffee}'
  styles: 'app/**/*.styl'

gulp.task 'scripts', ->
  es.merge(gulp.src('app/**/*.coffee').pipe(coffee bare: true),
           gulp.src 'app/**/*.js')
  .pipe(transpile type: 'amd', moduleName: (m) -> "appkit/#{m}")
  .pipe(concat 'app.js', sourcesContent: true, prefix: 1)
  .pipe gulp.dest dest.assets

gulp.task 'styles', ->
  gulp.src(src.styles).pipe(stylus())
  .pipe gulp.dest dest.assets

gulp.task 'templates', ->
  gulp.src(src.templates)
  .pipe(emblem())
  .pipe(defineModule 'plain',
    wrapper: 'Ember.TEMPLATES[\'<%= templateName %>\'] = <%= emberHandlebars %>'
    context: (ctx) ->
      file = ctx.file
      ext = path.extname file.path
      root = path.resolve './app/templates'
      emberHandlebars: 'Ember.Handlebars.template(<%= contents %>)'
      templateName: path.relative(root, file.path).slice 0, -ext.length)
  .pipe(concat 'templates.js', sourcesContent: true, prefix: 2)
  .pipe gulp.dest dest.assets

gulp.task 'maps', ->
  gulp.src('vendor/bootstrap/dist/css/bootstrap.css.map')
  .pipe gulp.dest dest.assets

gulp.task 'fonts', ->
  gulp.src('vendor/font-awesome/fonts/*')
  .pipe gulp.dest dest.fonts

gulp.task 'index', ['scripts', 'styles', 'templates'], ->
  gulp.src('app/index.html')
  .pipe(preprocess context: dist: false, tests: false)
  .pipe(usemin())
  .pipe gulp.dest dest.root

gulp.task 'default', ['index', 'fonts', 'maps'], ->
  gulp.watch _.values(src), ['index']

  gulp.watch 'app/index.html', ['index']
  gulp.watch 'vendor/**/*.js', ['index']
  server = livereload()
  nodemon(script: 'app.js', watch: ['api/', 'config/'], ext: 'js coffee').on 'restart', ->
    setTimeout (-> server.changed 'index.html'), 3000
  gulp.watch('.tmp/public/**/*').on 'change', (file) ->
    server.changed file.path

