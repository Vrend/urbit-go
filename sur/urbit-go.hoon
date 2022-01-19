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
    goes-first=@ta
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
  $%  [%challenge name=@t who=ship komi=@rs handicap=@ud size=@ud order=@ta] :: challenge another ship
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
--
