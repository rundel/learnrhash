test_that("test list objects", {
  test = list(
    a = 1,
    b = list(
      c = list(d = 1),
      e = 3
    )
  )

  test_base64 = encode_obj(test)

  # Allowed Chracters A-Z, a-z, 0-9, +, /, =
  expect_true(grepl("[A-Za-z0-9+/=]+", test_base64))
  expect_identical(test, decode_obj(test_base64))
})

test_that("test vectors", {
  a = 1
  b = "A"
  c = TRUE

  expect_identical(a, decode_obj(encode_obj(a)))
  expect_identical(b, decode_obj(encode_obj(b)))
  expect_identical(c, decode_obj(encode_obj(c)))
})

test_that("test compression", {
  test = list(
    a = 1,
    b = list(
      c = list(d = 1),
      e = 3
    )
  )

  test_bzip = encode_obj(test, "bzip2")
  test_gzip = encode_obj(test, "gzip")
  test_none = encode_obj(test, "none")

  expect_identical(test, decode_obj(test_bzip, "bzip2"))
  #expect_error(decode_obj(test_bzip, "gzip"))
  #expect_error(decode_obj(test_bzip, "none"))

  expect_identical(test, decode_obj(test_gzip, "gzip"))
  #expect_error(decode_obj(test_gzip, "bzip2"))
  #expect_error(decode_obj(test_gzip, "none"))

  expect_identical(test, decode_obj(test_none, "none"))
  #expect_error(decode_obj(test_none, "bzip2"))
  #expect_error(decode_obj(test_none, "gzip"))
})

test_that("test empty", {
  expect_identical(decode_obj(""), list())
})
