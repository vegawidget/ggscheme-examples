# all from CRAN
library("ggplot2")
library("readr")
library("listviewer")
library("vegawidget")
library("jsonlite")

# ggplot2-object
p <- ggplot(mtcars, aes(wt, mpg)) + 
    geom_point(colour = "red", size = 3)
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
        "x": {"field": "wt", "type": "quantitative"},
        "y": {"field": "mpg", "type": "quantitative"}
      },
       "aes_params": {
        "colour": {"value": "red"},
        "size":{"value":3}
      }
    }
  ],
  "scales": [],
  "labels": {
    "x": "wt",
    "y": "mpg"
  }
}
')

jsonedit(ggjson,mode='code')

ggjson$data$`data-00`$observations=mtcars

ggspec<-toJSON(ggjson,auto_unbox=TRUE)

write(ggspec,'test.json')

# vega-lite spec
spec_mtcars <-
  list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    data = list(values = mtcars),
    mark = list(
        type="point",
        color="red",
        size=60
    ),
    encoding = list(
      x = list(
            field = "wt", type = "quantitative",
            scale=list(zero=FALSE,padding=20)
        ),
        y=list(
            field = "mpg", type = "quantitative",
            scale=list(zero=FALSE,padding=20)
        )
    )
  ) 

as_vegaspec(spec_mtcars)