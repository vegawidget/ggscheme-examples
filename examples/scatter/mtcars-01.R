# all from CRAN
library("ggplot2")
library("readr")
library("listviewer")
library("vegawidget")
library("jsonlite")

# ggplot2-object
p<-ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) + 
  geom_point()
p
mtcars$'factor(cyl)'=factor(mtcars$cyl)


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
        "y": {"field": "mpg", "type": "quantitative"},
        "colour": {"field": "factor(cyl)", "type": "nominal"}
      }
    }
  ],
  "scales": [],
  "labels": {
    "x": "wt",
    "y": "mpg",
    "colour": "factor(cyl)"
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
    mark = "point",
    encoding = list(
      x = list(
            field = "wt", type = "quantitative",
            scale=list(zero=FALSE,padding=20)
        ),
        y=list(
            field = "mpg", type = "quantitative",
            scale=list(zero=FALSE,padding=20)
        ),
        color = list(field = "factor(cyl)", type = "nominal")
    )
  ) 

as_vegaspec(spec_mtcars)