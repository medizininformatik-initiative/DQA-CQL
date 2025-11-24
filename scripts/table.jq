["test", "system", "code", "display", "count"],
(.group[0].stratifier[] as $stratifier
  | ( $stratifier.stratum[]
      | (if .value.coding != null then
           (if .value.coding[0].extension[0].url == "http://terminology.hl7.org/CodeSystem/data-absent-reason" then
             [$stratifier.code[0].text, "data-absent-reason", .value.coding[0].extension[0].valueCode, null, .population[0].count]
            else
             [$stratifier.code[0].text, .value.coding[0].system, .value.coding[0].code, .value.coding[0].display, .population[0].count]
            end)
         elif .value.text != null and (($stratifier.code[0].text | endswith("non-matching") | not) or .value.text != "null") then
           [$stratifier.code[0].text, null, null, .value.text, .population[0].count]
         else
           empty
         end)))
| @csv
