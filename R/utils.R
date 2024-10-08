# Drop NULLs from a list
drop_nulls <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}

# Everything above this function in the stack will be hidden by default in the
# flamegraph.
..stacktraceoff.. <- function(x) x

modal_value0 <- function(x) {
  if (!length(x)) {
    return(NULL)
  }

  if (is.list(x)) {
    abort("Can't use `modal_value()` with lists.")
  }
  self_split <- unname(split(x, x))

  lens <- lengths(self_split)
  max_locs <- which(lens == max(lens))

  if (length(max_locs) != 1) {
    return(NULL)
  }

  modal <- self_split[[max_locs]]
  modal[[1]]
}
modal_value <- function(x) {
  modal_value0(x) %||% abort("Expected modal value.")
}

enquo0_list <- function(arg) {
  quo <- inject(enquo0(!!substitute(arg)), caller_env())

  # Warn if there are any embedded quosures as these are not supported
  quo_squash(quo, warn = TRUE)

  list(
    expr = quo_get_expr(quo),
    env = quo_get_env(quo)
  )
}


split_in_half <- function(x, pattern, fixed = FALSE, perl = FALSE) {
  pos <- regexpr(pattern, x, fixed = fixed, perl = perl)
  
  start <- as.vector(pos) - 1
  length <- attr(pos, "match.length")
  
  no_match <- !is.na(pos) & pos == -1L
  length[no_match] <- 0
  start[no_match] <- nchar(x)[no_match]

  cbind(
    substr(x, 1, start),
    substr(x, start + length + 1, nchar(x))
  )
}
