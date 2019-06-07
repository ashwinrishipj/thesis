library(mongolite)
library(plyr)
library(dplyr)
library(twitteR)
library(ROAuth)
library(wordcloud)
library(tm)
library(igraph)
library(ggplot2)
library(readtext)
library (tuber)

consumer_key <- "WfXMTCCC0C7h1GWQvAuUpiD6v"
consumer_secret <- "P0jMsqwfwekow6bPUc4BLxeCLfMKIkIsCqaanfgrnoMFy6IJI1"
access_token <- "523870397-EcuX2XaykeHfTwAunmHSc5Zm10ZxBglaq0Tljt85"
access_secret <- "5NrT9ICifGtainJgXx7QR00MSdPjY759ZYhMijb66IHLK"


setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

#* Plot a histogram
#* @png
#* @get /echo
function(msg="")
{
#Extract tweets. Example-
tweets = searchTwitter(msg,lang = "en", n=50)
tweets
setwd("C:/Users/Ashwin Rishi/Desktop/thesis/thesis/final R")
neg.words = scan("negative-words.txt", what="character", comment.char=";")
pos.words = scan("positive-words.txt", what="character", comment.char=";")

sample=NULL #Initialising
for (tweet in tweets)
  sample = c(sample,tweet$getText())

#converts to data frame
df <- do.call("rbind", lapply(tweets, as.data.frame))
View(df)
colnames(df)
#remove odd characters
df$text <- sapply(df$text,function(row) iconv(row, "latin1", "ASCII", sub="")) #remove emoticon
df$text = gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", df$text) #remove URL
df$text= gsub("[^[:alnum:]///' ]", "", df$text)#remove special caharacter
df$text=gsub('[0-9]+', '', df$text)
df$text=gsub("[[:punct:]]", " ", df$text)
sample <- df$text

generateYoutubeId = function()
{
  path <- "C:\\Users\\Ashwin Rishi\\Desktop\\thesis\\thesis\\final R\\videoAnalysis\\processed\\links.txt"
  app_id <- "151536471484-7alicm14kiijn4vtaemuntmepmft8elh.apps.googleusercontent.com"
  app_secret <-"AIzaSyDccjAtqIn3bXLSWEV1r4UTmhFRxaSdvow"
  yt_oauth(app_id, app_secret, token = "")
  res<-yt_search(term = "winston speech")
  View(res)
  final<-head(res[-1,1:1])
  View(final)
  final <- sub("^", "https://www.youtube.com/watch?v=", final)
  write.table(final, file = path, sep = "",
              row.names = FALSE,quote = FALSE)
}
generateYoutubeId()

#my_data <- read.delim("C:/Users/AR064679/Documents/thesis/final R/videoAnalysis/processed/output.txt")
#View(my_data)
#DFtranspose <- cbind(t(sample[52, ]), t(my_data))
#rownames(DFtranspose) <- sample[1, ]

#ggplot(df, aes(x=term,y=freq))+geom_bar(stat = "identity")+xlab("keyword")+ylab("no.of times the keyword appears")+coord_flip()



score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  list=lapply(sentences, function(sentence, pos.words, neg.words)
  {
    sentence = gsub('[[:punct:]]',' ',sentence)
    sentence = gsub('[[:cntrl:]]','',sentence)
    sentence = gsub('\\d+','',sentence)  #removes decimal number
    sentence = gsub('\n','',sentence)    #removes new lines
    sentence = tolower(sentence)
    word.list = str_split(sentence, '\\s+')
    words = unlist(word.list)  #changes a list to character vector
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    pp = sum(pos.matches)
    nn = sum(neg.matches)
    score = sum(pos.matches) - sum(neg.matches)
    list1 = c(score, pp, nn)
    return (list1)
  }, pos.words, neg.words)
  score_new = lapply(list, `[[`, 1)
  pp1 = lapply(list, `[[`, 2)
  nn1 = lapply(list, `[[`, 3)
  
  scores.df = data.frame(score = score_new, text=sentences)
  positive.df = data.frame(Positive = pp1, text=sentences)
  negative.df = data.frame(Negative = nn1, text=sentences)
  
  list_df = list(scores.df, positive.df, negative.df)
  return(list_df)
}

# Clean the tweets
result = score.sentiment(sample, pos.words, neg.words)
#install.packages("reshape")
library(reshape)
#Creating a copy of result data frame
test1=result[[1]]
test2=result[[2]]
test3=result[[3]]

