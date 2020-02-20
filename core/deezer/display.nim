
import
  json,
  strutils,
  strformat

type
  Artist = object
    id*: JsonNode
    name*: JsonNode
    link*: JsonNode
    picture_small*: JsonNode
    picture_medium*: JsonNode
    picture_big*: JsonNode
    picture_xl*: JsonNode
    tracklist*: JsonNode

  Album = object
    id*: JsonNode
    title*: JsonNode
    cover_small*: JsonNode
    cover_medium*: JsonNode
    cover_big*: JsonNode
    cover_xl*: JsonNode
    tracklist*: JsonNode

  Track = object
    id*: JsonNode
    title*: JsonNode
    link*: JsonNode
    preview*: JsonNode
    artist*: JsonNode
    album*: JsonNode

proc display*(data: JsonNode) =
  var n = 1
  for d in data:
    let 
      track = to(d, Track)
      artist = to(d["artist"], Artist)
      album = to(d["album"], Album)
      display = "\n" & join([
        fmt"[{n}] track: {track.title.getStr()} -id: {track.id.getInt()} -url: {track.link.getStr()}",
        fmt"    preview: {track.preview.getStr()}",
        fmt"    artist: {artist.name.getStr()} -id: {artist.id.getInt()}",
        fmt"    album: {album.title.getStr()} -id: {album.id.getInt()}"
      ], "\n")
    echo display

proc displayPlaylist*(data: JsonNode) =
  var n = 1
  let data = data["SONGS"]["data"]
  for d in data:
    let
      sng_id = d["SNG_ID"].getStr()
      sng_title = d["SNG_TITLE"].getStr()
      art_id = d["ART_ID"].getStr()
      art_name = d["ART_NAME"].getStr()
      alb_id = d["ALB_ID"].getStr()
      alb_title = d["ALB_TITLE"].getStr()
      display = "\n" & join([
        fmt"[{n}] song: {sng_title} -id: {sng_id}",
        fmt"    artist: {art_name} -id: {art_id}",
        fmt"    album: {alb_title} -id: {alb_id}"
      ], "\n")
    echo display
    inc n

proc displayPageProfile*(data: JsonNode, tab: string) =
  var n = 1
  let data = data["TAB"][tab]["data"]
  
  if data.len == 0:
    echo "[x] nothing found."
    quit()
  
  case tab
  of "loved":
    for d in data:
      let
        sng_id = d["SNG_ID"].getStr()
        sng_title = d["SNG_TITLE"].getStr()
        art_id = d["ART_ID"].getStr()
        art_name = d["ART_NAME"].getStr()
        alb_id = d["ALB_ID"].getStr()
        alb_title = d["ALB_TITLE"].getStr()
        display = "\n" & join([
          fmt"[{n}] song: {sng_title} -id: {sng_id}",
          fmt"    artist: {art_name} -id: {art_id}",
          fmt"    album: {alb_title} -id: {alb_id}"
        ], "\n")
      echo display
      inc n

  of "playlists":
    for d in data:
      let
        playlist_id = d["PLAYLIST_ID"].getStr()
        title = d["TITLE"].getStr()
        date_add = d["DATE_ADD"].getStr()
        date_create = d["DATE_CREATE"].getStr()
        date_mod = d["DATE_MOD"].getStr()
        nb_song = d["NB_SONG"].getInt()
        display = "\n" & join([
          fmt"[{n}] playlist: {title} -id: {playlist_id} -total songs: {nb_song}",
          fmt"    added: {date_add} -creation: {date_create} -last modif.: {date_mod}"
        ], "\n")
      echo display
      inc n
  
  of "albums":
    for d in data:
      let
        art_id = d["ART_ID"].getStr()
        art_name = d["ART_NAME"].getStr()
        alb_id = d["ALB_ID"].getStr()
        alb_title = d["ALB_TITLE"].getStr()
        date_favorite = d["DATE_FAVORITE"].getStr()
        display = "\n" & join([
          fmt"[{n}] album: {alb_title} -id: {alb_id} -added: {date_favorite}",
          fmt"    artist: {art_name} -id: {art_id}"
        ], "\n")
      echo display
      inc n

  of "artists":
    for d in data:
      let
        art_id = d["ART_ID"].getStr()
        art_name = d["ART_NAME"].getStr()
        date_favorite = d["DATE_FAVORITE"].getStr()
        display = "\n" & fmt"[{n}] artist: {art_name} -id: {art_id} -added: {date_favorite}"
      echo display
      inc n

  of "shows":
    for d in data:
      let
        show_id = d["SHOW_ID"].getStr()
        show_name = d["SHOW_NAME"].getStr()
        show_description = d["SHOW_DESCRIPTION"].getStr()
        display = "\n" & join([
          fmt"[{n}] podcast: {show_name} -id: {show_id}",
          fmt"    description: {show_description}"
        ], "\n") 
      echo display
      inc n
