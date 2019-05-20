library(tidyverse)
library(jsonlite)
library(vegawidget)

# load a dataset
housing <- read_csv("dataSets/landdata-states.csv")
housing$Home_Value<-housing$Home.Value


# ggplot2-object
gg <- ggplot(housing, aes(x = Home_Value)) +
  geom_histogram(stat = "bin", binwidth=4000)
gg

# ggschame based on ggscheme.json
# The dataset housing is so large. So we ignore the data attribute
ggscheme<-list(
    title="housing",
    width=640,
    height=480,
    data=c(),
    layer=list(
        layer1=list(
            mark=list(
                type="geom_hist"
            ),
            encoding=list(
                x=list(
                    bin=list(
                        bins=30,
                        binwidth=4000
                    ),
                    field="Home_Value",type="numeric",
                    scale=list(domain=c(-1000,1000000))
                ),
                y=list(
                    scale=list(domain=c(-50,1700))
                ),
                weight=list(
                    field=NULL
                )
            )
        )
    )
)

ggscheme<-toJSON(ggscheme)
ggscheme

# vega-lite spec
spec_house <-
  list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    description = "An house example.",
    width=640,
    height=480,
    data = list(values = housing),
    mark = "bar",
    encoding = list(
      x = list(
            bin=list(
                maxbins=30,
                step=4000
            ),
            field = "Home_Value", type = "quantitative",
            axis = list(labelAngle = 0)
        ),
        y=list(
            aggregate = "count", type = "quantitative",
             scale=list(domain="unaggregated")
        )
    )
  ) 

as_vegaspec(spec_house)
  
vlspec<-toJSON(spec_house)
vlspec