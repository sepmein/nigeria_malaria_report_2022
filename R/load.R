load_pop_cyril <- function(p_pop_cyril) {
    pop_cyril <- readxl::read_xls(p_pop_cyril,
                                  sheet = "LGA Pop-National",
                                  skip = 1,
                                  n_max = 776) |>
        to_lower() |>
        rename(`2006` = `2006 pop`,
               adm1 = "statename",
               adm2 = "lga name") |>
        mutate(`2022` = `2021` * `2021` / `2020`) |>
        select(
            adm1,
            `2006`,
            `2007`,
            `2008`,
            `2009`,
            `2010`,
            `2011`,
            `2012`,
            `2013`,
            `2014`,
            `2015`,
            `2016`,
            `2017`,
            `2018`,
            `2019`,
            `2020`,
            `2021`,
            `2022`
        ) |>
        group_by(adm1) |>
        summarise_all(sum) |>
        pivot_longer(
            cols = c(
                `2006`,
                `2007`,
                `2008`,
                `2009`,
                `2010`,
                `2011`,
                `2012`,
                `2013`,
                `2014`,
                `2015`,
                `2016`,
                `2017`,
                `2018`,
                `2019`,
                `2020`,
                `2021`,
                `2022`
            )
        ) |>
        rename(year = name, population_lga_cyril = value) |>
        mutate(
            year = as.numeric(year),
            population_lga_cyril = floor(population_lga_cyril)
        ) |>
        mutate(adm1 = str_replace(adm1, "Akwa lbom", "Akwa Ibom")) |>
        mutate(adm1 = str_replace(adm1,
                                  "FCT, Abuja", "Federal Capital Territory")) |>
        mutate(adm1 = str_replace(adm1,
                                  "Nassarawa", "Nasarawa")) |>
        filter(adm1 != "Source:") |>
        filter(!is.na(adm1)) |>
        gen_id_if_not_exist()
    pop_cyril <- upData(
        pop_cyril,
        rename = c(population_lga_cyril = "pop"),
        # labels = c(
        #     adm1 = "Administrative Level 1",
        #     year = "Year",
        #     pop = "Population Estimated by Cyril"
        # ),
        units = c(year = "year",
                  pop = "people")
    ) |>
        setDT()
}

load_pop_routine <- function(p_routine) {
    read_csv(p_routine) |>
        gen_id_if_not_exist() |>
        upData(# labels = c(
            #     adm1 = "Administrative Level 1",
            #     year = "Year",
            #     pop = "Population all ages ",
            #     pop_u5 = "Population under 5 years"
            # ),
            units = c(
                year = "year",
                pop = "people",
                pop_u5 = "people"
            )) |>
        setDT() |>
        setkeyv(c("id", "adm1", "year"))
}

load_adm1 <- function(p_adm1) {
    read_csv(p_adm1) |>
        gen_id_if_not_exist() |>
        setDT() |>
        setkeyv(c("id", "adm1")) |>
        arrange(adm1)
    
}

load_estimated_file <- function(p_estimated) {
    # Read the CSV file
    estimated <- fread(p_estimated)
    
    # Convert column names to lower case
    colnames(estimated) <- tolower(colnames(estimated))
    
    # Rename columns
    setnames(estimated, c("pop", "name"), c("pop_map", "adm1"))
    
    # Mutate adm1 column to replace values
    estimated[, adm1 := gsub("Abuja", "Federal Capital Territory", adm1)]
    estimated[, adm1 := gsub("Nassarawa", "Nasarawa", adm1)]
    
    # Select specific columns to keep
    estimated <-
        estimated[, !c("iso3", "age", "par", "id"), with = FALSE]
    
    upData(
        estimated,
        rename = c(
            pop_map = "pop",
            incidence_rate_all_age_rmean = "incidence_estimated_rmean",
            incidence_rate_all_age_lci = "incidence_estimated_lci",
            incidence_rate_all_age_uci = "incidence_estimated_uci",
            incidence_rate_all_age_median = "incidence_estimated_median"
        ),
        # labels = c(
        #     adm1 = "Administrative Level 1",
        #     pop = "Population Estimated by Malaria Atlas Project",
        #     incidence_estimated_rmean = "Mean value of incidence rate estimated",
        #     incidence_estimated_lci = "Lower confidence intervals of incidence rate estimated ",
        #     incidence_estimated_uci = "Upper confidence intervals of incidence rate estimated",
        #     incidence_estimated_median = "Median value of incidence rate estimated"
        # ),
        units = c(
            pop = "people",
            incidence_estimated_rmean = "cases per 1,000 people per year",
            incidence_estimated_lci = "cases per 1,000 people per year",
            incidence_estimated_uci = "cases per 1,000 people per year",
            incidence_estimated_median = "cases per 1,000 people per year"
        )
    )
}

