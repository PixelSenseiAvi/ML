import matplotlib.pyplot as plt 
from sklearn import datasets
from sklearn import svm

# here we are going to use standard mnist datasets
# Loading digits data

digits = datasets.load_digits() 
# info of digits are stored in digitalized format in data
# corresponding digits are stored in target

clf = svm.SVC(gamma = 0.001, C=100)

# both rows should be same
print(len(digits.data)) #data
print(len(digits.target)) #labels


x,y = digits.data[:-10], digits.target[:-10]
clf.fit(x,y)

print("prediction:",clf.predict(digits.data[-5]))

plt.imshow(digits.images[-5], cmap = plt.cm.gray_r, interpolation = "nearest")
plt.show()
