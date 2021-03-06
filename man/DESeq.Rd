% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core.R
\name{DESeq}
\alias{DESeq}
\title{Differential expression analysis based on the Negative Binomial (a.k.a. Gamma-Poisson) distribution}
\usage{
DESeq(object, test = c("Wald", "LRT"), fitType = c("parametric", "local",
  "mean"), sfType = c("ratio", "poscounts", "iterate"), betaPrior,
  full = design(object), reduced, quiet = FALSE,
  minReplicatesForReplace = 7, modelMatrixType, useT = FALSE, minmu = 0.5,
  parallel = FALSE, BPPARAM = bpparam())
}
\arguments{
\item{object}{a DESeqDataSet object, see the constructor functions
\code{\link{DESeqDataSet}},
\code{\link{DESeqDataSetFromMatrix}},
\code{\link{DESeqDataSetFromHTSeqCount}}.}

\item{test}{either "Wald" or "LRT", which will then use either 
Wald significance tests (defined by \code{\link{nbinomWaldTest}}),
or the likelihood ratio test on the difference in deviance between a
full and reduced model formula (defined by \code{\link{nbinomLRT}})}

\item{fitType}{either "parametric", "local", or "mean"
for the type of fitting of dispersions to the mean intensity.
See \code{\link{estimateDispersions}} for description.}

\item{sfType}{either "ratio", "poscounts", or "iterate"
for teh type of size factor estimation. See
\code{\link{estimateSizeFactors}} for description.}

\item{betaPrior}{whether or not to put a zero-mean normal prior on
the non-intercept coefficients 
See \code{\link{nbinomWaldTest}} for description of the calculation
of the beta prior. In versions \code{>=1.16}, the default is set
to \code{FALSE}, and shrunken LFCs are obtained afterwards using
\code{\link{lfcShrink}}.}

\item{full}{for \code{test="LRT"}, the full model formula,
which is restricted to the formula in \code{design(object)}.
alternatively, it can be a model matrix constructed by the user.
advanced use: specifying a model matrix for full and \code{test="Wald"}
is possible if \code{betaPrior=FALSE}}

\item{reduced}{for \code{test="LRT"}, a reduced formula to compare against,
i.e., the full formula with the term(s) of interest removed.
alternatively, it can be a model matrix constructed by the user}

\item{quiet}{whether to print messages at each step}

\item{minReplicatesForReplace}{the minimum number of replicates required
in order to use \code{\link{replaceOutliers}} on a
sample. If there are samples with so many replicates, the model will
be refit after these replacing outliers, flagged by Cook's distance.
Set to \code{Inf} in order to never replace outliers.}

\item{modelMatrixType}{either "standard" or "expanded", which describe
how the model matrix, X of the GLM formula is formed.
"standard" is as created by \code{model.matrix} using the
design formula. "expanded" includes an indicator variable for each
level of factors in addition to an intercept. for more information
see the Description of \code{\link{nbinomWaldTest}}.
betaPrior must be set to TRUE in order for expanded model matrices
to be fit.}

\item{useT}{logical, passed to \code{\link{nbinomWaldTest}}, default is FALSE,
where Wald statistics are assumed to follow a standard Normal}

\item{minmu}{lower bound on the estimated count for fitting gene-wise dispersion
and for use with \code{nbinomWaldTest} and \code{nbinomLRT}}

\item{parallel}{if FALSE, no parallelization. if TRUE, parallel
execution using \code{BiocParallel}, see next argument \code{BPPARAM}.
A note on running in parallel using \code{BiocParallel}: it may be
advantageous to remove large, unneeded objects from your current
R environment before calling \code{DESeq},
as it is possible that R's internal garbage collection
will copy these files while running on worker nodes.}

\item{BPPARAM}{an optional parameter object passed internally
to \code{\link{bplapply}} when \code{parallel=TRUE}.
If not specified, the parameters last registered with
\code{\link{register}} will be used.}
}
\value{
a \code{\link{DESeqDataSet}} object with results stored as
metadata columns. These results should accessed by calling the \code{\link{results}}
function. By default this will return the log2 fold changes and p-values for the last
variable in the design formula.  See \code{\link{results}} for how to access results
for other variables.
}
\description{
This function performs a default analysis through the steps:
\enumerate{
\item estimation of size factors: \code{\link{estimateSizeFactors}}
\item estimation of dispersion: \code{\link{estimateDispersions}}
\item Negative Binomial GLM fitting and Wald statistics: \code{\link{nbinomWaldTest}}
}
For complete details on each step, see the manual pages of the respective
functions. After the \code{DESeq} function returns a DESeqDataSet object,
results tables (log2 fold changes and p-values) can be generated
using the \code{\link{results}} function.
Shrunken LFC can then be generated using the \code{\link{lfcShrink}} function. 
All support questions should be posted to the Bioconductor
support site: \url{http://support.bioconductor.org}.
}
\details{
The differential expression analysis uses a generalized linear model of the form:

\deqn{ K_{ij} \sim \textrm{NB}( \mu_{ij}, \alpha_i) }{ K_ij ~ NB(mu_ij, alpha_i) }
\deqn{ \mu_{ij} = s_j q_{ij} }{ mu_ij = s_j q_ij }
\deqn{ \log_2(q_{ij}) = x_{j.} \beta_i }{ log2(q_ij) = x_j. beta_i }

where counts \eqn{K_{ij}}{K_ij} for gene i, sample j are modeled using
a Negative Binomial distribution with fitted mean \eqn{\mu_{ij}}{mu_ij}
and a gene-specific dispersion parameter \eqn{\alpha_i}{alpha_i}.
The fitted mean is composed of a sample-specific size factor
\eqn{s_j}{s_j} and a parameter \eqn{q_{ij}}{q_ij} proportional to the
expected true concentration of fragments for sample j.
The coefficients \eqn{\beta_i}{beta_i} give the log2 fold changes for gene i for each
column of the model matrix \eqn{X}{X}.
The sample-specific size factors can be replaced by
gene-specific normalization factors for each sample using
\code{\link{normalizationFactors}}.

For details on the fitting of the log2 fold changes and calculation of p-values,
see \code{\link{nbinomWaldTest}} if using \code{test="Wald"},
or \code{\link{nbinomLRT}} if using \code{test="LRT"}.

Experiments without replicates do not allow for estimation of the dispersion
of counts around the expected value for each group, which is critical for
differential expression analysis. The DESeq2 authors have decided to no
longer support the data exploratory (with warning) behavior of previous
versions, and so analysis of designs without replicates will be removed
in the Oct 2018 release: DESeq2 v1.22.0, after which DESeq2 will give an error.
The release DESeq2 v1.20.0 will give a deprecation warning, and then use a design
with only an intercept to estimate dispersion, the behavior for all previous
versions of DESeq2 and the DESeq package.

The argument \code{minReplicatesForReplace} is used to decide which samples
are eligible for automatic replacement in the case of extreme Cook's distance.
By default, \code{DESeq} will replace outliers if the Cook's distance is
large for a sample which has 7 or more replicates (including itself).
This replacement is performed by the \code{\link{replaceOutliers}}
function. This default behavior helps to prevent filtering genes
based on Cook's distance when there are many degrees of freedom.
See \code{\link{results}} for more information about filtering using
Cook's distance, and the 'Dealing with outliers' section of the vignette.
Unlike the behavior of \code{\link{replaceOutliers}}, here original counts are
kept in the matrix returned by \code{\link{counts}}, original Cook's
distances are kept in \code{assays(dds)[["cooks"]]}, and the replacement
counts used for fitting are kept in \code{assays(dds)[["replaceCounts"]]}.

Note that if a log2 fold change prior is used (betaPrior=TRUE)
then expanded model matrices will be used in fitting. These are
described in \code{\link{nbinomWaldTest}} and in the vignette. The
\code{contrast} argument of \code{\link{results}} should be used for
generating results tables.
}
\examples{

# see vignette for suggestions on generating
# count tables from RNA-Seq data
cnts <- matrix(rnbinom(n=1000, mu=100, size=1/0.5), ncol=10)
cond <- factor(rep(1:2, each=5))

# object construction
dds <- DESeqDataSetFromMatrix(cnts, DataFrame(cond), ~ cond)

# standard analysis
dds <- DESeq(dds)
res <- results(dds)

# moderated log2 fold changes
resultsNames(dds)
resLFC <- lfcShrink(dds, coef=2, type="apeglm")

# an alternate analysis: likelihood ratio test
ddsLRT <- DESeq(dds, test="LRT", reduced= ~ 1)
resLRT <- results(ddsLRT)

}
\references{
Love, M.I., Huber, W., Anders, S. (2014) Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome Biology, 15:550. \url{https://doi.org/10.1186/s13059-014-0550-8}
}
\seealso{
\code{link{results}}, \code{\link{lfcShrink}}, \code{\link{nbinomWaldTest}}, \code{\link{nbinomLRT}}
}
\author{
Michael Love
}
