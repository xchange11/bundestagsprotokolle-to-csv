element csv {
for $meeting in //dbtplenarprotokoll
  let $snr := $meeting/@sitzung-nr/string()
  let $datum := $meeting/@sitzung-datum/string()
  let $wahlperiode := $meeting/@wahlperiode/string()
  (: to separate serialization into different files
   because out of main memory error :)
  where xs:int($snr) <= 100 
  for $top in $meeting/sitzungsverlauf/tagesordnungspunkt
    let $top_id := element top_id {$top/@top-id/string()}
    for $rede in $top/rede
      let $rede_id := element rede_id {$rede/@id/string()}
      for tumbling window $w  in $rede/*
        start $s at $spos previous $sprev next $snext 
        when ( $s/@klasse="redner" or name($s) = "name")
        let $rede_klasse := element rede_klasse {
          if ($s/@klasse="redner") then
            "rede_segment"
          else 
            "vorsitz_segment"  
        }
        let $vorsitz_name := element vorsitz_name {
           if(name($s) = "name") then $s/string()
        }
        let $redner_id := element redner_id {
          if ($s/@klasse="redner") then
           $s/redner/@id/string()         
        }
        let $full_name:= element redner {
          if ($s/@klasse="redner") then
            $s/redner/name/(vorname, nachname)/string()
        }
        let $fraktion := element fraktion {
          if ($s/@klasse="redner") then
            $s/redner/name/fraktion/string()
        }
        let $vorname:= element vorname {
          if ($s/@klasse="redner") then
            $s/redner/name/vorname/string()
          }
        let $nachname:= element nachname {
          if ($s/@klasse="redner") then
            $s/redner/name/nachname/string()
          }
          let $rolle :=  element rolle{
            if ($s/@klasse="redner") then
              $s/redner/name/rolle/rolle_lang/string()
          else
            "Vorsitz"  
          }
return (
    for $p in $w[position() > 1]
    count $c
    let $rede_klasse := 
      if(name($p) = "kommentar") then
         element rede_klasse {"kommentar"} 
      else 
         $rede_klasse 
    where $rede_klasse = "rede_segment"  
    return element _{
      element date { $datum },
      element meeting_nr {$snr},
      element electoral_term { $wahlperiode },
      element class { $p/@klasse/string() },
      $top_id,
      element speech_id { $rede_id/string() },
      element speaker_id {$redner_id/string()},
      element last_name {$nachname/string()},
      element first_name {$vorname/string()},
      element party {$fraktion/string()},
      element role {$rolle/string()},
      element sequence_nr {$c},
      element text {
        $p/normalize-space(string())
      },
    ()
   }
)
}=> csv:serialize(map{"separator":';', "header":"true"})