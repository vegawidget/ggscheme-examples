First components of the ggspec function
================

-----

<br/>

**Initial plan of attack**:

Start with small, simple components to extract certain elements we need.
Then work to combine these components to build the full ggspec.

<br/>

**Notes**:

Still need to do quite a bit of work with the functions for the data,
but I feel the functions for the layers are coming along nicely.

<br/>

-----

## Extracting elements

<br/>

``` r
p <- ggplot(iris) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length)) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length), color = "firebrick") +
  scale_y_log10() 

p
```

![](01-ggspec-components_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

<br/>

-----

### Extracting data

**Proposal**: Save the data at top-level and then have a reference to
the appropriate data within the layers as such:

    {
      "data": {
        "data-00": {
          "metadata": {},
          "observations": [{}, {}]
        }
      }
    }

<br/>

The first move will be to create the list `data` where all of the data
will live. We create the list when extracting the default data and then
add to it when dealing with the layers.

**Default data**:

``` r
## How to make this applicable to multiple factors?
## How to have this only run IF a factor is detected?

create_meta <- function(dat){
  loc <- purrr::detect_index(dat, is.factor)
  levels <- purrr::pluck(dat, loc, levels)
  meta <- list(levels) ## How to evaluate the name first??
  names(meta) <- names(dat)[loc]
  meta
}

get_data_default <- function(p){
  dat00 <- purrr::pluck(p, "data")
  meta <- create_meta(dat00)
  dat00 <- list(
    observations = jsonlite::toJSON(dat00), 
    metadata = meta
  )
  list(`data-00` = dat00)
}
```

``` r
data <- get_data_default(p)
str(data)
```

    ## List of 1
    ##  $ data-00:List of 2
    ##   ..$ observations: 'json' chr "[{\"Sepal.Length\":5.1,\"Sepal.Width\":3.5,\"Petal.Length\":1.4,\"Petal.Width\":0.2,\"Species\":\"setosa\"},{\""| __truncated__
    ##   ..$ metadata    :List of 1
    ##   .. ..$ Species: chr [1:3] "setosa" "versicolor" "virginica"

<br/>

**Layer data**:

(THIS NEEDS WORK)

Do we need both a `get_data_layers` that collects all data other than
the default data and a `get_layer_data` which saves the reference to
which data is to be used?

`get_data_layers()` should then ammend the `data` list created by the
previous function.

``` r
get_data_layers <- function(ind) {
  # How to add in check that it isn't NULL ??
  data[[ind+1]] <- purrr::pluck(p, "layers", ind, "data") #, .default = `data-00`)
} 

## will then need to run additional functions to get name and create metadata
```

<br/>

-----

### Extracting layers

<br/>

Within each layer-object, we need:  
1\. data (a reference id?)  
2\. geom  
3\. geom\_params (maybe) 4. mapping  
5\. aes\_params  
6\. stat (maybe)  
7\. stat\_params (maybe)

<br/>

**The data**

(THIS NEEDS WORK)

`get_layer_data()` should save an id to reference which data source from
the top-level data should be used.

How to extract a name for the dataset??

``` r
get_layer_data <- function(ind) {
  # How to extract a name for the dataset??
  data <- purrr::pluck(p, "layers", ind, "data", .default = "data-00")
} 
```

<br/>

**The geom**:

``` r
get_layer_geom <- function(ind){
  list(
    class = purrr::pluck(p, "layers", ind, "geom", class)
  )
}
```

``` r
str(get_layer_geom(1))
```

    ## List of 1
    ##  $ class: chr [1:4] "GeomPoint" "Geom" "ggproto" "gg"

<br/>

**The geom parameters**:

<br/>

**The mapping**:

``` r
get_layer_mapping_vars <- function(aes, ind) {
  field = purrr::pluck(p, "layers", ind, "mapping", aes, rlang::get_expr)
  type = NULL
  list(field = field, type = type)
}

get_layer_mapping <- function(ind){
  map_names <- purrr::pluck(p, "layers", ind, "mapping", names)
  mapping <- as.list(map_names)
  names(mapping) <- map_names
  map(mapping, get_layer_mapping_vars, ind)
}
```

``` r
str(get_layer_mapping(2))
```

    ## List of 2
    ##  $ x:List of 2
    ##   ..$ field: symbol Petal.Width
    ##   ..$ type : NULL
    ##  $ y:List of 2
    ##   ..$ field: symbol Petal.Length
    ##   ..$ type : NULL

**Question**: Do we need to save the environment with the symbol?

<br/>

**The aesthetic parameters**:

``` r
get_layer_aes_params <- function(ind){
  purrr::pluck(p, "layers", ind, "aes_params")
}
```

``` r
str(get_layer_aes_params(2))
```

    ## List of 1
    ##  $ colour: chr "firebrick"

<br/>

**The stat**:

For right now, we will just extract the class.

``` r
get_layer_stat <- function(ind){
  list(
    class = purrr::pluck(p, "layers", ind, "stat", class)
  )
}
```

``` r
str(get_layer_stat(2))
```

    ## List of 1
    ##  $ class: chr [1:4] "StatIdentity" "Stat" "ggproto" "gg"

<br/>

**The stat parameters**:

<br/>

-----

#### Putting the layers together

``` r
get_layers <- function(ind){
  list(
    data = get_layer_data(ind),
    geom = get_layer_geom(ind),
    geom_params = list(),
    mapping = get_layer_mapping(ind),
    aes_params = get_layer_aes_params(ind),
    stat = get_layer_stat(ind),
    stat_params = list()
  )
}

str(map(1:2, get_layers))
```

    ## List of 2
    ##  $ :List of 7
    ##   ..$ data       : chr "data-00"
    ##   ..$ geom       :List of 1
    ##   .. ..$ class: chr [1:4] "GeomPoint" "Geom" "ggproto" "gg"
    ##   ..$ geom_params: list()
    ##   ..$ mapping    :List of 2
    ##   .. ..$ x:List of 2
    ##   .. .. ..$ field: symbol Petal.Width
    ##   .. .. ..$ type : NULL
    ##   .. ..$ y:List of 2
    ##   .. .. ..$ field: symbol Petal.Length
    ##   .. .. ..$ type : NULL
    ##   ..$ aes_params : NULL
    ##   ..$ stat       :List of 1
    ##   .. ..$ class: chr [1:4] "StatIdentity" "Stat" "ggproto" "gg"
    ##   ..$ stat_params: list()
    ##  $ :List of 7
    ##   ..$ data       : chr "data-00"
    ##   ..$ geom       :List of 1
    ##   .. ..$ class: chr [1:4] "GeomPoint" "Geom" "ggproto" "gg"
    ##   ..$ geom_params: list()
    ##   ..$ mapping    :List of 2
    ##   .. ..$ x:List of 2
    ##   .. .. ..$ field: symbol Petal.Width
    ##   .. .. ..$ type : NULL
    ##   .. ..$ y:List of 2
    ##   .. .. ..$ field: symbol Petal.Length
    ##   .. .. ..$ type : NULL
    ##   ..$ aes_params :List of 1
    ##   .. ..$ colour: chr "firebrick"
    ##   ..$ stat       :List of 1
    ##   .. ..$ class: chr [1:4] "StatIdentity" "Stat" "ggproto" "gg"
    ##   ..$ stat_params: list()

<br/>

-----

### Extracting scales

We should note that in the plot object, scales only appear if they are
specified by the user.

<br/>

``` r
get_scales_transform <- function(ind) {
  trans = purrr::pluck(p, "scales", "scales", ind, "trans", "transform")
  fun = rlang::fn_body(trans)
  bindings = as.list(ls(environment(trans)))
  names(bindings) <- ls(environment(trans))
  
  list(
    fun = fun, 
    bindings = map(bindings, ~ pluck(rlang::fn_env(trans), .x))
  )
  
}


get_scales <- function(ind){
  list(
    class = purrr::pluck(p, "scales", "scales", ind, class),
    aesthetics = purrr::pluck(p, "scales", "scales", ind, "aesthetics"),
    transform = get_scales_transform(ind)
  )
}

str(get_scales(1))
```

    ## List of 3
    ##  $ class     : chr [1:5] "ScaleContinuousPosition" "ScaleContinuous" "Scale" "ggproto" ...
    ##  $ aesthetics: chr [1:10] "y" "ymin" "ymax" "yend" ...
    ##  $ transform :List of 2
    ##   ..$ fun     : language {  log(x, base) }
    ##   ..$ bindings:List of 3
    ##   .. ..$ base : num 10
    ##   .. ..$ inv  :function (x)  
    ##   .. ..$ trans:function (x)

<br/>

-----

### Extracting labels

``` r
get_labels <- function(p){
  purrr::pluck(p, "labels")
}


get_labels(p)
```

    ## $x
    ## [1] "Petal.Width"
    ## 
    ## $y
    ## [1] "Petal.Length"

<br/>

-----

## Creating the spec

``` r
gg2spec <- function(p){
  
  n_layers <- length(p$layers)
  n_scales <- length(p$scales$scales)
  
  list(
    data = get_data_default(p),
    layers = map(seq_along(1:n_layers), get_layers),
    scales = map(seq_along(1:n_scales), get_scales),
    labels = get_labels(p)
  )
}
```

``` r
p_spec <- gg2spec(p)
str(p_spec)
```

    ## List of 4
    ##  $ data  :List of 1
    ##   ..$ data-00:List of 2
    ##   .. ..$ observations: 'json' chr "[{\"Sepal.Length\":5.1,\"Sepal.Width\":3.5,\"Petal.Length\":1.4,\"Petal.Width\":0.2,\"Species\":\"setosa\"},{\""| __truncated__
    ##   .. ..$ metadata    :List of 1
    ##   .. .. ..$ Species: chr [1:3] "setosa" "versicolor" "virginica"
    ##  $ layers:List of 2
    ##   ..$ :List of 7
    ##   .. ..$ data       : chr "data-00"
    ##   .. ..$ geom       :List of 1
    ##   .. .. ..$ class: chr [1:4] "GeomPoint" "Geom" "ggproto" "gg"
    ##   .. ..$ geom_params: list()
    ##   .. ..$ mapping    :List of 2
    ##   .. .. ..$ x:List of 2
    ##   .. .. .. ..$ field: symbol Petal.Width
    ##   .. .. .. ..$ type : NULL
    ##   .. .. ..$ y:List of 2
    ##   .. .. .. ..$ field: symbol Petal.Length
    ##   .. .. .. ..$ type : NULL
    ##   .. ..$ aes_params : NULL
    ##   .. ..$ stat       :List of 1
    ##   .. .. ..$ class: chr [1:4] "StatIdentity" "Stat" "ggproto" "gg"
    ##   .. ..$ stat_params: list()
    ##   ..$ :List of 7
    ##   .. ..$ data       : chr "data-00"
    ##   .. ..$ geom       :List of 1
    ##   .. .. ..$ class: chr [1:4] "GeomPoint" "Geom" "ggproto" "gg"
    ##   .. ..$ geom_params: list()
    ##   .. ..$ mapping    :List of 2
    ##   .. .. ..$ x:List of 2
    ##   .. .. .. ..$ field: symbol Petal.Width
    ##   .. .. .. ..$ type : NULL
    ##   .. .. ..$ y:List of 2
    ##   .. .. .. ..$ field: symbol Petal.Length
    ##   .. .. .. ..$ type : NULL
    ##   .. ..$ aes_params :List of 1
    ##   .. .. ..$ colour: chr "firebrick"
    ##   .. ..$ stat       :List of 1
    ##   .. .. ..$ class: chr [1:4] "StatIdentity" "Stat" "ggproto" "gg"
    ##   .. ..$ stat_params: list()
    ##  $ scales:List of 1
    ##   ..$ :List of 3
    ##   .. ..$ class     : chr [1:5] "ScaleContinuousPosition" "ScaleContinuous" "Scale" "ggproto" ...
    ##   .. ..$ aesthetics: chr [1:10] "y" "ymin" "ymax" "yend" ...
    ##   .. ..$ transform :List of 2
    ##   .. .. ..$ fun     : language {  log(x, base) }
    ##   .. .. ..$ bindings:List of 3
    ##   .. .. .. ..$ base : num 10
    ##   .. .. .. ..$ inv  :function (x)  
    ##   .. .. .. ..$ trans:function (x)  
    ##  $ labels:List of 2
    ##   ..$ x: chr "Petal.Width"
    ##   ..$ y: chr "Petal.Length"
