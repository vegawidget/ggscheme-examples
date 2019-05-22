library(ggplot2)
library(jsonlite)
library(vegawidget)

# ggplot2-object
p<-ggplot(diamonds, aes(carat, price))+ geom_point(alpha=1/100)
p

# ggschame based on ggscheme.json
# The dataset diamond is so large. So we ignore the data attribute
ggscheme<-list(
    title="diamonds",
    width=640,
    height=480,
    data=diamonds,
    layer=list(
        layer1=list(
            mark=list(
                type="geom_point",
                opacity=1/100
            ),
            encoding=list(
                x=list(
                    field="carat",type="numeric",
                    scale=list(domain=c(0,5))
                ),
                y=list(
                    field="price",type="int",
                    scale=list(domain=c(0,20000))
                )
            )
        )
    )
)

ggscheme<-toJSON(ggscheme,auto_unbox=TRUE)
ggscheme
write(ggscheme,file="test.json")


# vega-lite spec
spec_diamonds <-
  list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    description = "An diamonds example.",
    width=640,
    height=480,
    data = list(values = diamonds),
    mark = list(
        type="point",
        opacity=1/100
    ),
    encoding = list(
      x = list(
            field = "carat", type = "quantitative",
            scale=list(domain=c(-0.04,5.25))
        ),
        y=list(
            field = "price", type = "quantitative",
            scale=list(domain=c(-598.85,19747.85))

        )
    )
  ) 

as_vegaspec(spec_diamonds)
  
vlspec<-toJSON(spec_diamonds)
vlspec