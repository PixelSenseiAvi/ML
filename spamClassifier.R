# for text mining
library(tm)
# ggplot2
library('ggplot2')

# paths
spam.path <- '/home/chik/Downloads/03-Classification/data/spam/'
spam2.path <- '/home/chik/Downloads/03-Classification/data/spam_2/'
easyham.path <- '/home/chik/Downloads/03-Classification/data/easy_ham/'
easyham2.path <- '/home/chik/Downloads/03-Classification/data/easy_ham_2/'
hardham.path <- '/home/chik/Downloads/03-Classification/data/hard_ham/'
hardham2.path <- '/home/chik/Downloads/03-Classification/data/hard_ham_2/'

# creating a function to return the message after null line
get.msg <- function(path){
  # creating connection to the path
  # open = rt means read as text
  con <- file(path, open = "rt", encoding = "latin1")
  # readLines is used to read lines from a connection
  text <- readLines(con = con)
  # Taking the text after null line
  msg <- text[seq(which(text == "")[1] + 1, length(text), 1)]
  close(con)
  return(paste(msg, collapse = "\n"))
}

# dir returns the character stream of the files in the directory
spam.docs <- dir(spam.path)
spam.docs <- spam.docs[which(spam.docs!="cmds")]
# sapply applies a function to a vector and return the resulting vector
all.spam <- sapply(X = spam.docs, FUN = function(p) get.msg(paste(spam.path,p,sep = "")))

# getting TDM - term documentation matrix
# TDM gives the m*n matrix that defines the num of times each word occuring in a document
get.tdm <- function(doc.vec){
  # creating corpus of the documents 
  # VectorSource is used for creating source for Corpus  
  doc.corpus <- Corpus(VectorSource(doc.vec))
  # stopwords is used to remove common words in english
  # And, minFreq ensures that the min frequency of a word in TDM should be 2
  control <- list(stopwords = TRUE, removePunctuation = TRUE,
                  removeNumbers = TRUE, minDocFreq = 2)
  # TermDocumentatMatrix
  doc.dtm <- TermDocumentMatrix(x = doc.corpus, control = control)
  return(doc.dtm)
}

spam.tdm <- get.tdm(all.spam)

spam.matrix <- as.matrix(spam.tdm)
# total count of a word in all docs
spam.counts <- rowSums(spam.matrix)
# to df
spam.df <- data.frame(cbind(names(spam.counts), as.numeric(spam.counts)), stringsAsFactors = FALSE)
names(spam.df) <- c("term", "frequency")
spam.df$frequency <- as.numeric(spam.df$frequency)

# calculating % of documents in which word occurs by using spam.matrix
spam.occurrence <- sapply(1:nrow(spam.matrix), function(i){
                            length(which(spam.matrix[i, ] > 0)) / ncol(spam.matrix)})
# calculating density of each word w.r.t. entire corpus
spam.density <- spam.df$frequency / sum(spam.df$frequency)
# transforming data in df
spam.df <- transform(spam.df, density = spam.density, occurance = spam.occurrence)

# Now we got our spam data
# Similarly for ham data

ham.docs <- dir(easyham.path)
ham.docs <- ham.docs[which(ham.docs!="cmds")]

# taking only first 500 rows
ham.docs <- ham.docs[1:500]

all.ham <- sapply(X = ham.docs, FUN = function(p) get.msg(paste(easyham.path,p,sep = "")))

ham.tdm <- get.tdm(all.ham)

ham.matrix <- as.matrix(ham.tdm)

ham.counts <- rowSums(ham.matrix)

ham.df <- data.frame(cbind(names(ham.counts), as.numeric(ham.counts)), stringsAsFactors = FALSE)
names(ham.df) <- c("term", "frequency")
ham.df$frequency <- as.numeric(ham.df$frequency)

ham.occurrence <- sapply(1:nrow(ham.matrix), function(i){
  length(which(ham.matrix[i, ] > 0)) / ncol(ham.matrix)})

ham.density <- ham.df$frequency / sum(ham.df$frequency)

ham.df <- transform(ham.df, density = ham.density, occurance = ham.occurrence)


# classify email
# Assume the probability of the words that are not in TDM to be 0.000001
classify.email <- function(path, training.df, prior =0.5, c = 1e-6){
  # get.msg for reading message
  msg <- get.msg(path)
  # TDM for msg
  msg.tdm <- get.tdm(msg)
  # getting freq of matrix
  msg.freq <- rowSums(as.matrix(msg.tdm))
  
  # Common words in training df (say spam) and our msg
  msg.match <- intersect(names(msg.freq), training.df$term)
  
  # If match is of length <1 then it means none of the terms are in our training data (say spam)
  if(length(msg.match)<1){
    return(prior*c^(length(msg.freq)))
  }else{ 
    # else product of the probability of the match products and also that do not match (1e-6)
    # match.probs - probability of the matching words
    match.probs <- training.df$occurance[match(msg.match, training.df$term)]
    # there is 0.5 probab that an email is spam so u also have to take that in consideration
    # c*length of the product that does not match
    # overall product is given by
    return(prior* prod(match.probs)*c^(length(msg.freq)-length(msg.match)))
  }
  
  # The result is our Bayesian estimate 
}

