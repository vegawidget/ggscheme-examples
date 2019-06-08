library(ggplot2)
library(jsonlite)

data<-fromJSON('https://vega.github.io/editor/data/cars.json')

p<-ggplot(data)+geom_point(aes(x=Horsepower,y=Miles_per_Gallon))+
  theme(panel.background = element_rect(fill = "Orange"))
p









{
  "$schema": "https://vega.github.io/schema/vega-lite/v3.json",
  "description": "A scatterplot with orange overall background and yellow view background.",
  "background": "orange",
  "view": {"fill": "yellow"},
  "data": {"url": "data/cars.json"},
  "mark": "point",
  "encoding": {
    "x": {"field": "Horsepower", "type": "quantitative"},
    "y": {"field": "Miles_per_Gallon", "type": "quantitative"}
  }
}