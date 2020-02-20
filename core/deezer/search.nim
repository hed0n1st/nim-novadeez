
import
  uri,
  json,
  httpclient

import api

const searchUrl = "https://api.deezer.com/2.0/search/track/?"

proc doSearch*(deezer: var Deezer, search: string, max_items: string = "1"): JsonNode =
  deezer.doClient()
  let 
    deezerReq = {
      "q": search,
      "index": "0",
      "nb_items": max_items,
      "output": "json"
    }
    deezerResp = deezer.client.request(
      url = searchUrl & encodeQuery(deezerReq),
      httpMethod = HttpGet
    )
  result = parseJson(deezerResp.body)["data"]
