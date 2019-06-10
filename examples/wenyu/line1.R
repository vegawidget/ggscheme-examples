library(ggplot2)
library(jsonlite)
library(vegawidget)

# load a dataset
df <- data.frame(supp=rep(c("VC", "OJ"), each=3),
                dose=rep(c("D0.5", "D1", "D2"),2),
                len=c(106.8, 115, 133, 104.2, 110, 129.5))
df

# ggplot2-object
gg<-ggplot(df, aes(x=dose, y=len, group=supp)) +
  geom_line(aes(color=supp))+
  geom_point()
gg

# ggschame based on ggscheme.json
ggscheme<-list(
    title="df",
    width=640,
    height=480,
    data=df,
    layer=list(
        layer1=list(
            mark=list(
                type="geom_line"
            ),
            encoding=list(
                x=list(
                    field="dose",type="character"
                ),
                y=list(
                    field="len",type="numeric",
                    scale=list(domain=c(102.76,134.44))
                ),
                color=list(
                    field="supp", type="character"
                )
            )
        ),
        layer2=list(
            mark=list(
                type="geom_point",
                filled=TRUE
            ),
            encoding=list(
                x=list(
                    field="dose",type="character"
                ),
                y=list(
                    field="len",type="numeric",
                    scale=list(domain=c(102.76,134.44))
                )
            )
        )
        
    )
)

ggscheme<-toJSON(ggscheme,auto_unbox=TRUE)
write(ggscheme,'test.json')
  
# vega-lite spec
spec_df<-list(
    `$schema`= vega_schema(), # specifies Vega-Lite
    description = "An df example.",
    width=640,
    height=480,
    data = list(values = df),
    layer=list(
        list(
        mark = "line",
        encoding = list(
            x = list(
                field = "dose", type = "nominal",
                axis = list(labelAngle = 0)
            ),
            y=list(
                field = "len", type = "quantitative",
                scale=list(domain=c(102.76,134.44))      
            ),
            color=list(
                field="supp", type = "nominal"  
            )
        )),
        list(
            mark=list(
                type="point",
                filled=TRUE
            ),
            encoding = list(
            x = list(
                field = "dose", type = "nominal",
                axis = list(labelAngle = 0)
            ),
            y=list(
                field = "len", type = "quantitative",
                scale=list(domain=c(102.76,134.44))       
            )
        )
        )
    )
    
)

as_vegaspec(spec_df)
  
vlspec<-toJSON(spec_df)
vlspec