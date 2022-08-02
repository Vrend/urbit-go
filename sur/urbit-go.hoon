:: Copyright (C) 2021 Vrend
::
:: This file is part of urbit-go.
::
:: urbit-go is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: urbit-go is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with urbit-go. If not, see <https://www.gnu.org/licenses/>.

|%
+$  piece  $?(%white %black)
::
+$  board  $~((generate-board 19) $:(n=@ud m=(map (pair @ud @ud) piece)))
::
+$  n-tree  (map (pair @ud @ud) (list (pair @ud @ud)))
::
++  default-handicap-19  (my ~[['a' 16 16] ['b' 4 4] ['c' 16 4] ['d' 4 16] ['e' 10 10] ['f' 4 10] ['g' 16 10] ['h' 10 16] ['i' 10 4]])
::
++  default-handicap-13  (my ~[['a' 11 11] ['b' 3 3] ['c' 11 3] ['d' 3 11] ['e' 7 7] ['f' 3 7] ['g' 11 7] ['h' 7 11] ['i' 7 3]])
::
++  default-handicap-9  (my ~[['a' 8 8] ['b' 2 2] ['c' 8 2] ['d' 2 8] ['e' 5 5] ['f' 2 5] ['g' 8 5] ['h' 5 8] ['i' 5 2]])
::
++  handicap-map  (my ~[[0 ""] [1 "a"] [2 "ab"] [3 "abc"] [4 "abcd"] [5 "abcde"] [6 "abcdfg"] [7 "abcdefg"] [8 "abcdfghi"] [9 "abcdefghi"]])
::
+$  go-challenge
  $~  :*  name='Example Game'
          game-id=*@dau
          challenger=*@p
          challenged=*@p
          komi=.7.5
          handicap=0
          board-size=19
          goes-first=%random
      ==
  $:
    name=@t
    game-id=@dau
    challenger=@p
    challenged=@p
    komi=@rs
    handicap=@ud
    board-size=@ud
    goes-first=@tas
  ==
::
+$  game-result
  $~  :*  black-score=.0
          white-score=.0
          result=~
      ==
  $:
    black-score=@rs
    white-score=@rs
    result=(unit @p)
  ==
::
+$  go-game
  $~  :*  game-id=*@dau
          name='Example Game'
          host=*@p
          black=*@p
          white=*@p
          turn=1
          history=[~]
          game-board=*board
          komi=.7.5
          handicap=0
          pass=0
          result=~
          dead-stones=~
      ==
  $:
    game-id=@dau
    name=@t
    host=@p
    black=@p
    white=@p
    turn=@ud
    history=(list board)
    game-board=board
    komi=@rs
    handicap=@ud
    pass=@ud
    result=(unit game-result)
    dead-stones=(unit [@p (set (pair @ud @ud))])
  ==
::
+$  go-action
  $%  [%challenge name=@t who=ship komi=@rs handicap=@ud size=@ud order=@tas] :: challenge another ship
      [%send-challenge challenge=go-challenge] :: emitted by agents to send a challenge to a participant
      [%accept-challenge who=ship] :: Accept the challenge sent by who
      [%decline-challenge who=ship] :: Decline the challenge sent by who
      [%withdraw-challenge who=ship] :: Withdraw the challenge sent to who
      [%resign id=@dau] :: Resign from game with ID
      [%move id=@dau position=[@ud @ud]] :: Make a move with ID and position
      [%pass id=@dau] :: Pass in game with ID
      [%dead-stones id=@dau stones=(set (pair @ud @ud))] :: send a set of dead stones for a specific game
  ==
::
++  generate-board
  |=  n=@ud
  ?>  (gth n 0)
  ^-  board
  =|  output=(map (pair @ud @ud) piece)
  [n output]
