/-  urbit-go
=,  format
|_  act=(list go-challenge:urbit-go)
++  grab
  |%
  ++  noun  (list go-challenge:urbit-go)
  --
++  grow
  |%
  ++  noun  act
  ++  json
    =+  act
    %+  frond:enjs
      'challenges'
    a+(turn act challenge-to-json:urbit-go)
  --
++  grad  %noun
--
