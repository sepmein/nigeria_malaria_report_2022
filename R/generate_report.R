#' Generate a report using a template and a database
#'
#' This function generates a report using a template and a database. The template
#' should contain placeholders for the values in the database. The placeholders
#' should be in the format {column_name}. The database should be a data frame with
#' columns that match the placeholders in the template.
#'
#' @param template A character string containing the template for the report.
#' @param db_for_report A data frame containing the data to be used in the report.
#'
#' @return A character string containing the generated report.
#'
#' @examples
#' # Generate a report for two districts
#' template <- "The {district} has a population of {population}."
#' data <- data.frame(district = c("District A", "District B"), population = c(1000, 2000))
#' generate_report(template, data)
#'
#' @importFrom glue glue_data
#' @importFrom labelled remove_val_labels
#' @importFrom haven is.labelled
#' @importFrom dplyr arrange mutate_if as_tibble
#' @importFrom scales label_number label_percent
#' template example:
#'  The {district} has a population of {population}
#' district example:
#'  c('Abbia State', 'Lagos State')
#' data example:
#'  data.frame(district = c('Abbia State', 'Lagos State'), population = c(100, 200))
generate_report <- function(template, db_for_report) {
  # loop through the list
  #  [1] "adm1"                           "pop_census_2019"                "pop_cyril_2022"
  #  [4] "cases_2021"                     "cases_2018"                     "p_cases_2021"
  #  [7] "incid_2018"                     "incid_2021"                     "prev_micro_2015"
  # [10] "prev_micro_2021"                "cases_trend"                    "incid_trend"
  # [13] "prev_trend"                     "cumulative_cases_averted_2015"  "cumulative_cases_averted_2021"
  # [16] "cumulative_cases_averted_trend" "year_most_recent_itn_campaign"  "llins_num"
  # [19] "population_slept_itn_2015"      "population_slept_itn_2021"      "population_slept_itn_trend"
  # [22] "finger_2015"                    "finger_2021"                    "finger_trend"
  # [25] "advice_treatment_fever_2015"    "advice_treatment_fever_2021"    "advice_treatment_fever_trend"
  # [28] "ipt2_cov_2015"                  "ipt2_cov_2021"                  "ipt2_cov_trend"
  scale_cut_custom <- c(
    ` ` = 0,
    k = 10^3,
    ` million` = 10^6
  )
  db_for_report |>
    as_tibble() |>
    arrange(adm1) |>
    mutate_if(haven::is.labelled, labelled::remove_val_labels) |>
    glue_data(
      template,
      adm1 = adm1,
      pop_census_2019 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(pop_census_2019),
      pop_cyril_2022 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(pop_cyril_2022),
      cases_2021 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(cases_2021),
      cases_2018 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(cases_2018),
      p_cases_2021 = label_percent(accuracy = 0.1)(p_cases_2021),
      incid_2018 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(incid_2018 * 1000),
      incid_2021 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(incid_2021 * 1000),
      prev_micro_2015 = label_percent(accuracy = 0.1)(prev_micro_2015 /100),
      prev_micro_2021 = label_percent(accuracy = 0.1)(prev_micro_2021 /100),
      cases_trend = cases_trend,
      incid_trend = incid_trend,
      prev_trend = prev_trend,
      cumulative_cases_averted_2015 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(cumulative_cases_averted_2015),
      cumulative_cases_averted_2021 = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(cumulative_cases_averted_2021),
      cumulative_cases_averted_trend = cumulative_cases_averted_trend,
      year_most_recent_itn_campaign = year_most_recent_itn_campaign,
      llins_num = label_number(
        accuracy = 0.1,
        scale_cut = scale_cut_custom
      )(llins_num),
      population_slept_itn_2015 = label_percent(accuracy = 0.1)(population_slept_itn_2015 /100),
      population_slept_itn_2021 = label_percent(accuracy = 0.1)(population_slept_itn_2021 /100),
      population_slept_itn_trend = population_slept_itn_trend,
      finger_2015 = label_percent(accuracy = 0.1)(finger_2015 /100),
      finger_2021 = label_percent(accuracy = 0.1)(finger_2021 /100),
      finger_trend = finger_trend,
      advice_treatment_fever_2015 = label_percent(accuracy = 0.1)(advice_treatment_fever_2015 /100),
      advice_treatment_fever_2021 = label_percent(accuracy = 0.1)(advice_treatment_fever_2021 /100),
      advice_treatment_fever_trend = advice_treatment_fever_trend,
      ipt2_cov_2015 = label_percent(accuracy = 0.1)(ipt2_cov_2015),
      ipt2_cov_2021 = label_percent(accuracy = 0.1)(ipt2_cov_2021),
      ipt2_cov_trend = ipt2_cov_trend,
      rainfall = label_number(
        accuracy = 0.1,big.mark = ","
      )(rainfall)
    )
}
