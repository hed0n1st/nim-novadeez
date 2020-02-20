
import 
  os,
  parsecfg

type
  Config* = object
    playerFile*: string
    playerArgs*: string
    useProxy*: string
    proxy*: string
    arlCookie*: string
    defaultPlaylist*: string

let configFile = joinPath(getAppDir(), "novadeez.ini")

proc createConfig() =
  echo "[!] novadeez.ini not found and created. please edit this configuration file with proper params!"
  var conf = newConfig()
  conf.setSectionKey("main", "useProxy", "0")
  conf.setSectionKey("main", "proxy", "http://localhost:9055")
  conf.setSectionKey("player", "playerFile", "C:\\Users\\emman\\scoop\\apps\\fmedia\\current\\fmedia.exe")
  conf.setSectionKey("player", "playerArgs", "--notui --gui")
  conf.setSectionKey("deezer", "arlCookie", "0")
  conf.setSectionKey("playlists", "default", "0")
  conf.writeConfig(configFile)

proc loadConfig*(): Config =
  var conf = loadConfig(configFile)
  result.playerFile = conf.getSectionValue("player", "playerFile")
  result.playerArgs = conf.getSectionValue("player", "playerArgs")
  result.useProxy = conf.getSectionValue("main", "useProxy")
  result.proxy = conf.getSectionValue("main", "proxy")
  result.arlCookie = conf.getSectionValue("deezer", "arlCookie")
  result.defaultPlaylist = conf.getSectionValue("playlists", "default")

proc updateConfig*(section: string, key: string, value: string) =
  var conf = loadConfig(configFile)
  conf.setSectionKey(section, key, value)
  conf.writeConfig(configFile)

proc doConfig*() =
  case fileExists(configFile)
  of false: createConfig()
  of true: discard
