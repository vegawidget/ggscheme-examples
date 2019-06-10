library(ggplot2)
library(jsonlite)
library(vegawidget)

# ggplot2-object
p<-ggplot(mpg, aes(class)) + geom_bar(aes(weight = displ,fill = drv))
p

# ggschame based on ggscheme.json
# The dataset diamond is so large. So we ignore the data attribute
ggscheme<-list(
    title="mpg",
    width=640,
    height=480,
    data=mpg,
    layer=list(
        layer1=list(
            mark=list(
                type="geom_bar"
            ),
            encoding=list(
                x=list(
                    field="class",type="character",
                    scale=list(domain=c(1.32,5.62))
                ),
                y=list(
                    scale=list(domain=c(-3.1,65.1))
                ),
                weight=list(
                    field="displ"
                ),
                fill=list(
                    field="drv"
                )
            )
        )
    )
)

ggscheme<-toJSON(ggscheme,auto_unbox=TRUE)
write(ggscheme,"test.json")

# vega-lite spec
spec_mtcars <-
  list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    description = "An mpg example.",
    width=640,
    height=480,
    data = list(values = mpg),
    mark = "bar",
    encoding = list(
      x = list(
            field = "class", type = "nominal",
            axis = list(labelAngle = 0)
        ),
        fill=list(
            field="drv"
        ),
        y=list(
            aggregate = "sum",
            field="displ",
            type = "quantitative",
            scale=list(domain="unaggregated")
        )
    )
  ) 

as_vegaspec(spec_mtcars)
  
vlspec<-toJSON(spec_mtcars)
vlspec