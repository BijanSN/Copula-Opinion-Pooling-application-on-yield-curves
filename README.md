# Copula-Opinion-Pooling-application-on-yield-curves
A non-parametric extention of the Black-Litterman model applied on US yield curve adapted from Meucci, Attilio, Beyond Black-Litterman: Views on Non-Normal Markets (November 2005).
Available at SSRN: https://ssrn.com/abstract=848407 or http://dx.doi.org/10.2139/ssrn.848407


# 1. Black-Litterman using copula approach (COP)

One of the main drawbacks of the previous BL implementation is embedded into the former
prior described. Indeed, as stated earlier, **the prior follows a normal distribution around the
mean of the excessive market returns. In reality, this is not the case at all, as our empirical data
suggests. To bypass this problem, the copula-opinion pooling (COP) - an extension in a classical
Black-Litterman method- implements a prior which correctly reflects the dependency structure
of the market using multivariate copula**. The intuition is the same as before; the Black-Litterman
method requires 2 inputs: Market views and well as the manager’s. In order to infer the nonparametric
market prior this time, the probability density function of the market should be
estimated. The intuition being that past distribution of the market reflects our “prior”
assumption on how the market will behave in the future, which seems as a more reasonable
assumption than a normal distribution around the excess market returns.
The prior market distribution is computed through Monte Carlo simulations, drawn from
the previous prior distribution computed before. Those simulations are not subject to the curse
of dimensionality, and represent an efficient way to construct market views. We can now depart
from the standard efficient allocation by integrating some of our subjective views on the market.
The second input of the Black-Litterman method is the manager’s views, which is left
unchanged in this case. As before, the posterior is defined as a weighted average between the
market and the views, with a confidence coefficient associated to both.


In this section, we will highlight the drawbacks of using a normally distributed prior using
empirical data. Using data on the US treasury yield, the COP approach has been implemented,
using “Beyond Black-Litterman in Practice:a Five-Step Recipe to Input Views on non-Normal
Markets” from Attilio Meucci, as a benchmark for our analysis. Part of the matlab code of the
project are borrowed from him in this section. The yield rate are plotted below from different
maturities, from 3 months to 30 years:

 ![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/Curve2D.png)

The plot is coherent with the economic theory; ceteris paribus, for a higher maturity
corresponds to a higher risk premium and therefore a higher yield. Inversions of the yield curve
may suggest worsening expectation concerning the future, hence higher maturities carrying
lesser yield. Furthermore, the yield curve can be derived as well, adding a third dimension:
maturities.

 ![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/3DcurveYield2.png)


We can extract the linear dependency among the curves by the simple pearson correlation,
as shown with this heatmap:

 ![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/HeatmapYield.png)


As our intuition suggests, the closer on yield is from another one, the higher is the
correlation between them, since they are affected by the same risk factors. The correlation still
remains above 0.6, which is consequent. Now, we want to capture other form of dependences,
through copula. As described before, the first step consists of extracting the market views.
The empirical (unsmoothed) CDF looks as a “stair” function, which didn’t allow the derivation into the PDF. A kernel smoothing is applied on the CDF in order to correctly represent the density of the change in yield.

 ![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/SmoothedCDF.jpg)

Compute the market distribution now yield the following results:

 ![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/PDFs.jpg)

As we can see, the distribution of the yield changes are leptokurtic and mostly centered
around zero. **Applying univariate Jarque-Bera tests and Mardia’s multivariate test on the change
of yield shows a clear rejection from the normality distribution assumption mostly due to the
presence of these fat negative tails**. Graphically, looking specifically at the 3 months yield
change and a gaussian distribution shows a clear difference on the distribution of the yield than
the traditional Black-Litterman model assumption, hence the importance of choosing a
different market prior, as sesen below.

 ![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/3MLepto.png)

We can now draw simulations of those distribution in order to simulate our market prior.
For example, the histogram of the 3 month yield versus the 2 year yield can be shown below.
It is not really informative by itself, but by extracting the margins from theses distribution, the
notion of copula emerges.


![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/3m-2y.jpg)

---

![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/Copula.jpg)


As we can see, there is a clustering of data on both side of the tails, which corresponds to
a t-copula. We will therefore use this model to represent the codependency of the weekly
changes. Finally, the parameter of the t-copula are estimated through a maximum-likelihood.

# An application on a fixed income strategy : 2-5-10 Butterflies

Following the same example as Attilio Meucci (2006), the views are defined such that the
investor expects a steepening of the intermediate yield curve. More specifically, the manager
expected an increase of 10 basis point of the spread 2-20 years as well as a 5 .bp bullish view
on the 2-5-10 butterfly (short 2th&10th year and long the 5th year yield)


The first line of the pick matrix is therefore [0 -1 0 0 0 1] with an associated coefficient of
0.001. The second line is [0 -0.5 1 -0.5 0 0] with a coefficient of 0.0005. The vector of expected
excess returns of each view ‘Q’ is therefore [0.001, 0.0005].
Intuitively, higher yield leads to a decrease of the bonds price, the manager should have a
short position on bonds for the 5 year yield as well the 20 year yield, according to his view. For
the second view, the proceed of the sell of the 5 year maturity is used on both the 2 year and 10
year maturity to bet on a steepening of the yield curve around that maturity.
From this plot, we can see that the prior market assumption is blended with our particular
view, in order to create a new, posterior view on the market. This posterior view can be
implemented in order to create a new allocation, depending on the framework we are using.
A summary table of the difference between the prior and the posterior yield change are
given below: Each column represent the different maturities, respectively 2,5,10 and 20 years.


![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/MeanYield.PNG)
![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/StdYield.PNG)
![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/KurtosisYield.PNG)
![alt text](https://github.com/BijanSN/Copula-Opinion-Pooling-application-on-yield-curves/blob/master/Plots/SkewnessYield.PNG)

As we can expect,the view of the manager twisted the expected mean returns of the
posterior in line with his expectations. Indeed, the expected mean of the change in yield for the
2nd maturity of the posterior is slightly lower than the prior’s, consequence of the both views
of the manager, the fact that the slope of the yield curve is expected to steepen. Similarly,the
10th yield increases as we expect the spear 2-20 to widen. As for the 5th yield, the bullish view
is represented by a higher expected yield change. For the standard deviations , the skewness,
and the kurtosis, no significant changes arises between the prior and posterior expected yield
change. However, we can easily see that for both the prior and posterior, the overall skewness
of the change in yield is slightly negative and the overall kurtosis is above 3, indicating a
leptokurtic distributions of the yield change, indicating again a departure from the gaussian
approximation.


## Conclusion
We are at the edge of a financial revolution. With the surge of data, machine learning and
artificial intelligence techniques applied to finance are becoming more efficient at solving
financial-related problems than us, humans. A legitimate controversial question can be brought
here; Are we still going to be useful? What is the
competitive advantage a human has over an algorithm? We believe it’s our intuition. The
Black-Litterman model combines these two paradigms; By combining the expertise we
gathered the last couples of years with our intuition, we can achieve better results. The assumption of normality was also rejected several times
through our project, leading the development of new tools in order to correctly model financial
information. This was highlighted through the COP approach from Meucci, but the research
must go on. To conclude with, we presented a relatively new approach to asset management :
combining a specialist view with the market’s can potentially yields higher results, depending
on certains criteria, such as the confidence of the manager on his views. An extension would
be to analyse if an optimal confidence level (yielding a better allocation) could be inferred.

# Additional References 
* http://lup.lub.lu.se/luur/download?func=downloadFile&recordOId=5472145&fileOId=5472158

