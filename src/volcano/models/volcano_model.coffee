 class window.VolcanoModel extends Backbone.Model
    initialize: (parsedFile)->
        @genes = @formatFile(parsedFile)
        @numGenes = @genes.length
        @geneNames = (gene.gene_name for gene in @genes)
        @geneIds = ("gene_#{id}" for id in [1..@numGenes])
        @x_extent = @getXExtent()
        @y_extent = @getYExtent()

    formatFile: (file) ->
        file.map (row) =>
            x: +row.x
            y: +row.y
            gene_name: row.gene_name

    getGene: (geneId)->
        @genes[@geneIds.indexOf(geneId)]

    getXExtent: ->
        x = @genes.map (value)->
            value.x
        d3.extent(x)

    getYExtent: ->
        y = @genes.map (value)->
            value.y
        d3.extent(y)

    getColumnNames: ->
        non_numeric_column_names = /cluster/
        Object.keys(@genes[0]).filter (columnName) =>
            !columnName.match(non_numeric_column_names) && isNumber(@genes[1][columnName])

