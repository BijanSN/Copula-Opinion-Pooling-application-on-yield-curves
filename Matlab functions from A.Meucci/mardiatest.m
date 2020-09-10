function [H stats] = mardiatest(X,alpha)
% MARDIATEST Mardia multivariate normality test using skewness & kurtosis.
%   H = MARDIATEST(X,ALPHA) performs Mardia's test of multivariate
%   normality to determine if the null hypothesis of multivariate 
%   normality is a reasonable assumption regarding the population
%   distributions of a random samples contained within the columns of X. X
%   must be a N-values by M-samples array. The desired significance level,
%   ALPHA, is an optional scalar input (default = 0.05).
%
%   The function performs three tests: of the multivariate skewness; the
%   multivariate skewness corrected for small samples; and the multivariate
%   kurtosis. H is a 1-by-3 array indicating the results of the hypothesis
%   tests:

%     H(i) = 0 => Do not reject the null hypothesis at significance level
%     ALPHA.
%     H(i) = 1 => Reject the null hypothesis at significance level ALPHA.


% %  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2003). Mskekur: Mardia's multivariate skewness
% %    and kurtosis coefficients and its hypotheses testing. A MATLAB file. [WWW document]. URL 
% %    http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=3519&objectType=FILE
% %
% %  References:
% % 
% %  Mardia, K. V. (1970), Measures of multivariate skewnees and kurtosis with
% %         applications. Biometrika, 57(3):519-530.
% %  Mardia, K. V. (1974), Applications of some measures of multivariate skewness
% %         and kurtosis for testing normality and robustness studies. Sankhyâ A,
% %         36:115-128
% %  Stevens, J. (1992), Applied Multivariate Statistics for Social Sciences. 2nd. ed.
% %         New-Jersey:Lawrance Erlbaum Associates Publishers. pp. 247-248.


% Check number of input arguements
if (nargin < 1) || (nargin > 2)
    error('Requires one or two input arguments.')
end

% Define default ALPHA if only one input is provided
if nargin == 1, 
    alpha = 0.05;
end

% Check for validity of ALPHA
if ~isscalar(alpha) || alpha>0.5 || alpha <0
    error('Input ALPHA must be a scalar between 0 and 0.5.')
end

[n,p] = size(X);

% Check for validity of X
if p < 2 || ~isnumeric(X)
    error('Input X must be a numeric array with at least 2 columns.')
end


difT = [];
for     j = 1:p
   difT = [difT,(X(:,j) - mean(X(:,j)))];
end;

S = cov(X);                     % Variance-covariance matrix
D = difT * inv(S) * difT';      % Mahalanobis' distances matrix
b1p = (sum(sum(D.^3))) / n^2;   % Multivariate skewness coefficient
b2p = trace(D.^2) / n;          % Multivariate kurtosis coefficient

k = ((p+1)*(n+1)*(n+3)) / ...
    (n*(((n+1)*(p+1))-6));      % Small sample correction
v = (p*(p+1)*(p+2)) / 6;        % Degrees of freedom
g1c = (n*b1p*k) / 6;            % Skewness test statistic corrected for small sample (approximates to a chi-square distribution)
g1 = (n*b1p) / 6;               % Skewness test statistic (approximates to a chi-square distribution)
P1 = 1 - chi2cdf(g1,v);         % Significance value of skewness
P1c = 1 - chi2cdf(g1c,v);       % Significance value of skewness corrected for small sample

g2 = (b2p-(p*(p+2))) / ...
    (sqrt((8*p*(p+2))/n));      % Kurtosis test statistic (approximates to a unit-normal distribution)
P2 = 1-normcdf(abs(g2));        % Significance value of kurtosis


% Prepare outputs

stats.Hs  = (P1 < alpha);
stats.Ps  = P1;
stats.Ms  = g1;
stats.CVs = chi2inv(1-alpha,v);
stats.Hsc = (P1c < alpha);
stats.Psc = P1c;
stats.Msc = g1c;
stats.Hk  = (P2 < alpha);
stats.Pk  = P2;
stats.Mk  = g2;
stats.CVk = norminv(1-alpha,0,1);

H = [stats.Hs stats.Hsc stats.Hk];