element csv {
  for $mdb in //DOCUMENT/MDB
  let $nachname := $mdb/NAMEN/NAME/NACHNAME/string()
  let $vorname := $mdb/NAMEN/NAME/VORNAME/string() 
  let $id :=  $mdb/ID
  let $birthdate := $mdb/BIOGRAFISCHE_ANGABEN/GEBURTSDATUM
  let $fraktion :=  $mdb/WAHLPERIODEN/WAHLPERIODE[last()]/INSTITUTIONEN/INSTITUTION[INSART_LANG = "Fraktion/Gruppe"]/INS_LANG/string()
  return element record {
    element person_id {$id/string()},
    element last_name { $nachname  },
    element first_name {$vorname },
    element birthdate {$birthdate/string()},
    element party {$fraktion}
  }  
}
=> csv:serialize(map {
  "separator": ";",
  "header": true()
})