# Trying to classify hard ham emails

hardham.docs <- dir(hardham.path)
hardham.docs <- hardham.docs[which(hardham.docs!="cmds")]

# testing against spam 
hardham.spamtest <- sapply(hardham.docs, FUN = function(p) 
  classify.email(paste(hardham.path,p, sep = ""), training.df = spam.df))

# testing against easyham
hardham.easyhamtest <- sapply(hardham.docs, FUN = function(p) 
  classify.email(paste(hardham.path,p, sep = ""), training.df = ham.df))

# taking greater values
hardham.res <- ifelse(hardham.spamtest > hardham.easyhamtest, TRUE, FALSE)

# Nice 93.9759 % accuracy on hardham

# Single function to classify spam or ham
# In general practice the ratio of ham-to-spam is 80-20%
spam.classifier <- function(path){
  pr.spam <- classify.email(path, spam.df, prior = 0.2)
  pr.ham <- classify.email(path, ham.df, prior = 0.8)
  return(c(pr.spam, pr.ham, ifelse(pr.spam > pr.ham, 1, 0)))
}


#
easyham2.docs <- dir(easyham2.path)
easyham2.docs <- easyham2.docs[which(easyham2.docs != "cmds")]

hardham2.docs <- dir(hardham2.path)
hardham2.docs <- hardham2.docs[which(hardham2.docs != "cmds")]

spam2.docs <- dir(spam2.path)
spam2.docs <- spam2.docs[which(spam2.docs != "cmds")]

# Classify them all!
easyham2.class <- suppressWarnings(lapply(easyham2.docs,
                                          function(p){ 
                                            spam.classifier(file.path(easyham2.path, p))
                                            }))
hardham2.class <- suppressWarnings(lapply(hardham2.docs,
                                          function(p)
                                          { spam.classifier(file.path(hardham2.path, p))
                                          }))
spam2.class <- suppressWarnings(lapply(spam2.docs,
                                       function(p){
                                         spam.classifier(file.path(spam2.path, p))
                                       }))

# Create a single, final, data frame with all of the classification data in it
easyham2.matrix <- do.call(rbind, easyham2.class)
easyham2.final <- cbind(easyham2.matrix, "EASYHAM")

hardham2.matrix <- do.call(rbind, hardham2.class)
hardham2.final <- cbind(hardham2.matrix, "HARDHAM")

spam2.matrix <- do.call(rbind, spam2.class)
spam2.final <- cbind(spam2.matrix, "SPAM")

class.matrix <- rbind(easyham2.final, hardham2.final, spam2.final)
class.df <- data.frame(class.matrix, stringsAsFactors = FALSE)
names(class.df) <- c("Pr.SPAM" ,"Pr.HAM", "Class", "Type")
class.df$Pr.SPAM <- as.numeric(class.df$Pr.SPAM)
class.df$Pr.HAM <- as.numeric(class.df$Pr.HAM)
class.df$Class <- as.logical(as.numeric(class.df$Class))
class.df$Type <- as.factor(class.df$Type)

# Getting accuracy
get.results <- function(bool.vector)
{
  results <- c(length(bool.vector[which(bool.vector == FALSE)]) / length(bool.vector),
               length(bool.vector[which(bool.vector == TRUE)]) / length(bool.vector))
  return(results)
}

# Save results as a 2x3 table
easyham2.col <- get.results(subset(class.df, Type == "EASYHAM")$Class)
hardham2.col <- get.results(subset(class.df, Type == "HARDHAM")$Class)
spam2.col <- get.results(subset(class.df, Type == "SPAM")$Class)

class.res <- rbind(easyham2.col, hardham2.col, spam2.col)
colnames(class.res) <- c("NOT SPAM", "SPAM")
print(class.res)

# 98% accuracy on easyham , 93 on hard ham , and 73 on spam 

# scatterplot of predicted probabilities

ggplot(data = class.df, aes(x = log(Pr.HAM), y = log(Pr.SPAM))) +
  geom_point(aes(color = Type))  + geom_abline(intercept = 0)+
  xlab("log[Pr(HAM)]") +
  ylab("log[Pr(SPAM)]") +
    theme_bw() + theme(axis.title.x = element_blank(), axis.title.y = element_blank())
