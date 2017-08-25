require(e1071)

# set seed is used to standarize the random numbers 
# so the performance does not changes every time you select some random variables 
set.seed(1)

# matrix of normalized random numbers
x = matrix(rnorm(200*2), ncol = 2)

# take first 100 rows to be high income people
x[1:100,] <- x[1:100,]+2
# take next 50 rows as low income people
x[101:150,] <- x[101:150,]-2
#rest is middle class

## goal: seperate middle class to non- middle class

#label: non-middle and middle class people
y <- c(rep(1,150), rep(2,50))

df <- data.frame(x=x, y=as.factor(y))
plot(x, col =y)

# trainig data - any 100 from 200
train <- sample(200,100)

model <- svm(y~., data = df[train,], kernel = "radial", gamma = 1, cost = 1)
plot(model, df[train,])
summary(model)

# increasing cost - high variance
model <- svm(y~., data = df[train,], kernel = "radial", gamma = 1, cost = 10000)
plot(model, df[train,])
# This is the case of overfitting

# cost and gamma vector for tunning
c <- seq(0.01, 10, by = 0.05)
g <- seq(0.05, 5, by = 0.05)

# tunning cost and gamma using cross validation set
tune.out <- tune(svm, y~., data = df[train,], kernel = "radial", ranges = list(cost = c, gamma = g))
summary(tune.out)
plot(tune.out$best.model, df[train,])

test <- -train
table(true = df[test,"y"], pred = predict(tune.out$best.model, news = df[test,]))

# so we got an accuracy of 70%