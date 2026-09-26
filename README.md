# Transparent-ML-algorithms
## Description
ML algorithms are designed to reduce error, that is some measure of the difference between the actual and predicted vectors for the target feature.  However, in most cases, the produced model is difficult to interpret.  For example neural networks are non-linear mathematical transformations, and cannot easily be understood.  Decision trees are somewhat easier, but can be difficult to interpret especially when lengthy.  Moreover, both are designed to cover the entire space of the target feature.  This algorithm addresses a different question (although, ironically, with a representation similar to models that pre-date modern ML), to wit:  
Can you give me an easily intepretable description that maximally describes some subset of the target population, and minimally describes the non-target population.
## A few brief clarifying examples
### A numerical example
Problem: In the R dataset mtcars, give me a conjunction of features that describe the top 25% of cars by mpg  
Answer (with the default matthews metric):  
IF  
a) 1.51 < wt < 2.62, and  
b) .17 < am < 1  
THEN  
mgp is in top 25%  
The cells in the confusion matrix are tp = 7, fn = 1, tn = 24, and fp = 0.  This produces a score of .9165 with the matthews metric.  
### A categorical example  
Problem: In the R dataset iris, give me a conjunction of features that describe the versicolor species  
Answer (with the default matthews metric):  
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
### Test cases
