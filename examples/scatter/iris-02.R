# all from CRAN
library("ggplot2")
library("readr")
library("listviewer")
library("vegawidget")
library("jsonlite")

# iris$Petal.Length=iris$Petal.Length+10
iris
# ggplot2-object
p <-
  ggplot(iris) +
  geom_point(aes(x = Petal.Width, y = Petal.Length, color = Species)) + 
  labs(
    title = "Hello World"
  )

p

names(p)
p$layers[[1]][["data"]]
str(p$layers[[1]][["geom"]])
str(p$layers[[1]][["mapping"]])
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
        "x": {"field": "Petal.Width", "type": "quantitative"},
        "y": {"field": "Petal.Length", "type": "quantitative"},
        "colour": {"field": "Species", "type": "nominal"}
      }
    }
  ],
  "scales": [],
  "labels": {
    "title": "Hello World",
    "x": "Petal.Width",
    "y": "Petal.Length",
    "colour": "Species"
  }
}
')

jsonedit(ggjson,mode='code')

ggjson$data$`data-00`$observations=iris

ggspec<-toJSON(ggjson,auto_unbox=TRUE)

write(ggspec,'test.json')

# vega-lite spec
spec_iris <-
list(
    `$schema` = vega_schema(), # specifies Vega-Lite
    title="Hello World",
    data = list(values = iris),
    mark =list(
        type="point"
    ),
    encoding = list(
      x = list(
            field = "Petal\\.Width", type = "quantitative"
        ),
        y=list(
            field = "Petal\\.Length", type = "quantitative"
        ),
        colour=list(
            field="Species",type="nominal"
        )
    )
)

as_vegaspec(spec_iris)
  
vlspec<-toJSON(spec_iris)
vlspec