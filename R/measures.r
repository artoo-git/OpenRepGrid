###############################################################################
###  						            GRID INDEX MEASURES     							          ###
###                                                                         ###
###     All function for index measures start with a lower case "i"         ###
###     e.g. 'iBias' that stand for index followed by the an acronym        ###
###     of what is calculated.                                              ###
###                                                                         ###
###############################################################################


###############################################################################
###  						            MEASURES FROM SLATER 1977							          ###
###############################################################################

#' Calculate 'bias' of grid as defined by Slater (1977). 
#'
#' "Bias records a tendency for reponses to accumulate at one end of the 
#' grading scale" (Slater, 1977, p.88). 
#'
#' @param  x        \code{repgrid} object.
#' @param min       Minimum grid scale value. 
#' @param max       Maximum grid scale value.
#' @param digits    Numeric. Number of digits to round to (default is 
#'                  \code{2}).
#' @return Numeric.
#'
#' @references      Slater, P. (1977). \emph{The measurement of intrapersonal space 
#'                  by Grid technique}. London: Wiley.
#'
#' @note STATUS:    Working and checked against example in Slater, 1977, p. 87.
#'                  
#' @author        Mark Heckmann
#' @export
#' @seealso       \code{\link{indexVariability}} 
#'
indexBias <- function(x, min, max, digits=2){
  dat <- x@ratings[ , ,1]
  if (missing(min)) 
    min <- x@scale$min
  if (missing(max)) 
    max <- x@scale$max
  p <- min + (max - min)/2 			# scale midpoint
  q <- max - p									# distance to scale limits
  n <- nrow(dat)								# number of rows (constructs)
  row.means <- apply(dat, 1, mean, na.rm=TRUE)		# means of construct rows
  bias <- (sum((row.means - p)^2) / n)^.5 / q		  # calculation of bias
  round(bias, digits)
}


#' Calculate 'variability' of a grid as defined by Slater (1977).
#'
#' Variability records a tendency for the responses to gravitate 
#' towards both end of the gradings scale. (Slater, 1977, p.88).
#'
#' @param  x      \code{repgrid} object.
#' @param min     Minimum grid scale value. 
#' @param max     Maximum grdi scale value. 
#' @param digits  Numeric. Number of digits to round to (default is 
#'                \code{2}).
#' @return        Numeric.
#'
#' @references    Slater, P. (1977). \emph{The measurement of intrapersonal space 
#'                by Grid technique}. London: Wiley.
#'
#' @note          STATUS: working and checked against example in Slater, 1977 , p.88.
#'
#' @author        Mark Heckmann
#' @export
#' @seealso       \code{\link{indexBias}} 
#'
indexVariability <- function(x, min, max, digits=2){
  if (missing(min)) 
    min <- x@scale$min
  if (missing(max)) 
    max <- x@scale$max
  
  D <- as.matrix(center(x))       # row centered grid matrix
  W <- D %*% t(D)									# co-variation Matrix W
  V <- diag(W)										# extract trace (construct variations)
  V.tot <- sum(V, na.rm=T)       # total variation
  
  p <- min + (max - min)/2 					    # scale midpoint
  q <- max - p								          # distance to scale limits
  n <- nrow(D)								        # number of rows (constructs)
  m <- ncol(D)								        # number of columns (elements)
  res <- (V.tot/(n*(m-1)))^.5/q			        # calculate variability
  round(res, digits)
}


###############################################################################
###  						              OTHER INDICES          							          ###
###############################################################################

#' Percentage of Variance Accounted for by the First Factor (PVAFF)
#'
#' The PVAFF is used as 
#' a measure of cognitive complexity. It was introduced in an unpublished
#' PhD thesis by Jones (1954, cit. Bonarius, 1965).
#' To calculate it, the 'first factor' is extracted from the construct 
#' correlation matrix by principal component analysis.
#' The PVAFF reflects the amount of variation that is accounted for by a single 
#' linear component. If a single latent component is able to explain the
#' variation in the grid, the cognitive complexity is said to be low. 
#' In this case the construct system is regarded as 'simple' (Bell, 2003).
#'
#' The percentage of variance is calculated using the corelation matrix
#' of te constructs submitted to \code{\link{svd}}.
#' 
#' @section Development: 
#' TODO: Results have not yet been checked against other grid programs.
#'
#' @param x         \code{repgrid} object.
#' @export
#' @author          Mark Heckmann
#' @references      Bell, R. C. (2003). An evaluation of indices used to 
#'                  represent construct structure. In G. Chiari & M. L. 
#'                  Nuzzo (Eds.), \emph{Psychological Constructivism and 
#'                  the Social World} (pp. 297-305). Milan: FrancoAngeli.
#'
#'                  Bonarius, J. C. J. (1965). Research in the personal 
#'                  construct theory of George A. Kelly: role construct 
#'                  repertory test and basic theory. In B. A. Maher (Ed.), 
#'                  \emph{Progress in experimental personality research}
#'                  (Vol. 2). New York: Academic Press.
#'
#'                  James, R. E. (1954). \emph{Identification in terms of personal 
#'                  constructs} (Unpublished doctoral thesis). Ohio State 
#'                  University, Columbus, OH.  
#'
#' @examples 
#'
#'    indexPvaff(bell2010)
#'    indexPvaff(feixas2004)
#'
#'    # save results to object
#'    p <- indexPvaff(bell2010)
#'    p
#'
#'
indexPvaff <- function(x){
  if (!inherits(x, "repgrid")) 
    stop("Object must be of class 'repgrid'")
  cr <- constructCor(x)
  sv <- svd(cr)$d 
  pvaff <- sv[1]^2/sum(sv^2)
  return(pvaff)
}


#' Print method for class indexPvaff.
#' 
#' @param x         Object of class indexPvaff.
#' @param digits    Numeric. Number of digits to round to (default is 
#'                  \code{2}).
#' @param ...       Not evaluated.
#' @export
#' @method          print indexPvaff
#' @keywords        internal
#'
print.indexPvaff <- function(x, digits=2, ...)
{
  cat("\n########################################################")
  cat("\nPercentage of Variance Accounted for by the First Factor")
  cat("\n########################################################")
  cat("\n\nPVAFF: ", round(x*100, digits), "%")
}


# Another version of PVAFF giving slightly different results
# maybe due to Bessel's correction. Still unclear which one 
# is correct.
indexPvaff2 <- function(x){
  if (!inherits(x, "repgrid")) 
    stop("Object must be of class 'repgrid'")
  r <- constructCor(x)
  sv <- princomp(r)$sdev
  pvaff <- sv[1]^2/sum(sv^2)
}


#' Calculate intensity index.
#'
#' The Intensity index has been suggested by Bannister (1960) as a 
#' measure of the amount of construct linkage. Bannister suggested 
#' that the score reflects the degree of organization of the construct 
#' system under investigation (Bannister & Mair, 1968). The index 
#' resulted from his and his colleagues work on construction systems 
#' of patient suffering schizophrenic thought disorder. The concept of 
#' intensity has a theoretical connection to the notion of "tight" and 
#' "loose" construing as proposed by Kelly (1991). While tight constructs 
#' lead to unvarying prediction, loose constructs allow for varying 
#' predictions. Bannister hypothesized that schizophrenic thought disorder 
#' is liked to a process of extremely loose construing leading to a loss 
#' of predictive power of the subject's construct system. The Intensity 
#' score as a structural measure is thought to reflect this type of 
#' system disintegration (Bannister, 1960). 
#' 
#' Implementation as in the Gridcor programme and explained on the 
#' correspoding help pages: 
#' "\ldots the sum of the squared values of the correlations 
#' of each construct with the rest of the constructs, averaged by the total 
#' number of constructs minus one. This process is repeated with each 
#' element, and the overall Intensity is calculated by averaging the 
#' intensity scores of constructs and elements."
#' \url{http://www.terapiacognitiva.net/record/pag/man11.htm}.
#' Currently the total is calculated as the unweighted average of all 
#' single scores (for elements and construct).
#'
#' @title         Intensity index 
#'
#' @section Development: TODO: Results have not been tested against other programs' results.
#'
#' @param x       \code{repgrid} object.
#' @param rc      Whether to use Cohen's rc for the calculation of
#'                inter-element correlations. See \code{\link{elementCor}}
#'                for further explanations of this measure.
#' @param trim    The number of characters a construct is trimmed to (default is
#'                \code{30}). If \code{NA} no trimming occurs. Trimming
#'                simply saves space when displaying correlation of constructs
#'                or elements with long names.
#' @return        An object of class \code{indexIntensity} containing a list 
#'                with the following elements: \cr
#'                
#'  \item{c.int}{Intensity scores by construct.}
#'  \item{e.int}{Intensity scores by element.}
#'  \item{c.int.mean}{Average intensity score for constructs.}
#'  \item{e.int.mean}{Average intensity score for elements.}
#'  \item{total.int}{Total intensity score.}
#'
#' @export      
#' @author      Mark Heckmann
#'
#' @references    Bannister, D. (1960). Conceptual structure in 
#'                thought-disordered schizophrenics. \emph{The Journal 
#'                of mental science}, 106, 1230-49.
#' @examples 
#' 
#'  indexIntensity(bell2010)
#'  indexIntensity(bell2010, trim=NA)
#'
#'  # using Cohen's rc for element correlations
#'  indexIntensity(bell2010, rc=TRUE)
#'
#'  # save output 
#'  x <- indexIntensity(bell2010)
#'  x
#'  
#'  # printing options
#'  print(x, digits=4)
#'  
#'  # accessing the objects' content
#'  x$c.int
#'  x$e.int
#'  x$c.int.mean
#'  x$e.int.mean
#'  x$total.int
#' 
indexIntensity <- function(x, rc=FALSE, trim=30)
{
  if (!inherits(x, "repgrid")) 
    stop("Object must be of class 'repgrid'")
  cr <- constructCor(x, trim=trim)
  nc <- getNoOfConstructs(x)
  diag(cr) <- 0                                           # out zeros in diagonal (won't have an effect)
  c.int <- apply(cr^2, 2, function(x) sum(x) / (nc-1))    # sum of squared correlations / nc -1 
  
  er <- elementCor(x, rc=rc, trim=trim) 
  ne <- getNoOfElements(x)
  diag(er) <- 0                                           # out zeros in diagonal (won't have an effect)
  e.int <- apply(er^2, 2, function(x) sum(x) / (ne-1))    # sum of squared correlations / ne -1 
  
  c.int.mean <- mean(c.int, na.rm=TRUE)       # mean of construct intensity scors
  e.int.mean <- mean(e.int, na.rm=TRUE)       # mean of element intensity scors
  
  total.int <- mean(c(c.int, e.int, na.rm=TRUE))
  
  res <- list(c.int=c.int,
              e.int=e.int,
              c.int.mean=c.int.mean,
              e.int.mean=e.int.mean,
              total.int=total.int)	            
  class(res) <- "indexIntensity"
  res
}