extract_estimated_incidence <- function(estimated) {
    estimated[, .(
        adm1,
        year,
        incidence_estimated_rmean,
        incidence_estimated_lci,
        incidence_estimated_uci,
        incidence_estimated_median
    )] |> gen_id_if_not_exist()
}

extract_estimated_population <- function(estimated) {
    estimated[, .(adm1, year, pop)] |> gen_id_if_not_exist()
}
cal_cases <- function(adm1,
                      incidence_estimated,
                      j_adm1_incidence_estimated,
                      pop,
                      j_adm1_pop) {
    incidence <- adm1[j_adm1_incidence_estimated,
                      on = c("id" = "id_adm1")][incidence_estimated,
                                                on = c("id_db" = "id")]
    setkey(incidence, id, year)
    
    pop_adm1 <- adm1[j_adm1_pop,
                     on = c("id" = "id_adm1")][pop,
                                               on = c("id_db" = "id")]
    setkey(pop_adm1, id, year)
    
    incidence[pop_adm1][, cases := incidence_estimated_rmean * pop][, .(adm1, year, cases)]
}

cal_cases_adjusted <- function(adm1,
                               incidence_estimated,
                               j_adm1_incidence_estimated,
                               pop,
                               j_adm1_pop) {
    incidence <- adm1[j_adm1_incidence_estimated,
                      on = c("id" = "id_adm1")][incidence_estimated,
                                                on = c("id_db" = "id")]
    setkey(incidence, id, year)
    
    pop_adm1 <- adm1[j_adm1_pop,
                     on = c("id" = "id_adm1")][pop,
                                               on = c("id_db" = "id")]
    setkey(pop_adm1, id, year)
    
    cases <- incidence[pop_adm1][, cases := incidence_estimated_rmean * pop][year >= 2009]
    
    # Extract values for the years 2009
    pop_2009 <- cases[year == 2009, .(adm1, pop_2009 = pop)]
    
    # Merge the baseline adjusted incidence back into the original data.table
    result <- cases[pop_2009,
                    .(adm1,
                      year,
                      cases,
                      adj_cases = incidence_estimated_rmean * pop * pop_2009 / pop),
                    on = "adm1"]
    
    return(result)
}

