/-  urbit-go
=,  format
|_  act=(list go-game:urbit-go)
++  grab
  |%
  ++  noun  (list go-game:urbit-go)
  --
++  grow
  |%
  ++  noun  act
  ++  json
    =+  act
    %+  frond:enjs
      'active-games'
    a+(turn act game-to-json:urbit-go)
  --
++  grad  %noun
--