#' Print method for class indexIntensity.
#' 
#' @param x         Object of class indexIntensity.
#' @param digits    Numeric. Number of digits to round to (default is 
#'                  \code{2}).
#' @param ...       Not evaluated.
#' @export
#' @method          print indexIntensity
#' @keywords        internal
#'
print.indexIntensity <- function(x, digits=2, ...)
{
  cat("\n################")
  cat("\nIntensity index")
  cat("\n################")
  cat("\n\nTotal intensity:", round(x$total.int, digits), "\n")
  
  cat("\n\nAverage intensity of constructs:", round(x$c.int.mean, digits), "\n")
  cat("\nItensity by construct:\n")
  df.c.int <- data.frame(intensity=x$c.int)
  rownames(df.c.int) <- paste(seq_along(x$c.int), names(x$c.int))
  print(round(df.c.int, digits))
  
  cat("\n\nAverage intensity of elements:", round(x$e.int.mean, digits), "\n")
  cat("\nItensity by element:\n")
  df.e.int <- data.frame(intensity=x$e.int)
  rownames(df.e.int) <- paste(seq_along(x$e.int), names(x$e.int))
  print(round(df.e.int, digits))
}








###############################################################################
###    					            CONFLICT MEASURES       							          ###
###############################################################################

#' Print function for class indexConflict1
#' 
#' @param x         Object of class indexConflict1.
#' @param digits    Numeric. Number of digits to round to (default is 
#'                  \code{1}).
#' @param ...       Not evaluated.
#' @export
#' @method          print indexConflict1
#' @keywords        internal
#' 
print.indexConflict1 <- function(x, digits=1, ...)
{
  cat("\n################################")
  cat("\nConflicts based on correlations")
  cat("\n################################") 
  cat("\n\nAs devised by Slade & Sheehan (1979)")
  
  cat("\n\nTotal number of triads:", x$total)
  cat("\nNumber of imbalanced triads:",x$imbalanced)
  
  cat("\n\nProportion of balanced triads:", 
      round(x$prop.balanced * 100, digits=digits), "%")
  cat("\nProportion of imbalanced triads:", 
      round(x$prop.imbalanced * 100, digits=digits), "%")
}


#' Conflict measure as proposed by Slade and Sheehan (1979) 
#'
#' The first approach to mathematically derive a conflict measure based on
#' grid data was presented by Slade and Sheehan (1979). Their 
#' operationalization is based on an approach by Lauterbach (1975) 
#' who applied the \emph{balance theory} (Heider, 1958) for a quantitative 
#' assessment of psychological conflict. It is based on a count of 
#' balanced and imbalanced triads of construct correlations.
#' A triad is imbalanced if one or all three of the correlations are 
#' negative, i. e. leading to contrary implications. This approach 
#' was shown by Winter (1982) to be flawed. An improved version was 
#' proposed by Bassler et al. (1992) and has been implemented
#' in the function \code{indexConflict2}.
#'
#' The table below shows when a triad made up of the constructs
#' A, B, and C is balanced and imbalanced.
#'
#' \tabular{cccc}{
#'  cor(A,B) \tab  cor(A,C) \tab  cor(B,C) \tab  Triad characteristic \cr
#'  +   \tab  +   \tab  +   \tab   balanced               \cr
#'  +   \tab  +   \tab  -   \tab   imbalanced             \cr
#'  +   \tab  -   \tab  +   \tab   imbalanced             \cr
#'  +   \tab  -   \tab  -   \tab   balanced               \cr
#'  -   \tab  +   \tab  +   \tab   imbalanced             \cr
#'  -   \tab  +   \tab  -   \tab   balanced               \cr
#'  -   \tab  -   \tab  +   \tab   balanced               \cr
#'  -   \tab  -   \tab  -   \tab   imbalanced             \cr
#' }
#'
#' @title         Conflict measure for grids (Slade & Sheehan, 1979) based on correlations.
#'
#' @param x       \code{repgrid} object.
#' @return        A list with the following elements:
#' 
#'    \item{total}{Total number of triads} 
#'    \item{imbalanced}{Number of imbalanced triads} 
#'    \item{prop.balanced}{Proportion of balanced triads} 
#'    \item{prop.imbalanced}{Proportion of imbalanced triads} 
#'
#' @references    Bassler, M., Krauthauser, H., & Hoffmann, S. O. (1992). 
#'                A new approach to the identification of cognitive conflicts 
#'                in the repertory grid: An illustrative case study. 
#'                \emph{Journal of Constructivist Psychology, 5}(1), 95-111.
#'
#'                Heider, F. (1958). \emph{The Psychology of Interpersonal Relation}.
#'                John Wiley & Sons.
#'
#'                Lauterbach, W. (1975). Assessing psychological conflict. 
#'                \emph{The British Journal of Social and Clinical Psychology, 14}(1), 43-47.
#'
#'                Slade, P. D., & Sheehan, M. J. (1979). The measurement of 
#'                'conflict' in repertory grids. \emph{British Journal 
#'                of Psychology, 70}(4), 519-524.
#'  
#'                Winter, D. A. (1982). Construct relationships, psychological 
#'                disorder and therapeutic change. \emph{The British Journal of 
#'                Medical Psychology, 55} (Pt 3), 257-269.
#' 
#' @author        Mark Heckmann
#' @export
#' @seealso \code{\link{indexConflict2}} for an improved version of this measure;
#'          see \code{\link{indexConflict3}} for a measure based on distances.
#'
#' @examples \dontrun{
#'    
#'    indexConflict1(feixas2004)
#'    indexConflict1(boeker)
#'
#' }
#'
indexConflict1 <- function(x) {
  if (!inherits(x, "repgrid")) 
    stop("Object must be of class 'repgrid'")
  r <- constructCor(x)                    # construct correlation matrix
  z <- fisherz(r)
  nc <- getNoOfConstructs(x)              # number of constructs
  comb <- t(combn(nc, 3))                 # all possible correlation triads
  balanced <- rep(NA, nrow(comb))         # set up result vector
  
  for (i in 1:nrow(comb)){
    z.triad <- z[t(combn(comb[i, ], 2))]  # correlations of triad
    z.prod <- prod(z.triad)
    if (sign(z.prod) > 0)   # triad is imbalanced if product of correlations is negative
      balanced[i] <- TRUE else
        balanced[i] <- FALSE
  } 
  prop.balanced <- sum(balanced) / length(balanced)    # proportion of 
  prop.imbalanced <- 1 - prop.balanced                                # proportion of 
  
  res <- list(total=length(balanced),
              imbalanced=sum(!balanced),
              prop.balanced=prop.balanced, 
              prop.imbalanced=prop.imbalanced)
  class(res) <- "indexConflict1"
  res
}