load_dhs <- function(p_dhs) {
    dhs <- fread(p_dhs)
    #  [1] "Country
    #  [2] "Year"
    #  [3] "Survey"
    #  [4] "State"
    #  [5] "Level"
    #  [6] "Malaria prevalence according to RDT"
    #  [7] "Malaria prevalence according to microscopy"
    #  [8] "Persons with access to an insecticide-treated mosquito net (ITN)"
    #  [9] "Children who took any ACT"
    # [10] "Children tested for malaria with RDT"
    # [11] "Children with fever who had blood taken from a finger or heel for testing"
    # [12] "Existing insecticide-treated mosquito nets (ITNs) used last night"
    # [13] "Children under 5 who slept under any net"
    # [14] "Population who slept under an insecticide-treated mosquito net (ITN) last night"
    # [15] "Advice or treatment for fever sought from a health facility or provider"
    # [16] "Children under 5 who slept under an insecticide-treated net (ITN)"
    # rename columns, labels and units,
    # rename state to adm1
    # rename year to year
    dhs <- upData(
        dhs,
        rename = c(
            "State" = "adm1",
            "Year" = "year",
            "Survey" = "survey",
            "Malaria prevalence according to RDT" = "prevalence_rdt",
            "Malaria prevalence according to microscopy" = "prevalence_microscopy",
            "Persons with access to an insecticide-treated mosquito net (ITN)" = "access_itn",
            "Children who took any ACT" = "children_act",
            "Children tested for malaria with RDT" = "children_tested_rdt",
            "Children with fever who had blood taken from a finger or heel for testing" = "children_fever_blood",
            "Existing insecticide-treated mosquito nets (ITNs) used last night" = "existing_itn_used",
            "Children under 5 who slept under any net" = "u5_slept_any_net",
            "Population who slept under an insecticide-treated mosquito net (ITN) last night" = "population_slept_itn",
            "Advice or treatment for fever sought from a health facility or provider" = "advice_treatment_fever",
            "Children under 5 who slept under an insecticide-treated net (ITN)" = "u5_slept_itn"
        ),
        # labels = c(
        #     prevalence_rdt = "Malaria prevalence according to RDT",
        #     prevalence_microscopy = "Malaria prevalence according to microscopy",
        #     access_itn = "Persons with access to an insecticide-treated mosquito net (ITN)",
        #     children_act = "Children who took any ACT",
        #     children_tested_rdt = "Children tested for malaria with RDT",
        #     children_fever_blood = "Children with fever who had blood taken from a finger or heel for testing",
        #     existing_itn_used = "Existing insecticide-treated mosquito nets (ITNs) used last night",
        #     u5_slept_any_net = "Children under 5 who slept under any net",
        #     population_slept_itn = "Population who slept under an insecticide-treated mosquito net (ITN) last night",
        #     advice_treatment_fever = "Advice or treatment for fever sought from a health facility or provider",
        #     u5_slept_itn = "Children under 5 who slept under an insecticide-treated net (ITN)"
        # ),
        units = c(
            prevalence_rdt = "%",
            prevalence_microscopy = "%",
            access_itn = "%",
            children_act = "%",
            children_tested_rdt = "%",
            children_fever_blood = "%",
            existing_itn_used = "%",
            u5_slept_any_net = "%",
            population_slept_itn = "%",
            advice_treatment_fever = "%",
            u5_slept_itn = "%"
        )
    )
    # exclude country
    # filter out Level == "L1"
    # remove level column
    dhs[, Country := NULL]
    dhs <- dhs[Level != "L1"]
    dhs[, Level := NULL]
    return(dhs)
}

load_ipt <- function(p_ipt) {
    ipt <- fread(p_ipt)
    ipt <- upData(ipt,
                  # labels = c(
                  #     adm1 = "Administrative level 1",
                  #     date = "Date",
                  #     name = "Ipt1 or Ipt2 coverage",
                  #     value = "The value of the coverage"
                  # ),
                  units = c(date = "Date",
                            value = "%"))
    
    return(ipt)
}

load_rainfall <- function(p_rainfall) {
    rainfall <- fread(p_rainfall)
    rainfall <- upData(rainfall,
                       # labels = c(
                       #     adm1 = "Administrative level 1",
                       #     date = "Date",
                       #     year = "Year",
                       #     month = "Month",
                       #     rainfall = "Total Rainfall of the month in the district"
                       # ),
                       units = c(
                           date = "Date",
                           year = "Year",
                           month = "Month",
                           rainfall = "mm"
                       ))
    return(rainfall)
}

load_smc <- function(p_smc) {
    smc <- fread(p_smc)
    smc <- upData(smc,
                  # labels = c(
                  #     adm1 = "Administrative level 1",
                  #     date = "Date",
                  #     name = "Seasonal malaria chemoprevention Number",
                  #     value = "The number of the Seasonal malaria chemoprevention"
                  # ),
                  units = c(date = "Date",
                            value = "Doses"))
    return(smc)
}

