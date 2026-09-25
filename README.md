# Transparent-ML-algorithms
## Description
ML algorithms are designed to reduce error, that is some measure of the difference between the actual and predicted vectors for the target feature.  However, in most cases, the produced model is difficult to interpret.  For example neural networks are non-linear mathematical transformations, and cannot easily be understood.  Decision trees are somewhat easier, but can be difficult to interpret especially when lengthy.  Moreover, both are designed to cover the entire space of the target feature.  This algorithm poses a different question than common machine learning algorithsm that are designed to minimize error (although, ironically, some of the earliest ML algorithms worked in a similar fashion).  
To wit: can you give me an intepretable description that maximally describes some subset of the target population, and minimally describes the non-target population.
## A few brief clarifying examples
### A numerical example
Problem: In the R dataset mtcars, give me a conjunction of features that describe the top 25% of cars by mpg  
Answer (with matthews metric):  
IF  
a) 1.51 < wt < 2.62, and  
b) .17 < am < 1  
THEN  
mgp in top 25%  
The cells in the confusion matrix are tp = 7, fn - 1, tn = 24, and fp = 0
### A categorical example
## Summary and notes
As the above examples demonstrate, the algorithm produces a list of conjunctions that describe the specified target region.  Note that  
a) This algorithm will attempt to find the optimal list of conjunctions relative to the metric provided
b) The algorithm works with both numerical and factor non-target columns, and numerical and factor target columns
c) The algorithm is typically much faster than a ML algorithms with the exception of linear regression (but provides ranges rather than simple feature correlations with the output), and is also  
d) The performance as indicated by the metric score is often good compared to standard ML, but may be inferior, especially when a disjunctive representation is required to find the optimal performance