#' Conflict measure as proposed by Bassler et al. (1992). 
#'
#' The function calculates the conflict measure as devised
#' by Bassler et al. (1992). It is an improved version of the ideas
#' by Slade and Sheehan (1979) that have been implemented in
#' the function \code{\link{indexConflict1}}. The new approach 
#' also takes into account the magnitude of the correlations in
#' a traid to assess whether it is balanced or imbalanced. 
#' As a result, small correlations that are psychologically meaningless
#' are considered accordingly. Also, correlations with a  small magnitude, 
#' i. e. near zero, which may  be positive or negative due to 
#' chance alone will no longer distort the measure (Bassler et al., 1992).
#' 
#'
#' Description of the balance / imbalance assessment:
#'
#' \enumerate{
#'    \item   Order correlations of the triad by absolute magnitude, so that
#'            \eqn{ r_{max} > r_{mdn} > r_{min} }{r_max > r_mdn > r_min}.
#'    \item   Apply Fisher's Z-transformation and devision by 3
#'            to yield values between 1 and -1  
##            (\eqn{ Z_{max} > Z_{mdn} > Z_{min} }{Z_max > Z_mdn > Z_min}).
#'    \item   Check whether the triad is balanced by assessing if the 
#'            following relation holds:
#'    \itemize{
#'        \item   If \eqn{ Z_{max} Z_{mdn} > 0 }{ Z_max x Z_mdn > 0}, 
#'                the triad is balanced if \eqn{ Z_{max} Z_{mdn} - Z_{min} <= crit }
#'                { Z_max x Z_mdn - Z_min <= crit }.
#'        \item   If \eqn{ Z_{max} Z_{mdn} < 0 }{ Z_max x Z_mdn < 0}, 
#'                the triad is balanced if \eqn{ Z_{min}  - Z_{max} Z_{mdn} <= crit }
#'                { Z_min - Z_max x Z_mdn <= crit }.
#'    }        
#'  }
#'
#' @section Personal remarks (MH): I am a bit suspicious about step 2 from above. To devide by 3 appears pretty arbitrary.
#'        The r for a z-values of 3 is 0.9950548 and not 1.
#'        The r for 4 is 0.9993293. Hence, why not a value of 4, 5, or 6?
#'        Denoting the value to devide by with \code{a}, the relation for the
#'        first case translates into \eqn{ a  Z_{max}  Z_{mdn} <= \frac{crit}{a} + Z_{min} }
#'        { a x Z_max x Z_mdn =< crit/a + Z_min}. This shows that a bigger value of \code{a}
#'        will make it more improbabale that the relation will hold.
#'
#'
#' @title         Conflict measure for grids (Bassler et al., 1992) based on correlations.
#'
#' @param x       \code{repgrid} object.
#' @param crit    Sensitivity criterion with which triads are marked as 
#'                unbalanced. A bigger values willl lead to less imbalanced 
#'                triads. The default is \code{0.03}. The value should
#'                be adjusted with regard to the researchers interest.
#' @references    Bassler, M., Krauthauser, H., & Hoffmann, S. O. (1992). 
#'                A new approach to the identification of cognitive conflicts 
#'                in the repertory grid: An illustrative case study. 
#'                \emph{Journal of Constructivist Psychology, 5}(1), 95-111.
#'
#'                Slade, P. D., & Sheehan, M. J. (1979). The measurement of 
#'                'conflict' in repertory grids. \emph{British Journal 
#'                of Psychology, 70}(4), 519-524.
#'
#' @author        Mark Heckmann
#' @export
#' @seealso       See \code{\link{indexConflict1}} for the older version 
#'                of this measure; see \code{\link{indexConflict3}} 
#'                for a measure based on distances instead of correlations.
#'
#' @examples \dontrun{
#'
#'  indexConflict2(bell2010)
#'   
#'  x <- indexConflict2(bell2010)  
#'  print(x)
#'  
#'  # show conflictive triads
#'  print(x, output=2)
#'  
#'  # accessing the calculations for further use
#'  x$total
#'  x$imbalanced
#'  x$prop.balanced
#'  x$prop.imbalanced
#'  x$triads.imbalanced
#' }
#' 
indexConflict2 <- function(x, crit=.03){
  if (!inherits(x, "repgrid")) 
    stop("Object must be of class 'repgrid'")
  r <- constructCor(x)                    # construct correlation matrix
  z <- fisherz(r)
  nc <- getNoOfConstructs(x)              # number of constructs
  comb <- t(combn(nc, 3))                 # all possible correlation triads
  balanced <- rep(NA, nrow(comb))         # set up result vector
  
  for (i in 1:nrow(comb)){	
    z.triad <- z[t(combn(comb[i, ], 2))]      # z-values of triad
    ind <- order(abs(z.triad), decreasing=T)  # order for absolute magnitude
    z.triad <- z.triad[ind]               # reorder z values by magnitude               
    z.12 <- prod(z.triad[1:2])            # product of two biggest z values
    z.3 <- z.triad[3]                     # minimal absolute z value
    # select case for inequality relation assessment
    if (sign(z.12) > 0) {
      balanced[i] <- z.12 - z.3 <= crit
    } else {
      balanced[i] <- z.3 - z.12 <= crit
    }  
  } 
  prop.balanced <- sum(balanced) / length(balanced)    # proportion of 
  prop.imbalanced <- 1 - prop.balanced                 # proportion of 
  
  res <- list(total=length(balanced),
              imbalanced=sum(!balanced),
              prop.balanced=prop.balanced, 
              prop.imbalanced=prop.imbalanced,
              triads.imbalanced=comb[!balanced, ])
  class(res) <- "indexConflict2"
  res
}


indexConflict2Out1 <- function(x, digits=1) {
  cat("\n###############################")
  cat("\nConflicts based on correlations")
  cat("\n###############################") 
  cat("\n\nAs devised by Bassler et al. (1992)")
  
  cat("\n\nTotal number of triads:", x$total)
  cat("\nNumber of imbalanced triads:", x$imbalanced)  
  cat("\n\nProportion of balanced triads:", 
      round(x$prop.balanced * 100, digits=digits), "%")
  cat("\nProportion of imbalanced triads:", 
      round(x$prop.imbalanced * 100, digits=digits), "%\n")
}


indexConflict2Out2 <- function(x) {
  cat("\nConstructs that form imbalanced triads:\n")
  df <- as.data.frame(x$triads.imbalanced)
  colnames(df) <- c(" ", "  ", "   ")
  print(df)
}


#' Print method for class indexConflict2
#' 
#' @param x       A \code{repgrid} object.
#' @param digits  Numeric. Number of digits to round to (default is 
#'                \code{1}).
#' @param output  Numeric. The output printed to the console. \code{output=1} (default) 
#'                will print information about the conflicts to the console.
#'                \code{output=2} will additionally print the conflictive
#'                triads. 
#' @param ...     Not evaluated.
#' @export
#' @method        print indexConflict2
#' @keywords      internal
#'
print.indexConflict2 <- function(x, digits=1, output=1, ...){
  indexConflict2Out1(x, digits=digits) 
  if (output == 2) 
    indexConflict2Out2(x)
} 