cal_cumulative_cases_averted <- function(cases) {
    cases <- cases[order(year)][, .(adm1, year, cases)][, dcast(.SD, adm1 ~ year, value.var = "cases")][, base_case := `2009`][, .SD,
                                                                                                                               .SDcols = c("adm1", "base_case", "2009":"2022")][,
                                                                                                                                                                                melt(
                                                                                                                                                                                    .SD,
                                                                                                                                                                                    id.vars = c("adm1", "base_case"),
                                                                                                                                                                                    variable.name = "year",
                                                                                                                                                                                    value.name = "value"
                                                                                                                                                                                )][, cases_averted := base_case - value][, .(year, cumulative_cases_averted = cumsum(cases_averted)),
                                                                                                                                                                                                                         by = .(adm1)]
}

cal_cumulative_cases_averted_adjusted <- function(cases) {
    # baseline year is the cases in 2009
    cases_baseline <- cases[year == 2009,
                            .(adm1, cases_baseline = adj_cases)]
    cases[cases_baseline,
          cases_averted := cases_baseline - adj_cases,
          on = "adm1"][, .(year, cumulative_cases_averted = cumsum(cases_averted)),
                       by = .(adm1)]
}

#  <- tar_read(cumulative_cases_averted_pop_cyril)
cal_db_for_report <- function(adm1,
                              population_census,
                              population_cyril_estimated,
                              cases_estimated_pop_estimated,
                              incidence_estimated,
                              dhs,
                              cumulative_cases_averted,
                              llins,
                              ipt,
                              seasons,
                              rainfall_adm1) {
    # load population census
    result <- adm1[population_census,
                   on = "adm1"][, pop_census_2019 := population_2019][, .(adm1, pop_census_2019)]
    
    # load population cyril estimated
    pop_cyril_estimated <- population_cyril_estimated[year == 2022][, pop_cyril_2022 := pop][, .(adm1, pop_cyril_2022)]
    
    result <- result[pop_cyril_estimated,
                     on = "adm1"]
    
    # load cases estimated pop estimated
    cases_2021 <- cases_estimated_pop_estimated[year == 2021][, cases_2021 := cases][, .(adm1, cases_2021)]
    # summarize across adm1 get one national total cases for 2021
    total_cases_2021 <- cases_2021[, sum(cases_2021)]
    # WMR cases
    total_cases_2021_wmr <- 65399501
    
    cases_2018 <- cases_estimated_pop_estimated[year == 2018][, cases_2018 := cases][, .(adm1, cases_2018)]
    
    result <- result[cases_2021, on = "adm1"]
    result <- result[cases_2018, on = "adm1"]
    result[, p_cases_2021 := cases_2021 / total_cases_2021]
    
    # load incidence estimated
    incid_2018 <- incidence_estimated[year == 2018][, incid_2018 := incidence_estimated_rmean][, .(adm1, incid_2018)]
    incid_2021 <- incidence_estimated[year == 2021][, incid_2021 := incidence_estimated_rmean][, .(adm1, incid_2021)]
    
    result <- result[incid_2018, on = "adm1"]
    result <- result[incid_2021, on = "adm1"]
    
    # load dhs
    # load prevalence microscopy
    prev_micro_2015 <- dhs[year == 2015][, prev_micro_2015 := prevalence_microscopy][, .(adm1, prev_micro_2015)]
    prev_micro_2021 <- dhs[year == 2021][, prev_micro_2021 := prevalence_microscopy][, .(adm1, prev_micro_2021)]
    result <- result[prev_micro_2015, on = "adm1"]
    result <- result[prev_micro_2021, on = "adm1"]
    # compare cases in 2018 and 2021, generate a new column: cases_trend, if 2021 > 2018 then cases_trend = "increased", else cases_trend = "decreased"
    result[, cases_trend := ifelse(cases_2021 > cases_2018, "increased", "decreased")]
    result[, incid_trend := ifelse(incid_2021 > incid_2018, "increased", "decreased")]
    # calculate the trend in prevalence
    result[, prev_trend := ifelse(prev_micro_2021 > prev_micro_2015,
                                  "increased",
                                  "decreased")]
    
    cumulative_cases_averted_2015 <-
        cumulative_cases_averted[year == 2015][, cumulative_cases_averted_2015 := cumulative_cases_averted][, .(adm1, cumulative_cases_averted_2015)]
    cumulative_cases_averted_2021 <-
        cumulative_cases_averted[year == 2021][, cumulative_cases_averted_2021 := cumulative_cases_averted][, .(adm1, cumulative_cases_averted_2021)]
    
    result <- result[cumulative_cases_averted_2015, on = "adm1"]
    result <- result[cumulative_cases_averted_2021, on = "adm1"]
    result <-
        result[, cumulative_cases_averted_trend := ifelse(
            cumulative_cases_averted_2021 > cumulative_cases_averted_2015,
            "increased",
            "decreased"
        )]
    
    itn_campaigns <- tar_read(itn_campaigns)
    itn_campaigns <-
        itn_campaigns[, .(adm1, year_most_recent_itn_campaign)]
    result <- result[itn_campaigns, on = "adm1"]
    
    # sum up the number of LLINs distributed in each adm1
    llins <- llins[, .(llins_num = sum(llins_num)), by = .(adm1)]
    result <- result[llins, on = "adm1"]
    
    # get population_slept_itn from DHS for 2015 and 2021
    population_slept_itn_2015 <- dhs[year == 2015][, population_slept_itn_2015 := population_slept_itn][, .(adm1, population_slept_itn_2015)]
    population_slept_itn_2021 <- dhs[year == 2021][, population_slept_itn_2021 := population_slept_itn][, .(adm1, population_slept_itn_2021)]
    result <- result[population_slept_itn_2015, on = "adm1"]
    result <- result[population_slept_itn_2021, on = "adm1"]
    result[,
           population_slept_itn_trend := ifelse(
               population_slept_itn_2021 > population_slept_itn_2015,
               "increased",
               "decreased"
           )]
    
    # children_fever_blood 2015, 2021 from dhs
    finger_2015 <- dhs[year == 2015][,
                                     finger_2015 := children_fever_blood][, .(adm1, finger_2015)]
    
    finger_2021 <- dhs[year == 2021][,
                                     finger_2021 := children_fever_blood][, .(adm1, finger_2021)]
    
    result <- result[finger_2015,
                     on = "adm1"][finger_2021,
                                  on = "adm1"]
    result[, finger_trend := ifelse(finger_2021 > finger_2015, "increased", "decreased")]
    # get advice_treatment_fever from DHS for 2015 and 2021
    advice_treatment_fever_2015 <- dhs[year == 2015][, advice_treatment_fever_2015 := advice_treatment_fever][, .(adm1, advice_treatment_fever_2015)]
    advice_treatment_fever_2021 <- dhs[year == 2021][, advice_treatment_fever_2021 := advice_treatment_fever][, .(adm1, advice_treatment_fever_2021)]
    result <- result[advice_treatment_fever_2015, on = "adm1"]
    result <- result[advice_treatment_fever_2021, on = "adm1"]
    result[,
           advice_treatment_fever_trend := ifelse(
               advice_treatment_fever_2021 > advice_treatment_fever_2015,
               "increased",
               "decreased"
           )]
    
    
    ipt2 <- ipt[name == "ipt2_cov"][,
                                    ipt2_cov := value]
    # get ipt2 coverage from 2015 and 2021
    ipt2_cov_2015 <- ipt2[year == 2015][, ipt2_cov_2015 := ipt2_cov][, .(adm1, ipt2_cov_2015)]
    ipt2_cov_2021 <- ipt2[year == 2021][, ipt2_cov_2021 := ipt2_cov][, .(adm1, ipt2_cov_2021)]
    result <- result[ipt2_cov_2015, on = "adm1"]
    result <- result[ipt2_cov_2021, on = "adm1"]
    result[,
           ipt2_cov_trend := ifelse(ipt2_cov_2021 > ipt2_cov_2015,
                                    "increased", "decreased")]
    
    result <- result[seasons, on = "adm1"]
    result <- result[rainfall_adm1, on = "adm1"]
    
    return(result)
}

