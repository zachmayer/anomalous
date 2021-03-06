anomaly <- function(x, n = 10, method = "hdr", robust = TRUE, 
                    plot = TRUE, labels = TRUE, col) {
  # x: a matrix returned by `tsmeasures` function
  nc <- nrow(x)
  if (nc < n) {
    stop("Your n is too large.")
  }
  x[is.infinite(x)] <- NA # ignore inf values
  naomit.x <- na.omit(x) # ignore missing values
  na.act <- na.action(naomit.x)
  if (is.null(na.act)) {
    avl <- 1:nc
  } else {
    avl <- (1:nc)[-na.action(naomit.x)]
  }
  method <- match.arg(method)
  # robust PCA space (scaling version)
  if (robust) {
    rbt.pca <- pcaPP::PCAproj(naomit.x, k = 2, center = mean, scale = sd)
  } else {
    rbt.pca <- princomp(scale(naomit.x, center = TRUE, scale = TRUE), 
                        cor = TRUE)
  }
  scores <- rbt.pca$scores
  scoreswNA <- matrix(, nrow = nc, ncol = 2)
  scoreswNA[avl, ] <- scores
  tmp.idx <- vector(length = n)
  if (method == "hdr") {
    hdrinfo <- hdrcde::hdr.2d(x = scores[, 1], y = scores[, 2], 
                              kde.package = "ks")
    tmp.idx <- order(hdrinfo$fxy)[1:n]
    main <- "Lowest densities on anomalies"
  } 
  # else { # alpha hull using binary split
  #   first <- 0
  #   last <- 10
  #   len.out <- 0
  #   alpha <- numeric(length = n)
  #   numiter <- 0
  #   while (len.out != n && (numiter <- numiter + 1) <= 20) {
  #     fit <- alphahull::ahull(scores, alpha = half <- (first + last)/2)
  #     radius <- fit$arcs[, 3]
  #     check <- radius == 0
  #     len.out <- length(radius[check])

  #     if (len.out >= 1 && len.out <= n) {
  #       xpos <- fit$arcs[check, 1]
  #       xidx <- which(is.element(scores[, 1], xpos))
  #       tmp.idx <- xidx
  #     }
  #     if (len.out >= 0 && len.out <= n) {
  #       last <- half
  #     } else {
  #       first <- half
  #     } 
  #   }
  #   main <- "alpha-hull on anomalies"
  # }
  idx <- avl[tmp.idx] # Put back with NA
  if (plot) {
    if (missing(col)) {
      col <- c("grey", "darkblue")
    } else {
      lencol <- length(col)
      if (lencol == 1L) {
        col <- rep(col, 2)
      } else {
        col <- unique(col)[1:2]
      }
    }
    xrange <- range(scores[, 1], na.rm = TRUE)
    yrange <- range(scores[, 2], na.rm = TRUE)
    plot(x = scores[-tmp.idx, 1], y = scores[-tmp.idx, 2], 
         pch = 19, col = col[1L], xlab = "PC1", ylab = "PC2", main = main,
         xlim = xrange, ylim = yrange)
    points(scores[tmp.idx, 1], scores[tmp.idx, 2], 
           col = col[2L], pch = 17)
    if (labels) {
      text(scores[tmp.idx, 1] + 0.3, scores[tmp.idx, 2], 
           col = col[2L], label = 1:length(idx), cex = 1.2)
    }
  }
  return(structure(list(index = idx, scores = scoreswNA)))
}