#' Conflict measure as proposed by Bell (2004). 
#'
#' Measure of conflict or inconsistency as proposed by Bell (2004).
#' The identification of conflict is based on distances rather than 
#' correlations as in other measures of conflict \code{\link{indexConflict1}}
#' and \code{\link{indexConflict2}}. It assesses if the 
#' distances between all components of a triad, made up of one element 
#' and two constructs, satisfies the "triangle inequality" (cf. Bell, 2004).
#' If not, a triad is regarded as conflictive. An advantage of the measure 
#' is that it can be interpreted not only as a global measure for a 
#' grid but also on an element, construct, and element by construct level 
#' making it valuable for detailed feedback. Also, differences in conflict 
#' can be submitted to statistical testing procedures.
#'
#' Status:  working; output for euclidean and manhattan distance 
#'          checked against Gridstat output. \cr
#' TODO:    standardization and z-test for discrepancies; 
#'          Index of Conflict Variation.
#'
#' @title       Conflict or inconsistenciy measure for grids (Bell, 2004) based on distances.
#'
#' @param x             \code{repgrid} object.
#' @param p             The power of the Minkowski distance. \code{p=2} (default) will result
#'                      in euclidean distances, \code{p=1} in city block
#'                      distances.
#' @param e.out         Numeric. A vector giving the indexes of the elements
#'                      for which detailed stats (number of conflicts per element,
#'                      discrepancies for triangles etc.) are promted 
#'                      (default \code{NA}, i.e. no detailed stats for any element).
#' @param e.threshold   Numeric. Detailed stats are prompted for those elements with a an 
#'                      attributable percentage to the overall conflicts 
#'                      higher than the supplied threshold
#'                      (default \code{NA}).
#' @param c.out         Numeric. A vector giving the indexes of the constructs
#'                      for which detailed stats (discrepancies for triangles etc.) 
#'                      are promted (default \code{NA}, i. e. no detailed stats).
#' @param c.threshold   Numeric. Detailed stats are prompted for those constructs with a an 
#'                      attributable percentage to the overall conflicts 
#'                      higher than the supplied threshold
#'                      (default \code{NA}).
#' @param trim          The number of characters a construct (element) is trimmed to (default is
#'                      \code{10}). If \code{NA} no trimming is done. Trimming
#'                      simply saves space when displaying the output.
#'
#' @return              A list (invisibly) containing containing: \cr
#'                      \item{potential}{number of potential conflicts}
#'                      \item{actual}{count of actual conflicts}
#'                      \item{overall}{percentage of conflictive relations}
#'                      \item{e.count}{number of involvements of each element in conflictive relations}
#'                      \item{e.perc}{percentage of involvement of each element in total of conflictive relations}
#'                      \item{e.count}{number of involvements of each construct in conflictive relation}
#'                      \item{c.perc}{percentage of involvement of each construct in total of conflictive relations}
#'                      \item{e.stats}{detailed statistics for prompted elements}
#'                      \item{c.stats}{detailed statistics for prompted constructs}                     
#'                      \item{e.threshold}{threshold percentage. Used by print method}
#'                      \item{c.threshold}{threshold percentage. Used by print method}
#'                      \item{enames}{trimmed element names. Used by print method}
#'                      \item{cnames}{trimmed construct names. Used by print method}
#'
#' @references    Bell, R. C. (2004). A new approach to measuring inconsistency 
#'                or conflict in grids. Personal Construct Theory & Practice, 
#'                (1), 53-59.
#' @section output: For further control over the output see \code{\link{print.indexConflict3}}.
#' @author        Mark Heckmann
#' @export
#' @seealso       See \code{\link{indexConflict1}} and \code{\link{indexConflict2}} 
#'                for conflict measures based on triads of correlations.
#'
#' @examples \dontrun{
#'
#'  # calculate conflicts
#'  indexConflict3(bell2010)
#'  
#'  # show additional stats for elements 1 to 3
#'  indexConflict3(bell2010, e.out=1:3)
#'  
#'  # show additional stats for constructs 1 and 5
#'  indexConflict3(bell2010, c.out=c(1,5))
#'  
#'  # finetune output
#'  ## change number of digits
#'  x <- indexConflict3(bell2010)
#'  print(x, digits=4)
#'
#'  ## omit discrepancy matrices for constructs
#'  x <- indexConflict3(bell2010, c.out=5:6)
#'  print(x, discrepancies=FALSE)
#'  
#' }
#'
#'
indexConflict3 <- function(x, p=2,  
                           e.out=NA, e.threshold=NA,
                           c.out=NA, c.threshold=NA,
                           trim=20) {
  # To assess the triangle inequality we need:
  #
  # - d.ij   'distance'  between element i and constuct j
  # - d.ik   'distance'  between element i and constuct k
  # - d.jk   distance between the constructs j and k
  #
  # Let the distance between element i and a construct j (i.e. d.ij)
  # be the rating of element i on construct j.
  # The distance between the constucts it the distance (euclidean or city block)
  # between them without taking into account the element under consideration.
  
  s <- getRatingLayer(x)            # grid scores matrix
  ne <- getNoOfElements(x)
  nc <- getNoOfConstructs(x)
  enames <- getElementNames2(x, index=T, trim=trim,  pre="", post=" ")
  cnames <- getConstructNames2(x, index=T, trim=trim, mode=1, pre="", post=" ")
  
  # set up result vectors
  # confict.disc      discrepancy for each triangle (indexed e, c1, c2)
  # confict.e         number of conflicts for each element
  # conflict.c        number of conflicts for each construct
  # conflict.total    overall value of conflictive triangles
  conflict.disc  <- array(NA, dim=c(nc, nc, ne))
  conflict.e  <- rep(0, ne)
  conflict.c  <- rep(0, nc)
  conflict.total <- 0
  conflicts.potential <-  ne * nc *(nc -1)/2
  # e is i, c1 is j and c2 is k in Bell's Fortran code
  
  for (e in seq_len(ne)){
    # average distance between constructs c1 and c2 not taking into account
    # the element under consideration. Generalization for any minkwoski metric
    dc <- dist(s[, -e], method="minkowski", p=p) / (ne - 1)^(1/p)     # Bell averages the unsquared distances (euclidean), 
    dc <- as.matrix(dc)   # convert dist object to matrix             # i.e. divide euclidean dist by root of n or p in the general case
    
    for (c1 in seq_len(nc)){
      for (c2 in seq_len(nc)){
        if (c1 < c2){
          d.jk <- dc[c1, c2]
          d.ij <- s[c1, e]
          d.ik <- s[c2, e]
          
          # assess if triangle inequality fails., i.e. if one distance is bigger 
          # than the sum of the other two distances. The magnitude it is bigger
          # is recorded in disc (discrepancy)
          if (d.ij > (d.ik + d.jk))
            disc <- d.ij-(d.ik + d.jk) else 
              if (d.ik > (d.ij + d.jk))
                disc <- d.ik-(d.ij + d.jk) else 
                  if (d.jk > (d.ij + d.ik))
                    disc <- d.jk - (d.ij + d.ik) else 
                      disc <- NA
          
          # store size of discrepancy in confict.disc and record discrepancy
          # by element (confict.e) construct (confict.c) and overall (confict.total)
          if (!is.na(disc)){
            conflict.disc[c1, c2, e]  <- disc
            conflict.disc[c2, c1, e]  <- disc
            conflict.e[e]  <- conflict.e[e] + 1       
            conflict.c[c1]  <- conflict.c[c1] + 1
            conflict.c[c2]  <- conflict.c[c2] + 1
            conflict.total <- conflict.total + 1
          }
        }
      }   
    }
  }
  
  # add e and c names to results
  dimnames(conflict.disc)[[3]] <- enames  
  conflict.e.df <- data.frame(percentage=conflict.e)
  rownames(conflict.e.df) <- enames
  conflict.c.df <- data.frame(percentage=conflict.c)
  rownames(conflict.c.df) <- cnames
  
  
  ### Detailed stats for elements ###
  
  conflictAttributedByConstructForElement <- function(e){
    e.disc.0 <- e.disc.na <- conflict.disc[ , , e]          # version with NAs and zeros for no discrepancies
    e.disc.0[is.na(e.disc.0)] <- 0                          # replace NAs by zeros
    
    e.disc.no <- apply(!is.na(e.disc.na), 2, sum)           # number of conflicts per construct   
    e.disc.perc <- e.disc.no / sum(e.disc.no) * 100         # no conf. per as percentage
    e.disc.perc.df <- data.frame(percentage=e.disc.perc)      # convert to dataframe
    rownames(e.disc.perc.df) <- cnames                      # add rownames
    
    n.conflict.pairs <-  sum(e.disc.no) / 2                 # number of conflicting construct pairs all elements
    disc.avg <- mean(e.disc.0)                              # average level of discrepancy
    disc.sd <- sd(as.vector(e.disc.na), na.rm=T)            # sd of discrepancies
    
    disc.stand <- (e.disc.na - disc.avg) / disc.sd          # standardized discrepancy
    
    list(e=e, 
         disc=e.disc.na,
         pairs=n.conflict.pairs,
         constructs=e.disc.perc.df,
         avg=disc.avg,
         sd=disc.sd)#,
    #disc.stand=round(disc.stand, digits))
  }
  
  
  ### Detailed stats for constructs ###
  
  conflictAttributedByElementForConstruct <- function(c1) {
    c1.disc.0 <- c1.disc.na <- conflict.disc[c1, , ]     # version with NAs and zeros for no discrepancies
    rownames(c1.disc.na) <- paste("c", seq_len(nrow(c1.disc.na)))
    colnames(c1.disc.na) <- paste("e", seq_len(ncol(c1.disc.na)))
    
    c1.disc.0[is.na(c1.disc.0)] <- 0                     # replace NAs by zeros
    
    disc.avg <- mean(c1.disc.0)                          # average level of discrepancy
    disc.sd <- sd(as.vector(c1.disc.na), na.rm=T)        # sd of discrepancies
    list(c1=c1, 
         disc=c1.disc.na,
         avg=disc.avg,
         sd=disc.sd)#,
    #disc.stand=round(disc.stand, digits))
  }
  
  # Select which detailed stats for elements. Either all bigger than
  # a threshold or the ones selected manually.
  if (!is.na(e.out[1]))
    e.select <- e.out else 
      if (!is.na(e.threshold[1]))
        e.select <- which(conflict.e/conflict.total *100 > e.threshold) else
          e.select <- NA
  
  e.stats <- list()               # list with detailed results
  if (!is.na(e.select[1])){
    for (e in seq_along(e.select))
      e.stats[[e]] <- conflictAttributedByConstructForElement(e.select[e]) 
    names(e.stats) <- enames[e.select]   
  }
  
  # Select which detailed stats for constructs. Either all bigger than
  # a threshold or the ones selected manually.
  if (!is.na(c.out[1]))
    c.select <- c.out else 
      if (!is.na(c.threshold[1]))
        c.select <- which(.5*conflict.c/conflict.total *100 > c.threshold) else
          c.select <- NA
  
  c.stats <- list()               # list with detailed results
  if (!is.na(c.select[1])){
    for (c in seq_along(c.select))
      c.stats[[c]] <- conflictAttributedByElementForConstruct(c.select[c])
    names(c.stats) <- cnames[c.select]   
  }
  
  res <- list(potential = conflicts.potential,
              actual = conflict.total,  
              overall = conflict.total/conflicts.potential * 100,
              e.count = conflict.e,
              e.perc = conflict.e.df / conflict.total * 100,
              c.count= conflict.c,
              c.perc = .5 * conflict.c.df / conflict.total * 100,
              e.stats = e.stats,
              c.stats = c.stats,
              e.threshold = e.threshold,    # threshold for elements
              c.threshold = c.threshold,
              enames=enames,                # element names
              cnames=cnames)
  class(res) <- "indexConflict3"
  res
}


### Output to console ###
indexConflict3Out1 <- function(x, digits=1) {
  cat("\n##########################################################")
  cat("\nCONFLICT OR INCONSISTENCIES BASED ON TRIANGLE INEQUALITIES")
  cat("\n##########################################################\n")
  cat("\nPotential conflicts in grid: ", x$potential)
  cat("\nActual conflicts in grid: ", x$actual) 
  cat("\nOverall percentage of conflict in grid: ", 
      round(x$actual / x$potential * 100, digits), "%\n") 
  
  cat("\nELEMENTS")
  cat("\n########\n")
  cat("\nPercent of conflict attributable to element:\n\n")
  print(round(x$e.perc * 100, digits)) 
  cat("\nChi-square test of equal count of conflicts for elements.\n")
  print(chisq.test(x$e.count))
  
  cat("\nCONSTRUCTS")
  cat("\n##########\n")
  cat("\nPercent of conflict attributable to construct:\n\n")
  print(round(x$c.perc , digits))
  cat("\nChi-square test of equal count of conflicts for constructs.\n")
  print(chisq.test(x$c.count))
  #print(sd(conflict.c.perc))
  #print(var(conflict.c.perc))    
}


