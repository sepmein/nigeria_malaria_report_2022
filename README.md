# Documentation for Nigeria Malaria Report 2022 code

This code repository is for the Nigeria Malaria Report 2022. The code is written in R by Chunzhe ZHANG([sepmein\@gmail.com](mailto:sepmein@gmail.com){.email}). The code is used to calculate, generate and plot the data and figures in the report. The code implement the reproducible rule, which means the code can be used to generate the same results with a single command. The main package to facilitate this approach is called [`targets`](https://docs.ropensci.org/targets/). The code is written in modular way, which means the code is divided into several modules, each of which is responsible for a specific task.

------------------------------------------------------------------------

## Very brief introduction of the `targets` package

The `targets` package is a pipeline toolkit for statistics and data science in R. It is designed to solve the problem of reproducibility in computational research, where the code and data are constantly changing.

It is a powerful pipeline toolkit designed to improve the efficiency and reproducibility of data science and statistics workflows. It allows users to define a series of steps in their analysis, known as a pipeline, where later steps depend on the results of earlier ones. Each step is represented by a target.

Here's a very brief overview of how it works:

-   Define Targets: Users define targets, which are the individual steps or units of work in the pipeline. A target can be a data transformation, statistical model, plot, etc.

-   Create a Pipeline: Once targets are defined, they are connected together to form a pipeline, where some targets depend on the outputs of others.

-   Run the Pipeline: When the user runs the pipeline, targets evaluates each target in the correct order, with respect to their dependencies, and stores the results.

-   Caching: One of the key features of targets is caching. Once a target has been built, its result is stored, or cached, so if you modify a part of your pipeline, only the affected targets will be rebuilt on the next run, saving time and computational resources.

-   Reproducibility: targets helps in maintaining the reproducibility of the analysis by keeping track of the environment, code, and data that produce the output, making it easier to share the analysis with others or adapt it to new data.

Here is a simplistic example:

``` r
library(targets)

# Define the targets
tar_pipeline(
  tar_target(raw_data, read.csv('data.csv')),
  tar_target(clean_data, data_cleaning(raw_data)),
  tar_target(model, lm(y ~ x, data = clean_data)),
  tar_target(summary_stats, summary(model))
)

# Run the pipeline
tar_make()
```

In this example, `raw_data`, `clean_data`, `model`, and `summary_stats` are targets in the pipeline, representing different steps in the analysis, and they will be executed in the correct order based on their dependencies when `tar_make()` is called. If the raw data or the data cleaning code changes, then all subsequent targets will be updated, but if only the model code changes, then only the model and `summary_stats` will be updated, utilizing the caching feature of the targets package.

------------------------------------------------------------------------

## Quick Start

Install R(obviously) then install the packages required.

### Required packages

run the following code to install the packages:

``` r
install.packages(c("targets",
          "tarchetypes"))
install.packages(c("sf",
          "tibble",
          "data.table",
          "readr",
          "glue",
          "qs",
          "purrr",
          "scales",
          "readxl",
          "janitor",
          "dplyr",
          "tidyr",
          "ggplot2",
          "stringr",
          "Hmisc",
          "wesanderson",
          "scales",
          "tmap"))
```

The `snt` package was developed by the author of this code. It is a package that specified for the malaria data analysis procedure. The package contains some functions that are used frequently in the code. The package can be installed by running the following code:

``` r
# install devtools if you have not installed it
install.packages("devtools")
# install snt package
devtools::install_github("WorldHealthOrganization/snt")
```

### Run the code

Use `tar_make()` function to run the code.

``` r
targets::tar_make()
```

Check how the code was organized and generate a graph of the targets by running the following code:

``` r
targets::tar_visnetwork()
```

Run just a single target by running the following code:

``` r
targets::tar_make(db_for_report)
```

Change the `db_for_report` to the target you want to run.

Debug the code firsly add `browser()` in the function to be debuged, then run the following code to enter the debug mode of the `R`:

``` r
targets::tar_make(callr_function = NULL)
```

## How this package is organized

The code is organized in a modular way. Each module is responsible for a specific task. The modules are organized in the following way:

![DHIS2](R/structure/1.%20dhis2.png)

![Household Surveys](R/structure/2.%20household%20surveys.png)

![Incidence and Mortality](R/structure/3.%20incidence%20and%20mortality.png)

![Rainfall](R/structure/4.%20rainfall.png){width="500"}

![Report Generation](R/structure/5.%20report%20generation.png){width="500"}

------------------------------------------------------------------------

### `_targets.R` file

The main file for define the targets. The targets are defined in the `tar_targets()` function. The targets are inter-connected with each other.

#### Targets pipeline

This script employs the targets package in R to create a pipeline for loading, transforming, and visualizing various datasets related to NGA (likely Nigeria). The datasets cover administrative, population, mortality, death, incidence, rainfall, and other demographic and environmental data.

The script creates multiple targets, where each target is a step in the pipeline. The outputs of the targets are files, plots, or processed data tables.

There are 3 targets in the pipeline:

1.  `file` with the format = "file", the specified target denotes the data resources required by the project. For example:

``` r
tar_target(adm1_file,
         "data/2023-04-01_nga_adm1.csv",
         format = "file"),
```

This command from the project specified the file path of the administrative level 1 of Nigeria. The content of this file is as follows:

``` .csv
adm1
Kaduna
Kwara
Sokoto
Akwa Ibom
Ebonyi
Ekiti
Kano
Katsina
Delta
Enugu
Edo
Oyo
Gombe
Rivers
Cross River
Ondo
Abia
Bayelsa
Lagos
Bauchi
Kebbi
Plateau
Nasarawa
Ogun
Anambra
Zamfara
Osun
Yobe
Benue
Niger
Kogi
Imo
Adamawa
Jigawa
Taraba
Federal Capital Territory
Borno
```

The `target` package will cache and track the file, and if the file is changed, the target will be updated. Otherwise the target will not be rerun in the next run.

2.  data processing targets

Those function started with `load_` are used to read data and run the data management for this particular data. For example:

``` r
  # This function is a comprehensive function that includes all the data processing steps
  tar_target(
    db_for_report,
    cal_db_for_report(
      adm1,
      population_census,
      population_cyril_estimated,
      # cases_estimated_pop_estimated,
      cases_estimated_pop_cyril,
      incidence_estimated_raw,
      dhs,
      cumulative_cases_averted_pop_cyril_adjusted,
      llins,
      ipt,
      seasons,
      rainfall_adm1,
      itn_campaigns
    )
  )
```

The name of this target is `db_for_report`. Function `cal_db_for_report` was used to generate `db_for_report`, the parameters inside the `()` were another `targets` pre-defined. For example `adm1` is a target that was defined in the `_targets.R` file. The `cal_db_for_report` function will read the data from the targets and process the data to generate the final data for the report.:

``` r
  # 2.2. load adm1 data by using load_adm1 function
  tar_target(adm1,
    load_adm1(adm1_file)),
  # 1.2. target for loading the NGA adm1 data
  tar_target(adm1_file,
    "data/2023-04-01_nga_adm1.csv",
    format = "file"
  )
```

The `adm1` target is a target that use `load_adm1` functions to read the data from the `adm1_file` target. The `adm1_file` target is a file target that define the path of the adm1 data file, which was explained in the previous section of `_target.R` file.

So in short, if illustrated as a DAG of the targets, it will be like this:

``` mermaid
graph LR
A[adm1_file] --> B[adm1]
B[adm1] --> C[db_for_report]
```

**3. data visualization targets**

The data visualization targets are used to generate the figures for the report. The figures are generated by using the `ggplot2` package. The figures are saved in the `figures` folder.

``` r
  tar_target(
    plot_pop,
    gen_plot_pop(pop_by_adm1),
    pattern = map(pop_by_adm1),
    iteration = "list"
  ),
```

explanation of the code:

-   `tar_target` is the function to define a target
-   `plot_pop` is the name of the target
-   `gen_plot_pop` is the function to generate the plot
-   `pop_by_adm1` is the data used to generate the plot, the data is a pre-defined target in the `_targets.R` file
-   `pattern = map(pop_by_adm1)` means the target will be generated for each element in the `pop_by_adm1` target, which is a list of data frames
-   `iteration = "list"` means the target will be generated for each element in the `pop_by_adm1` target, which is a list of data frames

The result will be a list of plots, each plot is for a specific administrative level 1 of Nigeria. The plots will be saved in the `result/plot` folder.

Example plot is as follows:

![Abia population](result/plot/Abia%20-%2001%20-%20pop.png)

`gen_plot_pop` is a function defined in the `R/plot.R` file. The function is as follows:

gen_plot_pop that generates a population plot for a given population data frame. The function uses the ggplot2 and cowplot packages to create a line plot of population over time, with points indicating the population for each year. The plot is saved as both an EPS and PNG file in the 'result/plot' directory. The function returns the ggplot object used to generate the plot.

The gen_plot_pop function first reads in the population data frame using the tar_read function. It then selects the year and pop columns, and converts the year column to a factor. The function then uses ggplot to create a line plot of population over time, with points indicating the population for each year. The plot is customized to remove the y-axis label, x-axis label, and legend, and to resize the plot to 0.6 of its original size. The legend is also customized to ensure that it is clear and easy to read. Finally, the function saves the plot as both an EPS and PNG file in the 'result/plot' directory and returns the ggplot object used to generate the plot.

The code of the function is as follows:

``` r
gen_plot_pop <- function(pop) {
    result <- pop |>
        select(year, pop) |>
        filter(year != 2022) |>
        mutate(year = as.factor(year)) |>
        ggplot(aes(year, pop)) + geom_line(colour = wes_palette("Darjeeling1",
        n = 5)[5], linewidth = 2, group = 1) +
        geom_point(fill = "white", shape = 21,
            size = 3, stroke = 1, colour = wes_palette("Darjeeling1",
                n = 5)[5]) + 
        scale_y_continuous(labels = label_number(accuracy = 1)) +
        scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
        cowplot::theme_cowplot() + theme(plot.margin = unit(c(0, 0, 0, 0), "mm"), 
        axis.title.x = element_blank(),
        axis.title.y = element_blank(), 
        legend.position = "none",
        axis.text = element_text(size = 6.6))

    if ("adm1" %in% names(pop)) {
        filename <- pop$adm1 |>
            unique()
    } else {
        filename <- "National"
    }

    ggsave(filename = paste0(filename, " - 01 - pop",
        ".eps"), plot = result, path = "result/plot",
        height = 1.8 * 2 * 0.6, width = 6 * 0.6)
    ggsave(filename = paste0(filename, " - 01 - pop",
        ".png"), plot = result, path = "result/plot",
        height = 1.8 * 2 * 0.6, width = 6 * 0.6)
    return(result)
}
```

Detailed explanation of the above code is as follows:

1.  select the year and pop columns, and convert the year column to a factor
2.  use ggplot to create a line plot of population over time, with points indicating the population for each year
3.  customize the plot to remove the y-axis label, x-axis label, and legend, and to resize the plot to 0.6 of its original size, as was required by the publication purpose
4.  customize the legend to ensure that it is clear and easy to read, `label_number` is a useful function from the `scales` package, provide a flexible way to format the labels of the plot, the `label_number` function is used to format the y-axis labels.
5.  check the administrative level of the plot, if the plot is for the national level, the plot name will be `National`, otherwise the plot name will be the name of the administrative level 1
6.  save the plot as both an EPS and PNG file in the 'result/plot' directory

Other plot functions has similar structure, with some minor differences. Detailed explanation of the other plot functions will be provided in the comment section of `plot.R` file.

------------------------------------------------------------------------

------------------------------------------------------------------------

### `R/` folder

The `R/` folder contains the code for the functions used in the `_targets.R` file. The functions are organized in the following way:

-   `load.R`
-   `plot.R`

#### `load.R`

The load.R file is a part of the NGA 2022 WMR Supplement project and contains functions for loading and processing data related to malaria prevalence, cases, incidence, ITN usage, and other factors. The file includes several functions that load and process different types of data, including population census data, malaria case data, estimated malaria incidence data, and DHS survey data.

The excerpt shown is a part of the load_national_indicators function, which loads and processes data to generate national indicators related to malaria prevalence, cases, incidence, ITN usage, and other factors. The function takes the following data frames as input: population_census, cases, incidence_estimated_raw, and dhs. The function filters the data frames to only include data from the year 2021 and for Nigeria (NGA). The function then joins the data frames and calculates various indicators related to malaria prevalence, cases, incidence, ITN usage, and other factors. The resulting data frame is saved as a CSV file in the "result" directory and returned.

The data management package `data.table` was used to process the data. The `data.table` package is a powerful package for data management. It is much faster than the `dplyr` package. The `data.table` package is used to process the data in this project.

Example usage of `data.table` package in the `load.R`:

``` r
load_smc <- function(p_smc) {
    smc <- read_excel(p_smc, skip = 1)
    smc <- as.data.table(smc)
    smc <- smc[, .(adm1, adm2, year, smc1_num,
        smc2_num, smc3_num, smc4_num)]
    smc <- smc[, .(smc1_num = sum(smc1_num, na.rm = TRUE),
        smc2_num = sum(smc2_num, na.rm = TRUE),
        smc3_num = sum(smc3_num, na.rm = TRUE),
        smc4_num = sum(smc4_num, na.rm = TRUE)),
        by = .(adm1, year)]
    smc <- melt(smc, id.vars = c("adm1", "year"),
        variable.name = "name")

    adm1 <- smc$adm1 |>
        unique()
    year <- smc$year |>
        unique()
    name <- smc$name |>
        unique()

    meta <- CJ(adm1, year, name)
    smc <- smc[meta, on = c("adm1", "year", "name")]
    return(smc)
}
```

-   `as.data.table(smc)` converts `smc` object from data frame to data table.
-   `smc <- smc[, .(adm1, adm2, year, smc1_num, smc2_num, smc3_num, smc4_num)]` selects the columns of the data table
-   `smc <- smc[, .(smc1_num = sum(smc1_num, na.rm = TRUE), smc2_num = sum(smc2_num, na.rm = TRUE), smc3_num = sum(smc3_num, na.rm = TRUE), smc4_num = sum(smc4_num, na.rm = TRUE)), by = .(adm1, year)]` calculates the sum of the columns by aggregating the data by `adm1` and `year`
-   `smc <- melt(smc, id.vars = c("adm1", "year"), variable.name = "name")` converts the data from wide format to long format
-   `meta <- CJ(adm1, year, name)` generates a data table that contains all the possible combinations of `adm1`, `year`, and `name`
-   `smc <- smc[meta, on = c("adm1", "year", "name")]` joins the `smc` data table with the `meta` data table

Overall, the load.R file provides a set of functions for loading and processing data related to malaria prevalence, cases, incidence, ITN usage, and other factors. These functions are designed to support the NGA 2022 WMR Supplement project and can be used to analyze and visualize data related to malaria prevalence, cases, incidence, ITN usage, and other factors.

Detailed explanation of the above code please refer to the comments in the `load.R` file.

#### `plot.R`

The code is primarily focused on generating visualizations related to malaria incidence, prevalence, treatment, and mortality. The functions generate bar plots, line plots, and thematic maps, each visualizing different aspects of the data. The visualizations are saved in different formats (PNG, EPS, TIFF) to specified paths. The code employs data transformation, filtering, and mutation to shape the data suitable for visualizations. The file includes several functions that clean and process different types of data, including DHS survey data, estimated malaria incidence and case data, population census data, LLIN distribution data, IPT coverage data, seasonal information data, rainfall data, and ITN campaign data. Each function takes a data frame as input and returns a cleaned and processed data frame.

The code is modular, with each function performing a specific task, enhancing readability and maintainability. The code extensively uses the pipe (`|>`) operator for chaining functions, which makes the code more readable. Functions from packages are called with explicit namespaces, e.g., `cowplot::theme_cowplot()`, which is a good practice to avoid conflicts between packages.

All functions consistently save the plots to the "result/plot" directory, maintaining uniformity. Filenames are conditionally assigned based on the presence of a variable, which is a thoughtful approach to handle variability in input data structures.

Packages Used:

-   `ggplot2` Extensively used for creating static graphics like bar plots and line plots.

-   `cowplot` Used for theming the ggplot objects.

-   `tmap` Employed for creating thematic maps.

-   `wesanderson` Utilized for accessing color palettes.

-   `scales` Used for formatting axis labels.

An example of plotting function in `plot.R`

``` r
gen_plot_estimated_cases <- function(cases) {
  minimum_incidences <- min(cases$cases)
  min_incidences_y_lab <- minimum_incidences / 4
  result <- cases |>
    filter(year < 2022) |>
    filter(year > 2013) |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year, y = cases)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[4],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[4]
    ) +
    # labs(y = "Estimated malaria cases") +
    scale_y_continuous(labels = label_number(accuracy = 1),
                       limits = c(min_incidences_y_lab, NA)) +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 0), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )
  
  if ("adm1" %in% names(cases)) {
    filename <- cases$adm1 |> unique()
  } else {
    filename <- "National"
  }

  ggsave(
    filename = paste0(filename, " - 02 - wmr_cases", ".eps"),
    plot = result,
    path = "result/plot",
    height = 2.4 * 0.6,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 02 - wmr_cases", ".png"),
    plot = result,
    path = "result/plot",
    height = 2.4 * 0.6,
    width = 6 * 0.6
  )
  return(result)
}
```

The `gen_plot_estimated_cases` function is designed to create a line plot visualizing estimated malaria cases over the years. The function filters the data to include years greater than 2013 and less than 2022, and then generates a plot using `ggplot2`. The plot is saved in both *.eps* and *.png* formats in the "result/plot" directory.

> Step by Step Explanation

##### **Data Filtering**

The function takes a data frame cases as an input. It filters the data to include rows where the year is greater than 2013 and less than 2022.

``` r
cases |>
  filter(year < 2022) |>
  filter(year > 2013)
```

##### **Data Transformation**

The year column is mutated to a factor variable. This is important for correctly ordering the x-axis in the plot.

``` r
mutate(year = as.factor(year))
```

##### **Plotting**

A ggplot object is created with year on the x-axis and cases on the y-axis. A line and points are added to the plot with specific aesthetic properties, such as color and size. The y-axis is scaled, and labels are formatted for readability. Several theme adjustments are made to finalize the plot appearance, such as removing axis titles and adjusting text size.

``` r
ggplot(aes(x = year, y = cases)) +
  geom_line(...) +
  geom_point(...) +
  scale_y_continuous(...) +
  theme(...)
```

##### **Saving the Plot**

The filename is determined based on the presence of the adm1 column in the cases data frame. The plot is then saved in both .eps and .png formats with specific dimensions in the "result/plot" directory.

``` r
ggsave(filename = ..., plot = result, path = "result/plot", height = ..., width = ...)
```

More detailed explanation of the code please refer to the code section of the file.

#### generate_report.R

The `generate_report` function is designed to process and format a given dataset (`db_for_report`) according to a specified template (`template`). It primarily focuses on arranging, mutating, and labeling the data in a way that is suitable for report generation. The function handles a variety of data points related to malaria cases, population, treatment, and other related metrics.

##### **Parameters**

-   template: A template that specifies the format in which the report should be generated.
-   db_for_report: A data frame containing the data to be processed and included in the report.

##### **Processing Steps**

-   Data Conversion and Arrangement Converts the input data frame to a tibble and arranges it by adm1. Removes value labels from labelled columns.

-   Data Labeling and Formatting: Applies custom labeling and formatting to various columns in the data frame. Uses different scales and accuracies for different types of data, such as numbers, percentages, and trends. Converts some metrics to suitable scales (e.g., thousands, millions) for better readability.

-   Data Gluing Uses the glue_data function to combine the formatted data with the specified template.

-   Returns The function does not explicitly return a value but is expected to generate a report based on the provided template and processed data.

##### **Dependencies**

The function relies on the `haven`, `labelled`, and `glue` packages, so these packages should be installed and loaded.

------------------------------------------------------------------------

### `data/` folder

The data used in the project were stored in the `data/` folder. The naming of the data files are in the following format: `2023-04-01_nga_adm1.csv`, date of entry + country code + administrative level + file type. The data files are in the `csv` format. The data files are used to generate the data for the report. The data files are not the final data for the report, they are the raw data that need to be processed to generate the final data for the report.