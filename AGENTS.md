Always default to using the tidyverse in R unless otherwise instructed, don't add any additional spacing before or after " <- " in assignments. 

Use the base pipe |>. 

Always include package assignment of functions with :: when writing R code. 

Write if statements with brackets {}. 

Give descriptive variable names to all code in snake case. 

When writing code mid pipe use the format (\(.) if (nrow(.) >= 1) {
    data_func(
      data = .
    )
  })()

Avoid for loops if possible, writing purrr code instead.

## Code comments

Include comments where it is helpful to elucidate what is going on, but not if it is obvious.

## Commit messages

When asked for commit messages provide just the commit message, make sure to escape quotes like so: \"