
import
  osproc,
  uri,
  times,
  strutils,
  strformat,
  httpclient,
  htmlparser,
  xmltree

import ../../core/config

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
    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
    "Connection": "Keep-alive",
    "Origin": "https://www.nova.fr",
    "Referer": "https://www.nova.fr/radionova/radio-nova",
    "X-Requested-With": "XMLHttpRequest"
  }
  formUrl = "https://www.nova.fr/radionova/radio-nova"
  radioUrl = "http://novazz.ice.infomaniak.ch/novazz-128.mp3"

type
  RadioNova* = object
    client*: HttpClient
    formData*: array[0..6, tuple[key: string, value: string]]
    artist*: string
    track*: string
    spotifyUrl*: string
    deezerUrl*: string
    appleUrl*: string

proc nowFormData*(nova: var RadioNova) =
  let
    today = now()
    day = today.monthday
    month = today.month.ord()
    year = today.year
    hour = today.hour
    minutes = today.minute
    formData = {
      "form_build_id": "form-VOwU4Cv0VPBvhGw_V-_8xS_hR2gdx1D5KDU7ezhm3TM",
      "form_id": "cqctform",
      "day": $day,
      "month": $month,
      "year": $year,
      "hour": $hour,
      "minutes": $minutes
    }
  nova.formData = formData

proc dateFormData*(nova: var RadioNova,
                    day: string,
                    month: string,
                    year: string,
                    hour: string,
                    minutes: string) =
  let formData = {
      "form_build_id": "form-VOwU4Cv0VPBvhGw_V-_8xS_hR2gdx1D5KDU7ezhm3TM",
      "form_id": "cqctform",
      "day": day,
      "month": month,
      "year": year,
      "hour": hour,
      "minutes": minutes
  }
  nova.formData = formData

proc getNovaData*(nova: var RadioNova) =
  let config = loadConfig()
  case config.useProxy.parseBool()
  of true:
    let proxy = newProxy(config.proxy)
    nova.client = newHttpClient(proxy = proxy)
  of false:
    nova.client = newHttpClient()
    nova.client.headers = newHttpHeaders(headers)

  let
    novaResp = nova.client.request(
      url = formUrl,
      httpMethod = HttpPost,
      body = encodeQuery(nova.formData)
    )
    parsedHtml = parseHtml(novaResp.body)

  # artist/track
  var artist: string
  var track: string
  for tdiv in parsedHtml.findAll("div"):
    case tdiv.attr("class")
    of "name":
      artist = tdiv.innerText()
    of "description":
      track = tdiv.innerText()
      break # we only need the first one

  # social links
  var spotifyUrl: string
  var deezerUrl: string
  var appleUrl: string
  for li in parsedHtml.findAll("li"):
    case li.findAll("a")[0].attr("class")
    of "socicon-spotify":
      spotifyUrl = li.findAll("a")[0].attr("href")
    of "socicon-deezer":
      deezerUrl = li.findAll("a")[0].attr("href")
    of "socicon-apple":
      appleUrl = li.findAll("a")[0].attr("href")
      break # we only need the first one

  nova.artist = artist.toLower()
  nova.track = track.toLower()
  nova.spotifyUrl = spotifyUrl
  nova.deezerUrl = deezerUrl
  nova.appleUrl = appleUrl

proc display*(nova: var RadioNova) =
  echo "[\u266b]" & fmt" artist: {nova.artist} - track: {nova.track}"
  if nova.spotifyUrl != "": echo fmt"    {nova.spotifyUrl}"
  if nova.deezerUrl != "": echo fmt"    {nova.deezerUrl}"
  if nova.appleUrl != "":  echo fmt"    {nova.appleUrl}"

proc startPlayer*() =
  let
    config = loadConfig()
    playerFile = config.playerFile
    playerArgs = config.playerArgs

  var args: seq[string]
  for arg in playerArgs.split():
    args.add(arg)
  args.add(radioUrl)

  let
    playerProc = startProcess(command = playerFile, args = args)
    pidFile = open("player.pid", fmWrite)

  pidFile.write(playerProc.processID)
  pidFile.close()
  playerProc.close()

proc stopPlayer*() =
  let
    pidFile = open("player.pid", fmRead)
    playerPid = pidFile.readLine().parseInt()
  discard execProcess(fmt"taskkill /PID {playerPid} /F")
