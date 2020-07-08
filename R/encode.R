

#' @export
encode_obj = function(obj, compress = c("bzip2", "gzip", "xz", "none"))  {
  compress = match.arg(compress)

  raw = serialize(obj, NULL)
  comp_raw = memCompress(raw, type = compress)

  base64enc::base64encode(comp_raw)
}

#' @export
decode_obj = function(txt, compress = c("bzip2", "gzip", "xz", "none")) {
  compress = match.arg(compress)

  comp_raw = base64enc::base64decode(txt)
  raw = memDecompress(comp_raw, type = compress)

  unserialize(raw)
}
