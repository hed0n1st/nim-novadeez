
import docopt
  
import core/config
import core/radionova/radionova
import core/deezer/[api, search, display]

let doc = """
NOVA-DEEZ: search artist/track on nova, try to find it on deezer and add it to the
desired playlist. 
           also you can manage some of your favorites in your deezer account.

Usage:
  novadeez check [--date <day> <month> <year> <hour> <minutes>]
  novadeez player (start|stop)
  novadeez add <sng_id>...
  novadeez add --playlist <playlist_id> <sng_id>...
  novadeez del <sng_id>...
  novadeez del --playlist <playlist_id> <sng_id>...
  novadeez loved [--add <sng_id> | --del <sng_id>]
  novadeez playlists [--list <playlist_id> | --add <playlist_name> | --del <playlist_id>]
  novadeez albums [--add <album_id> | --del <album_id>]
  novadeez artists [--add <artist_id> | --del <artist_id>]
  novadeez shows [--add <show_id> | --del <show_id>]

Options:
  -h --help  Show this message.
"""

let args = docopt(doc, version = "v0.1")

when isMainModule:
  var deezer: Deezer
  var nova: RadioNova
  doConfig()
  
  if args["player"]:
    if args["start"]: startPlayer()
    if args["stop"]: stopPlayer()

  if args["check"] and not args["--date"]:
    nova.nowFormData()
    nova.getNovaData()
    nova.display()

    let data = deezer.doSearch(nova.artist & " " & nova.track)
    display(data)

  if args["check"] and args["--date"]:
    let
      day = $args["<day>"]
      month = $args["<month>"]
      year = $args["<year>"]
      hour = $args["<hour>"]
      minutes = $args["<minutes>"]
    nova.dateFormData(day, month, year, hour, minutes)
    nova.getNovaData()
    nova.display()

    let data = deezer.doSearch(nova.artist & " " & nova.track)
    display(data)

  if args["add"]:
    var sng_ids: seq[string]
    for sng_id in args["<sng_id>"]: sng_ids.add($sng_id)
    if args["--playlist"]:
      deezer.playlistAddSongs(sng_ids, $args["<playlist_id>"])
    else:
      deezer.playlistAddSongs(sng_ids)

  if args["del"]:
    var sng_ids: seq[string]
    for sng_id in args["<sng_id>"]: sng_ids.add($sng_id)
    if args["--playlist"]:
      deezer.playlistDeleteSongs(sng_ids, $args["<playlist_id>"])
    else:
      deezer.playlistDeleteSongs(sng_ids)

  if args["loved"]:
    if not args["--add"] and not args["--del"]:
      let loved = deezer.pageProfileLoved()
      displayPageProfile(loved, "loved")
    if args["--add"]: deezer.favoriteSongAdd($args["<sng_id>"])
    if args["--del"]: deezer.favoriteSongRemove($args["<sng_id>"])  

  if args["playlists"]:
    if not args["--list"] and not args["--add"] and not args["--del"]:
      let playlists = deezer.pageProfilePlaylists()
      displayPageProfile(playlists, "playlists")
    if args["--list"]:
      let playlist = deezer.pagePlaylist($args["<playlist_id>"])
      displayPlaylist(playlist)
    if args["--add"]: deezer.playlistCreate($args["<playlist_name>"])
    if args["--del"]: deezer.playlistDelete($args["<playlist_id>"])

  if args["albums"]:
    if not args["--add"] and not args["--del"]:
      let albums = deezer.pageProfileAlbums()
      displayPageProfile(albums, "albums")
    if args["--add"]: deezer.albumAddFavorite($args["<album_id>"])
    if args["--del"]: deezer.albumDeleteFavorite($args["<album_id>"])

  if args["artists"]:
    if not args["--add"] and not args["--del"]:
      let artists = deezer.pageProfileArtists()
      displayPageProfile(artists, "artists")
    if args["--add"]: deezer.artistAddFavorite($args["<artist_id>"])
    if args["--del"]: deezer.artistDeleteFavorite($args["<artist_id>"])

  if args["shows"]:
    if not args["--add"] and not args["--del"]:
      let shows = deezer.pageProfileShows()
      displayPageProfile(shows, "shows")
    if args["--add"]: deezer.showAddFavorite($args["<show_id>"])
    if args["--del"]: deezer.showDeleteFavorite($args["<show_id>"])
