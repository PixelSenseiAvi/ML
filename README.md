# ML

# Linear Regression
This technique is used to predict the real valued output or near-real valued output, on a given data set. On this technique we analyze the trend in the given data set and predict the values accordingly.

[![Linear-Regression](http://www.biostathandbook.com/pix/regressionlollipop.gif)](#features)

The line represents the predicted values, and dots( above and below) represents the actual values.


The General Equation of a line is:
  Y=mx+c
  
  
So Our main objective is to minimize the distance between two; for this we calculate
# Error Function
  This gives the mean square distance of the data-sets values( Dots on above graph) and predicted values(line). This is given by:
  [![Error-function](https://spin.atomicobject.com/wp-content/uploads/linear_regression_error1.png)](#features)
  where y(i) represents data-values and mx+b represents predicted values. Where m,b are the parameter values that can be calculated by gradient descent.
  

We have to calculate values m,b; So that our Error function can be minimum:
# Gradient Descent
Gradient Descent at a point gives the tangent to curve we are traversing. It gives us the direction whether to traverse up or down.
[![Gradient-Descent](https://spin.atomicobject.com/wp-content/uploads/linear_regression_gradient1.png)](#features)


# Learning Rate
Learning Rate is used to determine how fast to learn. The Learning Rate cannot be too high and can not be too low, we have to choose according to the given data set.


# Special Thanks
  Siraj Raval and Andrew Ng for this awesome content. -XOXO
