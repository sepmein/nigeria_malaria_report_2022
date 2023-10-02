
#' Loads population data from an Excel file and performs data cleaning and transformation.
#'
#' This function reads an Excel file containing population data for local government areas (LGAs) in Nigeria,
#' performs data cleaning and transformation, and returns a data table with the cleaned and transformed data.
#'
#' @param p_pop_cyril The file path of the Excel file containing the population data.
#'
#' @return A data table containing the cleaned and transformed population data.
#'
#' @examples
#' load_pop_cyril('/path/to/population_data.xlsx')
load_pop_cyril <- function(p_pop_cyril) {
    pop_cyril <- readxl::read_xls(p_pop_cyril,
        sheet = "LGA Pop-National", skip = 1,
        n_max = 776) |>
        sn_to_lower() |>
        rename(`2006` = `2006 pop`, adm1 = "statename",
            adm2 = "lga name") |>
        mutate(`2022` = `2021` * `2021`/`2020`) |>
        mutate(`2005` = `2006` * `2006`/`2007`) |>
        mutate(`2004` = `2005` * `2005`/`2006`) |>
        mutate(`2003` = `2004` * `2004`/`2005`) |>
        mutate(`2002` = `2003` * `2003`/`2004`) |>
        mutate(`2001` = `2002` * `2002`/`2003`) |>
        mutate(`2000` = `2001` * `2001`/`2002`) |>
        select(adm1, `2000`, `2001`, `2002`, `2003`,
            `2004`, `2005`, `2006`, `2007`, `2008`,
            `2009`, `2010`, `2011`, `2012`, `2013`,
            `2014`, `2015`, `2016`, `2017`, `2018`,
            `2019`, `2020`, `2021`, `2022`) |>
        group_by(adm1) |>
        summarise_all(sum) |>
        pivot_longer(cols = c(`2000`, `2001`,
            `2002`, `2003`, `2004`, `2005`, `2006`,
            `2007`, `2008`, `2009`, `2010`, `2011`,
            `2012`, `2013`, `2014`, `2015`, `2016`,
            `2017`, `2018`, `2019`, `2020`, `2021`,
            `2022`)) |>
        rename(year = name, population_lga_cyril = value) |>
        mutate(year = as.numeric(year), population_lga_cyril = floor(population_lga_cyril)) |>
        mutate(adm1 = str_replace(adm1, "Akwa lbom",
            "Akwa Ibom")) |>
        mutate(adm1 = str_replace(adm1, "FCT, Abuja",
            "Federal Capital Territory")) |>
        mutate(adm1 = str_replace(adm1, "Nassarawa",
            "Nasarawa")) |>
        filter(adm1 != "Source:") |>
        filter(!is.na(adm1)) |>
        gen_id_if_not_exist()
    pop_cyril <- upData(pop_cyril, rename = c(population_lga_cyril = "pop"),
        units = c(year = "year", pop = "people")) |>
        setDT()
}

# Loads a population routine file and
# performs some data cleaning and
# formatting.  Args: p_routine: A string
# representing the file path of the
# population routine file.  Returns: A
# data.table object with the cleaned and
# formatted data.
load_pop_routine <- function(p_routine) {
    read_csv(p_routine) |>
        gen_id_if_not_exist() |>
        upData(units = c(year = "year", pop = "people",
            pop_u5 = "people")) |>
        setDT() |>
        setkeyv(c("id", "adm1", "year"))
}

# Loads and processes adm1 data from a CSV
# file Args: p_adm1: A string representing
# the file path of the CSV file Returns: A
# data.table object with the adm1 data
load_adm1 <- function(p_adm1) {
    read_csv(p_adm1) |>
        gen_id_if_not_exist() |>
        setDT() |>
        setkeyv(c("id", "adm1")) |>
        arrange(adm1)

}

# Function to load estimated file Args:
# p_estimated: path to the estimated file
# Returns: Estimated data with specific
# columns selected and renamed
load_estimated_file <- function(p_estimated) {
    # Read the CSV file
    estimated <- fread(p_estimated)

    # Convert column names to lower case
    colnames(estimated) <- tolower(colnames(estimated))

    # Rename columns
    setnames(estimated, c("pop", "name"), c("pop_map",
        "adm1"))

    # Mutate adm1 column to replace values
    estimated[, adm1 := gsub("Abuja", "Federal Capital Territory",
        adm1)]
    estimated[, adm1 := gsub("Nassarawa", "Nasarawa",
        adm1)]

    # Select specific columns to keep
    estimated <- estimated[, !c("iso3", "age",
        "par", "id"), with = FALSE]

    # Update data with new column names and
    # units
    upData(estimated, rename = c(pop_map = "pop",
        incidence_rate_all_age_rmean = "incidence_estimated_rmean",
        incidence_rate_all_age_lci = "incidence_estimated_lci",
        incidence_rate_all_age_uci = "incidence_estimated_uci",
        incidence_rate_all_age_median = "incidence_estimated_median"),
        units = c(pop = "people", incidence_estimated_rmean = "cases per 1,000 people per year",
            incidence_estimated_lci = "cases per 1,000 people per year",
            incidence_estimated_uci = "cases per 1,000 people per year",
            incidence_estimated_median = "cases per 1,000 people per year"))
}

