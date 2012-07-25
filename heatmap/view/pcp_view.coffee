class window.PcpView extends Backbone.View
    initialize: ->
        unless @model.get("hidePCP")
            @render()

            # model changes that update the view
            @model.on "change:currentGeneName", => @showCurrentGeneName()
            @model.on "change:clickedGeneName", => @showClickedGeneName()
            @model.on "change:currentCluster", => @showCurrentCluster()
            @model.on "change:currentTag", => @showCurrentTag()

    events: ->
        # mouse events that change the model
        "mouseover .expression-line": "changeCurrentGeneName"
        "mouseout .expression-line": "changeCurrentGeneName"
        "click .expression-line": "changeClickedGeneName"

        # mouse events that update the view
        "click .expression-point": "showExpressionPointText"

    render: ->
        @columnNamesMargin = d3.max(columnName.length for columnName in @model.columnNames)
        @margin =
            top: 300
            right: 50
            bottom: @columnNamesMargin*10
            left: 150
        @width = d3.max([400,@model.columnNames.length*40])
        @height = 300

        @pcp = d3.select(@el)
            .attr("width", @width + @margin.right + @margin.left)
            .attr("height", @height + @margin.top + @margin.bottom)
          .append("g")
            .attr("transform", "translate(#{@margin.left},#{@margin.top})")

        @x = d3.scale.ordinal()
            .domain(@model.columnNames)
            .rangePoints([0, @width],.2)
        @y = d3.scale.linear()
            .domain(@model.getExtent())
            .range([@height, 0],.2)

        @line = d3.svg.line()
            .defined((d) => _.isFinite(d.geneExpression)) # skip null and NaN specific to d3.line, useful to determine which elements are not defined
            .x((d) => @x(d.condition))
            .y((d) => @y(d.geneExpression))

        @xAxis = d3.svg.axis().scale(@x).tickSize(6,0)
        @renderedXAxis = @pcp.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0,#{@height})")
            .call(@xAxis)

        # rotate x-axis labels
        @renderedXAxis.selectAll("text")
            .attr("dx", "-.5em")
            .attr("dy", ".3em")
            .attr("text-anchor", "end")
            .attr("transform","rotate(-45)")

        @yAxis = d3.svg.axis().scale(@y).ticks(4).tickSize(6,0).orient("left")
        @renderedYAxis = @pcp.append("g")
            .attr("class", "y axis")
            .attr("transform", "translate(0,0)")
            .call(@yAxis)

        # Add y-axis name
        @renderedYAxis.append("text")
            .attr("text-anchor", "middle")
            .attr("dy","-.5em")
            .text("log-ratio")

        @addGeneExpressionLines()

        # Add y=0 line
        @pcp.append("line")
            .attr("y1", @y(0))
            .attr("y2", @y(0))
            .attr("x2", @width)
            .attr("class","axis zero")

    addGeneExpressionLines: ->
        @pcp.selectAll(".expression-line")
            .data(@getGeneExpressions()) # we use this instead of @model.geneExpressions because we need groupedGeneExpressions when "showGroups" is passed as a URL parameter
          .enter().append("path")
            .attr("class", "expression-line")
            .attr("name", (d,i)=> @model.geneNames[i])
            .attr("stroke", "steelblue" )
            .attr("stroke-opacity", .5)
            .attr("d", @line)

        if @model.get("showClusters")
            @pcp.selectAll(".expression-line")
                .attr("cluster", (d,i) => @model.clusters[i])
                .attr("stroke", (d,i) => window.clusterColor(@model.clusters[i]))

    getGeneExpressions: ->
        if @model.get("showGroups")
            @model.groupedGeneExpressions
        else
            @model.geneExpressions

    changeCurrentGeneName: (e)->
        e.stopPropagation()
        @model.set currentGeneName: if e.type=="mouseover" then d3.select(e.target).attr("name") else null

    changeClickedGeneName: (e)->
        e.stopPropagation()
        @model.set clickedGeneName: d3.select(e.target).attr("name")

    showExpressionPointText: (e) ->
        e.stopPropagation()
        d = e.target.__data__

        @pcp.append("text")
            .attr("class", "expression-text")
            .attr("x", @x(d.condition))
            .attr("y", @y(d.geneExpression))
            .attr("text-anchor","middle")
            .attr("dy", "-.8em")
            .text(d3.round(d.geneExpression,2))

    showCurrentGeneName: ->
        # the currentGeneName has changed, so we de-highlight every non-clicked gene
        @pcp.selectAll(".expression-line").filter(":not(.clicked)").classed("current",0)

        # remove any previous current titles (except the previously clicked gene, since we hide it)
        @pcp.selectAll("text.title").filter(":not(.clicked)").remove()

        currentGeneName = @model.get("currentGeneName")
        if currentGeneName?
            currentGene = @pcp.select("[name=#{currentGeneName}]")
            currentGene.classed("current",1)

            # if no other line is clicked, put current line on top (update z-index)
            if @pcp.select(".clicked").empty()
                currentGene.node().parentNode.appendChild(currentGene.node())

            # temporarily hide previously clicked gene title
            @pcp.selectAll("text.title").filter(".clicked").style("display","none")

            # show current gene title
            @pcp.append("text")
                .attr("class", "title")
                .attr("x", @width/2)
                .attr("y", -40)
                .attr("text-anchor","middle")
                .text(@model.getGeneSymbol(currentGeneName))
        else
            # Show gene title of the previously clicked gene
            @pcp.selectAll("text.title").filter(".clicked").style("display","block")

    showClickedGeneName: ->
        clickedGeneName = @model.get("clickedGeneName")
        if clickedGeneName?
            clickedGene = @pcp.select("[name=#{clickedGeneName}]")

            # clicked genes always go to the top
            clickedGene.node().parentNode.appendChild(clickedGene.node())

            # remove any previous clicked genes
            @removeClickedGeneName()

            clickedGene.classed("current clicked",1)
            data = clickedGene.node().__data__

            # show gene expression points on clicked line
            @pcp.selectAll(".expression-point")
                .data(data.filter((d)-> _.isFinite(d.geneExpression))) # skip null and NaN
              .enter().append("circle")
                .attr("class", "expression-point")
                .attr("cx", @line.x()) # use the line.x() accessor to set the cx parameter
                .attr("cy", @line.y())
                .attr("r", 5)

            # write gene expression values on clicked line
            @pcp.selectAll(".expression-text")
                .data(data.filter(@filterTextDatapoints))
              .enter().append("text")
                .attr("class", "expression-text")
                .attr("x", @line.x())
                .attr("y", @line.y())
                .attr("text-anchor","middle")
                .attr("dy", "-.8em")
                .text((d,i) -> d3.round(d.geneExpression,2))

            # we know the title exists because it was created on mouseover
            @pcp.select("text.title")
                .classed("clicked",1)
                .text(@model.getGeneSymbol(clickedGeneName))

        else
            # clicked background
            @removeClickedGeneName()

    filterTextDatapoints: (item,i,arr) ->
        significantDifference = .5

        (i == 0 and _.isFinite(item.geneExpression)) or # first of all groups and not null or NaN
        ((i == arr.length - 1) and _.isFinite(item.geneExpression)) or # last of all groups and not null or NaN
        (arr[i-1].geneExpression == null and _.isFinite(item.geneExpression)) or # preceded by a null, so first in group and not null or NaN
        (arr[i+1].geneExpression == null and _.isFinite(item.geneExpression)) or # followed by a null and not null or NaN
        (_.isFinite(item.geneExpression) and item.geneExpression > arr[i-1].geneExpression and item.geneExpression > arr[i+1].geneExpression and ( Math.abs(item.geneExpression - arr[i-1].geneExpression) > significantDifference or Math.abs(item.geneExpression - arr[i+1].geneExpression) > significantDifference)) or
        (_.isFinite(item.geneExpression) and item.geneExpression < arr[i-1].geneExpression and item.geneExpression < arr[i+1].geneExpression and ( Math.abs(item.geneExpression - arr[i-1].geneExpression) > significantDifference or Math.abs(item.geneExpression - arr[i+1].geneExpression) > significantDifference))

    removeClickedGeneName: ->
        @pcp.selectAll(".expression-point").remove()
        @pcp.selectAll(".expression-text").remove()
        @pcp.selectAll(".expression-line").classed("current clicked",0)
        @pcp.select("text.title").text("")

    showCurrentCluster: ->
        currentCluster = @model.get("currentCluster")

        d3.select("#pcp").style("top", d3.select("body").node().scrollTop)

        if currentCluster
            # grey out non-current cluster genes
            @pcp.selectAll(".expression-line").attr("stroke","#999")

            @pcp.selectAll(".expression-line[cluster='#{currentCluster}']")
                .attr("stroke", (d,i) => window.clusterColor(currentCluster) )
                .each( -> this.parentNode.appendChild(this) )
        else
            @pcp.selectAll(".expression-line").remove()
            @addGeneExpressionLines() # we redo the whole thing because we changed gene order, so the clusters don't match

    showCurrentTag: ->
        currentTag = @model.get("currentTag")

        # we move it up because it makes no sense to stay at current scrollHeight if the number of genes with the currentTag is much smaller.
        d3.select("#pcp").style("top", 0)
        scroll(0,0)

        # TODO: undo any cluster selection when clicking on a tag

        if currentTag
            # @model.set currentCluster: "all"
            taggedGeneNames = _(d3.selectAll("#heatmap .row")).chain().first() # select all rows
                                .filter((d) ->d.style.display != "none") # keep those that are visible
                                .map((d)-> d3.select(d).attr("name")).value() # collect the names: gene_1, gene_3, ...

            # color lines with tagged genes
            @pcp.selectAll(".expression-line")
                .attr("stroke","#999") # grey out all lines
                .filter((d,i) -> _.include(taggedGeneNames, (d3.select(this).attr("name")))) # select lines with tagged genes
                .attr("stroke", (d,i) -> window.clusterColor(d3.select(this).attr("cluster"))) # color them based on their cluster
                .each( -> this.parentNode.appendChild(this) ) # update their z-index
        else
            # unselected currentTag
            @pcp.selectAll(".expression-line").remove()
            @addGeneExpressionLines() # we redo the whole thing because we changed gene order, so the clusters don't match



