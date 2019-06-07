library (tuber)
path <- "C:\\Users\\AR064679\\Documents\\thesis\\final R\\videoAnalysis\\processed\\links.txt"
app_id <- "151536471484-d9lcn5ms69arj6f10v3ja4opdf718ppq.apps.googleusercontent.com"
app_secret <-"AmPrW7gfBKqJdZ8_LpUXKNVJ"
yt_oauth(app_id, app_secret, token = "")
res<-yt_search(term = "winston speech")
View(res)
final<-head(res[-1,1:1])
View(final)
final <- sub("^", "https://www.youtube.com/watch?v=", final)
write.table(final, file = path, sep = "",
            row.names = FALSE,quote = FALSE)