# This function extracts estimated incidence
# from a data table Input: estimated - data
# table containing estimated incidence
# Output: data table containing extracted
# estimated incidence
extract_estimated_incidence <- function(estimated) {
    estimated[, .(adm1, year, incidence_estimated_rmean,
        incidence_estimated_lci, incidence_estimated_uci,
        incidence_estimated_median)] |>
        gen_id_if_not_exist()
}

# This function extracts estimated
# population from a data table Input:
# estimated - data table containing
# estimated population Output: data table
# containing extracted estimated population
extract_estimated_population <- function(estimated) {
    estimated[, .(adm1, year, pop)] |>
        gen_id_if_not_exist()
}

# This function calculates cases from
# estimated incidence and population Input:
# adm1 - data table containing adm1
# information incidence_estimated - data
# table containing estimated incidence
# j_adm1_incidence_estimated - join table
# for adm1 and estimated incidence pop -
# data table containing population
# j_adm1_pop - join table for adm1 and
# population Output: data table containing
# calculated cases
cal_cases <- function(adm1, incidence_estimated,
    j_adm1_incidence_estimated, pop, j_adm1_pop) {
    incidence <- adm1[j_adm1_incidence_estimated,
        on = c(id = "id_adm1")][incidence_estimated,
        on = c(id_db = "id")]
    setkey(incidence, id, year)

    pop_adm1 <- adm1[j_adm1_pop, on = c(id = "id_adm1")][pop,
        on = c(id_db = "id")]
    setkey(pop_adm1, id, year)
    incidence[pop_adm1][, cases := incidence_estimated_rmean *
        pop][, .(adm1, year, cases)]
}

# This function calculates adjusted cases
# from estimated incidence and population
# Input: adm1 - data table containing adm1
# information incidence_estimated - data
# table containing estimated incidence
# j_adm1_incidence_estimated - join table
# for adm1 and estimated incidence pop -
# data table containing population
# j_adm1_pop - join table for adm1 and
# population Output: data table containing
# calculated adjusted cases
cal_cases_adjusted <- function(adm1, incidence_estimated,
    j_adm1_incidence_estimated, pop, j_adm1_pop) {
    setkey(adm1)
    setkey(j_adm1_incidence_estimated)
    setkey(incidence_estimated)
    setkey(pop)
    setkey(j_adm1_pop)
    incidence <- adm1[j_adm1_incidence_estimated,
        on = c(id = "id_adm1")][incidence_estimated,
        on = c(id_db = "id")]
    pop_adm1 <- adm1[j_adm1_pop, on = c(id = "id_adm1")][pop,
        on = c(id_db = "id")]
    cases <- incidence[pop_adm1, on = c("id",
        "adm1", "year")][, cases := incidence_estimated_rmean *
        pop][year >= 2009]
    # Extract values for the years 2009
    pop_2009 <- cases[year == 2009, .(adm1, pop_2009 = pop)]
    # Merge the baseline adjusted incidence
    # back into the original data.table
    result <- cases[pop_2009, .(adm1, year, cases,
        adj_cases = incidence_estimated_rmean *
            pop * pop_2009/pop), on = "adm1"]

    return(result)
}

load_dhs_national <- function(p_dhs) {
    dhs <- read_excel(p_dhs) |>
        as.data.table()
    # [1] 'Country [2] 'Year' [3] 'Survey'
    # [6] 'Malaria prevalence according to
    # RDT' [7] 'Malaria prevalence according
    # to microscopy' [8] 'Persons with
    # access to an insecticide-treated
    # mosquito net (ITN)' [9] 'Children who
    # took any ACT' [10] 'Children tested
    # for malaria with RDT' [11] 'Children
    # with fever who had blood taken from a
    # finger or heel for testing' [12]
    # 'Existing insecticide-treated mosquito
    # nets (ITNs) used last night' [13]
    # 'Children under 5 who slept under any
    # net' [14] 'Population who slept under
    # an insecticide-treated mosquito net
    # (ITN) last night' [15] 'Advice or
    # treatment for fever sought from a
    # health facility or provider' [16]
    # 'Children under 5 who slept under an
    # insecticide-treated net (ITN)' rename
    # columns, labels and units, rename
    # state to adm1 rename year to year
    dhs <- upData(dhs, rename = c(Year = "year",
        Survey = "survey", `Malaria prevalence according to RDT` = "prevalence_rdt",
        `Malaria prevalence according to microscopy` = "prevalence_microscopy",
        `Persons with access to an insecticide-treated mosquito net (ITN)` = "access_itn",
        `Children who took any ACT` = "children_act",
        `Children tested for malaria with RDT` = "children_tested_rdt",
        `Children with fever who had blood taken from a finger or heel for testing` = "children_fever_blood",
        `Existing insecticide-treated mosquito nets (ITNs) used last night` = "existing_itn_used",
        `Children under 5 who slept under any net` = "u5_slept_any_net",
        `Population who slept under an insecticide-treated mosquito net (ITN) last night` = "population_slept_itn",
        `Advice or treatment for fever sought from a health facility or provider` = "advice_treatment_fever",
        `Children under 5 who slept under an insecticide-treated net (ITN)` = "u5_slept_itn"),
        units = c(prevalence_rdt = "%", prevalence_microscopy = "%",
            access_itn = "%", children_act = "%",
            children_tested_rdt = "%", children_fever_blood = "%",
            existing_itn_used = "%", u5_slept_any_net = "%",
            population_slept_itn = "%", advice_treatment_fever = "%",
            u5_slept_itn = "%"))
    # exclude country filter out Level ==
    # 'L1' remove level column
    dhs[, Country := NULL]
    dhs[, children_fever_blood := children_fever_blood/advice_treatment_fever *
        100]
    return(dhs)
}

