First components of the ggspec function
================

<br/>

This document builds off `01-ggspec-components` and incorporates Ian’s
[architecture ideas](https://github.com/vegawidget/ggspec/issues/1).

-----

## Extracting elements

<br/>

``` r
p <- ggplot(data = iris) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length)) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length), color = "firebrick") +
  scale_y_log10()

p
```

![](02-ggspec-components_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

<br/>

-----

### Extracting data

The first move will be to create the list `data` where all of the data
will live.

<!-- QUESTION: what to do about `waiver()` objects? -->

`data_int()` will create an intermediate-form for the data. The inputs
are the plot data and the plot layers. The result is a named list of
datasets where each list contains the elements `metadata`, `variables`,
and `hash`.

``` r
data_int <- function(data_plt, layers_plt) {
  # Return a named list of datasets, named `data-00`, `data-01`, ... 
  #join together default data and layer data
  dat <- append(list(data_plt), map(layers_plt, pluck, "data"))
  
  #format the lists of data
  dat <- purrr::map(dat, format_data_int)
  
  # how to name the datasets??
  
  # remove NULL entries
  purrr::discard(dat, is.null)
}
```

#### Helper functions

`create_meta_levels()`

``` r
# create_meta_levels <- function(dat){
#   loc <- purrr::detect_index(dat, is.factor)
#   levels <- purrr::pluck(dat, loc, levels)
#   meta <- list(levels) ## How to evaluate the name first??
#   names(meta) <- names(dat)[loc]
#   meta
# }
# 
```

`format_data_int()` will format each list of data so that it contains:  
\- `metadata`, could be a named list, using names of variables:  
\- `type`, first pass at `"quantitative"`, …, based on class, etc.  
\- `levels`, optional, vector of strings, used for factor-levels  
\- `variables`, the data frame itself  
\- `hash`, the md5 hash of the data frame

``` r
format_data_int <- function(dat) {
  if(is.waive(dat) || is.null(dat)) return(NULL) 
  else {
    list(
      metadata = map_chr(dat, class),
      variables = dat,
      hash = NULL # need to use digest package
    )
  }
}
```

Example of the function in use:

``` r
str(data_int(p$data, p$layers))
```

    ## List of 1
    ##  $ :List of 3
    ##   ..$ metadata : Named chr [1:5] "numeric" "numeric" "numeric" "numeric" ...
    ##   .. ..- attr(*, "names")= chr [1:5] "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width" ...
    ##   ..$ variables:'data.frame':    150 obs. of  5 variables:
    ##   .. ..$ Sepal.Length: num [1:150] 5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
    ##   .. ..$ Sepal.Width : num [1:150] 3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
    ##   .. ..$ Petal.Length: num [1:150] 1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
    ##   .. ..$ Petal.Width : num [1:150] 0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
    ##   .. ..$ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##   ..$ hash     : NULL

<br/>

This intermediate-form could be used to generate the ggspec-form; it
could also be useful later.

`data_spc()` will return a named list of datasets, named `data-00`,
`data-01`, …

Each list will have: - `metadata`, as in `data_int()` - `observations`,
transpose of variables

``` r
format_data_spec <- function(dat) {
  list(
    metadata = dat$metadata,
    observations = transpose(dat$variables)
  )
}

data_spc <- function(data_int) {
  map(data_int, format_data_spec)
}
```

``` r
str(data_spc(data_int(p$data, p$layers)), max.level = 2)
```

    ## List of 1
    ##  $ :List of 2
    ##   ..$ metadata    : Named chr [1:5] "numeric" "numeric" "numeric" "numeric" ...
    ##   .. ..- attr(*, "names")= chr [1:5] "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width" ...
    ##   ..$ observations:List of 150

<br/>

-----

### Extracting layers

<br/>

Within each layer-object, we need:  
1\. data (a reference id?)  
2\. geom  
3\. geom\_params (maybe)  
4\. mapping  
5\. aes\_params  
6\. stat (maybe)  
7\. stat\_params (maybe)

<br/>

The ggspec layers are a function of the ggplot layers, but also of the
data and scales:

Operates on a single layer, used with purrr::map() to get `layers_spc`  
\- if `layer_plt` has no data, use `data-00`  
\- if `layer_plt` has data, hash it and compare against `data_int`, use
name  
\- make sure that the mapping field is a name in the dataset  
\- can use type from the dataset metadata for now, can incorporate
scales later

``` r
get_layers <- function(layer) {
  pluck_layer <- purrr::partial(purrr::pluck, .x = layer)
  
  list(
    data = list(),
    geom = list(
      class = pluck_layer("geom", class, 1)
    ),
    mapping = pluck_layer("mapping") %>% map(get_mappings),
    aes_params = pluck_layer("aes_params"),
    stat = list(
      class = pluck_layer("stat", class, 1)
    )
  )
}


layer_int <- function(layer_plt) {
  map(layer_plt, get_layers)
}
```

Helper functions:

``` r
get_mappings <- function(aes) {
  list(field = rlang::get_expr(aes),
       type = NULL
  ) 
}
```

Example of function being used:

``` r
str(layer_int(p$layers))
```

    ## List of 2
    ##  $ :List of 5
    ##   ..$ data      : list()
    ##   ..$ geom      :List of 1
    ##   .. ..$ class: chr "GeomPoint"
    ##   ..$ mapping   :List of 2
    ##   .. ..$ x:List of 2
    ##   .. .. ..$ field: symbol Petal.Width
    ##   .. .. ..$ type : NULL
    ##   .. ..$ y:List of 2
    ##   .. .. ..$ field: symbol Petal.Length
    ##   .. .. ..$ type : NULL
    ##   ..$ aes_params: NULL
    ##   ..$ stat      :List of 1
    ##   .. ..$ class: chr "StatIdentity"
    ##  $ :List of 5
    ##   ..$ data      : list()
    ##   ..$ geom      :List of 1
    ##   .. ..$ class: chr "GeomPoint"
    ##   ..$ mapping   :List of 2
    ##   .. ..$ x:List of 2
    ##   .. .. ..$ field: symbol Petal.Width
    ##   .. .. ..$ type : NULL
    ##   .. ..$ y:List of 2
    ##   .. .. ..$ field: symbol Petal.Length
    ##   .. .. ..$ type : NULL
    ##   ..$ aes_params:List of 1
    ##   .. ..$ colour: chr "firebrick"
    ##   ..$ stat      :List of 1
    ##   .. ..$ class: chr "StatIdentity"

In `layer_spc` we will compare the layer data with `data_int` and
determine the types of the variable by comparing with `data_int` and
`scales_spc`

``` r
layer_spc <- function(layer_int, data_int, scales_spc) {
  
  
  
}
```

Example of function being used:

### Extracting scales

<br/>

I think that scales will be one-to-one: Operates on a single scale, used
with purrr::map() to get `scales_spc`

will need to check if there is anything there…

``` r
get_scales <- function(scale) {
  
  pluck_scale <- purrr::partial(purrr::pluck, .x = scale)

    
  list(
    name = pluck_scale("name"),
    class = pluck_scale(class, 1),
    aesthetics = pluck_scale("aesthetics"),
    transform = list(
      name = pluck_scale("trans", "name")
    )
  )
}

scale_spc <- function(scale_plt) {
  
  map(scale_plt, get_scales)
}
```

``` r
str(scale_spc(p$scales$scales))
```

    ## List of 1
    ##  $ :List of 4
    ##   ..$ name      : NULL
    ##   ..$ class     : chr "ScaleContinuousPosition"
    ##   ..$ aesthetics: chr [1:10] "y" "ymin" "ymax" "yend" ...
    ##   ..$ transform :List of 1
    ##   .. ..$ name: chr "log-10"

<br/>

-----

### Extracting labels

Finally, labels:

``` r
find_scale_labs <- function(labs) {
  lab <- pluck(labs, "name")
  if(!is.waive(lab)) {
    names(lab) <- pluck(labs, "aesthetics", 1)
    lab
  }
  
}

labels_spc <- function(labels_plt, scales_plt) {
  # Find the right way to deal with labels - we could run into a
  # problem if we have, say, multiple color scales
  scale_labs <- map(p_scale$scales$scales, find_scale_labs)
  
  # How to replace the labels with scale labels???
  
}
```

``` r
p_lab <- ggplot(iris) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length)) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length), color = "firebrick") +
  scale_y_log10() +
  labs(x = "new lab")

p_scale <- ggplot(iris) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length)) + 
  geom_point(aes(x = Petal.Width, y = Petal.Length), color = "firebrick") +
  scale_y_log10("new lab") 
```
