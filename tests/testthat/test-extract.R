
test_that("test extract w/ good data", {

  # Example state object from demo-types.Rmd
  df = tibble::tribble(
    ~student, ~student_id, ~hash,
    "Colin", 20000, "QlpoOTFBWSZTWeVuJ2oAA0d/gP/7aAhoC7BViyIOyr/v/+BAAcACsAS7C1CSk0JpmpNqep5Mk2hB6Q0AMRkZDRo0ESgk0mjCm0jJoNBoaGgA08o0aMgc0xMmTRhMExNMAmAQwRgRgEoqeo9NEmGjEaAmAjEwg0yGIYF8pU0k7G+6BUtHSYxJJAJFL6W5UCrilRyWGtmw1GqpSrRJBA2fT+uz/VuOlmnCp4+XqtIastNWKVwhhEJEy0ph5bKdX76SO3aH4vv11oDoiPXx7wYJ2rpgkR114rTC4VgPPe2auPKXtfRNHr4GunJmVN1GCKmeCpSIHcg02pekubiVKwzZNyJSzWNoZ2YNzeaVxhkzFsjDjLuDMsB3QAaoKRAQgSDILEEKQAGsUkkBDNEUDo7R7DmKBZUuTggyhKAOSpFKKbDUcMznhknT1b5jnNEVveZw8iU2FziM2DEcgUkIFeHApF7yYcts1w6NFnAXyrns4VMbVAj5+ikGl5l2aeMcGZeiZkCD42EJkRt00Oxd/moXKnwDA2aNZwnCazkZ0noMoXDAMyZag5BSiAyj+2n9ckRFzQU56GQFjr81nKKKKXicMDScxOZx+1IMUARqneOUqlfxj0oqY2Kwv4yK9XCwrJRwmMP4ZUPr8nVF81IqijfkoqaPuQxMTFCXkQjCh5oNBwPE08iZLunbRHarIjFlSuhBELCwQ6xqiCDc8mjSZ0oF2r9qtAn2KAK+si1CpdcVvJQ83qPIkJUvo+A0FFgCqET1auDXhFLaTCdCrHWGMkObrqmDiZSYLB1p0cHC48TlpTzFrYzTmTkLaDEGkrnoBL4Txz6UhvWMRyEwUbGdhK5CPkSUnJN8DQbg9bz/kGEDb6dUZIpb/i7kinChIcrcTtQ=",
    "Mine",  10000, "QlpoOTFBWSZTWYeyPVYAA0x/gP/7aAhoC7BVgyIOyr/v/+BAAcACsAdqC1CSU0AIaGBRk0D1BoAA0ANNAiUEmgmE1MTEANDQ0AMmjRoyBzAJgJkYARiYmEwmCGmJpgJSTUn4RJiY9RkNRiBppiMBMI0YJfKV1k7W+gCpaBrcYEkgEil9bcqtTFKjkstbNhqNQGlWgSKB8P69H+5/vgOxmzy42PP11kN3NTdxSreOEGkTLSmHJZTr/fUR2dIfi+yvcEHVFOzj3AwTdumCQXbXhtMLhWA817Z648he19U1ezea68hnAdCMUVNMRSkQOCDTpS9oXMyXKwz3zRKWawtDi1NMjgaWlcsMdBbIw4y7gzNAdwQGoikEEIEgyCwBCkQBrFJFQ0QVA59p7TlKBZUuTfgyhKAOSpFKKfY2HDNJtknV17THSaHP6mgMpUN521jPb7y6FkYBcntpIbZJzHhjNzdOnzpm0XcN+RZT6UCPj5LQcWNiyVSk4UrxTXhB7+xCXo/frgs5olfDEMFmcGm6pAmJiBeRXA9h4dgMCRCRwRoYwgOw/WeTtsqianWhjX1OmNvZ52RsMMMb5AODUcBSeA/FMMoAlVn8TqhUP6B6gWSVleXaCOvNCxmKCcTMbBrR9ftKquPRFscr83Fc4fnQyZMoStFgxW84HBgB4y1TrHsqfrlizkZo0pYgrkFuMIwXuUsgNseThxlwYwKJrYQTmT4ZtJFqFXNOpL6Yl4DAQJUvo8BgKFRhVCs3xsyg1wiidIhlVS38Va8By9tUwcTKTBYO8nRv8LjxOWlNha2M1508JbUOBhM5sYl4JBz0pjMSoCOQWKGQOokUp3DyumrFtoNRiPY835BhA6fVsjJFLf8XckU4UJCHsj1W"
  )


  all = extract_hash(df, hash)
  qs = extract_questions(df, hash)
  exs = extract_exercises(df, hash)

  expect_equal(dim(all), c(10,5))
  expect_equal(dim(qs), c(6,6))
  expect_equal(dim(exs), c(4,7))
})

