function (x, xvar = c("norm", "df", "arc.length", "step"), breaks = TRUE, 
          plottype = c("coefficients", "Cp"), omit.zeros = FALSE, eps = 1e-10, 
          ...) 
{
    object <- x
    plottype <- match.arg(plottype)
    xvar <- match.arg(xvar)
    coef1 <- object$beta
    if (x$type != "LASSO" && xvar == "norm") 
        coef1 = betabreaker(x)
    stepid = trunc(as.numeric(dimnames(coef1)[[1]]))
    coef1 <- scale(coef1, FALSE, 1/object$normx)
    if (omit.zeros) {
        c1 <- drop(rep(1, nrow(coef1)) %*% abs(coef1))
        nonzeros <- c1 > eps
        cnums <- seq(nonzeros)[nonzeros]
        coef1 <- coef1[, nonzeros, drop = FALSE]
    }
    else cnums <- seq(ncol(coef1))
    s1 <- switch(xvar, norm = {
        s1 <- apply(abs(coef1), 1, sum)
        s1/max(s1)
    }, df = object$df, arc.length = cumsum(c(0, object$arc.length)), 
    step = seq(nrow(coef1)) - 1)
    xname <- switch(xvar, norm = "Shrinkage factor", df = "Df", 
                    arc.length = "Arc Length", step = "Step")
    if (plottype == "Cp") {
        Cp <- object$Cp
        plot(s1, Cp, type = "l", xlab = xname, main = object$type, 
             ...)
    }
    else {
        matplot(s1, coef1, xlab = xname, ..., type = "l", pch = "*", 
                ylab = "Standardized Coefficients")
        title(object$type, line = 0.5)
        abline(h = 0, lty = 6)
        axis(4, at = coef1[nrow(coef1), ], labels = paste(cnums), 
             cex = 0.2, adj = 0)
        if (breaks) {
            axis(3, at = s1, labels = paste(stepid), lty = 3, cex = 0.1)
            abline(v = s1)
        }
    }
    invisible()
}