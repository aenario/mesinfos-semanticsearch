{exec} = require 'child_process'
fs     = require 'fs'
logger = require('printit')
            date: false
            prefix: 'cake'

option '-f', '--file [FILE*]' , 'List of test files to run'
option '-d', '--dir [DIR*]' , 'Directory of test files to run'
option '-e' , '--env [ENV]', 'Run tests with NODE_ENV=ENV. Default is test'

options =  # defaults, will be overwritten by command line options
    file        : no
    dir         : no

# Grab test files of a directory recursively
walk = (dir, excludeElements = []) ->
    fileList = []
    list = fs.readdirSync dir
    if list
        for file in list
            if file and file not in excludeElements
                filename = "#{dir}/#{file}"
                stat = fs.statSync filename
                if stat and stat.isDirectory()
                    fileList2 = walk filename, excludeElements
                    fileList = fileList.concat fileList2
                else if filename.substr(-6) is "coffee"
                    fileList.push filename
    return fileList

taskDetails = '(default: ./tests, use -f or -d to specify files and directory)'
task 'tests', "Run tests #{taskDetails}", (opts) ->
    logger.options.prefix = 'cake:tests'
    files = []
    options = opts

    if options.dir
        dirList   = options.dir
        files = walk(dir, files) for dir in dirList
    if options.file
        files  = files.concat options.file
    unless options.dir or options.file
        files = walk "tests"

    env = if options['env'] then "NODE_ENV=#{options.env}" else "NODE_ENV=test"
    env += " DB_NAME=cozy_test AXON_PORT=9223"
    logger.info "Running tests with #{env}..."
    command = "#{env} mocha " + files.join(" ") + " --reporter spec --colors "
    command += "--compilers coffee:coffee-script/register"
    exec command, (err, stdout, stderr) ->
        console.log stdout
        if err
            logger.error "Running mocha caught exception:\n" + err
            process.exit 1
        else
            logger.info "Tests succeeded!"
            process.exit 0

task 'tests-client-e2e', "Run client, test", ->
    exec "karma start client/test/karma-e2e.conf.js", (err, stdout, stderr) ->
        console.log stdout
        if err
            logger.error "Running mocha caught exception:\n" + err
            console.log stderr
            process.exit 1
        else
            logger.info "Tests succeeded!"
            process.exit 0

task 'tests-client', "Run client, test", ->
    exec "start client/test/karma.conf.js", (err, stdout, stderr) ->
        console.log stdout
        if err
            logger.error "Running mocha caught exception:\n" + err
            console.log stderr
            process.exit 1
        else
            logger.info "Tests succeeded!"
            process.exit 0


task "coverage", "Generate code coverage of tests", ->
        logger.options.prefix = 'cake:coverage'
        files = walk "tests"

        logger.info "Generating instrumented files..."
        bin = "./node_modules/.bin/coffeeCoverage --path abbr"
        command = "mkdir instrumented && " + \
                  "#{bin} server.coffee instrumented/server.js && " + \
                  "#{bin} server instrumented/server"
        exec command, (err, stdout, stderr) ->

            if err
                logger.error err
                cleanCoverage -> process.exit 1
            else
                logger.info "Instrumented files generated."
                env = "COVERAGE=true NODE_ENV=test " + \
                      "DB_NAME=cozy_test AXON_PORT=9223"
                command = "#{env} mocha tests/ " + \
                          "--compilers coffee:coffee-script/register " + \
                          "--reporter html-cov > coverage/coverage.html"
                logger.info "Generating code coverage..."
                exec command, (err, stdout, stderr) ->
                    if err
                        logger.error err
                        cleanCoverage -> process.exit 1
                    else
                        cleanCoverage ->
                            logger.info "Code coverage generation succeeded!"
                            process.exit 0

# use exec-sync npm module and use "invoke" in other tasks
cleanCoverage = (callback) ->
    logger.info "Cleaning..."
    command = "rm -rf instrumented"
    exec command, (err, stdout, stderr) ->
        if err
            logger.error err
            callback err
        else
            logger.info "Cleaned!"
            callback()

task "clean-coverage", "Clean the files generated for coverage report", ->
    cleanCoverage (err) ->
        if err
            process.exit 1
        else
            process.exit 0


task "lint", "Run Coffeelint", ->
    logger.options.prefix = 'cake:lint'
    logger.info 'Start linting...'
    command = "coffeelint -f coffeelint.json -r server/"
    exec command, (err, stdout, stderr) ->
        if err
            logger.error err
        else
            console.log stdout

task 'build', 'Build CoffeeScript to Javascript', ->
    logger.options.prefix = 'cake:build'
    logger.info "Start compilation..."
    command = "coffee -cb --output build/server server && " + \
              "coffee -cb --output build/ server.coffee"
    exec command, (err, stdout, stderr) ->
        if err
            logger.error "An error has occurred while compiling:\n" + err
            process.exit 1
        else
            logger.info "Compilation succeeded."
            process.exit 0