# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
        packages = c("tibble", "readr", 
                     "glue", "qs","purrr",
                     "scales"), # packages that your targets need to run
        format = "qs" # default storage format
        # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
        tar_target(
                name = template_raw,
                command = "data/template.txt",
                format = "file"
        ),
        tar_target(
                template,
                command = read_template(template_raw)
        ),
        tar_target(
                population_census_file,
                "data/2022-04-01_nga_population_census.csv",
                format ="file"
        ),
        tar_target(
               population_census,
               read_csv(population_census_file) |> janitor::clean_names()
        ),
        tar_target(
          report,
          generate_report(
            template,
            population_census
          )
        ),
        tar_target(
                write,
                write_report(
                        report,
                        "result/report.txt"
                ),
                format = "file"
        )
)
