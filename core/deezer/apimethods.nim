
import
  json,
  strutils

# PROFILE PAGES Loved/Playlists/Albums/Artists/Podcasts
proc deezer_pageProfile*(user_id: string, tab: string): JsonNode =
  result = %* {
    "user_id": user_id,
    "tab": tab,
    "nb": 10
  }

# Loved/Favorites
proc favorite_songAdd*(id: string): JsonNode =
  result = %* {
    "SNG_ID": id,
    "CTXT": {
      "id": id,
      "t": "player"
    }
  }

proc favorite_songRemove*(id: string): JsonNode =
  result = %* {
    "SNG_ID": id,
    "CTXT": {
      "id": id,
      "t": "playlist_page"
    }
  }

# Playlists
proc playlist_create*(name: string): JsonNode =
  result = %* {
    "title": name,
    "description": "",
    "status": 1,
    "songs": false,
    "tags": []
  }

proc playlist_delete*(id: string): JsonNode =
  result = %* {
    "playlist_id": id.parseInt()
  }

proc playlist_addSongs*(id: string, ids: JsonNode): JsonNode =
  result = %* {
    "playlist_id": id,
    "songs": ids,
    "offset": -1
  }

proc playlist_deleteSongs*(id: string, ids: JsonNode): JsonNode =
  result = %* {
    "playlist_id": id,
    "songs": ids,
    "ctxt": {
      "id": id,
      "t":"playlist_page"
    }
  }

proc deezer_pagePlaylist*(id: string): JsonNode =
  result = %* {
    "playlist_id": id,
    "lang": "fr",
    "nb": 40,
    "start": 0,
    "tab": 0,
    "tags": true,
    "header": true
  }

# Albums
proc album_addFavorite*(id: string): JsonNode =
  result = %* {
    "ALB_ID": id,
    "CTXT": {
      "id": id,
      "t": "artist_discography"
    }
  }

proc album_deleteFavorite*(id: string): JsonNode =
  result = %* {
    "ALB_ID": id,
    "CTXT": {
      "id": id,
      "t": "profile_albums"
    }
  }

# Artists
proc artist_addFavorite*(id: string): JsonNode =
  result = %* {
    "ART_ID": id,
    "CTXT": {
      "id": id,
      "t": "artist_smartradio"
    }
  }

proc artist_deleteFavorite*(id: string): JsonNode =
  result = %* {
    "ART_ID": id,
    "CTXT": {
      "id": id,
      "t": "profile_artists"
    }
  }

# Podcasts(shows)
proc show_addFavorite*(id: string): JsonNode =
  result = %* {
    "SHOW_ID": id,
    "CTXT": {
      "id": id,
      "t": "dynamic_page_show"
    }
  }

proc show_deleteFavorite*(id: string): JsonNode =
  result = %* {
    "SHOW_ID": id,
    "CTXT": {
      "id": id,
      "t": "profile_shows"
    }
  }
