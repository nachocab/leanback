fs            = require 'fs'
{exec, spawn} = require 'child_process'

# order of files in `inFiles` is important
config =
  srcDir:  'src'
  outDir:  'lib'
  inFiles: [
    'aux'
    'longitudinal/views/dashboard_view'
    'longitudinal/models/longitudinal_model'
    'longitudinal/views/heatmap_view'
    'longitudinal/views/pcp_view'
  ]
  outFile: 'leanback'
  uglifier:  'uglifyjs'

outJS = "#{config.outDir}/#{config.outFile}"
strFiles = ("#{config.srcDir}/#{file}.coffee" for file in config.inFiles).join ' '

# deal with errors from child processes
exerr  = (err, sout,  serr)->
  process.stdout.write err  if err
  process.stdout.write sout if sout
  process.stdout.write serr if serr

# this will keep the non-minified compiled and joined file updated as files in
# `inFile` change.
task 'watch', 'watch and compile changes in source dir', ->
  watch = exec "coffee -j #{outJS}.js -cw #{strFiles}"
  watch.stdout.on 'data', (data)-> process.stdout.write data

task 'build', 'join and compile *.coffee files', ->
  exec "coffee -j #{outJS}.js -c #{strFiles}", exerr

task 'min', 'minify compiled *.js file', ->
  exec "#{config.uglifier} #{outJS}.js -o #{outJS}.min.js", exerr

task 'bam', 'build and minify', ->
  invoke 'build'
  invoke 'min'

task 'wam', 'watch and compile changes in source dir', ->
  watch = exec "coffee -j #{outJS}.js -cw #{strFiles}"
  watch.stdout.on 'data', (data)->
    invoke 'min'
    process.stdout.write data

