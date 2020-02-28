xquery version "1.0";

import module namespace edoxy="http://www.bbaw.de/telota/ediarum/oxygen" at "lib.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

if ($edoxy:index='places')
then (edoxy:getPlaceList())
else if ($edoxy:index='persons')
then (edoxy:getPersonList())
else if ($edoxy:index='orgs')
then (edoxy:getOrgList())
else if ($edoxy:index='bibl')
then (edoxy:getBiblList())
else if ($edoxy:index='items')
then (edoxy:getItemList())
else if ($edoxy:index='letters')
then (edoxy:getLetterList())
else if ($edoxy:index='comments')
then (edoxy:getCommentsList())
else if ($edoxy:index='keywords')
then (edoxy:getKeywordList())
else ()