#Creating three different data frames for Score, Positive and Negative
#Removing text column from data frame
test1$text=NULL
test2$text=NULL
test3$text=NULL
#Storing the first row(Containing the sentiment scores) in variable q
q1=test1[1,]
q2=test2[1,]
q3=test3[1,]
qq1=melt(q1,var='Score')
qq2=melt(q2,var='Positive')
qq3=melt(q3,var='Negative') 
qq1['Score'] = NULL
qq2['Positive'] = NULL
qq3['Negative'] = NULL
#Creating data frame
table1 = data.frame(Text=result[[1]]$text, Score=qq1)
table2 = data.frame(Text=result[[2]]$text, Score=qq2)
table3 = data.frame(Text=result[[3]]$text, Score=qq3)


#Merging three data frames into one
table_final=data.frame(Text=table1$Text, Score=table1$value, Positive=table2$value, Negative=table3$value)

mongodb<-mongo(collection = "senti",db="warehouse")
mongodb$insert(table_final)
allwords<-c("Anger","disgust","Not Satisfied","Equi-Vocal","Satisfied","Joy","Extreemely Happy")

#Histogram
positive<-table_final$Positive 
negative<-table_final$Negative 
hist(positive, col=terrain.colors(5))
hist(negative, col=rainbow(10))


hist(table_final$Score, col=rainbow(10),xaxt='n',xlab = "Sentiments",ylab = "Tweets",main="user Sentimental")
axis(1, at = seq(-3,3,by=1), labels = allwords)

#Pie
slices <- c(sum(table_final$Positive), sum(table_final$Negative))
labels <- c("Positive", "Negative")
#install.packages("plotrix")
library(plotrix)
#pie(slices, labels = labels, col=rainbow(length(labels)), main="Sentiment Analysis")
par(mfrow=c(3,1))
hist(positive, col="grey",xlim=c(0,2), ylim=c(0,35),main="overlapping")
hist(negative, col="white", xlim=c(0,3),xlab="positive and negative",add=T)
legend("topright", c("positive", "negative"), fill=c("grey", "white"))
box()
hist(table_final$Score, col=rainbow(10),xaxt='n',xlab = "Sentiments",ylab = "Tweets",main="user Sentimental")
axis(1, at = seq(-3,3,by=1), labels = allwords)
pie3D(slices, labels = labels, col=rainbow(length(labels)),explode=-0.00, main="Twitter Sentiment Analysis")

}

#* Plot a histogram
#* @png
#* @get /user
function()
{
  #now this is the beginning of taking a user from twitter and creating a bubble graph
  #of their followers and who they follow
  #get our twitter user
  start <- getUser("@ashwin_rishi")
  #lookup their friends and followers and add them to the variables
  theFriends <- lookupUsers(start$getFriendIDs())
  theFollowers <- lookupUsers(start$getFollowerIDs())
  
  #create a vector for friends and followers
  #we make the vector 20 friends and followers long (change the number 20 to change size of bubble graph)
  #pass in name parameter to get the friend/follower names only
  friends <- sapply(theFriends[1:20], name)
  followers <- sapply(theFollowers[1:20], name)
  
  #Create a 'relations' variable to merge the two data frames of friends and followers
  #Follower=friends creates the vertices of @ashwin_rishi 20 friends and makes arrows to them
  #User=followers, Follower=@ashwin_rishi Creates the vertices of the 20 people @ashwin_rishi follows and makes arrows to them
  relations <- merge(data.frame(User = '@ashwin_rishi', Follower=friends), data.frame
                     (User = followers, Follower='@ashwin_rishi'), all=TRUE)
  
  #create the graph of the relations variable and make the arrows directed
  g <- graph.data.frame(relations, directed = TRUE)
  
  #label the vertices with the followers and friends names
  V(g)$label <- V(g)$name
  
  #plot graph
  #NOTICE this loads in a differend window unlike the wordcloud which loads in the plots tab
  
  #TO CHANGE THE VERTICES COLOR, CLICK THE SELECT BUTTON IN THE TOP LEFT CORNER
  #OF THE GRAPHS WINDOW AND HIT 'SELECT ALL VERTICES', THEN RIGHT CLICK A VERTEX AND
  #HIT CHANGE COLOR
  tkplot(g)
  
}
