/-  urbit-go
=,  format
|_  act=go-action:urbit-go
++  grab
  |%
  ++  noun  go-action:urbit-go
  ++  json
    |=  jon=json
    ^-  go-action:urbit-go
    %-  go-action:urbit-go
    =/  head  ((ot:dejs ~[[%go-action so:dejs]]) jon)
    ?+  head  ~|  'bad json for go-action'  !!
      %challenge
        :-  %challenge
        %.  jon
        %-  ot:dejs
        :~  [%name so:dejs]
            [%who (se:dejs %p)]
            [%komi (se:dejs %rs)]
            [%handicap ni:dejs]
            [%size ni:dejs]
            [%order (se:dejs %ta)]
        ==
      %accept-challenge
        :-  %accept-challenge
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %decline-challenge
        :-  %decline-challenge
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %withdraw-challenge
        :-  %withdraw-challenge
        %.  jon
        %-  ot:dejs
        :~  [%who (se:dejs %p)]
        ==
      %resign
        :-  %resign
        %.  jon
        %-  ot:dejs
        :~  [%id (se:dejs %da)]
        ==
      %move
        :::-  %move
        =/  pre-move
          %.  jon
          %-  ot:dejs
          :~  [%id (se:dejs %da)]
              [%position (sa:dejs)]
          ==
        =/  coord=tape  +3:pre-move
        =/  index=@ud  (find " " coord)
        =/  c1=tape  (scag index coord)
        =/  c2=tape  (slag +(index) coord)
        :-  %move
        [id=+2:pre-move position=[(slav %ud c1) (slav %ud c2)]]
      %pass
        :-  %pass
        %.  jon
        %-  ot:dejs
        :~  [%id (se:dejs %da)]
        ==
    ==
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
