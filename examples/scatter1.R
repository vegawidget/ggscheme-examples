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
                x=list(
                    field="wt",type="numeric",
                    scale=list(domain=c(1.32,5.62))
                ),
                y=list(
                    field="mpg",type="numeric",
                    scale=list(domain=c(9.22,35.07))
                ),
                color = list(field = "factor(cyl)", type = "factor")
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
    width=640,
    height=480,
    data = list(values = mtcars),
    mark = "point",
    encoding = list(
      x = list(
            field = "wt", type = "quantitative",
            scale=list(domain=c(1.32,5.62))
        ),
        y=list(
            field = "mpg", type = "quantitative",
            scale=list(domain=c(9.22,35.07))
        ),
        color = list(field = "cyl", type = "nominal")
    )
  ) 

as_vegaspec(spec_mtcars)
  
vlspec<-toJSON(spec_mtcars)
vlspec