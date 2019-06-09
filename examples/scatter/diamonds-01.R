# all from CRAN
library("ggplot2")
library("readr")
library("listviewer")
library("vegawidget")
library("jsonlite")

# ggplot2-object
p<-ggplot(diamonds, aes(carat, price))+ geom_point(alpha=1/100)
p


names(p)
p$layers[[1]][["data"]]
str(p$layers[[1]][["geom"]])
str(p$mapping)
str(p$layers[[1]]$aes_params)
str(p$scales$scales)
str(p$scales$scales[[1]]$trans)
p$scales$scales[[1]]$trans$transform
ls(environment(p$scales$scales[[1]]$trans$transform))
environment(p$scales$scales[[1]]$trans$transform)$base
str(p$labels)



# ggspec
ggjson<-fromJSON('
{
  "data": {
    "data-00": {
      "metadata": {},
      "observations": [{}, {}]
    }
  },
  "layers": [
    {
      "data": "data-00",
      "geom": {"class": "GeomPoint"},
      "mapping": {
        "x": {"field": "carat", "type": "quantitative"},
        "y": {"field": "price", "type": "quantitative"}
      },
       "aes_params": {
        "alpha":{"value":0.01}
      }
    }
  ],
  "scales": [],
  "labels": {
    "x": "carat",
    "y": "price"
  }
}
')

jsonedit(ggjson,mode='code')

ggjson$data$`data-00`$observations=diamonds

ggspec<-toJSON(ggjson,auto_unbox=TRUE)

write(ggspec,'test.json')



# vega-lite spec
spec_diamonds <-
  list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    data = list(values = diamonds),
    mark = list(
        type="point",
        opacity=1/100
    ),
    encoding = list(
      x = list(
            field = "carat", type = "quantitative",
            scale=list(zero=FALSE,padding=20)
        ),
        y=list(
            field = "price", type = "quantitative",
            scale=list(zero=FALSE,padding=20)
        )
    )
  ) 

as_vegaspec(spec_diamonds)