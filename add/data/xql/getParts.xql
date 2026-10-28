xquery version "1.0";
(:
  Edirom Online
  Copyright (C) 2011 The Edirom Project
  http://www.edirom.de

  Edirom Online is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Edirom Online is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Edirom Online.  If not, see <http://www.gnu.org/licenses/>.

:)

declare namespace request="http://exist-db.org/xquery/request";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace conf="https://www.maxreger.info/conf";

import module namespace functx="http://www.functx.com";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

let $uri := request:get-parameter('uri', '')
let $mei := doc($uri)/root()

let $meiVersion := number(substring-before($mei/mei:mei/@meiversion/string(), '.'))

let $ret :=
    if ($meiVersion >= 5)
    then (
        for $part in $mei//mei:perfResList/mei:perfRes
            let $configResource := doc('xmldb:exist:///db/apps/mriExistDBconf/config.xml')
            let $mrpUrl := $configResource//conf:mrpURL
            let $key := $part/@auth
            let $keyTranslationURL := concat($mrpUrl, 'cat/rest/getTranslation.xql?key=', $key)
            let $partTranslated := functx:capitalize-first(hc:send-request(<hc:request href="{$keyTranslationURL}" method="get"/>)[2])
            return concat('{label:  "', $partTranslated, '", id:"', $part/@xml:id, '", selectedByDefault:true, selected:true}')
    )
    else (
        for $part in $mei//mei:instrumentation/mei:instrVoice
        return concat('{label: "', $part/@label, '", id:"', $part/@xml:id, '", selectedByDefault:true, selected:true}')
        )

return concat('[', string-join($ret, ','), ']')