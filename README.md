# Leanback

Leanback is a way to visualize longitudinal data interactively

# Motivation
Leanback was built to overcome the limitations of static heatmaps. See my [blog][] for further details

# Usage

    git clone git://github.com/nachocab/leanback.git
    cd leanback
    python -m SimpleHTTPServer 8888 # or your favorite server

Now open in Chrome/Firefox: http://localhost:8888/examples/longitudinal/index.html?groups=1&clusters=1 or look at a [live example][hiv_flu_groups_clusters_live]
![HIV Flu groups clusters](http://nachocab.ruhoh.com/assets/media/images/hiv_flu_groups_clusters.png)]

# URL Parameters

## file=PATH
You can specify any CSV file with a header row. It should have a column containing the names of each row. Columns containing the heatmap values should follow the format: group_timepoint_number (ex: hiv_day_3 or spain_year_2012). Optionally, a column named "cluster" may be added.

http://localhost:8888/examples/longitudinal/index.html?file=../data/hiv_fake_data.csv
[Live example][hiv_file_live]

## clusters=1
If this options is specified, and there is a column named "cluster" in the input file, lines in the parallel coordinate plot will be colored according to its cluster. Clicking on each cluster button will update the heatmap and the parallel coordinates plot accordingly.

http://localhost:8888/examples/longitudinal/index.html?clusters=1
[Live example][hiv_flu_clusters_live]

## tags=PATH
You can optionally specify a file without a header, that presents a comma-separated list of annotations or tags for each row in the heatmap.

http://localhost:8888/examples/longitudinal/index.html?clusters=1&groups=1&tags=../data/hiv_fake_tags.csv
[Live example][hiv_flu_tags_live]
![HIV groups clusters tags](http://nachocab.ruhoh.com/assets/media/images/hiv_groups_clusters_tags.png)]

## groups=1
If this option is specified, and the columns in the input file follow the convention group_timepoint_number, each group will be displayed separately in the parallel coordinates plot.

http://localhost:8888/examples/longitudinal/index.html?clusters=1&groups=1
[Live example][hiv_flu_groups_live]


# JS parameters
Other parameters are set in the code. Take a look at the file: examples/longitudinal/index.html

    var userOptions = { urlVars: urlVars, rowNameColumn: "gene_symbol", rowType: "DE genes" };
    var parsedGenesModel = new window.LongitudinalModel(parsedGenes, userOptions);

urlVars: represents the URL parameters
rowNameColumn: name of the column in the input file that contains the row names. For example: "gene_symbol"
rowType: type of content displayed, used to display in the title. For example: "DE genes" (Differentially Expressed)

# Requirements
Leanback uses [D3.js][d3], [CoffeeScript][coffee], [backbone.js][backbone], [Twitter Bootstrap][bootstrap] and [jQuery][jquery]

# Contributing
This project is at very early stages, so email me with any contributions or thoughts on how to improve it.




[blog]: http://reasoniamhere.com/visualization/interactive-heatmaps-of-longitudinal-data/
[hiv_file_live]: http://nachocab.ruhoh.com/examples/longitudinal/index.html?file=/assets/media/data/hiv_fake_data.csv
[hiv_flu_clusters_live]: http://nachocab.ruhoh.com/examples/longitudinal/index.html?clusters=1
[hiv_flu_groups_clusters_live]: http://nachocab.ruhoh.com/examples/longitudinal/index.html?groups=1&clusters=1
[hiv_flu_tags_live]: http://nachocab.ruhoh.com/examples/longitudinal/index.html?groups=1&clusters=1&tags=/assets/media/data/hiv_fake_tags.csv
[hiv_flu_groups_live]: http://nachocab.ruhoh.com/examples/longitudinal/index.html?groups=1
[d3]: http://d3js.org/
[coffee]: http://coffeescript.org/
[backbone]: http://backbonejs.org/
[bootstrap]: http://twitter.github.com/bootstrap/
[jquery]: http://code.jquery.com/