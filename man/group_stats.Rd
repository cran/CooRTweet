% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/group_stats.r
\name{group_stats}
\alias{group_stats}
\title{group_stats}
\usage{
group_stats(x)
}
\arguments{
\item{x}{a result \code{data.table} generated by \code{detect_coordinated_groups}}
}
\value{
a \code{data.table} with summary statistics for each group
}
\description{
Calculate coordinated group statistics:
total unique users per group, total posts in per group,
average time delta per group
}
\details{
This helper function gives you a summary of the coordinated
groups.
}
