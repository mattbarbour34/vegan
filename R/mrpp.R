"mrpp" <-
function (dat, grouping, permutations = 999, distance = "euclidean", 
    weight.type = 1, strata, parallel = getOption("mc.cores")) 
{
    classmean <- function(ind, dmat, indls) {
        sapply(indls, function(x)
               mean(c(dmat[ind == x, ind == x]),
                    na.rm = TRUE))
    }
    mrpp.perms <- function(ind, dmat, indls, w) {
        weighted.mean(classmean(ind, dmat, indls), w = w, na.rm = TRUE)
    }
    if (inherits(dat, "dist")) 
        dmat <- dat
    else if (is.matrix(dat) && nrow(dat) == ncol(dat) && all(dat[lower.tri(dat)] == 
        t(dat)[lower.tri(dat)])) {
        dmat <- dat
        attr(dmat, "method") <- "user supplied square matrix"
    }
    else dmat <- vegdist(dat, method = distance)
    if (any(dmat < -sqrt(.Machine$double.eps)))
        stop("dissimilarities must be non-negative")
    distance <- attr(dmat, "method")
    dmat <- as.matrix(dmat)
    diag(dmat) <- NA
    N <- nrow(dmat)
    grouping <- factor(grouping)
    indls <- levels(grouping)
    ncl <- sapply(indls, function(x) sum(grouping == x))
    w <- switch(weight.type, ncl, ncl - 1, ncl * (ncl - 1)/2)
    classdel <- classmean(grouping, dmat, indls)
    names(classdel) <- names(ncl) <- indls
    del <- weighted.mean(classdel, w = w, na.rm = TRUE)
    E.del <- mean(dmat, na.rm = TRUE)
    ## 'Classification strength' if weight.type == 1
    ## Do not calculate classification strength because there is no
    ## significance test for it. Keep the item in reserve for
    ## possible later re-inclusion.
    CS <- NA
    if (length(permutations) == 1) {
        if (missing(strata)) 
            strata <- NULL
        perms <- sapply(1:permutations,
                        function(x) grouping[permuted.index(N, strata = strata)])
    } else {
        perms <- apply(permutations, 1, function(indx) grouping[indx])
        permutations <- ncol(perms)
        if (nrow(perms) != N)
            stop(gettextf("'permutations' have %d columns, but data have %d rows",
                          ncol(perms), N))
    }
    ## Parallel processing
    if (is.null(parallel))
        parallel <- 1
    hasClus <- inherits(parallel, "cluster")
    if ((hasClus || parallel > 1)  && require(parallel)) {
        if(.Platform$OS.type == "unix" && !hasClus) {
            m.ds <- unlist(mclapply(1:permutations, function(i, ...)
                                    mrpp.perms(perms[,i], dmat, indls, w),
                                    mc.cores = parallel))
        } else {
            if (!hasClus) {
                parallel <- makeCluster(parallel)
             }
            m.ds <- parCapply(parallel, perms, function(x)
                              mrpp.perms(x, dmat, indls, w))
            if (!hasClus)
                stopCluster(parallel)
        }
    } else {
        m.ds <- apply(perms, 2, function(x) mrpp.perms(x, dmat, indls, w))
    }
    p <- (1 + sum(del >= m.ds))/(permutations + 1)
    r2 <- 1 - del/E.del
    out <- list(call = match.call(), delta = del, E.delta = E.del, CS = CS,
        n = ncl, classdelta = classdel,
                Pvalue = p, A = r2, distance = distance, weight.type = weight.type, 
        boot.deltas = m.ds, permutations = permutations)
    if (!missing(strata) && !is.null(strata)) {
        out$strata <- deparse(substitute(strata))
        out$stratum.values <- strata
    }
    class(out) <- "mrpp"
    out
}