indexConflict3Out2 <- function(x, digits=1, discrepancies=TRUE) {
  e.stats <- x$e.stats
  e.threshold <- x$e.threshold
  enames <- x$enames
  
  if (length(e.stats) == 0)     # stop function in case  
    return(NULL)
  
  cat("\n\nCONFLICTS BY ELEMENT")
  cat("\n####################\n")
  if (!is.na(e.threshold))
    cat("(Details for elements with conflict >", e.threshold, "%)\n")
  
  for (e in seq_along(e.stats)){
    m <- e.stats[[e]]
    if (!is.null(m)){
      cat("\n\n### Element: ", enames[m$e], "\n")
      cat("\nNumber of conflicting construct pairs: ", m$pairs, "\n")
      if (discrepancies){
        cat("\nConstruct conflict discrepancies:\n\n")
        disc <- round(m$disc, digits)
        print(as.data.frame(formatMatrix(disc, rnames="", 
                                         mode=2, diag=F), stringsAsFactors=F))
      }
      cat("\nPercent of conflict attributable to each construct:\n\n")    
      print(round(m$constructs, digits))
      cat("\nAv. level of discrepancy:   ", round(m$avg, digits), "\n")
      cat("\nStd. dev. of discrepancies: ", round(m$sd, digits + 1), "\n")
    }
  }
}


indexConflict3Out3 <- function(x, digits=1, discrepancies=TRUE) 
{
  c.threshold <- x$c.threshold
  c.stats <- x$c.stats
  cnames <- x$cnames
  
  if (length(c.stats) == 0)     # stop function in case  
    return(NULL)
  
  cat("\n\nCONFLICTS BY CONSTRUCT")
  cat("\n######################\n")
  if (!is.na(c.threshold))
    cat("(Details for constructs with conflict >", c.threshold, "%)\n")
  
  for (c in seq_along(c.stats)) {
    x <- c.stats[[c]]
    if (!is.null(x)) {
      cat("\n\n### Construct: ", cnames[x$c1], "\n")
      if (discrepancies) {
        cat("\nElement-construct conflict discrepancies:\n\n")
        disc <- round(x$disc, digits)
        print(as.data.frame(formatMatrix(disc, 
                                         rnames=paste("c", seq_len(nrow(x$disc)), sep=""), 
                                         cnames=paste("e", seq_len(ncol(x$disc)), sep=""),
                                         pre.index=c(F,F),
                                         mode=2, diag=F), stringsAsFactors=F))
      }
      cat("\nAv. level of discrepancy:   ", round(x$avg, digits), "\n")
      cat("\nStd. dev. of discrepancies: ", round(x$sd, digits + 1), "\n")
    }
  }
}


#' print method for class indexConflict3
#' 
#' @param x             Output from funtion indexConflict3
#' @param output        Type of output. \code{output=1} will print all results
#'                      to the console, \code{output=2} will only print the
#'                      detailed statistics for elements and constructs. 
#' @param digits        Numeric. Number of digits to round to (default is 
#'                      \code{2}).
#' @param discrepancies Logical. Whether to show matrices of discrepancies in 
#'                      detailed element and construct stats (default \code{TRUE}).
#' @param ...           Not evaluated.
#' @export
#' @method              print indexConflict3
#' @keywords            internal
#'                    
print.indexConflict3 <- function(x, digits=2, output=1, discrepancies=TRUE, ...)
{
  if (output == 1)
    indexConflict3Out1(x, digits=digits) 
  indexConflict3Out2(x, digits=digits, discrepancies=discrepancies)
  indexConflict3Out3(x, digits=digits, discrepancies=discrepancies) 
}


# plots distribution of construct correlations
#
indexDilemmaShowCorrelationDistribution <- function(x, e1, e2)
{
  rc.including <- constructCor(x)  
  rc.excluding <- constructCor(x[, -c(e1, e2)])
  rc.inc.vals <- abs(rc.including[lower.tri(rc.including)])
  rc.exc.vals <- abs(rc.excluding[lower.tri(rc.excluding)])
  
  histDensity <- function(vals, probs=c(.2, .4, .6, .8, .9), ...){
    h <- hist(vals, breaks=seq(0, 1.01, len=21), freq=F, 
              xlim=c(0, 1), border="white", col=grey(.8), ...)
    d <- density(vals)
    lines(d$x, d$y)
    q <- quantile(vals, probs=probs)
    abline(v=q, col="red")
    text(q, 0, paste(round(probs*100, 0), "%"), cex=.8, pos=2, col="red")  
  }
  
  layout(matrix(c(1,2), ncol=1))
  par(mar=c(3,4.2,2.4,2))
  histDensity(rc.inc.vals, cex.main=.8, cex.axis=.8, cex.lab=.8,
              main="Distribution of absolute construct-correlations \n(including 'self' and 'ideal self')")
  histDensity(rc.exc.vals,  cex.main=.8, cex.axis=.8, cex.lab=.8, 
              main="Distribution of absolute construct-correlations \n(excluding 'self' and 'ideal self')")
}


# internal workhorse for indexDilemma
#
# @param x               \code{repgrid} object.
# @param self            Numeric. Index of self element.
# @param ideal           Numeric. Index of ideal self element. 
# @param diff.mode       Numeric. Method adopted to classify construct pairs into congruent 
#                        and discrepant. With \code{diff.mode=1}, the minimal and maximal 
#                        score difference criterion is applied. With \code{diff.mode=0} the Mid-point
#                        rating criterion is applied. Default is \code{diff.mode=1}.

# @param diff.congruent  Is used if \code{diff.mode=1}. Maximal difference between
#                        element ratings to define construct as congruent (default
#                        \code{diff.congruent=1}). Note that the value
#                        needs to be adjusted by the user according to the rating scale
#                        used.
# @param diff.discrepant Is used if \code{diff.mode=1}. Minimal difference between
#                        element ratings to define construct as discrepant (default
#                        \code{diff.discrepant=4}). Note that the value
#                        needs to be adjusted by the user according to the rating scale
#                        used.
# @param diff.poles      Not yet implemented.
# @param r.min           Minimal correlation to determine implications between
#                        constructs.
# @param exclude         Whether to exclude the elements self and ideal self 
#                        during the calculation of the inter-construct correlations.
#                        (default is \code{FALSE}).
# @param index           Whether to print index numbers in front of each construct 
#                        (default is \code{TRUE}).
# @param trim            The number of characters a construct (element) is trimmed to (default is
#                        \code{20}). If \code{NA} no trimming is done. Trimming
#                        simply saves space when displaying the output.
# @param digits          Numeric. Number of digits to round to (default is 
#                        \code{2}).
# @author                Mark Heckmann, Alejandro García, Diego Vitali
# @export
# @keywords internal
# @return                A list with four elements containing different steps of the 
#                        calculation.
#

# THIS IS FUNCTION IS NEEDED TO OUTPUT DILEMMAS CORRECTLY
get.pole <- function(grid, pole){
  # NEW : get the label of the pole to invert construct if needed
  names <- function(grid){
    grid[[1]]
  }
  poles <- as.data.frame(lapply(grid@constructs, sapply, names))
  colnames(poles)<-1:length(poles)
  poles <- data.frame(lapply(poles, as.character), stringsAsFactors=FALSE)
  
  leftpole <- poles[1,]
  rightpole <- poles[2,]
  
  if (pole == 'left') {
    return(leftpole)
  }
  else if (pole == 'right') {
    return(rightpole)
  }
  else {
    print('Please, introduce left or right pole')
  }
}

