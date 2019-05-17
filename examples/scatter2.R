library(ggplot2)
library(jsonlite)
library(vegawidget)

# ggplot2-object
p <- ggplot(mtcars, aes(wt, mpg)) + 
    geom_point(colour = "red", size = 3)
p

# ggschame based on ggscheme.json
ggscheme<-list(
    title="mtcars",
    width=640,
    height=480,
    data=p$data,
    layer=list(
        layer1=list(
            mark=list(
                type="geom_point",
                color="red",
                size=3
            ),
            encoding=list(
                x=list(
                    field="wt",type="numeric",
                    scale=list(domain=c(1.32,5.62))
                ),
                y=list(
                    field="mpg",type="numeric",
                    scale=list(domain=c(9.22,35.07))
                )
            )
        )
    )
)

ggscheme<-toJSON(ggscheme)
ggscheme

# vega-lite spec
spec_mtcars <-
  list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    description = "An mtcars example.",
    data = list(values = mtcars),
    mark = list(
        type="point",
        color="red",
        size=c(3)
    ),
    encoding = list(
        x = list(
            field = "wt", type = "quantitative",
            scale=list(domain=c(1.32,5.62))
        ),
        y=list(
            field = "mpg", type = "quantitative",
            scale=list(domain=c(9.22,35.07))
        )
    )
  )

as_vegaspec(spec_mtcars)
  
vlspec<-toJSON(spec_mtcars)
vlspec