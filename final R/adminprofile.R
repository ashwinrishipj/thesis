#* Plot a histogram
#* @png
#* @get /echo
function(user)
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
#Follower=friends creates the vertices of @CCIcareers 20 friends and makes arrows to them
#User=followers, Follower=@CCICareer Creates the vertices of the 20 people @CCICareer follows and makes arrows to them
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
