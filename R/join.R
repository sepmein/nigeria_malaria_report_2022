# This function joins an adm1 data frame with a database data frame based on the "adm1" column, 
# removes rows where the "id" column is NA, and returns a data frame with columns "id_adm1" and "id_db".
join_adm1 <- function(adm1, db) {
        merged <- adm1[db, on = "adm1"]
        merged <- merged[!is.na(id)]
        merged <- merged[, .(id_adm1 = id, id_db = i.id)]
        setkey(merged, id_adm1, id_db)
        return(merged)
}

# This function removes the "adm1" column from a data frame.
after_join_adm1 <- function(db) {
        setDT(db)
        db[, adm1 := NULL]
        return(db)
}
