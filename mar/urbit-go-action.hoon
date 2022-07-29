/-  urbit-go
=,  format
|_  act=go-action:urbit-go
++  grab
  |%
  ++  noun  go-action:urbit-go
  ++  json
    |=  jon=^json
    ^-  go-action:urbit-go
    %.  jon
    %-  of:dejs
    :~  [%challenge (ot:dejs ~[name+so:dejs who+(se:dejs %p) komi+(se:dejs %rs) handicap+ni:dejs size+ni:dejs order+(se:dejs %tas)])]
        [%accept-challenge (ot:dejs ~[who+(se:dejs %p)])]
        [%decline-challenge (ot:dejs ~[who+(se:dejs %p)])]
        [%withdraw-challenge (ot:dejs ~[who+(se:dejs %p)])]
        [%resign (ot:dejs ~[id+(se:dejs %da)])]
        [%move (ot:dejs ~[id+(se:dejs %da) position+(cu:dejs move-from-json:urbit-go sa:dejs)])]
        [%dead-stones (ot:dejs ~[id+(se:dejs %da) stones+(cu:dejs dead-stones-from-json:urbit-go (ar:dejs sa:dejs))])]
        [%pass (ot:dejs ~[id+(se:dejs %da)])]
    ==
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
