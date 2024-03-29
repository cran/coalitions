context("Survey object")
test_that("as_survey works correctly", {
  expect_data_frame(
    forsa <- as_survey(
      percent    = c(0.41, 0.24, 0.13, 0.04, 0.08, 0.03, 0.03, 0.04),
      samplesize = 2508,
      parties    = c("cdu", "spd", "greens", "fdp", "linke", "pirates", "afd",
        "others")),
    nrows = 8L, ncols = 3L)
  expect_subset(colnames(forsa), c("party", "percent", "votes"))
  expect_equal(forsa$votes,
    c(1028.28, 601.92, 326.04, 100.32, 200.64, 75.24, 75.24, 100.32))
})


context("Redistribution")
test_that("Redistritubion works correctly", {
  forsa <- as_survey(
    percent    = c(0.41, 0.24, 0.13, 0.04, 0.08, 0.03, 0.03, 0.04),
    samplesize = 2508,
    parties    = c("cdu", "spd", "greens", "fdp", "linke", "pirates", "afd",
      "others"))
  expect_data_frame(result <- redistribute(forsa, hurdle = 0.05),
    nrows = 4, ncols = 3, any.missing = FALSE)
  expect_equal(round(result$percent, 2), c(0.48, 0.28, 0.15, 0.09))
})


context("Seat distribution functions")
test_that("Sainte-Lague/Scheppers works correctly", {
  expect_equal(sls(c(4.160, 3.380, 2.460), LETTERS[1:3], 10), c(4, 3, 3))

})
test_that("dHondt workds correctly", {
  expect_equal(dHondt(c(4160, 3380, 2460), LETTERS[1:3], 10), c(4, 4, 2))
  expect_equal(dHondt(c(4160, 7, 2460), LETTERS[1:3], 10), c(6, 0, 4))
})

test_that("get_seats excludes SSW-party from hurdle", {
  expect_equal(get_seats(tibble(A = c(0.625, 0.691, 0.667),
                                B = c(0.343, 0.297, 0.283),
                                ssw = c(0.032, 0.012, 0.050)),
                         tibble(pollster = rep("test", 3),
                                date = as.Date(rep("2022-04-13", 3)),
                                start = as.Date(rep("2022-04-13", 3)),
                                end = as.Date(rep("2022-04-13", 3)),
                                respondents = rep(200, 3),
                                party = c("A", "B", "ssw"),
                                percent = c(65, 32, 3),
                                votes = c(130, 64, 6))),
               tibble(sim = rep(1:3, each = 3),
                      party = rep(c("A", "B", "ssw"), 3),
                      seats = c(374L, 205L, 19L, 413L, 178L, 7L, 399L, 169L, 30L)))
})

test_that("the hurdle in get_seats works for every party except SSW", {
  expect_equal(get_seats(tibble(A = c(0.625, 0.691, 0.667),
                                B = c(0.343, 0.297, 0.283),
                                C = c(0.032, 0.012, 0.050)),
                         tibble(pollster = rep("test", 3),
                                date = as.Date(rep("2022-04-13", 3)),
                                start = as.Date(rep("2022-04-13", 3)),
                                end = as.Date(rep("2022-04-13", 3)),
                                respondents = rep(200, 3),
                                party = c("A", "B", "C"),
                                percent = c(65, 32, 3),
                                votes = c(130, 64, 6))),
               tibble(sim = c(1L, 1L, 2L, 2L, 3L, 3L, 3L),
                      party = c("A", "B", "A", "B", "A", "B", "C"),
                      seats = c(386L, 212L, 418L, 180L, 399L, 169L, 30L)))
})

context("Draw from posterior")
test_that("Drawing from posterior works", {
  forsa <- as_survey(
    percent    = c(0.41, 0.24, 0.13, 0.04, 0.08, 0.03, 0.03, 0.04),
    samplesize = 2508,
    parties    = c("cdu", "spd", "greens", "fdp", "linke", "pirates", "afd",
      "others"))
  draws <- draw_from_posterior(forsa, nsim = 10)
  expect_data_frame(draws, nrow = 10, ncol = 8)
  expect_error(draw_from_posterior(forsa, nsim = 10,
    prior = c(0.5, 0.5, 0.5, 0.5)))

})


context("helper functions")
test_that("Prettify function works correctly", {

  x <- colnames(tidyr::unnest(.survey_sample, "surveys"))
  trans <- prettify_strings(x, new = .trans_df$german_pretty)
  expect_equal(trans, c("Institut", "Datum", "Beginn", "Ende", "Befragte",
    "Umfrage"))
  trans <- prettify_strings(x, .trans_df$english)
  expect_equal(trans, c("pollster", "date", "start", "end", "respondents",
    "survey"))
  trans <- prettify_strings(c("asdf", "cdu", "cdu_gruene"),
    .trans_df$german, .trans_df$english_pretty)
  expect_equal(trans, c("asdf", "Union", "Union - Greens"))
  trans <- prettify_strings(as.factor(c("asdf", "cdu", "cdu_gruene")),
    .trans_df$german, .trans_df$english_pretty)
  expect_equal(trans, c("asdf", "Union", "Union - Greens"))


})
