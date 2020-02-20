
import
  uri,
  json,
  random,
  strutils,
  strformat,
  httpclient

import apimethods
import ../../core/[config, utils]

type
  Deezer* = object
    client*: HttpClient
    arlCookie*: string

  Tokens* = object
    csrf*: string
    cid*: string
    userId*: string

const 
  userAgent = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " &
    "AppleWebKit/537.36 (KHTML, like Gecko) " &
    "Chrome/73.0.3683.75 Safari/537.36 "
  )
  headers = {
    "Accept": "*/*",
    "Accept-Encoding": "",
    "Accept-Language": "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7",
    "User-Agent": userAgent,
    "Content-Language": "en-US; fr-FR",
    "Cache-Control": "max-age=0",
    "Content-type": "application/json",
    "Connection": "keep-alive"
  }
  apiUrl = "https://www.deezer.com/ajax/gw-light.php?"

proc doClient*(deezer: var Deezer) =
  let config = loadConfig()

  case config.useProxy.parseBool():
  of true:
    let proxy = newProxy(config.proxy)
    deezer.client = newHttpClient(proxy = proxy)
  of false:
    deezer.client = newHttpClient() 
  
  deezer.arlCookie = config.arlCookie
  deezer.client.headers = newHttpHeaders(headers)
  
proc doMethodUrl*(apiToken: string): string =
  proc cid(): string =
      while result.len < 9:
        result &= $rand(9)

  let methodUrl = {
    "api_version": "1.0",
    "api_token": apiToken,
    "input": "3",
    "cid": cid()
  }
  result = apiUrl & encodeQuery(methodUrl)

proc doMethodRequest*(deezer: var Deezer, deezerMethod: string, params: JsonNode, apiToken: string = ""): JsonNode =
  let 
    methodUrl = doMethodUrl(apiToken = apiToken)
    methodRequest = %* [{
      "method": deezerMethod,
      "params": params
    }]
    methodResp = deezer.client.request(
      url = methodUrl,
      httpMethod = HttpPost,
      body = $methodRequest
    )
  result = parseJson(methodResp.body)[0]["results"]
  # update cookies
  deezer.client = deezer.client.updateCookies(methodResp)

proc getTokens*(deezer: var Deezer): Tokens =
  deezer.doClient()
  deezer.client.headers.add("Cookie", "arl=" & deezer.arlCookie)
  let data = deezer.doMethodRequest(
    deezerMethod = "deezer.getUserData",
    params = %* {}
  )
  result.csrf = data["checkForm"].getStr()
  result.cid = data["SESSION_ID"].getStr()
  result.userId = $data{"USER", "USER_ID"}.getInt()


# PROFILE PAGES Loved/Playlists/Albums/Artists/Podcasts(shows)
proc pageProfileLoved*(deezer: var Deezer): JsonNode =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "deezer.pageProfile",
      deezer_pageProfile(tokens.userId, "loved"),
      tokens.csrf
    )
  result = data

proc pageProfilePlaylists*(deezer: var Deezer): JsonNode =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "deezer.pageProfile",
      deezer_pageProfile(tokens.userId, "playlists"),
      tokens.csrf
    )
  result = data

proc pageProfileAlbums*(deezer: var Deezer): JsonNode =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "deezer.pageProfile",
      deezer_pageProfile(tokens.userId, "albums"),
      tokens.csrf
    )
  result = data

proc pageProfileArtists*(deezer: var Deezer): JsonNode =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "deezer.pageProfile",
      deezer_pageProfile(tokens.userId, "artists"),
      tokens.csrf
    )
  result = data

proc pageProfileShows*(deezer: var Deezer): JsonNode =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "deezer.pageProfile",
      deezer_pageProfile(tokens.userId, "shows"),
      tokens.csrf
    )
  result = data

# Loved/Favorites
proc favoriteSongAdd*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "favorite_song.add",
      favorite_songAdd(id),
      tokens.csrf
    )
  discard data

proc favoriteSongRemove*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "favorite_song.remove",
      favorite_songRemove(id),
      tokens.csrf
    )
  discard data

# Playlists
proc playlistCreate*(deezer: var Deezer, name: string) =
  let 
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "playlist.create",
      playlist_create(name),
      tokens.csrf
    )
  updateConfig("playlists", "default", $data.getInt())
  updateConfig("playlists", name, $data.getInt())

proc playlistDelete*(deezer: var Deezer, id: string) =
  let 
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "playlist.delete",
      playlist_delete(id),
      tokens.csrf
    )
  discard data

proc playlistAddSongs*(deezer: var Deezer, ids: seq[string], playlist_id: string = "") =
  var playlist_id = playlist_id
  var idsJson = %* []
  for i, id in ids:
    idsJson.add(parseJson(fmt"[{id}, {i}]"))

  if playlist_id == "":
    let config = loadConfig()
    playlist_id = config.defaultPlaylist

  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "playlist.addSongs",
      playlist_addSongs(playlist_id, idsJson),
      tokens.csrf
    )
  discard data

proc playlistDeleteSongs*(deezer: var Deezer, ids: seq[string], playlist_id: string = "") =
  var playlist_id = playlist_id
  var idsJson = %* []
  for i, id in ids:
    idsJson.add(parseJson(fmt"[{id}, {i}]"))

  if playlist_id == "":
    let config = loadConfig()
    playlist_id = config.defaultPlaylist

  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "playlist.deleteSongs",
      playlist_deleteSongs(playlist_id, idsJson),
      tokens.csrf
    )
  discard data

proc pagePlaylist*(deezer: var Deezer, id: string): JsonNode =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "deezer.pagePlaylist",
      deezer_pagePlaylist(id),
      tokens.csrf
    )
  result = data

# Albums
proc albumAddFavorite*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "album.addFavorite",
      album_addFavorite(id),
      tokens.csrf
    )
  discard data

proc albumDeleteFavorite*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "album.deleteFavorite",
      album_deleteFavorite(id),
      tokens.csrf
    )
  discard data

# Artists
proc artistAddFavorite*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "artist.addFavorite",
      artist_addFavorite(id),
      tokens.csrf
    )
  discard data

proc artistDeleteFavorite*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "artist.deleteFavorite",
      artist_deleteFavorite(id),
      tokens.csrf
    )
  discard data

# Podcasts(shows)
proc showAddFavorite*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "show.addFavorite",
      show_addFavorite(id),
      tokens.csrf
    )
  discard data

proc showDeleteFavorite*(deezer: var Deezer, id: string) =
  let
    tokens = deezer.getTokens()
    data = deezer.doMethodRequest(
      "show.deleteFavorite",
      show_deleteFavorite(id),
      tokens.csrf
    )
  discard data
