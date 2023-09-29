# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
        packages = c(
          "sf",
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
          "snt",
          "stringr",
          "Hmisc",
          "wesanderson",
          "scales",
          "tmap"
        ),
        # packages that your targets need to run
        format = "qs" # default storage format
        # Set other options as needed.
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}},
# and {{future.batchtools}} to allow use_targets() to
# configure tar_make_future() options.

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed. # nolint

# Replace the target list below with your own:
list(
  # raw template file, check data/template.txt for detail
  tar_target(name = template_raw,
             command = "data/template.txt",
             format = "file"),
  # read temple file by using read_template function
  tar_target(name = template,
             command = read_template(template_raw)),
  tar_target(adm1_file,
             "data/2023-04-01_nga_adm1.csv",
             format = "file"),
  tar_target(adm1,
             load_adm1(adm1_file)),
  tar_target(population_census_file,
             "data/2022-04-01_nga_population_census.csv",
             format = "file"),
  tar_target(mortality_and_death_file,
             "data/2023-07-20-nga_death_mortality.xlsx",
             format = "file"),
  tar_target(national_mortality,
             load_mortality(mortality_and_death_file)),
  tar_target(plot_mortality, gen_plot_mortality(national_mortality)),
  tar_target(national_deaths,
             load_death(mortality_and_death_file)),
  tar_target(plot_deaths, gen_plot_deaths(national_deaths)),
  tar_target(population_census,
             load_pop_census(population_census_file)),
  tar_target(
    population_cyril_estimated_file,
    "data/2023-04-08-nga_population_cyril_estimated.xls",
    format = "file"
  ),
  tar_target(population_cyril_estimated,
             load_pop_cyril(population_cyril_estimated_file)),
  tar_target(j_adm1_pop_cyril,
             join_adm1(adm1, population_cyril_estimated)),
  tar_target(population_routine_file,
             "data/2023-04-08-nga_population_routine.csv",
             format = "file"),
  tar_target(population_routine_raw,
             load_pop_routine(population_routine_file)),
  tar_target(j_adm1_pop_routine,
             join_adm1(adm1, population_routine_raw)),
  tar_target(population_routine,
             after_join_adm1(population_routine_raw)),
  tar_target(
    estimated_file,
    "data/2023-04-05-incidence_rate_all_age_table_Nigeria_admin1_2000-2023.csv",
    format = "file"
  ),
  tar_target(
    f_cases_estimated_pop_cyril,
    "data/2023-07-13-nga_cases_estimated_cyril_estimated.xlsx",
    format = "file"
  ),
  tar_target(
    cases_estimated_pop_cyril,
    read_excel(f_cases_estimated_pop_cyril) |> as.data.table()
  ),
  tar_target(estimated,
             load_estimated_file(estimated_file)),
  tar_target(incidence_estimated_raw,
             extract_estimated_incidence(estimated)),
  tar_target(j_adm1_incidence_estimated,
             join_adm1(adm1, incidence_estimated_raw)),
  tar_target(incidence_estimated,
             after_join_adm1(incidence_estimated_raw)),
  tar_target(population_estimated_raw,
             extract_estimated_population(estimated)),
  tar_target(j_adm1_pop_estimated,
             join_adm1(adm1, population_estimated_raw)),
  tar_target(population_estimated,
             after_join_adm1(population_estimated_raw)),
  tar_target(
    cases_estimated_pop_estimated,
    cal_cases(
      adm1,
      incidence_estimated,
      j_adm1_incidence_estimated,
      population_estimated,
      j_adm1_pop_estimated
    )
  ),
  tar_target(
    cases_estimated_pop_estimated_adjusted,
    cal_cases_adjusted(
      adm1,
      incidence_estimated,
      j_adm1_incidence_estimated,
      population_estimated,
      j_adm1_pop_estimated
    )
  ),
  # tar_target(
  #         cases_estimated_pop_cyril,
  #         cal_cases(
  #                 adm1,
  #                 incidence_estimated,
  #                 j_adm1_incidence_estimated,
  #                 population_cyril_estimated,
  #                 j_adm1_pop_cyril
  #         )
  # ),
  tar_target(
    cases_estimated_pop_cyril_adjusted,
    cal_cases_adjusted(
      adm1,
      incidence_estimated,
      j_adm1_incidence_estimated,
      population_cyril_estimated,
      j_adm1_pop_cyril
    )
  ),
  tar_target(dhs_national_file,
             "data/2023-05-25-nga_dhs_natinonal.xlsx",
             format = "file"),
  tar_target(dhs_national, load_dhs_national(dhs_national_file)),
  tar_target(dhs_file,
             "data/2023-04-05-nga_dhs.csv",
             format = "file"),
  tar_target(dhs,
             load_dhs(dhs_file)),
  tar_target(ipt_file,
             "data/2023-06-27-nga_ipt.csv",
             format = "file"),
  tar_target(ipt,
             load_ipt(ipt_file)),
  tar_target(ipt_national_file,
             "data/2023-06-27-nga_national_ipt.csv",
             format = "file"),
  tar_target(ipt_national, fread(ipt_national_file)),
  tar_target(rainfall_file,
             "data/2023-04-09-nga_rainfall.csv",
             format = "file"),
  tar_target(rainfall,
             load_rainfall(rainfall_file)),
  tar_target(smc_file,
             "data/2023-04-09-nga_smc.csv",
             format = "file"),
  tar_target(smc_file_updated,
             "data/2023-06-24-nga_smc_updated.xlsx",
             format = "file"),
  tar_target(smc,
             load_smc(smc_file_updated)),
  tar_target(llins_file,
             "data/2023-04-09-nga_llins_updated.xlsx",
             format = "file"),
  tar_target(llins,
             load_llins(llins_file)),
  tar_target(
    cumulative_cases_averted_pop_estimated,
    cal_cumulative_cases_averted(cases_estimated_pop_estimated)
  ),
  # tar_target(
  #         cumulative_cases_averted_pop_cyril,
  #         cal_cumulative_cases_averted(cases_estimated_pop_cyril)
  # ),
  tar_target(
    cumulative_cases_averted_pop_estimated_adjusted,
    cal_cumulative_cases_averted_adjusted(cases_estimated_pop_estimated_adjusted)
  ),
  tar_target(
    cumulative_cases_averted_pop_cyril_adjusted,
    cal_cumulative_cases_averted_adjusted(cases_estimated_pop_cyril_adjusted)
  ),
  tar_target(itn_campaigns_file,
             "data/2023-04-10-nga_itn_campaign.csv",
             format = "file"),
  tar_target(itn_campaigns,
             load_itn_campaigns(itn_campaigns_file)),
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
      rainfall_adm1
    )
  ),
  tar_target(report,
             generate_report(template,
                             db_for_report)),
  tar_target(
    write,
    write_report(report,
                 "result/report.md"),
    format = "file",
    cue = tar_cue("always")
  ),
  tar_target(rainfall_adm1,
             cal_rainfall_adm1(rainfall)),
  tar_target(nga_seasons_file,
             "data/2023-04-11-nga_seasons.csv",
             format = "file"),
  tar_target(seasons,
             load_nga_seasons(nga_seasons_file)),
  tar_target(pop_national, population_cyril_estimated[, .(pop = sum(pop)), by = .(year)]),
  tar_target(pop_national_wmr, data.table(
    "year" = c(2006:2021),
    "pop" = c(
      144329760,
      148294032,
      152382512,
      156595760,
      160952848,
      165463744,
      170075936,
      174726128,
      179379008,
      183995792,
      188666928,
      193495904,
      198387616,
      203304496,
      208327408,
      213401328
    )
  )),
  
  tar_target(
    pop_by_adm1,
    population_cyril_estimated |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(
    plot_pop,
    gen_plot_pop(pop_by_adm1),
    pattern = map(pop_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_pop_national, gen_plot_pop(pop_national)),
  tar_target(plot_pop_national_wmr, gen_plot_pop(pop_national_wmr)),
  tar_target(
    estimated_cases_by_adm1,
    # cases_estimated_pop_estimated |>
    cases_estimated_pop_cyril |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(estimated_cases_national,
             cases_estimated_pop_estimated[, .(cases = sum(cases)), by = .(year)]),
  tar_target(
    plot_estimated_cases,
    gen_plot_estimated_cases(estimated_cases_by_adm1),
    pattern = map(estimated_cases_by_adm1),
    iteration = "list"
  ),
  tar_target(
    plot_estimated_cases_national,
    gen_plot_estimated_cases(estimated_cases_national)
  ),
  tar_target(
    estimated_incidence_by_adm1,
    incidence_estimated_raw |>
      mutate(across(starts_with("incidence_"), ~ .x * 1000)) |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(estimated_incidence_national,
             estimated[, .(pop = sum(pop),
                           cases = sum(pop * incidence_estimated_rmean)), by = .(year)][, .(year,     incidence_estimated_rmean = cases / pop)]),
  tar_target(
    plot_estimated_incidence,
    gen_plot_estimated_incidence(estimated_incidence_by_adm1),
    pattern = map(estimated_incidence_by_adm1),
    iteration = "list"
  ),
  tar_target(
    plot_incidences_national,
    gen_plot_estimated_incidence(estimated_incidence_national)
  ),
  tar_target(
    rainfall_by_adm1,
    rainfall |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(rainfall_national, rainfall[, .SD, .SDcol = -c("adm1")]),
  tar_target(
    plot_rainfall,
    gen_plot_rainfall(rainfall_by_adm1),
    pattern = map(rainfall_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_rainfall_national,
             gen_plot_rainfall(rainfall_national)),
  tar_target(prevalence_by_adm1,
             dhs |>
               group_by(adm1) |>
               arrange(adm1) |>
               tar_group(),
             iteration = "group"),
  tar_target(prevalence_national, dhs_national),
  tar_target(
    plot_prevalence,
    gen_plot_prevalence(prevalence_by_adm1),
    pattern = map(prevalence_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_prevalence_national, gen_plot_prevalence(dhs_national)),
  tar_target(itn_by_adm1,
             dhs |>
               group_by(adm1) |>
               arrange(adm1) |>
               tar_group(),
             iteration = "group"),
  tar_target(
    plot_itn,
    gen_plot_itn(itn_by_adm1),
    pattern = map(itn_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_itn_national, gen_plot_itn(dhs_national)),
  tar_target(fever_by_adm1,
             dhs |>
               group_by(adm1) |>
               arrange(adm1) |>
               tar_group(),
             iteration = "group"),
  tar_target(
    plot_fever,
    gen_plot_fever(fever_by_adm1),
    pattern = map(fever_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_fever_national, gen_plot_fever(dhs_national)),
  tar_target(llins_by_adm1,
             llins |>
               group_by(adm1) |>
               arrange(adm1) |>
               tar_group(),
             iteration = "group"),
  tar_target(
    plot_llins,
    gen_plot_llins(llins_by_adm1),
    pattern = map(llins_by_adm1),
    iteration = "list"
  ),
  tar_target(llins_national, llins[, .(llins_num = sum(llins_num, na.rm =
                                                         TRUE)), by = "year"]),
  tar_target(plot_llins_national, gen_plot_llins(llins_national)),
  tar_target(smc_by_adm1,
             smc |>
               group_by(adm1) |>
               arrange(adm1) |>
               tar_group(),
             iteration = "group"),
  tar_target(smc_national, smc[, .(value = sum(value, na.rm = TRUE)), by = c("year", "name")]),
  tar_target(
    plot_smc,
    gen_plot_smc(smc_by_adm1),
    pattern = map(smc_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_smc_national, gen_plot_smc(smc_national)),
  tar_target(
    cum_by_adm1,
    cumulative_cases_averted_pop_cyril_adjusted |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  tar_target(cum_national, cumulative_cases_averted_pop_cyril_adjusted[,
                                                                       .(cumulative_cases_averted = sum(cumulative_cases_averted)), by = "year"]),
  tar_target(
    plot_cum,
    gen_plot_cum(cum_by_adm1),
    pattern = map(cum_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_cum_national, gen_plot_cum(cum_national)),
  tar_target(ipt_by_adm1,
             ipt |>
               group_by(adm1) |>
               arrange(adm1) |>
               tar_group(),
             iteration = "group"),
  tar_target(
    plot_ipt,
    gen_plot_ipt(ipt_by_adm1),
    pattern = map(ipt_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_ipt_national, gen_plot_ipt(ipt_national)),
  tar_target(
    indicators,
    gen_indicator(
      population_census,
      cases_estimated_pop_estimated,
      incidence_estimated_raw,
      dhs
    )
  ),
  tar_target(
    indicators_national,
    gen_indicator_national(
      population_census,
      estimated_cases_national,
      estimated_incidence_national,
      dhs_national
    )
  ),
  tar_target(
    plot_incidence_national_map,
    gen_plot_incidence_map(incidence_estimated_raw, nga_shp)
  ),
  tar_target(nga_shp_file, "data/shapefiles/NGA_adm1.shp", format = "file"),
  tar_target(nga_shp, st_read(nga_shp_file)),
  
  tar_target(plot_prevalence_national_map,
             gen_plot_prevalence_map(dhs, nga_shp)),
  tar_target(f_deaths,
             "data/2023-07-02-nga_cum_estimated_deaths_averted.xlsx",
             format = "file"),
  tar_target(d_deaths,
             read_excel(f_deaths) |> as.data.table()),
  tar_target(cum_deaths,
             d_deaths,),
  tar_target(plot_cum_deaths,
             gen_plot_cum_deaths(cum_deaths))
  
  
)
