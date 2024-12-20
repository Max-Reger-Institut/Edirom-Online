xquery version "3.0";
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

  ID: $Id: work.xqm 1324 2012-05-15 13:59:35Z daniel $
:)


(:~
: This module provides library functions for Works
:
: @author <a href="mailto:roewenstrunk@edirom.de">Daniel Röwenstrunk</a>
:)
module namespace work = "http://www.edirom.de/xquery/work";

declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace edirom="http://www.edirom.de/ns/1.3";

declare function local:getLocalizedTitle($node) {

    let $lang := request:get-parameter('lang', '')
    let $nodeName := local-name($node)
    let $titleMain := $node/mei:title[@xml:lang = $lang]/mei:titlePart[@type='main']/text()
    let $titlePerf := $node/mei:title[@xml:lang = $lang]/mei:titlePart[@type='perf']/text()
    let $identifierCategory := $node/mei:identifier[@type='category']/text()
    let $identifierGenre := $node/mei:identifier[@type='genre']/text()
    let $identifierCounter := $node/mei:identifier[@type='counter']/text()
    let $identifierNo := $node/mei:identifier[@type='no']/text()
    let $titleNew := if($identifierCategory = 'opus' and $identifierNo)
                        then(concat($titleMain, if ($titlePerf) then (concat(' ', $titlePerf)) else () , ' op. ', $identifierCounter,' Nr. ', $identifierNo))
                        else if($identifierCategory = 'opus')
                        then(concat($titleMain, if ($titlePerf) then (concat(' ', $titlePerf)) else (), ' op. ', $identifierCounter))
                        else if($identifierCategory = 'woo' and $identifierNo)
                        then(concat($titleMain, if ($titlePerf) then (concat(' ', $titlePerf)) else (), ' WoO ', $identifierGenre ,'/', $identifierCounter,' Nr. ', $identifierNo))
                        else if($identifierCategory = 'woo')
                        then(concat($titleMain, if ($titlePerf) then (concat(' ', $titlePerf)) else (), ' WoO ', $identifierGenre, '/', $identifierCounter))
                    else()
    return
        normalize-space(string($titleNew))

};

(:~
: Returns a JSON representation of a Work
:
: @param $uri The URI of the Work's document to process
: @return The JSON representation
:)
declare function work:toJSON($uri as xs:string) as xs:string {
    
    let $work := doc($uri)/mei:mei
    return
        concat('
            {',
                'id: "', $work/string(@xml:id), '", ',
                'doc: "', $uri, '", ',
(:                'title: "', local:getLocalizedTitle($work//mei:workDesc/mei:work/mei:titleStmt)/replace(., '"', '\\"'), '"',:)
                'title: "', normalize-space(replace(string(local:getLocalizedTitle($work//mei:workDesc/mei:work/mei:titleStmt)), '"', '\\"')), '"',
            '}')
};

(:~
: Returns whether a document is a work or not
:
: @param $uri The URI of the document
: @return Is work or not
:)
declare function work:isWork($uri as xs:string) as xs:boolean {
    
    exists(doc($uri)//mei:mei) and exists(doc($uri)//mei:work) and not(doc($uri)//mei:source)
};

(:~
: Returns a works's label
:
: @param $source The URIs of the Work's document to process
: @return The label
:)
declare function work:getLabel($work as xs:string) as xs:string {
     
    local:getLocalizedTitle(doc($work)//mei:work/mei:titleStmt)
};

(:~
: Returns the forst works id
:
: @param $uri The URIs of the Edition
: @return The id
:)
declare function work:findWorkID($uri as xs:string) as xs:string {
     
    doc($uri)//edirom:work[1]/data(@xml:id)
};