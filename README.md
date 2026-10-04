# Transparent-ML-algorithms
## Description
ML algorithms are designed to reduce error, that is some measure of the difference between the actual and predicted vectors for the target feature.  However, in most cases, the produced model is difficult to interpret.  For example neural networks are non-linear mathematical transformations, and cannot easily be understood.  Decision trees are somewhat easier, but can be difficult to interpret especially when lengthy.  Moreover, both are designed to cover the entire space of the target feature.  This algorithm addresses a different question (although, ironically, with a representation similar to models that pre-date modern ML), to wit:  
Can you give me an easily intepretable description that maximally describes some subset of the target population, and minimally describes the non-target population.
## A few brief clarifying examples
### A numerical example
Problem: In the R dataset mtcars, give me a conjunction of features that describe the top 25% of cars by mpg  
Function call: makeprofile(mtcars,'mpg',.25)  
Result (with the default matthews metric):  
IF  
a) 1.51 < wt < 2.62, and  
b) .17 < am < 1  
THEN  
mpg is in top 25%  
The cells in the confusion matrix are tp = 7, fn = 1, tn = 24, and fp = 0.  This produces a score of .9165 with the matthews metric.  
### A categorical example  
Problem: In the R dataset iris, give me a conjunction of features that describe the versicolor species  
Function call: makeprofile(iris,'Species',targetlevel = 'versicolor')  
Result (with the default matthews metric):  
IF  
a) 4.9 < Sepal Length < 7, and  
b) 3 < Petal Length < 4.73  
THEN  
the species is versicolor  
The cells in the confusion matrix are tp = 43, fn = 7, tn = 100, and fp = 0.  This produces a score of .8965 with the matthews metric. 

## Summary and notes
As the above examples demonstrate, the algorithm produces a list of conjunctions that describe the specified target region.  Note that  
a) This algorithm will attempt to find the optimal list of conjunctions relative to the metric provided  
b) The algorithm works with both numerical and factor non-target columns, and numerical and factor target columns  
c) The algorithm is typically much faster than ML algorithms with the exception of linear regression, but provides a more easily interpretable explanation of the 
difference between the target and non-target populations than regression and other algorithms  
d) The performance on the training data as indicated by the metric score is often good compared to standard ML, but may be inferior to these algorithms, especially when a disjunctive representation produces a better result.  However, in these cases, the simpler conjunctive formulation may still be superior because it generalizes better to examples the algorithm has not yet seen.  
e) If the features in the conjunction are levers (that is, they causally determine the outcome rather than merely being correlated with it), the output tells directly you what you need to do in order to produce a result in the target range
## Running the code
### Downloading and running
### Arguments to the makeprofile function
dta - the data to analyze, as a data.frame  
  
targetname - the name of the column in the data to profile  
  
percent [default = .05] - if the target column is numeric, this argument determines the data rows to profile (for example, if percent is .1, then the algorithm will attempt to find a description of the 
top 10% of target values)  

top [default = TRUE] - if true, then profile the top n% of cases, otherwise the botton n% of cases  

targetlevel [default = ''] - if the target column is a factor, profile this factor level  

maxsd [default = 3]  the maximum standard deviation from the mean for a numeric feature to consider (for example, if maxsd is 2, then only values between -2 and +2 standard deviations from the mean will be considered in the conjunction for this feature  

sddelta [default = 1] the minimum interval in the maxsd range to consider; the algorithm will iterate over all multiples of this interval (for example, with the default values, the following standard deviation intervals will be considered for a given feature: -3 to -2, -3 to -1, -3 to 0, -3 to +1, -3 to +2, -3 to +3, -2 to -1, -2 to 0, -2 to 1, -2 to 2, -2 to 3, -1 to 0, -1 to +1, -1 to + 2, -1 to +3, 0 to +1, 0 to +2, 0 to +3, +1 to +2, +1 to +3, +2 to +3)  

beamsize [default = 32] the number of conjunctions to be considered at each step of the iteration, that is, adding an additional feature to each conjunction; the set of conjunctions is filtered at each stage by the given measure, with only the top beamsize surviving


### makeprofile return
makeprofile returns a data.frame with one or more rows, each representing a possible solution; all rows have the same evaluation which is the maximum found for these arguments.  Each row contains the number of features in the conjunction, the evaluation by the provided measure, the confusion matrix (true positive count, false negative count, true negative count, and false positive count) and a list of features in the conjunction and their value ranges, or if the feature is a factor, then the level for that factor.  For example, the table below shows that there are two equivalent solutions for iris dataset problem discussed above, one with two features in the conjunction (the third possible feature if filled out with NAs) and one with three.  The maximum possible solutions is limited to the beam size; in most cases there will be far fewer solutions, and often only one.  

| <h6>featcount | <h6>eval | <h6>tp | <h6>fn | <h6>tn | <h6>fp | <h6>feat1 | <h6>attr11 | <h6>attr21 | <h6>feat2 | <h6>attr12 | <h6>attr22 | <h6>feat3 | <h6>attr12 | <h6>attr23 |  
| --------- | ---- |--- | -- |--- | -- | ----- | ------ | ------ | ----- | ------ | ------ | ----- | ------ | ------ |
| <h6> 2 | <h6> 0.896 | <h6>43 |  <h6>7 |  <h6>100 | <h6>0 | <h6>SepalLength | <h6>4.90 | <h6>7 | <h6>PetalLength | <h6>3 | <h6>4.73 | <h6>NA | <h6>NA | <h6>NA |
| <h6>3 | <h6>0.896 |    <h6> 43   |     <h6>7   |  <h5>100    |  <h6>  0 | <h6>SepalLength | <h6>4.90  |   <h6> 7  | <h6>SepalWidth   |   <h6>2  |  <h6>3.4|<h5> PetalLength |  <h6>3   |  <h6>4.723  |

### Test cases
