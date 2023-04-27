join_adm1 <- function(adm1, db) {
        merged <- adm1[db, on = "adm1"]
        merged <- merged[!is.na(id)]
        merged <- merged[, .(id_adm1 = id, id_db = i.id)]
        setkey(merged, id_adm1, id_db)
        return(merged)
}
# remove adm1 from db
after_join_adm1 <- function(db){
        setDT(db)
        db[, adm1 := NULL]
        return(db)
}
