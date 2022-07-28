/-  urbit-go
=,  format
|_  act=go-challenge:urbit-go
++  grab
  |%
  ++  noun  go-challenge:urbit-go
  --
++  grow
  |%
  ++  noun  act
  ++  json
    =+  act
    %-  pairs:enjs
    :~  ['name' [%s name]]
        ['game-id' (sect:enjs game-id)]
        ['challenger' (ship:enjs challenger)]
        ['challenged' (ship:enjs challenged)]
        ['komi' [%s (scot %rs komi)]]
        ['handicap' (numb:enjs handicap)]
        ['board-size' (numb:enjs board-size)]
        ['goes-first' [%s goes-first]]
    ==
  --
++  grad  %noun
--
