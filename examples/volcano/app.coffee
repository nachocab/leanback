$(document).ready ->
    urlVars = getUrlVars()
    urlVars["path"] = "" if not urlVars["path"]?
    urlVars["suffix"] = "genes" if not urlVars["suffix"]?

    if urlVars["file"]
        file = urlVars["path"] + urlVars["file"]
        d3.text file, (text) ->
            parsedFile = d3.csv.parse text

            volcanoModel = new window.VolcanoModel(parsedFile)
            volcanoModel.set suffix: urlVars["suffix"]
            volcanoView = new window.VolcanoView(el: "#volcano", model: volcanoModel)
    else
        $('body').text("Please provide an input file")

