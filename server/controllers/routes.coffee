index = require './index'
semantic = require './semantic'

module.exports =

    'progress': get: index.progress

    'images/:doctype/:id/:file': get: index.image

    'semantic/nlp': get: semantic.executeNLP
    'semantic/around': get: semantic.findAround
    'semantic/sparql': post: semantic.executeSparql