indexDilemmaInternal <- function(x, self, ideal, 
                            diff.mode = 1, diff.congruent = 1,
                            diff.discrepant = 4, diff.poles = 1, 
                            r.min, exclude = FALSE, digits = 2,
                            index = T, trim = FALSE) # CHANGE: set defaults
                                                     # to RECORD 5.0 defaults
{
  s <- getRatingLayer(x)         # grid scores matrix
  # NEW: To invert constructs
  # create a vector of inverted scores for the 'self' element:
  # invscr = 8 - scr
  # Example: 2 -> 8 - 2 -> 6
  #          5 -> 8 - 5 -> 3
  inverteds <- getScale(x)[2] - s + 1   # e.g. 8 - 1
  nc <- getNoOfConstructs(x)
  cnames <- getConstructNames2(x, index=index, trim=trim, mode=1, pre="", post=" ")
  
  sc <- getScale(x)
  midpoint <- (sc[1] + sc[2])/2     # NEW (DIEGO) get scale midpoint this is importat in
                                    # when Alejandro's code check whether self/ideal   
                                    # is == to the midpoint or not (see below "Get Dilemmas" section)
  
  # GET IF CONSTRUCTS ARE DISCREPANT, CONGRUENT OR NEITHER    
  
  # difference self - ideal self  
  diff.between <- abs(s[, self] - s[, ideal])
  
  #is.congruent.e = logical() # UPDATE (DIEGO) - Simplified - we dont need two sets of logical characters variables now
  #type.c.elem <- character()
  is.congruent = logical()
  type.c <- character()
 
  # CORRECTION (ALEJANDRO): a construct 
  # can't be congruent if it's 'self' score is 4 (AKA self-
  # disorientation). Neither can be congruent if IDEAL is 4.
  # CORRECTION (Diego): I have just updated this avoid hardcoding the midpoint!!
  if (diff.mode == 1){
    for (i in 1:nc){
      if (s[,self][i] != midpoint){
        if (s[,ideal][i] != midpoint){
          is.congruent[i] <- diff.between[i] <= diff.congruent        
        }
        else{
          is.congruent[i] <- FALSE
        }
      }
      else{
        is.congruent[i] <- FALSE
      }
    }
  
  is.discrepant<- diff.between >= diff.discrepant
  is.neither <- !is.congruent & !is.discrepant
  
  type.c[is.congruent] <- "congruent"
  type.c[is.discrepant] <- "discrepant"
  type.c[is.neither] <- "neither"
  }
  # # difference from poles NOT YET IMPLEMENTED
  # sc <- getScale(x)
  # diff.pole1 <- abs(s[, c(e.self, e.ideal)] - sc[1])
  # diff.pole2 <- abs(s[, c(e.self, e.ideal)] - sc[2])
  # #are both elements within the allowed distance from the poles and at the same pole (congruent)
  # is.congruent.p <- diff.pole1[,1] <= diff.poles & diff.pole1[,2] <= diff.poles |
  #                   diff.pole2[,1] <= diff.poles & diff.pole2[,2] <= diff.poles
  # is.discrepant.p <- diff.pole1[,1] <= diff.poles & diff.pole2[,2] <= diff.poles |
  #                     diff.pole1[,1] <= diff.poles & diff.pole2[,2] <= diff.poles
  # 
  # is.neither.p <- !is.congruent.p & !is.discrepant.p 
  # type.c.poles[is.congruent.p] <- "congruent"
  # type.c.poles[is.discrepant.p] <- "discrepant"
  # type.c.poles[is.neither.p] <- "neither"
  #
  #
  ####################################################################################
  ## MIDPOINT-BASED CRITERION TO IDENTIFY CONGRUENT AND DISCREPANT constructs 
  ####################################################################################
  #### added by DIEGO
  #   I have tried to implement here the other popular method for the identification of 
  #   Congruent and Discrepant constructs. This proposed below is that applied by IDIOGRID
  #   software (V.2.3)
  #   IDIOGRID uses "the scale midpoint as the 'dividing line' for discrepancies; for example, 
  #   if the actual self (the Subject Element) is rated above the scale midpoint and the ideal 
  #   self (the Target Element) is rated below the midpoint, then a discrepancy exists (and 
  #   vice versa). If the two selves are rated on the same side of the scale or if either 
  #   the actual self or the ideal self are rated at the midpoint of the scale, then a discre- 
  #   pancy does not exist." ( from IDIOGRID manual)

  else if (diff.mode == 0){
    
    is.congruent <- (s[, self] < midpoint  &  s[, ideal] < midpoint) | 
                    (s[, self] > midpoint  &  s[, ideal] > midpoint)
  
    is.discrepant<- (s[, self] < midpoint  &  s[, ideal] > midpoint) | 
                    (s[, self] > midpoint  &  s[, ideal] < midpoint)
  
    is.neither<- !is.congruent & !is.discrepant
    type.c[is.congruent] <- "congruent"
    type.c[is.discrepant] <- "discrepant"
    type.c[is.neither] <- "neither"
  }else {stop("\nNO differentiation method (diff.mode) SELECTED! quitting ..")}

  ############## END OF MIDPOINT-BASED CRITERION ####################################
  



  ####################################################################################
  # DIEGO: This that I have commented-out is now redundant as the variables are not duplicates 
  # anymore and are calculated only in their conditional loop. This is more efficient
  # ###################################################################################
  #  if (diff.mode == 1){
  #  is.congruent <- is.congruent.e
  #  is.discrepant <- is.discrepant.e
  #  type.construct <- type.c.elem
  #  } else if (diff.mode == 0){ ##### ADDED CHOICE "0" for MIDPOINT RATING CRITERION
  #  is.congruent <- is.congruent.p
  #  is.discrepant <- is.discrepant.p
  #  type.construct <- type.c.poles 
  #  }
  # we just need the next line to reconnect with the original indexdilemma routine
  #####################################################################################
  type.construct <- type.c
  # GET CORRELATIONS
  
  # inter-construct correlations including and excluding 
  # the elements self and ideal self
  rc.include <- constructCor(x)                     # TODO digits=digits
  rc.exclude <- constructCor(x[, -c(self, ideal)])  #digits=digits
  
  # correlations to use for evaluation
  if (exclude)
    rc.use <- rc.exclude else
      rc.use <- rc.include
  
  # type.c.poles <- type.c.elem <- rep(NA, nrow(s)) # set up results vectors
  type.c <- rep(NA, nrow(s))
  # GET DILEMMAS
  
  # which pairs of absolute construct correlations are bigger than r.min?
  
  comb <- t(combn(nc, 2)) # all possible correlation pairs (don't repeat)
  needs.to.invert <- logical()
  
  # set up result vectors
  check <- bigger.rmin <- r.include <- r.exclude <- 
    type.c1 <- type.c2 <- rep(NA, nrow(comb))
  
  # check every pair of constructs for characteristics
  for (i in 1:nrow(comb)){
    c1 <- comb[i,1]
    c2 <- comb[i,2]
    r.include[i] <- rc.include[c1, c2]
    r.exclude[i] <- rc.exclude[c1, c2]
    type.c1[i] <- type.construct[c1]
    type.c2[i] <- type.construct[c2]
    
    # CORRECTION:
    # To create a dilemma, the 'self' scores of both contructs must be
    # on the same pole. We have to check for that.
    
    # REMOVED HARDCODED MIDPOINT
    # DIEGO: 4 is the midpoint and it was "hardcoded". This is not good if we have a scoring range
    # that is not 1-7 because in that case the midpoint will NOT be 4!
    #
    # DIEGO: another bug-fix is that in the section where the scripts "reorient" the constructs:
    # the code to re-orient the constructs is not controlling for self or ideal self to be scored 
    # as the midpoint. This causes the script break. I have added a condition for those combinations 
    # equivalent to self-score != midpoint
    
    if (s[c1, self] != midpoint & s[c2, self] != midpoint){
      if (s[c1, self] > midpoint & s[c2, self] > midpoint) {   
        if (rc.use[c1, c2] >= r.min) # CORRECTION: don't use ABS values,
          # we invert scores to check constructs
          # to find correlations the other way
          bigger.rmin[i] <- TRUE else
            bigger.rmin[i] <- FALSE
          check[i] <- (is.congruent[c1] & is.discrepant[c2]) |
            (is.discrepant[c1] & is.congruent[c2])
          needs.to.invert[c1] <- TRUE
          needs.to.invert[c2] <- TRUE
      }
      else if (s[c1, self] < midpoint & s[c2, self] < midpoint) {
        if (rc.use[c1, c2] >= r.min)
          bigger.rmin[i] <- TRUE else
            bigger.rmin[i] <- FALSE
          check[i] <- (is.congruent[c1] & is.discrepant[c2]) |
            (is.discrepant[c1] & is.congruent[c2])
          needs.to.invert[c1] <- FALSE
          needs.to.invert[c2] <- FALSE
      }
      
      # NEW:
      # Now check for inverted scores.
      # You only need to invert one construct at a time
      
      if (inverteds[c1, self] > midpoint & s[c2, self] > midpoint) {
        r.include[i] = cor(inverteds[c1,], s[c2,])
        r.exclude[i] = "*Not implemented"
        if (r.include[i] >= r.min) 
          bigger.rmin[i] <- TRUE else
            bigger.rmin[i] <- FALSE
        check[i] <- (is.congruent[c1] & is.discrepant[c2]) |
          (is.discrepant[c1] & is.congruent[c2])
        needs.to.invert[c2] <- TRUE
      }
      else if (inverteds[c1, self] < midpoint & s[c2, self] < midpoint){
        r.include[i] = cor(inverteds[c1,], s[c2,])
        r.exclude[i] = "*Not implemented"
        if (r.include[i] >= r.min) 
          bigger.rmin[i] <- TRUE else
            bigger.rmin[i] <- FALSE
        check[i] <- (is.congruent[c1] & is.discrepant[c2]) |
          (is.discrepant[c1] & is.congruent[c2])
        needs.to.invert[c1] <- TRUE
      }
      
      if (s[c1, self] > midpoint & inverteds[c2, self] > midpoint) {
        r.include[i] = cor(s[c1,], inverteds[c2,])
        r.exclude[i] = "*Not implemented"
        if (r.include[i] >= r.min) 
          bigger.rmin[i] <- TRUE else
            bigger.rmin[i] <- FALSE
        check[i] <- (is.congruent[c1] & is.discrepant[c2]) |
          (is.discrepant[c1] & is.congruent[c2])
        needs.to.invert[c1] <- TRUE
      }
      else if (s[c1, self] < midpoint & inverteds[c2, self] < midpoint) {
        r.include[i] = cor(s[c1,], inverteds[c2,])
        r.exclude[i] = "*Not implemented"
        if (r.include[i] >= r.min) 
          bigger.rmin[i] <- TRUE else
            bigger.rmin[i] <- FALSE
        check[i] <- (is.congruent[c1] & is.discrepant[c2]) |
          (is.discrepant[c1] & is.congruent[c2])
        needs.to.invert[c2] <- TRUE
      }
    }
    else{ # DIEGO: closing of the if() where I put the condition for self to be != to the midpoint score
    needs.to.invert[c1] <- FALSE
    needs.to.invert[c2] <- FALSE
    }
    #print(paste(needs.to.invert,s[c1,self],s[c2,self])) # Diego debug printout of variables
  }
  # New: invert construct label poles if needed
  needs.to.invert[is.na(needs.to.invert)] <- F
  #print(needs.to.invert)
  #print(nc)
  #print(is.na(needs.to.invert))
  
  leftpole <- get.pole(x, 'left')
  rightpole <- get.pole(x, 'right')
  
  for (i in 1:nc) {
    if (needs.to.invert[i]) {
      s[i, self] <- inverteds[i, self]
      cnames[i] = paste(rightpole[i], leftpole[i], sep = '-')
    }
    else {
      cnames[i] = paste(leftpole[i], rightpole[i], sep = '-')
    }
    
  }
  
  # GET RESULTS
  
  # 1: this data frame contains information related to 'self' and 'ideal' elements
  
  res1 <- data.frame(a.priori=type.construct, self=s[, self], ideal=s[, ideal],
                     stringsAsFactors=F)
  colnames(res1) <- c("A priori", "Self", "Ideal")
  rownames(res1) <- cnames
  
  # 2: This dataframe stores the information for all posible construct combinations
  res2 <- data.frame(c1=comb[,1], c2=comb[,2], r.inc=r.include, 
                     r.exc=r.exclude, bigger.rmin, type.c1, type.c2, check,
                     name.c1=cnames[comb[,1]], name.c2=cnames[comb[,2]], 
                     stringsAsFactors=F) 
  
  # 3: This dataframe contains informartion for all the dilemmas
  res3 <- subset(res2, check==T & bigger.rmin==T)  
  
  cnstr.labels = character()
  cnstr.labels.left <- cnstr.labels.right <- cnstr.labels
  
  # Number of dilemmas
  nd <- length(res3$c1)
  
  # New: Put all discrepant constructs to the right
  if (nd != 0) {
    for (v in 1:nd) {
      if (res3$type.c1[v] == 'discrepant') {
        cnstr.labels.left[v] = res3[v, 10]
        cnstr.labels.right[v] = res3[v, 9]
      }
      else {
        cnstr.labels.left[v] = res3[v, 9]
        cnstr.labels.right[v] = res3[v, 10]
      }
    }
  }
  
  # 4: NEW: reordered dilemma output
  res4 <- data.frame(cnstr.labels.left, Rtot=res3[,3], cnstr.labels.right, RexSI=res3[,4])                
  colnames(res4) = c('Self - Not self', 'Rtot', 'Self - Ideal', 'RexSI')
  
  list(res1=res1, res2=res2, res3=res3, res4=res4)
}


