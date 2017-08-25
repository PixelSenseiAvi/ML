require(e1071)

# set seed is used to standarize the random numbers 
# so the performance does not changes every time you select some random variables 
set.seed(1)

# matrix of normalized random numbers
x = matrix(rnorm(20*2), ncol = 2)

# labels
y = c(rep(-1,10),rep(1,10))

plot(x, col= (3-y))

# yet data is not seperable, so
x[y==1,] = x[y==1,] + 1 #add 1 to last 10 rows of x

plot(x, col= (3-y))

data <- data.frame(x = x, y= as.factor(y))

library(e1071)

model <- svm(y~., data = data, kernel = "linear", cost = 0.1, scale = FALSE)
plot(model, data)

c <- seq(0.01, 10, by = 0.005)

# tunning cost using cross validation set
set.seed(1)
tune.out <- tune(svm, y~., data = data, kernel = "linear", ranges = list(cost = c))
summary(tune.out)

bestmodel <- tune.out$best.model

