library(ggplot2)
library(jsonlite)
library(vegawidget)

# ggplot2-object
p<-ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) + 
  geom_point()
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
                type="geom_point"
            ),
            encoding=list(
                x=list(field="wt",type="numeric"),
                y=list(field="wt",type="numeric"),
                color = list(field = "factor(cyl)", type = "factor")
            )
        )
    )
)

ggscheme<-toJSON(ggscheme)
ggscheme

# vega-lite scheme
spec_mtcars <-
  list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    description = "An mtcars example.",
    data = list(values = mtcars),
    mark = "point",
    encoding = list(
      x = list(field = "wt", type = "quantitative"),
      y = list(field = "mpg", type = "quantitative"),
      color = list(field = "cyl", type = "nominal")
    )
  ) 

as_vegaspec(spec_mtcars)
  
vlspec<-toJSON(spec_mtcars)
vlspec