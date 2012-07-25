 class window.ParsedGenesModel extends Backbone.Model
    initialize: (parsedGenes)->
        @parsedGenes = parsedGenes # array of objects with column names as properties
        @geneSymbols = _.pluck(@parsedGenes, "gene_symbol")
        @geneNames = ("gene_#{id}" for id in [1..(@parsedGenes.length)])
        @columnNames = @getColumnNames()
        @columnGroups = @getColumnGroups()

        @geneExpressions = @getGeneExpressions()
        @groupedGeneExpressions = @getGroupedGeneExpressions()

        @clusters = _.pluck(@parsedGenes, "cluster")
        @clusterNames = @getClusterNames()

    getGeneSymbol: (geneName)->
        @geneSymbols[@geneNames.indexOf(geneName)]

    getColumnGroups: ->
        _.chain(@columnNames).map((columnName)-> columnName.split("_")[0]).uniq().value()

    getExtent: ->
        expressions = _.flatten(@geneExpressions.map (geneExpression)->
            geneExpression.map (item)->
                item.geneExpression
        )
        d3.extent(expressions)

    getColumnNames: ->
        specialColumnNames = /cluster|gene_symbol/

        # we look at the first object and assume every other object will have the same column names
        _.keys(@parsedGenes[0]).filter (columnName) =>
            !columnName.match specialColumnNames

    # Returns an object for each gene, with two properties: condition and geneExpression
    getGeneExpressions: ->
        @parsedGenes.map (gene) =>
            @columnNames.map (columnName) ->
                condition: columnName
                geneExpression: +gene[columnName] # make numeric

    # TODO refactor
    getGroupedGeneExpressions: ->
        @parsedGenes.map (gene) =>
            columnGroups = @columnGroups.slice(0); # to avoid @columnGroups.shift!()
            currentGroup = columnGroups.shift()

            expressions = []
            @columnNames.map (columnName) =>
                # add a null datapoint when changing column groups
                unless columnName.match ///^#{currentGroup}_///
                    expressions.push {condition: "", geneExpression: null}
                    currentGroup = columnGroups.shift()
                expressions.push {condition: columnName, geneExpression: +gene[columnName]}

            expressions

    # cluster names sorted by descending frequency of genes
    getClusterNames: ->
        clusterFrequencies = window.getFrequencies(@clusters)
        _.chain(clusterFrequencies).keys().sortBy((x)-> clusterFrequencies[x]).value().reverse()

    getTagFile: ->
        # TODO: make this a URL parameter
        "fake_tags.txt"
