module.exports = 
    entry: "./src/index.litcoffee"
    output:
        path: "dist"
        filename: "[hash].js"
        hash: true
    module:
        loaders: [
                    test: /\.png$/
                    loader: "file-loader"
                ,
                    test: /\.vs$/
                    loader: "raw-loader"
                ,
                    test: /\.fs$/
                    loader: "raw-loader"
                ,
                    test: /\.coffee$/
                    loader: "coffee-loader"
                ,
                    test: /\.litcoffee$/
                    loader: "coffee-loader?literate"
                ,
                    test: /\.sass$/
                    loader: (require "extract-text-webpack-plugin").extract "style-loader", "css-loader!sass-loader?indentedSyntax"
                ,
                    test: /\.msc$/
                    loader: "file-loader"
                ,
                    test: /\.msn$/
                    loader: "file-loader"
            ]
    plugins: [
                new (require "webpack-cleanup-plugin")
                    exclude: ["index.html"]
            ,
                new (require "extract-text-webpack-plugin") "[hash].css"
            ,
                new (require "html-webpack-plugin")
                    templateContent: (templateParams, compilation) ->
                        require("jade").renderFile "./src/index.jade", templateParams
        ]