load_pop_census <- function(p) {
    pop_census <- fread(p)
    pop_census <- upData(
        pop_census,
        # labels = c(
        #     adm1 = "Administrative level 1",
        #     population_2006 = "Population in 2006 Survey",
        #     population_2019 = "Population in 2019 Survey"
        # ),
        units = c(population_2006 = "Population",
                  population_2019 = "Population")
    )
}

load_itn_campaigns <- function(path) {
    itn_campaigns <- fread(path)
    
    itn_campaigns <- upData(
        itn_campaigns,
        # labels = c(
        #     adm1 = "Administrative level 1",
        #     year_previous_itn_campaign = "Year of previous ITN campaign",
        #     year_most_recent_itn_campaign = "Year of most recent ITN campaign"
        # ),
        units = c(
            year_most_recent_itn_campaign = "Year",
            year_previous_itn_campaign = "Year"
        )
    )
}

cal_rainfall_adm1 <- function(rainfall) {
    # adm1, year, month, rainfall
    # group by adm1, year, sum rainfall
    rainfall <-
        rainfall[, .(rainfall = sum(rainfall)), by = .(adm1, year)]
    # group by adm1, calculate mean rainfall
    rainfall <-
        rainfall[, .(rainfall = mean(rainfall)), by = .(adm1)]
}

