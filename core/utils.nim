
import
  tables,
  strutils,
  httpclient,
  encodings

proc updateCookies*(client: HttpClient, serverResp: Response): HttpClient =
  var newCookies: string

  for cookie in client.headers.table["cookie"]:
    var cookieData = cookie.split(";")[0]
    newCookies.add(cookieData & ";")

  for cookie in serverResp.headers.table["set-cookie"]:
    var cookieData = cookie.split(";")[0]
    newCookies.add(cookieData & ";")

  client.headers["Cookie"] = newCookies
  result = client

proc toLatin1*(toEnc: string): string =
  result = toEnc.convert(destEncoding = "iso-8859-1", srcEncoding = getCurrentEncoding())

proc add0*(n: string): string =
  if n.parseInt() < 10:
    result = "0" & n
  else:
    result = n

proc winValid*(toValid: string): string =
  let badChars = "\\/:*?\"<>|"
  for v in toValid:
    if not badChars.contains(v):
      result &= v
