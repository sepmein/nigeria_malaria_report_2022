# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
# default storage format is qs
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
  format = "qs"
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

# The following list defines a list of targets for the NGA 2022 WMR Supplement project.
# Each target represents a specific task or computation that needs to be performed
# in order to generate the desired output. The targets include loading data from
# various files, joining data frames, calculating statistics, and generating plots.
# The targets are defined using the `tar_target` function from the `targets` package.
# The targets are organized in a list, which can be passed to the `tar_make` function
# to execute the targets in the correct order.
# This file contains a list of targets for the NGA 2022 WMR Supplement project. Each target represents a specific task or computation that needs to be performed in order to complete the project.

list(
  ##### 1. file target data type #####
  # 1.1. raw template file, check data/template.txt for detail
  tar_target(name = file_template_raw,
    command = "data/template.txt",
    format = "file"
  ),
  # 1.2. target for loading the NGA adm1 data
  tar_target(adm1_file,
    "data/2023-04-01_nga_adm1.csv",
    format = "file"
  ),
  # 1.3. target for loading the NGA population census data
  tar_target(population_census_file,
    "data/2022-04-01_nga_population_census.csv",
    format = "file"),
  # 1.4. target for loading the NGA mortality and death data
  tar_target(mortality_and_death_file,
    "data/2023-07-20-nga_death_mortality.xlsx",
    format = "file"),
  # 1.5. target for loading the NGA population cyril estimated data
  tar_target(
    population_cyril_estimated_file,
    "data/2023-04-08-nga_population_cyril_estimated.xls",
    format = "file"
  ),
  # 1.6. target for loading the NGA routine population data
  tar_target(population_routine_file,
    "data/2023-04-08-nga_population_routine.csv",
    format = "file"),
  # 1.7. target for loading the NGA estimated incidence data
  tar_target(
    estimated_file,
    "data/2023-04-05-incidence_rate_all_age_table_Nigeria_admin1_2000-2023.csv",
    format = "file"
  ),
  # 1.8. target for loading the NGA cases estimated population cyril data
  tar_target(
    f_cases_estimated_pop_cyril,
    "data/2023-07-13-nga_cases_estimated_cyril_estimated.xlsx",
    format = "file"
  ),
  # 1.9. target for loading the NGA cases estimated population estimated data
  tar_target(dhs_national_file,
    "data/2023-05-25-nga_dhs_natinonal.xlsx",
    format = "file"),
  # 1.10. target for loading the NGA DHS data
  tar_target(dhs_file,
    "data/2023-04-05-nga_dhs.csv",
    format = "file"),
  # 1.11. target for loading the NGA IPT data
  tar_target(ipt_file,
    "data/2023-06-27-nga_ipt.csv",
    format = "file"),
  # 1.12. target for loading the NGA national IPT data
  tar_target(ipt_national_file,
    "data/2023-06-27-nga_national_ipt.csv",
    format = "file"),
  # 1.13. target for loading the NGA rainfall data
  tar_target(rainfall_file,
    "data/2023-04-09-nga_rainfall.csv",
    format = "file"),
  # 1.14. target for loading the NGA SMC data
  tar_target(smc_file,
    "data/2023-04-09-nga_smc.csv",
    format = "file"),
  # 1.15. target for loading the updated NGA SMC data
  tar_target(smc_file_updated,
    "data/2023-06-24-nga_smc_updated.xlsx",
    format = "file"),
  # 1.16. target for loading the NGA LLINs data
  tar_target(llins_file,
    "data/2023-04-09-nga_llins_updated.xlsx",
    format = "file"),
  # 1.17. target for loading the NGA ITN campaigns data
  tar_target(itn_campaigns_file,
    "data/2023-04-10-nga_itn_campaign.csv",
    format = "file"),
  # 1.18. target for loading the NGA seasons data
  tar_target(nga_seasons_file,
    "data/2023-04-11-nga_seasons.csv",
    format = "file"),
  # 1.19. target for loading the NGA deaths data
  tar_target(f_deaths,
    "data/2023-07-02-nga_cum_estimated_deaths_averted.xlsx",
    format = "file"),
  # 1.20. national administrative level 1 district shapefile
  tar_target(nga_shp_file, "data/shapefiles/NGA_adm1.shp", format = "file"),
  # 1.21. load the shapefile
  tar_target(nga_shp, st_read(nga_shp_file)),
  ##### 2. data processing ######
  # 2.1. read temple file by using read_template function
  tar_target(name = template,
    command = read_template(file_template_raw)),
  # 2.2. load adm1 data by using load_adm1 function
  tar_target(adm1,
    load_adm1(adm1_file)),
  # 2.3. load mortality and death data by using load_mortality function
  tar_target(national_mortality,
    load_mortality(mortality_and_death_file)),
  # 2.4. load deaths data by using load_death function
  tar_target(national_deaths,
    load_death(mortality_and_death_file)),
  # 2.5. load population census data by using load_pop_census function
  tar_target(population_census,
    load_pop_census(population_census_file)),
  # 2.6. load population cyril estimated data by using load_pop_cyril function
  tar_target(population_cyril_estimated,
    load_pop_cyril(population_cyril_estimated_file)),
  # 2.7. join adm1 data with population cyril estimated data by using join_adm1 function
  tar_target(j_adm1_pop_cyril,
    join_adm1(adm1, population_cyril_estimated)),
  # 2.8. load routine population data by using load_pop_routine function
  tar_target(population_routine_raw,
    load_pop_routine(population_routine_file)),
  # 2.9. join adm1 data with routine population data by using join_adm1 function
  tar_target(j_adm1_pop_routine,
    join_adm1(adm1, population_routine_raw)),
  # 2.10. remove adm1 column from routine population data by using after_join_adm1 function, only keep the id column
  tar_target(population_routine,
    after_join_adm1(population_routine_raw)),
  # 2.11. load estimated data by using load_estimated_file function
  tar_target(dhs,
    load_dhs(dhs_file)),
  # 2.12. join adm1 data with estimated data by using join_adm1 function
  tar_target(
    cases_estimated_pop_cyril,
    read_excel(f_cases_estimated_pop_cyril) |> as.data.table()
  ),
  # 2.13. load estimated data by using load_estimated_file function
  tar_target(estimated,
    load_estimated_file(estimated_file)),
  # 2.14. extract estimated incidence data by using extract_estimated_incidence function
  tar_target(incidence_estimated_raw,
    extract_estimated_incidence(estimated)),
  # 2.15. join adm1 data with estimated incidence data by using join_adm1 function
  tar_target(j_adm1_incidence_estimated,
    join_adm1(adm1, incidence_estimated_raw)),
  # 2.16. remove adm1 column from estimated incidence data by using after_join_adm1 function, only keep the id column
  tar_target(incidence_estimated,
    after_join_adm1(incidence_estimated_raw)),
  # 2.17. extract estimated population data by using extract_estimated_population function
  tar_target(population_estimated_raw,
    extract_estimated_population(estimated)),
  # 2.18. join adm1 data with estimated population data by using join_adm1 function
  tar_target(j_adm1_pop_estimated,
    join_adm1(adm1, population_estimated_raw)),
  # 2.19. remove adm1 column from estimated population data by using after_join_adm1 function, only keep the id column
  tar_target(population_estimated,
    after_join_adm1(population_estimated_raw)),
  # 2.20. calculate cases by using cal_cases function, using adm1, estimated incidence, estimated population, and join_adm1 function
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
  # 2.21. calculate cases by using cal_cases function, using adm1, estimated incidence, adjusted estimated population, and join_adm1 function
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
  #        adm1,
  #        incidence_estimated,
  #        j_adm1_incidence_estimated,
  #        population_cyril_estimated,
  #        j_adm1_pop_cyril
  #         )
  # ),
  # 2.21. calculate cases by using cal_cases function, using adm1, estimated incidence, estimated population from the NGA NMEP
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
  # 2.22. load DHS survey data
  tar_target(dhs_national, load_dhs_national(dhs_national_file)),
  # 2.23. load IPT data
  tar_target(ipt, load_ipt(ipt_file)),
  # 2.24. load national IPT data
  tar_target(ipt_national, fread(ipt_national_file)),
  # 2.25. load rainfall data
  tar_target(rainfall, load_rainfall(rainfall_file)),
  # 2.26. load SMC data
  tar_target(smc, load_smc(smc_file_updated)),
  # 2.27. load LLINs data
  tar_target(llins, load_llins(llins_file)),
  # 2.28. calculate cumulative cases averted by using cal_cumulative_cases_averted function
  tar_target(
    cumulative_cases_averted_pop_estimated,
    cal_cumulative_cases_averted(cases_estimated_pop_estimated)
  ),
# tar_target(
  #         cumulative_cases_averted_pop_cyril,
  #         cal_cumulative_cases_averted(cases_estimated_pop_cyril)
  # ),
  # 2.29. calculate cumulative cases averted by using cal_cumulative_cases_averted function, using adjusted population
  tar_target(
    cumulative_cases_averted_pop_estimated_adjusted,
    cal_cumulative_cases_averted(cases_estimated_pop_estimated_adjusted)
  ),
  # 2.30. calculate cumulative cases averted by using cal_cumulative_cases_averted function, using adjusted population from NMEP
  tar_target(
    cumulative_cases_averted_pop_cyril_adjusted,
    cal_cumulative_cases_averted_adjusted(cases_estimated_pop_cyril_adjusted)
  ),
  # 2.31. load ITN campaigns data
  tar_target(itn_campaigns,
    load_itn_campaigns(itn_campaigns_file)),
  # 2.32. generate the database for the report, using cal_db_for_report function
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
  ),
  # 2.33. calculate the rainfall data by using cal_rainfall_adm1 function
  tar_target(rainfall_adm1, cal_rainfall_adm1(rainfall)),
  # 2.34. generate report from the template defined and the db generated
  tar_target(report, generate_report(template, db_for_report)),
  # 2.35. export report from 2.34.
  tar_target(
    write,
    write_report(report,
      "result/report.md"),
    format = "file",
    cue = tar_cue("always")
  ),
  # 2.36. load seasons data
  tar_target(seasons, load_nga_seasons(nga_seasons_file)),
  # 2.37. load NGA population and sum up the population by year
  tar_target(pop_national,
    population_cyril_estimated[, .(pop = sum(pop)), by = .(year)]),
  # 2.38. load NGA national population, the data source was from World Malaria Report 2022
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
  # 2.39. load NGA national population, data source from the country, tar_group was used here to generate iteration of the population data for each adm1
  tar_target(
    pop_by_adm1,
    population_cyril_estimated |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  # 2.40. generate an iteration of the malaria confirmed cases by the national population and incidence for each adm1
  tar_target(
    estimated_cases_by_adm1,
    # cases_estimated_pop_estimated |>
    cases_estimated_pop_cyril |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  # 2.41. calculate the national malaria confirmed cases by the national population and incidence
  tar_target(estimated_cases_national,
    cases_estimated_pop_estimated[
      , .(cases = sum(cases)), by = .(year)]),
  # 2.42. generate an iteration of the malaria estimated incidence for each adm1, mutate was used to multiply the incidence by 1000 to calculate the incidence per 1000 population
  tar_target(
    estimated_incidence_by_adm1,
    incidence_estimated_raw |>
      mutate(across(starts_with("incidence_"), ~ .x * 1000)) |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  # 2.43. calculate the national malaria estimated incidence, population and the cases was summarized by year, then estimated incidence was calculated by dividing the cases by population
  tar_target(
    estimated_incidence_national,
    estimated[,.(pop = sum(pop), cases = sum(pop * incidence_estimated_rmean)),
      by = .(year)][, .(year, incidence_estimated_rmean = cases / pop)]),
  # 2.44. generate an iteration of rainfall for each adm1
  tar_target(
    rainfall_by_adm1,
    rainfall |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  # 2.45. calculate the nation rainfall by excluding the adm1 column, the data will later be used in the boxplot, so no need for aggregation
  tar_target(rainfall_national, rainfall[, .SD, .SDcol = -c("adm1")]),
  # 2.62. read the mortality and death data 
  tar_target(d_deaths,
    read_excel(f_deaths) |> as.data.table()),
  
  # 2.63. calculate cumulative deaths averted by the country
  tar_target(cum_deaths, d_deaths),
  # 2.64. extract adm1 level prevalence data from Household survey, and generate iteration
  tar_target(prevalence_by_adm1,
    dhs |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"),
  # 2.65. extract national prevalence data from household survey
  tar_target(prevalence_national, dhs_national),
  tar_target(itn_by_adm1,
    dhs |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"),
  # 2.66. treatment seeking status, adm1 level, extracted from household survey
  tar_target(fever_by_adm1,
    dhs |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"),
  # 2.67. indicators for the report, adm1 level, which is the data used in the table section of the report, gen_indicator function was used here
  tar_target(
    indicators,
    gen_indicator(
      population_census,
      cases_estimated_pop_estimated,
      incidence_estimated_raw,
      dhs
    )
  ),
  # 2.68. national indicators for the report
  tar_target(
    indicators_national,
    gen_indicator_national(
      population_census,
      estimated_cases_national,
      estimated_incidence_national,
      dhs_national
    )
  ),
  # 2.69. generate an iteration of the ITN data for each adm1
  tar_target(llins_by_adm1,
    llins |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"),
  # 2.70. generate an iteration of the cumulated cases averted for each adm1
  tar_target(
    cum_by_adm1,
    cumulative_cases_averted_pop_cyril_adjusted |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"
  ),
  # 2.71. calculate the national cumulated cases averted by year
  tar_target(cum_national, cumulative_cases_averted_pop_cyril_adjusted[,
                          .(cumulative_cases_averted = sum(cumulative_cases_averted)), by = "year"]),
  # 2.72. generate an iteration of the IPT data for each adm1
  tar_target(ipt_by_adm1,
    ipt |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"),
  # 2.73. generate an iteration of the SMC data for each adm1
  tar_target(smc_by_adm1,
    smc |>
      group_by(adm1) |>
      arrange(adm1) |>
      tar_group(),
    iteration = "group"),
  # 2.74. calculate the national SMC data by year
  tar_target(smc_national, smc[, .(value = sum(value, na.rm = TRUE)), by = c("year", "name")]),

  ###### 3. plotting ######
  # Below are the targets for generating plots, the plots are generated by using the functions defined in the R/plot.R file
  # Detailed explaination please check the R/plot.R file
  tar_target(plot_cum_deaths,
    gen_plot_cum_deaths(cum_deaths)),
  tar_target(plot_mortality, gen_plot_mortality(national_mortality)),
  tar_target(plot_deaths, gen_plot_deaths(national_deaths)),
  tar_target(
    plot_prevalence_national_map,
    gen_plot_prevalence_map(dhs, nga_shp)),
  tar_target(
    plot_incidence_national_map,
    gen_plot_incidence_map(incidence_estimated_raw, nga_shp)
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
    plot_rainfall,
    gen_plot_rainfall(rainfall_by_adm1),
    pattern = map(rainfall_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_rainfall_national,
    gen_plot_rainfall(rainfall_national)),
  tar_target(
    plot_prevalence,
    gen_plot_prevalence(prevalence_by_adm1),
    pattern = map(prevalence_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_prevalence_national, gen_plot_prevalence(dhs_national)),
  tar_target(
    plot_itn,
    gen_plot_itn(itn_by_adm1),
    pattern = map(itn_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_itn_national, gen_plot_itn(dhs_national)),
  tar_target(
    plot_fever,
    gen_plot_fever(fever_by_adm1),
    pattern = map(fever_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_fever_national, gen_plot_fever(dhs_national)),
  tar_target(
    plot_llins,
    gen_plot_llins(llins_by_adm1),
    pattern = map(llins_by_adm1),
    iteration = "list"
  ),
  tar_target(llins_national,
    llins[, 
      .(llins_num = sum(llins_num, na.rm = TRUE)),
      by = "year"]),
  tar_target(plot_llins_national, gen_plot_llins(llins_national)),
  tar_target(
    plot_smc,
    gen_plot_smc(smc_by_adm1),
    pattern = map(smc_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_smc_national, gen_plot_smc(smc_national)),
  tar_target(
    plot_cum,
    gen_plot_cum(cum_by_adm1),
    pattern = map(cum_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_cum_national, gen_plot_cum(cum_national)),
  tar_target(
    plot_ipt,
    gen_plot_ipt(ipt_by_adm1),
    pattern = map(ipt_by_adm1),
    iteration = "list"
  ),
  tar_target(plot_ipt_national, gen_plot_ipt(ipt_national))
)