load_nga_seasons <- function(p) {
    season <- fread(p)
}

gen_indicator <- function(population_census,
                          cases_estimated_pop_estimated,
                          incidence_estimated_raw,
                          dhs) {
    # State, Pop, "Malaria prevalence according to RDT",
    # "Malaria prevalence according to microscopy",
    # cases_mean, incidence,
    # "Persons with access to an insecticide-treated mosquito net (ITN)",
    # "Existing insecticide-treated mosquito nets (ITNs) used last night",
    # "Population who slept under an insecticide-treated mosquito net (ITN) last night",
    # "Children under 5 who slept under any net", # nolint
    # "Children under 5 who slept under an insecticide-treated net (ITN)",
    # "Advice or treatment for fever sought from a health facility or provider",
    # "Children with fever who had blood taken from a finger or heel for testing" # nolint
    
    # [1] "adm1"                      "pop"                       "cases"
    # [4] "incidence_estimated_rmean" "year"                      "survey"
    # [7] "prevalence_rdt"            "prevalence_microscopy"     "access_itn"
    # [10] "children_act"              "children_tested_rdt"       "children_fever_blood"
    # [13] "existing_itn_used"         "u5_slept_any_net"          "population_slept_itn"
    # [16] "advice_treatment_fever"    "u5_slept_itn"
    
    result <- population_census[, .(adm1, population_2019)][cases_estimated_pop_estimated[year == 2021][, .(adm1, cases)], on = "adm1"][incidence_estimated_raw[year == 2021][, .(adm1, incidence_estimated_rmean)], on = "adm1"][dhs[year == 2021], on = "adm1"] |> arrange(adm1)
    result <- result[,
                     .(
                         adm1,
                         pop = floor(population_2019),
                         "Malaria prevalence according to RDT" = prevalence_rdt,
                         "Malaria prevalence according to microscopy" = prevalence_microscopy,
                         cases = floor(cases),
                         incidence = incidence_estimated_rmean,
                         "Persons with access to an insecticide-treated mosquito net (ITN)" = access_itn,
                         "Existing insecticide-treated mosquito nets (ITNs) used last night" = existing_itn_used,
                         "Population who slept under an insecticide-treated mosquito net (ITN) last night" = population_slept_itn,
                         "Children under 5 who slept under any net" = u5_slept_any_net,
                         "Children under 5 who slept under an insecticide-treated net (ITN)" = u5_slept_itn,
                         "Advice or treatment for fever sought from a health facility or provider" = advice_treatment_fever,
                         "Children with fever who had blood taken from a finger or heel for testing" = children_fever_blood
                     )]
    write_csv(result, "result/indicators.csv")
    return(result)
    # rename columns
}