::
:: I'm putting JSON conversion code here, sue me
++  challenge-to-json
  |=  gc=go-challenge
  ^-  json
  %-  pairs:enjs:format
  :~  ['name' [%s name:gc]]
      ['game-id' [%s (scot %da game-id:gc)]]
      ['challenger' (ship:enjs:format challenger:gc)]
      ['challenged' (ship:enjs:format challenged:gc)]
      ['komi' [%s (scot %rs komi:gc)]]
      ['handicap' (numb:enjs:format handicap:gc)]
      ['board-size' (numb:enjs:format board-size:gc)]
      ['goes-first' [%s goes-first:gc]]
  ==
::
++  game-to-json
  |=  game=go-game
  ^-  json
  %-  pairs:enjs:format
  :~  ['game-id' [%s (scot %da game-id.game)]]
      ['name' [%s name.game]]
      ['host' (ship:enjs:format host.game)]
      ['black' (ship:enjs:format black.game)]
      ['white' (ship:enjs:format white.game)]
      ['turn' (numb:enjs:format turn.game)]
      ['history' (history-to-json history.game)]
      ['game-board' (board-to-json game-board.game)]
      ['komi' [%s (scot %rs komi.game)]]
      ['handicap' (numb:enjs:format handicap.game)]
      ['pass' (numb:enjs:format pass.game)]
      ['result' (result-to-json result.game)]
      ['dead-stones' (dead-stones-to-json dead-stones.game)]
  ==
::
++  board-to-json
  |=  b=board
  ^-  json
  =/  listified-board=(list [[@ud @ud] piece])  ~(tap by m.b) :: Turn map into list of key-value pairs
  =/  jsonified-board
     %+  turn :: run the following gate over every key-value pair
       listified-board
     |=  pos=[[@ud @ud] piece]
     [(crip ;:(weld (scow %ud +2:+2:pos) " " (scow %ud +3:+2:pos))) s+`@t`+3:pos] :: take each key-value pair and turn it into json [1 2] --> "1 2"
  (pairs:enjs:format ~[['n' (numb:enjs:format n.b)] ['m' (pairs:enjs:format jsonified-board)]]) :: recreate board structure as json
::
++  history-to-json
  |=  hist=(list board)
  ^-  json
  :-  %a
  (turn hist board-to-json)
::
++  result-to-json
  |=  unit-result=(unit game-result)
  ^-  json
  ?~  (drop unit-result)  ~ :: if it's null, return null
  =/  g-result=game-result  (need unit-result):: otherwise unpack it from a unit
  %-  pairs:enjs:format
  :~  ['black-score' [%s (scot %rs black-score.g-result)]]
      ['white-score' [%s (scot %rs white-score.g-result)]]
      ['result' ?~(result.g-result ~ (ship:enjs:format (need result.g-result)))] :: if the result isn't null, return the ship otherwise return null
  ==
::
++  dead-stones-to-json
  |=  unit-dead-stones=(unit [@p (set (pair @ud @ud))])
  ^-  json
  ?~  (drop unit-dead-stones)  ~ :: if null, return null
  =/  dead-stones=(list json)
    %+  turn
      ~(tap in +3:(need unit-dead-stones)) :: convert set to list and run gate below
    |=  pos=[@ud @ud]
    s+(crip ;:(weld (scow %ud +2:pos) " " (scow %ud +3:pos))) :: return a chord made up of both @ud's separated by a space
  %-  pairs:enjs:format
  :~
    ['ship' (ship:enjs:format +2:(need unit-dead-stones))]
    ['stones' [%a dead-stones]]
  ==
::
++  move-from-json
|=  coord=tape
=/  index=@ud  (need (find " " coord))
[(slav %ud (crip (scag index coord))) (slav %ud (crip (slag +(index) coord)))]
::
++  dead-stones-from-json
  |=  stones=(list tape)
  ^-  (set (pair @ud @ud))
  =/  stones-decoded=(list (pair @ud @ud))
    %+  turn
      stones
    |=  coord=tape
    ^-  (pair @ud @ud)
    =/  index=@ud  (need (find " " coord))
    [(slav %ud (crip (scag index coord))) (slav %ud (crip (slag +(index) coord)))]
  (silt stones-decoded)

--