# output function for indexDilemma
#
indexDilemmaOut0 <- function(res, self, ideal, enames, 
                             diff.discrepant, diff.congruent, exclude, r.min, diff.mode){
  cat("\n###################\n")
  cat("Implicative Dilemma")
  cat("\n###################\n")
  
  cat("\nActual Self Position:", enames[self])               
  cat("\nIdeal Self Position:", enames[ideal])   
  
  cat("\n\nA Priori Criteria (for classification):")
  # differentiation mode 0 for midpoint-based criterion (Grimes - Idiogrid) OR
  # differentiation mode 1 for Feixas "correlation cut-off" criterion
  if (diff.mode == 1){
    cat("\nDiscrepant Difference: >=", diff.discrepant)
    cat("\nCongruent Difference: <=", diff.congruent)
  }else if (diff.mode == 0){
    cat("\nUsing Midpoint rating criterion")
  }
  cat("\n\nCorrelation Criterion: >=", r.min)
  if (exclude)
    cat("\nCriterion Correlation excludes Self & Ideal") else 
      cat("\nCriterion Correlation includes Self & Ideal\n")
  
  cat("\nNumber of Implicative Dilemmas found:", nrow(res$res4), "\n")
  #Extreme Criteria:
  #Discrepant Difference: Self-Ideal greater than or equal to, Max Other-Self difference
  #Congruent Difference: Self-Ideal less than or equal to, Min Other-Self difference  
}


# output function for indexDilemma
#
indexDilemmaOut1 <- function(res){
  cat("\n\nClassification of Constructs")
  cat("\n############################\n\n")
  print(res$res1)
  cat("\n\tNote: if Self' score is not 4, left pole corresponds to Self\n")
}


# output function for indexDilemma
#
indexDilemmaOut2 <- function(res, exclude){
  # add asteristic to construct names
  # ids <- res$res3
  #  disc.c1 <- ids$type.c1 == "discrepant"
  #  disc.c2 <- ids$type.c2 == "discrepant"
  #  ids$name.c1[disc.c1] <- paste(ids$name.c1[disc.c1], "*", sep="")
  #  ids$name.c2[disc.c2] <- paste(ids$name.c2[disc.c2], "*", sep="")
  cat("\n\nDilemmatic Self-Ideal Construct Pairs")
  cat("\n#####################################")
  cat("\n\nBy A Priori Criteria:\n\n")
  cat("\n\t", 'Congruents on the left - Discrepants on the right', sep="", "\t\n")
  cat("\n", "\n")
  # df <- data.frame(RexSI=ids[,3], Rtot=ids[,4],
  #                   Constructs=paste(ids[,9], ids[,10], sep=" <==> "))
  df <- res$res4
  if (nrow(df) > 0){
    print(df)
    cat("\n\tRexSI = Correlations excluding Self & ideal")
    cat("\n\tRtot  = Correlations including Self & ideal")
    if (exclude)
      cor.used <- "RexSI" else
        cor.used <- "Rtot"
    cat("\n\t", cor.used, " was used as criterion", sep="")
  } else {
    cat("No implicative dilemmas detected")
  }
}