#' Load DHS data
#' 
#' This function loads DHS data from a CSV file and performs data cleaning and transformation.
#' Steps of the data cleaning and transformation are as follows:
#' 1. Read the CSV file into a data table, using the fread function.
#' 2. Add meta data information to the data table, using the upData function from the Hmisc package.
#' 3. exclude country column from the data table.
#' 4. filter out Level == 'L1' from the data table. as only L2 are used in the analysis.
#' 5. remove level column from the data table.
#' 6. rename columns, labels and units.
#' 7. calculate the percentage of children with fever who had blood taken from a finger or heel for testing by dividing the children_fever_blood column by the advice_treatment_fever column and multiplying by 100.
#' 8. return the resulting data table.
load_dhs <- function(p_dhs) {
    dhs <- fread(p_dhs)
    # [1] 'Country [2] 'Year' [3] 'Survey'
    # [5] 'Level' [6] 'Malaria prevalence
    # according to RDT' [7] 'Malaria
    # prevalence according to microscopy'
    # [8] 'Persons with access to an
    # insecticide-treated mosquito net
    # (ITN)' [9] 'Children who took any ACT'
    # [10] 'Children tested for malaria with
    # RDT' [11] 'Children with fever who had
    # blood taken from a finger or heel for
    # testing' [12] 'Existing
    # insecticide-treated mosquito nets
    # (ITNs) used last night' [13] 'Children
    # under 5 who slept under any net' [14]
    # 'Population who slept under an
    # insecticide-treated mosquito net (ITN)
    # last night' [15] 'Advice or treatment
    # for fever sought from a health
    # facility or provider' [16] 'Children
    # under 5 who slept under an
    # insecticide-treated net (ITN)' rename
    # columns, labels and units, rename
    # state to adm1 rename year to year
    dhs <- upData(dhs, rename = c(State = "adm1",
        Year = "year", Survey = "survey", `Malaria prevalence according to RDT` = "prevalence_rdt",
        `Malaria prevalence according to microscopy` = "prevalence_microscopy",
        `Persons with access to an insecticide-treated mosquito net (ITN)` = "access_itn",
        `Children who took any ACT` = "children_act",
        `Children tested for malaria with RDT` = "children_tested_rdt",
        `Children with fever who had blood taken from a finger or heel for testing` = "children_fever_blood",
        `Existing insecticide-treated mosquito nets (ITNs) used last night` = "existing_itn_used",
        `Children under 5 who slept under any net` = "u5_slept_any_net",
        `Population who slept under an insecticide-treated mosquito net (ITN) last night` = "population_slept_itn",
        `Advice or treatment for fever sought from a health facility or provider` = "advice_treatment_fever",
        `Children under 5 who slept under an insecticide-treated net (ITN)` = "u5_slept_itn"),
        units = c(prevalence_rdt = "%", prevalence_microscopy = "%",
            access_itn = "%", children_act = "%",
            children_tested_rdt = "%", children_fever_blood = "%",
            existing_itn_used = "%", u5_slept_any_net = "%",
            population_slept_itn = "%", advice_treatment_fever = "%",
            u5_slept_itn = "%"))
    # exclude country filter out Level ==
    # 'L1' remove level column
    dhs[, Country := NULL]
    dhs <- dhs[Level != "L1"]
    dhs[, Level := NULL]
    dhs[, children_fever_blood := children_fever_blood/advice_treatment_fever *
        100]
    return(dhs)
}

#' Load IPT data
#' 
#' This function loads IPT data from a CSV file and performs data cleaning and transformation.
#' Steps of the data cleaning and transformation are as follows:
#' 1. Read the CSV file into a data table, using the fread function.
#' 2. Add meta data information to the data table, using the upData function from the Hmisc package.
#' 3. Return the resulting data table.
load_ipt <- function(p_ipt) {
    ipt <- fread(p_ipt)
    ipt <- upData(ipt, units = c(date = "Date",
        value = "%"))

    return(ipt)
}

