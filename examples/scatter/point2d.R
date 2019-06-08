library(ggplot2)
library(jsonlite)

data<-fromJSON("https://vega.github.io/editor/data/cars.json")

p<-ggplot(data)+geom_point(aes(x=Horsepower,y=Miles_per_Gallon))
p


{
  "$schema": "https://vega.github.io/schema/vega-lite/v3.json",
  "description": "A scatterplot showing horsepower and miles per gallons for various cars.",
  "data": {"url": "data/cars.json"},
  "mark": "point",
  "encoding": {
    "x": {"field": "Horsepower","type": "quantitative"},
    "y": {"field": "Miles_per_Gallon","type": "quantitative"}
  }
}