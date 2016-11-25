### Welcome to NMSO.
This page hosts the MATLAB code for the Naive Multi-Scale Optimization (NMSO) algorithm to appear in, "[A Naive Multi-Scale Algorithm for Global Optimization Problems](http://www.sciencedirect.com/science/article/pii/S0020025516305370)", by Abdullah Al-Dujaili and S. Suresh.

This algorithm has secured the **third** place out of **28** algorithms in the BBComp competition in GECCO'15.
For more details, please refer to [this](http://bbcomp.ini.rub.de/results/BBComp2015GECCO/summary.html).
### Quick Demo
Fire MATLAB and run the following:
~~~
runDemo
~~~
This will walk you through a short demo of NMSO in action optimizing a function in 1-D and 2-D. You may want to toy with the algorithm's parameters (e.g., alpha and beta to get a better performance depending on the problem at hand).

### How to use NMSO

NMSO has been designed for Black-box Bound-constrained Global Optimization problems. The following would minimize a spherical function whose optimal solution at x=[0.231 0.231] in a 2-D problem space, with the variables being limited to [0,1], using a function evaluation budget of 1000.

~~~
func = @(x) sum((x-0.231).^2);
dim = 2;
maxRange = 1;
minRange = 0;
numEvaluations = 1000;
ftarget = 0;
[yBest,xBest]= NMSO(ftarget, func, numEvaluations, dim, maxRange, minRange, 0);
~~~

### Citation

If you write a scientific paper describing research that made use of this code, please cite the following paper:

~~~
@article{AlDujaili2016294,
title = "A Naive multi-scale search algorithm for global optimization problems ",
journal = "Information Sciences ",
volume = "372",
number = "",
pages = "294 - 312",
year = "2016",
note = "",
issn = "0020-0255",
doi = "http://dx.doi.org/10.1016/j.ins.2016.07.054",
url = "http://www.sciencedirect.com/science/article/pii/S0020025516305370",
author = "Abdullah Al-Dujaili and S. Suresh",
keywords = "Black-box optimization",
keywords = "Global optimization",
keywords = "Derivative-free optimization",
keywords = "Partitioning-based",
keywords = "Optimistic algorithms",
keywords = "Finite-time analysis ",
abstract = "Abstract This paper proposes a multi-scale search algorithm for solving global optimization problems given a finite number of function evaluations. We refer to this algorithm as the Naive Multi-scale Search Optimization (NMSO). \{NMSO\} looks for the optimal solution by optimistically partitioning the search space over multiple scales in a hierarchical fashion. Based on a weak assumption about the function smoothness, we present a theoretical analysis on its finite-time and asymptotic convergence. An empirical assessment of the algorithm has been conducted on the noiseless Black-Box Optimization Benchmarking (BBOB) testbed and compared with the state-of-the-art optimistic as well as stochastic algorithms. Moreover, the efficacy of \{NMSO\} has been validated on the black-box optimization competition within the GECCO’15 conference where it has secured the third place out of twenty-eight participating algorithms. Overall, \{NMSO\} is suitable for problems with limited function evaluations, low-dimensionality search space, and objective functions that are separable or multi-modal. Otherwise, it is comparable with the top performing algorithms. "
}
~~~