#' Load National IPT data
#' 
#' This function loads National IPT data from a CSV file and performs data cleaning and transformation.
#' Steps of the data cleaning and transformation are as follows:
#' 1. Read the CSV file into a data table, using the fread function.
#' 
#' 2. Add meta data information to the data table, using the upData function from the Hmisc package.
#' 3. Join the data table with the population data table, using the adm1 and year columns as the join keys.
#' 4. Calculate the coverage of IPT1 or IPT2 by dividing the value column by the pop column.
#' 5. Sum the pop and coverage columns by year and name.
#' 6. Calculate the coverage of IPT1 or IPT2 by dividing the coverage column by the pop column.
#' 7. Return the resulting data table.
load_ipt_national <- function(p_ipt, pop) {
    ipt <- fread(p_ipt)
    ipt <- upData(ipt, units = c(date = "Date",
        value = "%"))
    ipt <- ipt[pop, on = c("adm1", "year"), nomatch = FALSE]
    ipt[, cover := value * pop][, .(pop = sum(pop,
        na.rm = TRUE), cover = sum(cover, na.rm = TRUE)),
        by = c("year", "name")][, value :=
        cover/pop]
}

#' Load rainfall data
#' 
#' This function loads rainfall data from a CSV file and performs data cleaning and transformation.
#' Steps of the data cleaning and transformation are as follows:
#' 1. Read the CSV file into a data table, using the fread function.
#' 2. Add meta data information to the data table, using the upData function from the Hmisc package.
#' 3. Return the resulting data table.
load_rainfall <- function(p_rainfall) {
    rainfall <- fread(p_rainfall)
    rainfall <- upData(rainfall, units = c(date = "Date",
        year = "Year", month = "Month", rainfall = "mm"))
    return(rainfall)
}

#' Load Long Lasting Insecticidal Nets (LLINs) data
#' 
#' This function loads LLINs data from an Excel file and performs data cleaning and transformation.
#' Steps of the data cleaning and transformation are as follows:
#' 1. Read the Excel file into a data frame.
#' 2. transform the data frame to a data table.
#' 3. Reshape the data table from wide to long format
#' 4. Return the resulting data table.
load_llins <- function(p) {
    llins <- read_excel(p, sheet = "total")
    llins <- as.data.table(llins)
    # adm1,year,llins_num
    llins <- melt(llins, id.vars = "adm1", variable.name = "year",
        value.name = "llins_num")
    return(llins)
}

#' Load SMC data
#' 
#' This function loads SMC data from an Excel file and performs data cleaning and transformation.
#' Steps of the data cleaning and transformation are as follows:
#' 1. Read the Excel file into a data frame.
#' 2. Skip the first row of the data frame.
#' 3. Convert the data frame to a data table.
#' 4. Select the columns adm1, adm2, year, smc1_num, smc2_num, smc3_num, and smc4_num.
#' 5. Sum the columns smc1_num, smc2_num, smc3_num, and smc4_num by adm1 and year. Ignore NA values.
#' 6. Reshape the data table from wide to long format, with adm1 and year as the id variables and smc1_num, smc2_num, smc3_num, and smc4_num as the value variables. The resulting data table has one row for each adm1-year pair. The column names are adm1, year, name, and value.
#' 7. Create a data table containing all adm1-year pairs.
#' 8. Join the data table containing all adm1-year pairs to the data table containing the SMC data.
#' 9. Return the resulting data table.
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

load_pop_census <- function(p) {
    pop_census <- fread(p)
    pop_census <- upData(pop_census, units = c(population_2006 = "Population",
        population_2019 = "Population"))
}

load_itn_campaigns <- function(path) {
    itn_campaigns <- fread(path)

    itn_campaigns <- upData(itn_campaigns, units = c(year_most_recent_itn_campaign = "Year",
        year_previous_itn_campaign = "Year"))
}

load_mortality <- function(p) {
    d <- read_excel(p)
    d <- as.data.table(d)
    d <- d[year >= 2014, .(year, mortality)]
}

load_nga_seasons <- function(p) {
    season <- fread(p)
}

load_death <- function(p) {
    d <- read_excel(p)
    d <- as.data.table(d)
    d <- d[year >= 2014, .(year, deaths)]
}

#' Calculate the cumulative cases averted
#' 
#' This function calculates the cumulative cases averted based on the input data frame. The function takes a data frame containing the cases estimated by Cyril and returns a data frame containing the cumulative cases averted.
#' Detailed steps of the calculation are as follows:
#' 1. Order the data frame by year
#' 2. Select the columns adm1, year, and cases
#' 3. Reshape the data frame from wide to long format, with year as the id variable and cases as the value variable. The resulting data frame has one row for each adm1-year pair. The column names are adm1, year, and cases.
#' 4. Add a column base_case with the value of cases in 2009
#' 5. Select the columns adm1, base_case, and 2009:2022
#' 6. Reshape the data frame from wide to long format, with adm1 and base_case as the id variables and year as the value variable. The resulting data frame has one row for each adm1-year pair. The column names are adm1, base_case, year, and value.
#' 7. Add a column cases_averted with the value of base_case - value
#' 8. Caculate the cumulative cases averted by adm1 and year by using the cumsum function
#' 9. Return the resulting data frame
#' @param cases A data frame containing the cases estimated by Cyril
#' @return A data frame containing the cumulative cases averted
#' @export
cal_cumulative_cases_averted <- function(cases) {
    cases <- cases[order(year)][, .(adm1, year,
        cases)][, dcast(.SD, adm1 ~ year, value.var = "cases")][,
        base_case := `2009`][, .SD, .SDcols = c("adm1",
        "base_case", "2009":"2022")][, melt(.SD,
        id.vars = c("adm1", "base_case"), variable.name = "year",
        value.name = "value")][, cases_averted :=
        base_case - value][, .(year, cumulative_cases_averted = cumsum(cases_averted)),
        by = .(adm1)]
}