test_that("test extract w/ blank entry", {

  df = tibble::tribble(
    ~student, ~student_id, ~hash,
    "Colin", 20000, "QlpoOTFBWSZTWeVuJ2oAA0d/gP/7aAhoC7BViyIOyr/v/+BAAcACsAS7C1CSk0JpmpNqep5Mk2hB6Q0AMRkZDRo0ESgk0mjCm0jJoNBoaGgA08o0aMgc0xMmTRhMExNMAmAQwRgRgEoqeo9NEmGjEaAmAjEwg0yGIYF8pU0k7G+6BUtHSYxJJAJFL6W5UCrilRyWGtmw1GqpSrRJBA2fT+uz/VuOlmnCp4+XqtIastNWKVwhhEJEy0ph5bKdX76SO3aH4vv11oDoiPXx7wYJ2rpgkR114rTC4VgPPe2auPKXtfRNHr4GunJmVN1GCKmeCpSIHcg02pekubiVKwzZNyJSzWNoZ2YNzeaVxhkzFsjDjLuDMsB3QAaoKRAQgSDILEEKQAGsUkkBDNEUDo7R7DmKBZUuTggyhKAOSpFKKbDUcMznhknT1b5jnNEVveZw8iU2FziM2DEcgUkIFeHApF7yYcts1w6NFnAXyrns4VMbVAj5+ikGl5l2aeMcGZeiZkCD42EJkRt00Oxd/moXKnwDA2aNZwnCazkZ0noMoXDAMyZag5BSiAyj+2n9ckRFzQU56GQFjr81nKKKKXicMDScxOZx+1IMUARqneOUqlfxj0oqY2Kwv4yK9XCwrJRwmMP4ZUPr8nVF81IqijfkoqaPuQxMTFCXkQjCh5oNBwPE08iZLunbRHarIjFlSuhBELCwQ6xqiCDc8mjSZ0oF2r9qtAn2KAK+si1CpdcVvJQ83qPIkJUvo+A0FFgCqET1auDXhFLaTCdCrHWGMkObrqmDiZSYLB1p0cHC48TlpTzFrYzTmTkLaDEGkrnoBL4Txz6UhvWMRyEwUbGdhK5CPkSUnJN8DQbg9bz/kGEDb6dUZIpb/i7kinChIcrcTtQ=",
    "Mine",  10000, "QlpoOTFBWSZTWYeyPVYAA0x/gP/7aAhoC7BVgyIOyr/v/+BAAcACsAdqC1CSU0AIaGBRk0D1BoAA0ANNAiUEmgmE1MTEANDQ0AMmjRoyBzAJgJkYARiYmEwmCGmJpgJSTUn4RJiY9RkNRiBppiMBMI0YJfKV1k7W+gCpaBrcYEkgEil9bcqtTFKjkstbNhqNQGlWgSKB8P69H+5/vgOxmzy42PP11kN3NTdxSreOEGkTLSmHJZTr/fUR2dIfi+yvcEHVFOzj3AwTdumCQXbXhtMLhWA817Z648he19U1ezea68hnAdCMUVNMRSkQOCDTpS9oXMyXKwz3zRKWawtDi1NMjgaWlcsMdBbIw4y7gzNAdwQGoikEEIEgyCwBCkQBrFJFQ0QVA59p7TlKBZUuTfgyhKAOSpFKKfY2HDNJtknV17THSaHP6mgMpUN521jPb7y6FkYBcntpIbZJzHhjNzdOnzpm0XcN+RZT6UCPj5LQcWNiyVSk4UrxTXhB7+xCXo/frgs5olfDEMFmcGm6pAmJiBeRXA9h4dgMCRCRwRoYwgOw/WeTtsqianWhjX1OmNvZ52RsMMMb5AODUcBSeA/FMMoAlVn8TqhUP6B6gWSVleXaCOvNCxmKCcTMbBrR9ftKquPRFscr83Fc4fnQyZMoStFgxW84HBgB4y1TrHsqfrlizkZo0pYgrkFuMIwXuUsgNseThxlwYwKJrYQTmT4ZtJFqFXNOpL6Yl4DAQJUvo8BgKFRhVCs3xsyg1wiidIhlVS38Va8By9tUwcTKTBYO8nRv8LjxOWlNha2M1508JbUOBhM5sYl4JBz0pjMSoCOQWKGQOokUp3DyumrFtoNRiPY835BhA6fVsjJFLf8XckU4UJCHsj1W",
    "Empty", 0, encode_obj(list())
  )


  all = extract_hash(df, hash)
  qs = extract_questions(df, hash)
  exs = extract_exercises(df, hash)

  expect_equal(dim(all), c(11,5)) # Bad shows up with NAs and NULLs
  expect_equal(dim(qs), c(6,6))   # Dropped since no answers here
  expect_equal(dim(exs), c(4,7))
})


test_that("test extract w/ empty data", {
  df = tibble::tibble(
    student = "Colin",
    hash = encode_obj(list())
  )

  all = extract_hash(df)
  qs = extract_questions(df)
  exs = extract_exercises(df)

  expect_equal(nrow(all), 1)
  expect_true(all(c("student", "type", "id") %in% names(all)))


  df2 = tibble::tibble(
    student = c("Colin", "Mine"),
    hash = encode_obj(list())
  )

  all2 = extract_hash(df2)
  qs2 = extract_questions(df2)
  exs2 = extract_exercises(df2)


  expect_equal(nrow(all2), 2)
  expect_true(all(c("student", "type", "id") %in% names(all2)))


})


