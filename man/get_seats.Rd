% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seat-distribution.R
\name{get_seats}
\alias{get_seats}
\title{Calculate seat distribution from draws from posterior}
\usage{
get_seats(
  dirichlet.draws,
  survey,
  distrib.fun = sls,
  samplesize = NULL,
  hurdle = 0.05,
  others = "others",
  ...
)
}
\arguments{
\item{dirichlet.draws}{Matrix containing random draws from posterior.}

\item{survey}{The actual survey results on which \code{dirichlet.draws}
were based on.}

\item{distrib.fun}{Function to calculate seat distribution. Defaults to
\code{\link{sls}} (Sainte-Lague/Schepers).}

\item{samplesize}{Number of individuals participating in the \code{survey}.}

\item{hurdle}{The percentage threshold which has to be reached by a party
to enter the parliament. Any party called "ssw" will be exempt from the hurdle.}

\item{others}{A string indicating the name under which parties not listed
explicitly are subsumed.}

\item{...}{Further arguments passed to \code{distrib.fun}.}
}
\value{
A data frame containing seat distributions for each simulation in
\code{dirichlet.draws}
}
\description{
Calculate seat distribution from draws from posterior
}
\examples{
library(coalitions)
library(dplyr)
# get the latest survey for a sample of German federal election polls
surveys <- get_latest(surveys_sample)
# simulate 100 seat distributions
surveys <- surveys \%>\% mutate(draws = purrr::map(survey, draw_from_posterior, nsim = 100),
                              seats = purrr::map2(draws, survey, get_seats))
surveys$seats
}
\seealso{
\code{\link{draw_from_posterior}}, \code{\link{sls}},
\code{\link{dHondt}}
}
\keyword{distribution}
\keyword{seat}