#' Calculate the adjusted cumulative cases
#' 
#' This function calculates the adjusted cumulative cases based on the input data frame. The function takes a data frame containing the cases estimated by Cyril and returns a data frame containing the adjusted cumulative cases.
#' Detailed steps of the calculation are as follows:
#' 1. set the baseline year to 2009
#' 2. Select the columns adm1, year, and cases
#' 3. Join the data frame with the baseline year to the data frame with the cases estimated
#' 4. Calculate the cases_averted by subtracting the cases estimated from the baseline year from the cases estimated from the current year
#' 5. Caculate the cumulative cases averted by adm1 and year by using the cumsum function
#' 6. Return the resulting data frame
#' 
#' @param cases A data frame containing the cases estimated
#' @return A data frame containing the adjusted cumulative cases
#' @export
cal_cumulative_cases_averted_adjusted <- function(cases) {
    # baseline year is the cases in 2009
    cases_baseline <- cases[year == 2009, .(adm1,
        cases_baseline = adj_cases)]
    cases[cases_baseline, cases_averted :=
        cases_baseline - adj_cases, on = "adm1"][,
        .(year, cumulative_cases_averted = cumsum(cases_averted)),
        by = .(adm1)]
}

#' Calculate the database for the repor
#' 
#' This function calculates various indicators for the NGA 2022 WMR Supplement project based on input data frames. The function takes the following data frames as input: adm1, population_census, population_cyril_estimated, cases_estimated_pop_estimated, incidence_estimated, dhs, cumulative_cases_averted, llins, ipt, seasons, rainfall_adm1, and itn_campaigns. The function joins the data frames and calculates various indicators related to malaria prevalence, cases, incidence, ITN usage, and other factors. The resulting data frame is returned.
#' @param adm1 A data frame containing the adm1 data
#' @param population_census A data frame containing the population census data
#' @param population_cyril_estimated A data frame containing the population estimated by Cyril
#' @param cases_estimated_pop_estimated A data frame containing the cases estimated by Cyril
#' @param incidence_estimated A data frame containing the incidence estimated by Cyril
#' @param dhs A data frame containing the DHS data
#' @param cumulative_cases_averted A data frame containing the cumulative cases averted
#' @param llins A data frame containing the LLINs data
#' @param ipt A data frame containing the IPT data
#' @param seasons A data frame containing the seasons data
#' @param rainfall_adm1 A data frame containing the rainfall data
#' @param itn_campaigns A data frame containing the ITN campaigns data
#' @return A data frame containing the calculated indicators
#' @export
cal_db_for_report <- function(adm1, population_census,
    population_cyril_estimated, cases_estimated_pop_estimated,
    incidence_estimated, dhs, cumulative_cases_averted,
    llins, ipt, seasons, rainfall_adm1, itn_campaigns) {
    # load population census
    result <- adm1[population_census, on = "adm1"][,
        pop_census_2019 := population_2019][,
        .(adm1, pop_census_2019)]

    # load population cyril estimated
    pop_cyril_estimated <- population_cyril_estimated[year ==
        2022][, pop_cyril_2022 := pop][, .(adm1,
        pop_cyril_2022)]

    result <- result[pop_cyril_estimated, on = "adm1"]

    # load cases estimated pop estimated
    cases_2021 <- cases_estimated_pop_estimated[year ==
        2021][, cases_2021 := cases][, .(adm1,
        cases_2021)]
    # summarize across adm1 get one national
    # total cases for 2021
    total_cases_2021 <- cases_2021[, sum(cases_2021)]
    # WMR cases
    total_cases_2021_wmr <- 65399501

    cases_2018 <- cases_estimated_pop_estimated[year ==
        2018][, cases_2018 := cases][, .(adm1,
        cases_2018)]

    result <- result[cases_2021, on = "adm1"]
    result <- result[cases_2018, on = "adm1"]
    result[, p_cases_2021 := cases_2021/total_cases_2021]

    # load incidence estimated
    incid_2018 <- incidence_estimated[year ==
        2018][, incid_2018 := incidence_estimated_rmean][,
        .(adm1, incid_2018)]
    incid_2021 <- incidence_estimated[year ==
        2021][, incid_2021 := incidence_estimated_rmean][,
        .(adm1, incid_2021)]

    result <- result[incid_2018, on = "adm1"]
    result <- result[incid_2021, on = "adm1"]

    # load dhs load prevalence microscopy
    prev_micro_2015 <- dhs[year == 2015][, prev_micro_2015 :=
        prevalence_microscopy][, .(adm1, prev_micro_2015)]
    prev_micro_2021 <- dhs[year == 2021][, prev_micro_2021 :=
        prevalence_microscopy][, .(adm1, prev_micro_2021)]
    result <- result[prev_micro_2015, on = "adm1"]
    result <- result[prev_micro_2021, on = "adm1"]

    # compare cases in 2018 and 2021,
    # generate a new column: cases_trend, if
    # 2021 > 2018 then cases_trend =
    # 'increased', else cases_trend =
    # 'decreased'
    result[, cases_trend := ifelse(cases_2021 >
        cases_2018, "increased", "decreased")]
    result[, incid_trend := ifelse(incid_2021 >
        incid_2018, "increased", "decreased")]
    # calculate the trend in prevalence
    result[, prev_trend := ifelse(prev_micro_2021 >
        prev_micro_2015, "increased", "decreased")]

    # load cumulative cases averted
    cumulative_cases_averted_2015 <- cumulative_cases_averted[year ==
        2015][, cumulative_cases_averted_2015 :=
        cumulative_cases_averted][, .(adm1, cumulative_cases_averted_2015)]
    cumulative_cases_averted_2021 <- cumulative_cases_averted[year ==
        2021][, cumulative_cases_averted_2021 :=
        cumulative_cases_averted][, .(adm1, cumulative_cases_averted_2021)]

    # calculate the trend in cumulative
    # cases averted
    result <- result[cumulative_cases_averted_2015,
        on = "adm1"]
    result <- result[cumulative_cases_averted_2021,
        on = "adm1"]
    result <- result[, cumulative_cases_averted_trend :=
        ifelse(cumulative_cases_averted_2021 >
            cumulative_cases_averted_2015, "increased",
            "decreased")]

    itn_campaigns <- itn_campaigns[, .(adm1, year_most_recent_itn_campaign)]
    result <- result[itn_campaigns, on = "adm1"]

    # sum up the number of LLINs distributed
    # in each adm1
    llins <- llins[, .(llins_num = sum(llins_num)),
        by = .(adm1)]
    result <- result[llins, on = "adm1"]

    # get population_slept_itn from DHS for
    # 2015 and 2021
    population_slept_itn_2015 <- dhs[year == 2015][,
        population_slept_itn_2015 := population_slept_itn][,
        .(adm1, population_slept_itn_2015)]
    population_slept_itn_2021 <- dhs[year == 2021][,
        population_slept_itn_2021 := population_slept_itn][,
        .(adm1, population_slept_itn_2021)]
    result <- result[population_slept_itn_2015,
        on = "adm1"]
    result <- result[population_slept_itn_2021,
        on = "adm1"]
    result[, population_slept_itn_trend :=
        ifelse(population_slept_itn_2021 > population_slept_itn_2015,
            "increased", "decreased")]

    # children_fever_blood 2015, 2021 from
    # dhs
    finger_2015 <- dhs[year == 2015][, finger_2015 :=
        children_fever_blood][, .(adm1, finger_2015)]

    finger_2021 <- dhs[year == 2021][, finger_2021 :=
        children_fever_blood][, .(adm1, finger_2021)]

    result <- result[finger_2015, on = "adm1"][finger_2021,
        on = "adm1"]
    result[, finger_trend := ifelse(finger_2021 >
        finger_2015, "increased", "decreased")]
    # get advice_treatment_fever from DHS
    # for 2015 and 2021
    advice_treatment_fever_2015 <- dhs[year ==
        2015][, advice_treatment_fever_2015 :=
        advice_treatment_fever][, .(adm1, advice_treatment_fever_2015)]
    advice_treatment_fever_2021 <- dhs[year ==
        2021][, advice_treatment_fever_2021 :=
        advice_treatment_fever][, .(adm1, advice_treatment_fever_2021)]
    result <- result[advice_treatment_fever_2015,
        on = "adm1"]
    result <- result[advice_treatment_fever_2021,
        on = "adm1"]
    result[, advice_treatment_fever_trend :=
        ifelse(advice_treatment_fever_2021 > advice_treatment_fever_2015,
            "increased", "decreased")]
    ipt2 <- ipt[name == "ipt2_cov"][, ipt2_cov :=
        value]
    # get ipt2 coverage from 2015 and 2021
    ipt2_cov_2015 <- ipt2[year == 2015][, ipt2_cov_2015 :=
        ipt2_cov][, .(adm1, ipt2_cov_2015)]
    ipt2_cov_2021 <- ipt2[year == 2021][, ipt2_cov_2021 :=
        ipt2_cov][, .(adm1, ipt2_cov_2021)]
    result <- ipt2_cov_2015[result, on = "adm1"]
    result <- ipt2_cov_2021[result, on = "adm1"]
    result[, ipt2_cov_trend := ifelse(ipt2_cov_2021 >
        ipt2_cov_2015, "increased", "decreased")]
    result <- seasons[result, on = "adm1"]
    result <- rainfall_adm1[result, on = "adm1"]

    return(result)
}

