\name{reorder.hclust}
\alias{reorder.hclust}
\alias{rev.hclust}

\title{
Reorder a Hierarchical Clustering Tree
}

\description{

  Function takes a hierarchical clustering tree from
  \code{\link{hclust}} and a vector of values and reorders the
  clustering tree in the order of the supplied vector, maintaining the
  constraints on the tree. This is a method of generic function
  \code{\link{reorder}} and an alternative to reordering a
  \code{"dendrogram"} object with \code{\link{reorder.dendrogram}}

}

\usage{
\method{reorder}{hclust}(x, wts, 
   agglo.FUN = c("mean", "min", "max", "sum", "uwmean"), ...)
\method{rev}{hclust}(x)
}

\arguments{
  \item{x}{
    hierarchical clustering from \code{\link{hclust}}.
}
  \item{wts}{
    numeric vector for reordering.
}
  \item{agglo.FUN}{
    a function for weights agglomeration, see below.
}
  \item{\dots}{
    additional arguments (ignored).
}
}

\details{
  
  Dendrograms can be ordered in many ways. The \code{reorder} function
  reorders an \code{\link{hclust}} tree and provides an alternative to
  \code{\link{reorder.dendrogram}} which can reorder a
  \code{\link{dendrogram}}. The current function will also work
  differently when the \code{agglo.FUN} is \code{"mean"}: the
  \code{\link{reorder.dendrogram}} will always take the direct mean of
  member groups ignoring their sizes, but this function will used
  \code{\link{weighted.mean}} weighted by group sizes, so that the
  group mean is always the mean of member leaves (terminal nodes). If
  you want to ignore group sizes, you can use unweighted mean with
  \code{"uwmean"}. 

  The function accepts only a limited list of \code{agglo.FUN}
  functions for assessing the value of \code{wts} for groups. The
  ordering is always ascending, but the order of leaves can be
  reversed with \code{rev}. 

}

\value{
  Reordered \code{\link{hclust}} result object with added item
  \code{value} that gives the value of the statistic at each merge
  level. 
}

\author{
  Jari Oksanen
}
\note{
  These functions should really be in base \R.
}


\seealso{
  \code{\link{hclust}} for getting clustering trees,
  \code{\link{as.hclust.spantree}} to change a \pkg{vegan} minimum
  spanning tree to an \code{\link{hclust}} object, and
  \code{\link{dendrogram}} and \code{\link{reorder.dendrogram}} for an
  alternative implementation.
}
\examples{
data(mite, mite.env)
hc <- hclust(vegdist(wisconsin(sqrt(mite))))
ohc <- with(mite.env, reorder(hc, WatrCont))
plot(hc)
plot(ohc)
## Slightly different from reordered 'dendrogram' which ignores group
## sizes in assessing means.
den <- as.dendrogram(hc)
den <- with(mite.env, reorder(den, WatrCont, agglo.FUN = mean))
plot(den)
}

\keyword{multivariate}

