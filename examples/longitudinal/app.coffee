
$(document).ready ->
    urlVars = getUrlVars()
    urlVars["path"] = "" if not urlVars["path"]?
    urlVars["groups"] = 0 if not urlVars["groups"]?
    urlVars["clusters"] = 0 if not urlVars["clusters"]?
    urlVars["tags"] = 0 if not urlVars["tags"]?
    urlVars["no_heatmap"] = 0 if not urlVars["no_heatmap"]?
    urlVars["no_gene_names"] = 0 if not urlVars["no_gene_names"]?
    urlVars["no_pcp"] = 0 if not urlVars["no_pcp"]?

    if urlVars["file"]
        inputFile = urlVars["path"] + urlVars["file"]

        # TODO: give warning when the file doesn't exist

        d3.text inputFile, (text) ->
            parsedGenes = d3.csv.parse text

            parsedGenesModel = new window.ParsedGenesModel(parsedGenes)
            parsedGenesModel.set inputFile: inputFile

            parsedGenesModel.set hideHeatmap: urlVars["no_heatmap"]
            parsedGenesModel.set hideGeneNames: urlVars["no_gene_names"]
            parsedGenesModel.set hidePCP: urlVars["no_pcp"]

            parsedGenesModel.set showSuffix: urlVars["suffix"]
            parsedGenesModel.set showGroups: urlVars["groups"]
            parsedGenesModel.set showClusters: urlVars["clusters"]
            parsedGenesModel.set showTags: urlVars["tags"]

            parsedGenesModel.set currentGeneName: null
            parsedGenesModel.set clickedGeneName: null
            parsedGenesModel.set currentCluster: null
            parsedGenesModel.set currentTag: null

            d3.select("body").style("padding-top", d3.select("#dashboard").node().offsetHeight)

            d3.select("body").on "click", => # this can't be specified as a Backbone event because body is above @el
                # d3.event.stopPropagation()
                parsedGenesModel.set clickedGeneName: null
                parsedGenesModel.set currentTag: null
                d3.selectAll(".tag_name").classed("current",0)

                parsedGenesModel.set currentCluster: null
                d3.selectAll(".clusters span").classed("current",0)

            dashboardView = new window.DashboardView(el: "#dashboard", model: parsedGenesModel) # not sure why this needs to go before pcp, but otherwise cluster order changes.
            heatmapView = new window.HeatmapView(el: "#heatmap", model: parsedGenesModel, showTags:urlVars["tags"])
            pcpView = new window.PcpView(el: "#pcp", model: parsedGenesModel)
            # d3.select("body").style("width", "#{d3.max([2200,d3.select("#pcp").node().offsetWidth + d3.select("#heatmap").node().offsetWidth]) + 10}px")
            d3.select("main").style("width", "#{d3.select("#pcp").node().offsetWidth + d3.select("#heatmap").node().offsetWidth + 10}px")
            d3.select("body").style("width", "auto")
    else
        $("body").load("_landing.html")