#' Calculate the rainfall for each state in Nigeria
#' 
#' This function calculates the rainfall for each state in Nigeria. The function takes a data frame containing rainfall data as input. The calculation process is as follows:
#' 1. Group the data frame by adm1, year, and month.
#' 2. Calculate the sum of rainfall for each month.
#' 
cal_rainfall_adm1 <- function(rainfall) {
    # adm1, year, month, rainfall group by
    # adm1, year, sum rainfall
    rainfall <- rainfall[, .(rainfall = sum(rainfall)),
        by = .(adm1, year)]
    # group by adm1, calculate mean rainfall
    rainfall <- rainfall[, .(rainfall = mean(rainfall)),
        by = .(adm1)]
}

#' @title Calculate cumulative deaths averted
#' 
#' This function calculates cumulative deaths averted for each state in Nigeria. The function takes a data frame containing mortality data as input.
#' The calculation process is as follows:
#' 1. Filter the data frame to include only data from 2009 onwards. Detailed explaination was explained in the report.
#' 2. Calculate the baseline deaths in 2009.
#' 3. Calculate the deaths averted by subtracting the deaths in each year from the baseline deaths.
#' 4. Calculate the cumulative deaths averted by summing the deaths averted in each year.
#' @param d A data frame containing mortality data.
#' @return A data frame containing cumulative deaths averted for each state in Nigeria.
#' @export
#' @examples
#' # Load data frame
#' d <- read_csv('data/mortality.csv')
#' # Calculate cumulative deaths averted
#' cal_cumulative_deaths_averted(d)
#' # View the resulting data frame
#' head(d)
cal_cumulative_deaths_averted <- function(d) {
    # baseline year is the cases in 2009
    d <- d[year >= 2009]
    deaths_baseline <- d[year == 2009, deaths]
    d[, deaths_baseline := deaths_baseline][,
        deaths_averted := deaths_baseline -
            deaths][, .(year, cumulative_deaths_averted = cumsum(deaths_averted))]
}