#' Implicative Dilemmas
#'
#' Implicative dilemmas are closely related to the notion of 
#' conflict. An implicative dilemma arises when a desired change on one 
#' construct is associated with an undesired 
#' implication on another construct. 
#' E. g. a timid subject may want to become more socially skilled but 
#' associates being socially skilled with different negative characteristics 
#' (selfish, insensitive etc.). Hence, he may anticipate that becoming less
#' timid will also make him more selfish (cf. Winter, 1982). 
#' As a consequence the subject will resist to the change if the 
#' negative presumed implications will threaten the patients identity 
#' and the predictive power of his construct system. From this stance 
#' the resistance to change is a logical consequence coherent with 
#' the subjects construct system (Feixas, Saul, & Sanchez, 2000).
#' The investigation of the role of cognitive dilemma in different disorders 
#' in the context of PCP is a current field of research 
#' (e.g. Feixas & Saul, 2004, Dorough et al. 2007).
#'
#' The detection of implicative dilemmas happens in two steps. First the 
#' constructs are classified as being 'congruent' or 'discrepant'. Second
#' the correlation between a congruent and discrepant construct pair
#' is assessed if it is big enough to indicate an implication.
#' 
#' \bold{Classifying the construct} \cr
#' To detect implicit dilemmas the construct pairs are first
#' identified as 'congruent' or 'discrepant'. The assessment
#' is based on the rating differences between the elements
#' 'self' and 'ideal self'.
#' A construct is 'congruent' if the construction of the 'self' and the 
#' preferred state (i.e. ideal self) are the same or similar. 
#' A construct is discrepant if the construction of the 'self' and 
#' the 'ideal' is dissimilar. 
#'
#' There are two popular accepted methods to
#' identify congruent and discrepant constructs:
#' \enumerate{
#'    \item  "Scale Midpoint criterion" (cf. Grice 2008)
#'    \item  "Minimal and maximal score difference" (cf. Feixas & Saul, 2004)
#' }
#'
#' \emph{"Scale Midpoint criterion" (cf. Grice 2008)}
#'
#' As reported in the Idiogrid (v. 2.4) manual: "[..] The Scale Midpoint uses the 
#' scales as the 'dividing line' for discrepancies; for example, if the actual 
#' element is rated above the midpoint, then the discrepancy exists (and vice versa). 
#' If the two selves are the same as the actual side of the scale, then a discrepancy 
#' does not exist". As an example:
#' Assuming a scoring range of 1-7, the midpoint score will be 4, we then look at self 
#' and ideal-self scoring on any given construct and we proceed as follow:
#'
#' \itemize{
#'    \item If the scoring of Self AND Ideal Self are both < 4: construct is "Congruent"
#'    \item If the scoring of Self AND Ideal Self are both > 4: construct is "Congruent"
#'    \item If the scoring of Self is < 4 AND Ideal Self is > 4 (OR viceversa): construct is "discrepant"
#'    \item If scoring Self OR Ideal Self = 4 then the construct is NOT Discrepant and it is "Undifferentiated"
#' }
#'
#' \emph{Minimal and maximal score difference criterion (cf. Feixas & Saul, 2004)}
#'
#' This other method is more conservative and it is designed to minimize Type I errors by a) setting
#' a default minimum correlation between constructs of \code{r = .35}; b) discarding cases where the ideal Self and self are 
#' neither congruent or discrepant; c) discarding cases where ideal self is "not oriented", i.e. 
#' scored as the midpoint.
#''
#' E.g. suppose the element 'self' is rated 2 and 'ideal self' 5 on 
#' a scale from 1 to 6. The ratings differences are 5-2 = 3. If this 
#' difference is smaller than e.g. 1 the construct is 'congruent', if it
#' is bigger than 3 it is 'discrepant'. \cr
#'
#' The values used to classify the constructs 'congruent'
#' or 'discrepant' can be determined in several ways (cf. Bell, 2009):
#' \enumerate{
#'    \item   They are set 'a priori'.
#'    \item   They are implicitly derived by taking into account the rating
#'            differences to the other constructs. 
#'            Not yet implemented.
#' }
#'
#' The value mode is determined via the argument \code{diff.mode}.\cr
#' If no 'a priori' criteria to determine if the construct
#' is congruent or discrepant is supplied as an argument, the values are chosen
#' according to the range of the rating scale used. For the following scales
#' the defaults are chosen as:
#'
#' \tabular{ll}{
#' Scale                \tab 'A priori' criteria        \cr
#' 1 2                  \tab --> con: <=0    disc: >=1  \cr
#' 1 2 3                \tab --> con: <=0    disc: >=2  \cr
#' 1 2 3 4              \tab --> con: <=0    disc: >=2  \cr
#' 1 2 3 4 5            \tab --> con: <=1    disc: >=3  \cr
#' 1 2 3 4 5 6          \tab --> con: <=1    disc: >=3  \cr
#' 1 2 3 4 5 6 7        \tab --> con: <=1    disc: >=4  \cr
#' 1 2 3 4 5 6 7 8      \tab --> con: <=1    disc: >=5  \cr
#' 1 2 3 4 5 6 7 8 9    \tab --> con: <=2    disc: >=5  \cr
#' 1 2 3 4 5 6 7 8 9 10 \tab --> con: <=2    disc: >=6  \cr
#' }
#' 
#' \bold{Defining the correlations} \cr
#' As the implications between constructs cannot be derived from a 
#' rating grid directly, the correlation between two constructs 
#' is used as an indicator for implication. A large correlation means
#' that one construct pole implies the other. A small correlation 
#' indicates a lack of implication. The minimum criterion for a correlation
#' to indicate implication is set to .35 (cf. Feixas & Saul, 2004).
#' The user may also chose another value. To get a an impression
#' of the distribution of correlations in the grid, a visualization can 
#' be prompted via the argument \code{show}.
#' When calculating the correlation used to assess if an implication
#' is given or not, the elements under consideration (i. e. self and ideal self)
#' can be included (default) or excluded. The options will cause different
#' correlations (see argument \code{exclude}). \cr \cr
#'
#' \bold{Example of an implicative dilemma} \cr
#' A depressive person considers herself as timid and 
#' wished to change to the opposite pole she defines as extraverted. 
#' This construct is called discrepant as the construction of the 'self'
#' and the desired state (e.g. described by the 'ideal self') on 
#' this construct differ. The person also considers herself as 
#' sensitive (preferred pole) for which the opposite pole is selfish. 
#' This construct is congruent, as the person construes herself as 
#' she would like to be. If the person now changed on the discrepant 
#' construct from the undesired to the desired pole, i.e. from timid 
#' to extraverted, the question can be asked what consequences such a 
#' change has. If the person construes being timid and being sensitive 
#' as related and that someone who is extraverted will not be timid, a 
#' change on the first construct will imply a change on the congruent 
#' construct as well. Hence, the positive shift from timid to extraverted
#' is presumed to have a undesired effect in moving from sensitive towards
#' selflish. This relation is called an implicative dilemma. As the 
#' implications of change on a construct cannot be derived from a rating 
#' grid directly, the correlation between two constructs is used as an 
#' indicator for implication.
#'
#'
#' @title                 Detect implicative dilemmas (conflicts).
#'
#' @param x               \code{repgrid} object.
#' @param self            Numeric. Index of self element.
#' @param ideal           Numeric. Index of ideal self element. 
#' @param diff.mode       Numeric. Method adopted to classify construct pairs into congruent 
#'                        and discrepant. With \code{diff.mode=1}, the minimal and maximal 
#'                        score difference criterion is applied. With \code{diff.mode=0} the Mid-point
#'                        rating criterion is applied. Default is \code{diff.mode=1}.
#'
#' @param diff.congruent  Is used if \code{diff.mode=1}. Maximal difference between
#'                        element ratings to define construct as congruent (default
#'                        \code{diff.congruent=1}). Note that the value
#'                        needs to be adjusted by the user according to the rating scale
#'                        used.
#' @param diff.discrepant Is used if \code{diff.mode=1}. Minimal difference between
#'                        element ratings to define construct as discrepant (default
#'                        \code{diff.discrepant=3}). Note that the value
#'                        needs to be adjusted by the user according to the rating scale
#'                        used.
#' @param diff.poles      Not yet implemented.
#' @param r.min           Minimal correlation to determine implications between
#'                        constructs.
#' @param exclude         Whether to exclude the elements self and ideal self 
#'                        during the calculation of the inter-construct correlations.
#'                        (default is \code{FALSE}).
#' @param output          The type of output printed to the console. \code{output=1} prints
#'                        classification of the construct into congruent and discrepant
#'                        and the detected dilemmas. \code{output=1} only prints the latter.
#'                        \code{output=0} will surpress printing.
#'                        Note that the type of output does not affect the object
#'                        that is returned invisibly which will be the same in any case
#'                        (see value).
#' @param show            Whether to additionally plot the distribution
#'                        of correlations to help the user assess what level
#'                        is adequate for \code{r.min}.
#' @param index           Whether to print index numbers in front of each construct 
#'                        (default is \code{TRUE}).
#' @param trim            The number of characters a construct (element) is trimmed to (default is
#'                        \code{20}). If \code{NA} no trimming is done. Trimming
#'                        simply saves space when displaying the output.
#' @param digits          Numeric. Number of digits to round to (default is 
#'                        \code{2}).
#'
#' @author                Mark Heckmann, Alejandro García, Diego Vitali
#' @export
#' @return                Called for console output. Invisibly returns a list containing
#'                        the result dataframes and all results from the calculations.
#' @references            
#'                        Bell, R. C. (2009). \emph{Gridstat version 5 - A Program for Analyzing
#'                        the Data of A Repertory Grid} (manual). University of Melbourne,
#'                        Australia: Department of Psychology.
#'                        
#'                        Dorough, S., Grice, J. W., & Parker, J. (2007). Implicative 
#'                        dilemmas and psychological well-being. \emph{Personal Construct
#'                        Theory & Practice}, (4), 83-101.
#'
#'                        Feixas, G., & Saul, L. A. (2004). The Multi-Center Dilemma 
#'                        Project: an investigation on the role of cognitive conflicts 
#'                        in health. \emph{The Spanish Journal of Psychology, 7}(1), 69-78.
#'
#'                        Feixas, G., Saul, L. A., & Sanchez, V. (2000). Detection and 
#'                        analysis of implicative dilemmas: implications for the therapeutic
#'                        process. In J. W. Scheer (Ed.), \emph{The Person in Society: 
#'                        Challenges to a Constructivist Theory}. Giessen: Psychosozial-Verlag.
#'
#'                        Winter, D. A. (1982). Construct relationships, psychological
#'                        disorder and therapeutic change. \emph{British Journal of Medical 
#'                        Psychology, 55} (Pt 3), 257-269.
#'
#'                        Grice, J. W. (2008). Idiogrid: Idiographic Analysis with Repertory 
#'                        Grids (Version 2.4). Oklahoma: Oklahoma State University.
#'
#' @examples \dontrun{
#'  
#'  indexDilemma(boeker, self=1, ideal=2)
#'  indexDilemma(boeker, self=1, ideal=2, out=2)
#'
#'  # additionally show correlation distribution
#'  indexDilemma(boeker, self=1, ideal=2, show=T)
#'
#'  # adjust minimal correlation
#'  indexDilemma(boeker, 1, 2, r.min=.25)
#'
#'  # adjust congruence and discrepance ranges
#'  indexDilemma(boeker, 1, 2, diff.con=0, diff.disc=4)
#'
#'  }
#'
indexDilemma <- function(x, self = 1, ideal = ncol(x), 
                         diff.mode = 1, diff.congruent = NA,
                         diff.discrepant = NA, diff.poles=1, 
                         r.min=.35, exclude=FALSE, digits=2, show=F,
                         output=1, 
                         index=T, trim=20) # CHANGE: set 'self' and
                                  # 'ideal' to first and last column
                                  # respectively
{

  # automatic selection of a priori criteria
  sc <- getScale(x)
  if (is.na(diff.congruent))
    diff.congruent <- floor(diff(sc) * .25)
  if (is.na(diff.discrepant))
    diff.discrepant <-  ceiling(diff(sc) * .6)
  
  # detect dilemmas
  res <- indexDilemmaInternal(x, self=self, ideal=ideal, 
                              diff.mode=diff.mode, diff.congruent=diff.congruent,
                              diff.discrepant=diff.discrepant, diff.poles=diff.poles,
                              r.min=r.min, exclude=exclude, digits=digits, 
                              index=index, trim=trim)
  
  # type of output printed to te console
  enames <- getElementNames2(x, trim = trim, index = T)
  
  if (output == 1) {
    indexDilemmaOut0(res, self, ideal, enames, diff.discrepant, 
                     diff.congruent, exclude, r.min,diff.mode) # added diffmode to print mode in output
    indexDilemmaOut1(res)
    indexDilemmaOut2(res, exclude)
  }
  else if (output == 2) {
    indexDilemmaOut0(res, self, ideal, enames, diff.discrepant, 
                     diff.congruent, exclude, r.min,diff.mode)
    indexDilemmaOut2(res, exclude)
  }
  if (show) 
    indexDilemmaShowCorrelationDistribution(x, self, ideal)
  invisible(res)
}



######################
# Pemutation test to test if grid is random.
# "The null hypothesis [is] that a particular grid 
# is indis- tinguishable from an array of random numbers" 
# (Slater, 1976, p. 129).
#
randomTest <- function(x){
  x
}
# permutationTest
# Hartmann 1992: 
# To illustrate: If a person decided to produce a nonsense grid, 
# the most appropriate way to achieve this goal would be to rate 
#(rank) the elements randomly. The variation of the elements on 
# the con- structs would lack any psychological sense. Every 
# statistical analysis should then lead to noninterpretable results.







