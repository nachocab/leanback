# TODO: create a script to copy a project into a new project.
# TODO: allow brushing and show gene names
# TODO: allow searching by gene_name

class window.VolcanoView extends Backbone.View
    initialize: ->
        @render()
        @model.on "change:currentGeneId", => @updateCurrentGene()
        @model.on "change:clickedGeneId", => @updateClickedGene()
        d3.select("body").on("click", => @resetClickedGenePoint()) # can't be specified as a Backbone event because body is above @el

    events: ->
        "mouseover .gene-point": "updateMousedOverGenePoint"
        "mouseout .gene-point": "updateMousedOutGenePoint"
        "click .gene-point": "updateClickedGenePoint"

    updateMousedOverGenePoint: (e)->
        e.stopPropagation()
        @model.set currentGeneId: d3.select(e.target).attr("name")

    updateMousedOutGenePoint: (e)->
        e.stopPropagation()
        @model.set currentGeneId: null

    updateClickedGenePoint: (e)->
        e.stopPropagation()
        @model.set clickedGeneId: d3.select(e.target).attr("name")

    resetClickedGenePoint: ->
        d3.event.stopPropagation()
        @model.set clickedGeneId: null

    render: ->
        title = @model.numGenes + " " + unescape(@model.get("suffix"))
        d3.select("title").text(title)
        margin =
            top: 50
            right: 50
            bottom: 150
            left: 250
        @width = 600
        @height = 400

        @volcano = d3.select(@el)
            .attr("width", @width + margin.right + margin.left)
            .attr("height", @height + margin.top + margin.bottom)
          .append("g")
            .attr("transform", "translate(#{margin.left},#{margin.top})")

        @x = d3.scale.linear()
            .domain(@model.x_extent)
            .range([0, @width],.2)
        @y = d3.scale.linear()
            .domain([0, d3.max(@model.genes.map((i)->i.y))])
            .range([@height, 0],.2)

        xAxis = d3.svg.axis().scale(@x).tickSize(6,0)
        renderedXAxis = @volcano.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0,#{@height})")
            .call(xAxis)

        yAxis = d3.svg.axis().scale(@y).ticks(4).tickSize(6,0).orient("left")
        renderedYAxis = @volcano.append("g")
            .attr("class", "y axis")
            .attr("transform", "translate(0,0)")
            .call(yAxis)

        # Add y-axis name
        renderedYAxis.append("text")
            .attr("text-anchor", "middle")
            .attr("dy","-.5em")
            .text("-log10 p-value")

        # add y=.005
        @volcano.append("line")
            .attr("x1",@x(@model.x_extent[0]))
            .attr("x2",@x(@model.x_extent[1]))
            .attr("y1",@y(-Math.log(.005)/Math.log(10)))
            .attr("y2",@y(-Math.log(.005)/Math.log(10)))
            .style("stroke-width","1px")
            .style("stroke","red")

        non_significant = _.chain(@model.genes).pluck("y").reject((d)->Math.pow(10,-d)<.005).value()
        @volcano.append("text")
            .attr("x",@x(@model.x_extent[1])-160)
            .attr("y",@y(-Math.log(.005)/Math.log(10))+20)
            .text("#{non_significant.length} below .005 p-value")
            .attr("fill","red")

        @addGenePoints()

        @$(".gene-point").tooltip
            title: ->
                @__data__.gene_name + "<br>" + d3.round(@__data__.x,2)
            placement: "top"

    addGenePoints: ->
        @volcano.selectAll(".gene-point")
            .data(@model.genes)
          .enter().append("circle")
            .attr("class", "gene-point")
            .attr("name", (d,i) => @model.geneIds[i])
            .attr("stroke", "black" )
            .attr("stroke-width", .8 )
            .attr("fill", "steelblue" )
            .attr("fill-opacity", .8 )
            .attr("cx",(d) => @x(d.x))
            .attr("cy",(d) => @y(d.y))
            .attr("r",6)

    updateCurrentGene: ->
        @volcano.selectAll(".gene-point").filter(":not(.clicked)").classed("current",0)

        currentGeneId = @model.get("currentGeneId")
        if currentGeneId?
            currentGene = @volcano.select("[name=#{currentGeneId}]")

            # if no other line is clicked, put current line on top (update z-index)
            if @volcano.select(".clicked").empty()
                currentGene.node().parentNode.appendChild(currentGene.node())

            currentGene.classed("current",1)

            # temporarily hide clicked gene name
            @volcano.selectAll("text.title").filter(".clicked")
                .style("display","none")

            # show current gene name
            modelCurrentGene = @model.getGene(currentGeneId)
            $('#sidebar').html(@getSidebar(modelCurrentGene))
        else
            # show the clicked gene even if there is no current
            clickedGeneId = @model.get("clickedGeneId")
            if clickedGeneId?
                modelClickedGene = @model.getGene(clickedGeneId)
                $('#sidebar').html(@getSidebar(modelClickedGene))

    getSidebar: (gene) ->
        "<h2>#{gene.gene_name}</h2>
            log FC #{d3.round(gene.x,2)}<br>
            p-value #{Math.pow(10,-gene.y).toExponential(2)}"


    updateClickedGene: ->
        clickedGeneId = @model.get("clickedGeneId")
        if clickedGeneId?
            clickedGene = @volcano.select("[name=#{clickedGeneId}]")
            clickedGene.node().parentNode.appendChild(clickedGene.node())

            clickedGene.style("visibility","visible")

            @renderUnclickedGene()
            clickedGene.classed("current clicked",1)

            modelClickedGene = @model.getGene(clickedGeneId)
            $('#sidebar').html(@getSidebar(modelClickedGene))

        else
            @renderUnclickedGene()

    renderUnclickedGene: ->
        @volcano.selectAll(".gene-point").classed("current clicked",0)
        $('#sidebar').html("")