#' @title Generate indicators
#' 
#' This function generates state-level indicators for the NGA 2022 WMR Supplement project. The function takes four data frames as input: population_census, cases, incidence_estimated_raw, and dhs. The function joins the data frames and calculates various indicators related to malaria prevalence, cases, incidence, and ITN usage. The resulting data frame is written to a CSV file and returned.
#' @param population_census A data frame containing population census data.
#' @param cases A data frame containing malaria case data.
#' @param incidence_estimated_raw A data frame containing estimated malaria incidence data.
#' @param dhs A data frame containing DHS data.
#' @return A data frame containing state-level indicators for the NGA 2022 WMR Supplement project.
#' @export
#' @examples
#' # Load data frames
#' population_census <- read_csv('data/population_census.csv')
#' cases <- read_csv('data/cases.csv')
#' incidence_estimated_raw <- read_csv('data/#' incidence_estimated_raw.csv')
#' dhs <- read_csv('data/dhs.csv')
#' 
#' # Generate national-level indicators
#' indicators <- gen_indicator_national(population_census, cases, #' incidence_estimated_raw, dhs)
#' 
#' # View the resulting data frame
#' head(indicators)
gen_indicator <- function(population_census, cases_estimated_pop_estimated,
    incidence_estimated_raw, dhs) {
    # State, Pop, 'Malaria prevalence
    # according to RDT', 'Malaria prevalence
    # according to microscopy', cases_mean,
    # incidence, 'Persons with access to an
    # insecticide-treated mosquito net
    # (ITN)', 'Existing insecticide-treated
    # mosquito nets (ITNs) used last night',
    # 'Population who slept under an
    # insecticide-treated mosquito net (ITN)
    # last night', 'Children under 5 who
    # slept under any net', # nolint
    # 'Children under 5 who slept under an
    # insecticide-treated net (ITN)',
    # 'Advice or treatment for fever sought
    # from a health facility or provider',
    # 'Children with fever who had blood
    # taken from a finger or heel for
    # testing' # nolint

    # [1] 'adm1' 'pop' 'cases' [4]
    # 'incidence_estimated_rmean' 'year'
    # 'survey' [7] 'prevalence_rdt'
    # 'prevalence_microscopy' 'access_itn'
    # [10] 'children_act'
    # 'children_tested_rdt'
    # 'children_fever_blood' [13]
    # 'existing_itn_used' 'u5_slept_any_net'
    # 'population_slept_itn' [16]
    # 'advice_treatment_fever'
    # 'u5_slept_itn'
    browser()
    result <- population_census[, .(adm1, population_2019)][cases_estimated_pop_estimated[year ==
        2021][, .(adm1, cases)], on = "adm1"][incidence_estimated_raw[year ==
        2021][, .(adm1, incidence_estimated_rmean)],
        on = "adm1"][dhs[year == 2021], on = "adm1"] |>
        arrange(adm1)
    result <- result[, .(adm1, pop = round(population_2019/1000) *
        1000, `Malaria prevalence according to RDT` = prevalence_rdt,
        `Malaria prevalence according to microscopy` = prevalence_microscopy,
        cases = round(cases/1000) * 1000, incidence = round(incidence_estimated_rmean *
            1000, 1), `Persons with access to an insecticide-treated mosquito net (ITN)` = access_itn,
        `Existing insecticide-treated mosquito nets (ITNs) used last night` = existing_itn_used,
        `Population who slept under an insecticide-treated mosquito net (ITN) last night` = population_slept_itn,
        `Children under 5 who slept under any net` = u5_slept_any_net,
        `Children under 5 who slept under an insecticide-treated net (ITN)` = u5_slept_itn,
        `Advice or treatment for fever sought from a health facility or provider` = advice_treatment_fever,
        `Children with fever who had blood taken from a finger or heel for testing` = round(children_fever_blood,
            1))]
    write_csv(result, "result/indicators.csv")
    return(result)
    # rename columns
}

