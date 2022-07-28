/-  urbit-go
=,  format
|_  act=go-game:urbit-go
++  grab
  |%
  ++  noun  go-game:urbit-go
  --
++  grow
  |%
  ++  noun  act
  ++  json
    =+  act
    %-  pairs:enjs
    :~  ['game-id' (sect:enjs game-id)]
        ['name' [%s name]]
        ['host' (ship:enjs host)]
        ['black' (ship:enjs black)]
        ['white' (ship:enjs white)]
        ['turn' (numb:enjs turn)]
        ['history' (history-to-json:urbit-go history)]
        ['game-board' (board-to-json:urbit-go game-board)]
        ['komi' [%s (scot %rs komi)]]
        ['handicap' (numb:enjs handicap)]
        ['pass' (numb:enjs pass)]
        ['result' (result-to-json:urbit-go result)]
        ['dead-stones' (dead-stones-to-json:urbit-go dead-stones)]
    ==
  --
++  grad  %noun
--
