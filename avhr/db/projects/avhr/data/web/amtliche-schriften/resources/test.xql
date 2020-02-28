xquery version "3.0";

let $customer := <customer/>
return
typeswitch($customer)
   case element(USAddress)
            | element(AustraliaAddress)
            | element(MexicoAddress)
     return state
   case $a as element(CanadaAddress)
     return $a/province
   case $a as element(JapanAddress)
     return $a/prefecture
   default
     return ()