#' @title Generate national indicators
#' 
#' This function generates national-level indicators for the NGA 2022 WMR Supplement project. The function takes four data frames as input: population_census, cases, incidence_estimated_raw, and dhs. The function joins the data frames and calculates various indicators related to malaria prevalence, cases, incidence, and ITN usage. The resulting data frame is written to a CSV file and returned.
#' @param population_census A data frame containing population census data.
#' @param cases A data frame containing malaria case data.
#' @param incidence_estimated_raw A data frame containing estimated malaria incidence data.
#' @param dhs A data frame containing DHS data.
#' @return A data frame containing national-level indicators for the NGA 2022 WMR Supplement project.
#' @export
#' @examples
#' # Load data frames
#' population_census <- read_csv('data/population_census.csv')
#' cases <- read_csv('data/cases.csv')
#' incidence_estimated_raw <- read_csv('data/#' incidence_estimated_raw.csv')
#' dhs <- read_csv('data/dhs.csv')
#' 
#' # Generate national-level indicators
#' indicators <- gen_indicator_national(population_census, cases, #' incidence_estimated_raw, dhs)
#' 
#' # View the resulting data frame
#' head(indicators)
gen_indicator_national <- function(population_census,
    cases, incidence_estimated_raw, dhs) {
    # State, Pop, 'Malaria prevalence
    # according to RDT', 'Malaria prevalence
    # according to microscopy', cases_mean,
    # incidence, 'Persons with access to an
    # insecticide-treated mosquito net
    # (ITN)', 'Existing insecticide-treated
    # mosquito nets (ITNs) used last night',
    # 'Population who slept under an
    # insecticide-treated mosquito net (ITN)
    # last night', 'Children under 5 who
    # slept under any net', # nolint
    # 'Children under 5 who slept under an
    # insecticide-treated net (ITN)',
    # 'Advice or treatment for fever sought
    # from a health facility or provider',
    # 'Children with fever who had blood
    # taken from a finger or heel for
    # testing' # nolint

    # [1] 'adm1' 'pop' 'cases' [4]
    # 'incidence_estimated_rmean' 'year'
    # 'survey' [7] 'prevalence_rdt'
    # 'prevalence_microscopy' 'access_itn'
    # [10] 'children_act'
    # 'children_tested_rdt'
    # 'children_fever_blood' [13]
    # 'existing_itn_used' 'u5_slept_any_net'
    # 'population_slept_itn' [16]
    # 'advice_treatment_fever'
    # 'u5_slept_itn'
    population_census <- population_census[, .(population_2019 = sum(population_2019))][,
        country := "nga"]
    cases <- cases[year == 2021, .(cases)][, country :=
        "nga"]
    incidence_estimated_raw <- incidence_estimated_raw[year ==
        2021, .(incidence_estimated_rmean)][,
        country := "nga"]
    dhs <- dhs[year == 2021][, country := "nga"]
    result <- population_census[cases, on = "country"][incidence_estimated_raw,
        on = "country"][dhs, on = "country"]

    result <- result[, .(pop = floor(population_2019),
        `Malaria prevalence according to RDT` = prevalence_rdt,
        `Malaria prevalence according to microscopy` = prevalence_microscopy,
        cases = floor(cases), incidence = incidence_estimated_rmean,
        `Persons with access to an insecticide-treated mosquito net (ITN)` = access_itn,
        `Existing insecticide-treated mosquito nets (ITNs) used last night` = existing_itn_used,
        `Population who slept under an insecticide-treated mosquito net (ITN) last night` = population_slept_itn,
        `Children under 5 who slept under any net` = u5_slept_any_net,
        `Children under 5 who slept under an insecticide-treated net (ITN)` = u5_slept_itn,
        `Advice or treatment for fever sought from a health facility or provider` = advice_treatment_fever,
        `Children with fever who had blood taken from a finger or heel for testing` = children_fever_blood)]
    write_csv(result, "result/national_indicators.csv")
    return(result)
}
