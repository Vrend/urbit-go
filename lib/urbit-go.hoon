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

/-  urbit-go
=,  urbit-go
|%
:: Updates game board
++  update-board
  |=  [b=board x=@ud y=@ud value=(unit piece)]
  ^-  b=board :: output board
  =/  n=@ud  n.b :: get nxn value
  ?>  &((lte x n) (lte y n) (gte x 1) (gte y 1)) :: make sure update within bounds
  =/  the-board=(map (pair @ud @ud) piece)  m.b :: assign board map to variable
  ?~  value :: check if value is null
    :-  n :: if it is, delete the piece
    (~(del by the-board) [x y])
  :-  n :: if not replace the piece
  (~(put by the-board) [x y] (need value)) :: return the updated board in proper format
::
++  board-occupied :: takes a position [x y] and returns whether or not it's occupied
  |=  [b=board x=@ud y=@ud]
  ^-  ?
  ?!((~(has by m.b) [x y]))
::
++  valid-position :: returns if [x y] is a valid position (bounds checking)
  |=  [b=board x=@ud y=@ud]
  ^-  ?
  ?:  ?&((gte x 1) (gte y 1) (lte x n.b) (lte y n.b))  &  |
::
++  initialize-game :: Returns a game structure - initialized with players and board size
  |=  [time=@dau name=@t player1=@p player2=@p board-size=@ud handicap=@ud komi=@rs]
  ^-  [@tas (unit go-game)]
  ?.  ?|(=(board-size 19) =(board-size 13) =(board-size 9)) :: if board-size isn't 19x19 13x13 or 9x9
    [%bad-board ~] :: return null - bad board
  ?.  (lte handicap 9)  [%invalid-handicap ~] :: handicaps are bound between 0-9
  ?.  ?&((gth:rs komi .-1.000e3) (lth:rs komi .1.000e3)) :: komi is bound between -1000 - 1000
    [%invalid-komi ~]
  =|  game=go-game :: initialize game variable
  =.  game-id.game  time
  =.  name.game  name
  =.  black.game  player1 :: set player1 to black (goes first)
  =.  white.game  player2 :: set player2 to white
  =.  game-board.game  (generate-board board-size) :: generates the board based on give board size
  =.  handicap.game  handicap :: assigns number of handicap stones
  =.  komi.game  komi :: assigns value of komi (default 6.5)
  =.  game-board.game  (set-handicap game-board.game handicap.game) :: places handicap stones
  [%ok (some game)] :: return game
::
++  make-move :: the function that takes in a game state, position, and color, and changes the game state
  |=  [game=go-game position=[@ud @ud] color=piece]
  ^-  [@tas (unit go-game)]
  ?.  (valid-position game-board.game +2:position +3:position) :: checking if [x y] are valid coordinates
    [%invalid-position ~] :: invalid position
  ?.  (board-occupied game-board.game +2:position +3:position) :: checking if [x y] space occupied
    [%occupied ~] :: return %occupied
  ?.  =((get-turn-player game) color) :: if color isn't turn-player
    [%not-your-turn ~] :: return %not-your-turn
  =/  prospective-board=board  (update-board game-board.game +2:position +3:position (some color)) :: add piece at position
  =.  prospective-board  (capture prospective-board (get-other-player color)) :: remove other player's pieces
  =.  prospective-board  (capture prospective-board color) :: remove own pieces
  ?.  (check-suicide game-board.game prospective-board color) :: check if board results in piece suicide
    [%suicide ~]
  ?.  (check-ko prospective-board history.game) :: check for ko rule
    [%ko ~] :: repeat move in the past 3 turns
  =.  game-board.game  prospective-board :: replace old board with new
  =.  history.game  [prospective-board history.game] :: add new board to history
  =.  turn.game  +(turn.game) :: increment turn
  [%ok (some game)] :: return new game-state with %ok
::
++  check-ko :: Checks if any of the past 3 board-states match the prospective one
  |=  [b=board history=(list board)]
  ^-  ?
  =|  counter=@ud
  |- :: loop
  ?:  =(counter 3)  & :: we are only checking the latest 3 moves
  ?~  history  & :: if null, that means we've gone through all the boards (first 3 moves)
  ?:  =(i.history b)  | :: if the board is equal to the current head of history, return false
  $(history t.history, counter +(counter)) :: reset loop, increment counter
::
++  get-player-color :: only run if you know they're in the game!
|=  [game=go-game who=@p]
^-  piece
?:  =(black.game who)  %black:: player is black
%white :: player is white (or not in the game!)
::
++  get-turn-player :: gets the turn-player based on turn number
  |=  game=go-game
  ^-  piece
  =/  turn  turn.game
  ?:  =((mod turn 2) 1)  %black :: black plays on odd turns
  %white :: white plays on even turns
::
++  get-other-player :: returns the opposite color player
  |=  color=piece
  ?:  =(color %black)  %white
  %black
::
++  check-suicide :: checks if turn-player suicided pieces
  |=  [prev-board=board new-board=board color=piece]
  ^-  ?
  =/  prev-count=[black=@ud white=@ud]  (count-colors prev-board) :: get counts from previous board
  =/  new-count=[black=@ud white=@ud]  (count-colors new-board) :: get counts from new board
  ?:  =(color %black) :: if player is black
    ?:  (lte black.new-count black.prev-count)  |  & :: check black pieces
  ?:  (lte white.new-count white.prev-count)  |  & :: check white pieces
::
++  count-colors ::returns a cell of a sum of all white pieces and black pieces
  |=  game-board=board
  ^-  [black=@ud white=@ud]
  =|  white-count=@ud
  =|  black-count=@ud
  =/  position-values=(list piece)  ~(val by m.game-board) :: convert map to list of piece values
  |-
  ?~  position-values  [black-count white-count] :: when empty, return the counts
  ?:  =(i.position-values %white) :: if the piece is white
    $(position-values t.position-values, white-count +(white-count)) :: increment white
  $(position-values t.position-values, black-count +(black-count)) :: otherwise increment black
::
++  capture :: Takes in a board and color, and removes pieces of that color with no liberties
  |=  [game-board=board color=piece]
  |^
  =/  pairs=(list [[@ud @ud] ?])  (build-pairs game-board) :: produce pairs all with value %.n
  =|  bool-board=(map (pair @ud @ud) ?) :: create map
  =.  bool-board  (~(gas by bool-board) pairs) :: add pairs to map
  =.  bool-board  (pre-scan game-board bool-board) :: set empty points to %.y
  =/  temp-bool-board=(map (pair @ud @ud) ?)  (scan-board game-board bool-board) :: do first iteration
  |- :: loop
  ?:  =(bool-board temp-bool-board)  (remove-pieces game-board bool-board) :: exit condition - no further changes
  $(bool-board temp-bool-board, temp-bool-board (scan-board game-board temp-bool-board))
  ++  pre-scan :: set any 'empty' value to %.y
    |=  [b=board l=(map (pair @ud @ud) ?)]
    ^-  (map (pair @ud @ud) ?) :: output type
    (~(urn by l) |=([x=[@ud @ud] y=?] ?!(=((~(gut by m.b) x ~) color)))) :: if [x y] is color, set to %.n
  ++  build-pairs :: produces pairs in the form [[x y] %.t]
    |=  game-board=board
    =/  range=(list @ud)  (gulf 1 n.game-board) :: produce list from 1 to n
    =|  pairs=(list [[@ud @ud] ?]) :: set output variable
    =/  counter=@ud  1
    |- :: loop start
    ?:  (gth counter n.game-board)  pairs :: exit condition - return pairs
    $(pairs (weld pairs (turn range |=(x=@ud [[counter x] &]))), counter +(counter)) :: add one row of pairs and increment counter
  ++  remove-pieces :: removes all pieces in b marked as %.n in l
    |=  [b=board l=(map (pair @ud @ud) ?)]
    =/  pairs=(list [[@ud @ud] ?])  ~(tap by l) :: produce list of cells in format [[x y] ?]
    =.  pairs  (skim pairs |=(x=[[@ud @ud] ?] ?!(+3:x))) :: produce list of only pairs with %.n
    |- :: loop
    ?~  pairs  b :: if pairs is null (no more removals) return b
    =.  b  (update-board b +4:i.pairs +5:i.pairs ~) :: otherwise update the board
    $(pairs t.pairs) :: restart the loop
  --
::
++  scan-board :: Scans board for pieces to remove
  |=  [game-board=board bool-board=(map (pair @ud @ud) ?)] :: bool-board keeps track of what to remove
  |^
  =/  row-count=@ud  1 :: row counter - essentially a for loop
  |-
  ?:  (gth row-count n.game-board)  bool-board :: exit condition
  =.  bool-board  (calculate-column game-board bool-board row-count) :: run column
  $(row-count +(row-count)) :: increment row
  ++  calculate-column
    |=  [game-board=board bool-board=(map (pair @ud @ud) ?) row-count=@ud]
    =/  column-count=@ud  1 :: column counter - nested for loop
    |-
    ?:  (gth column-count n.game-board)  bool-board :: exit condition
    ?.  =((~(got by bool-board) [row-count column-count]) &) :: check if [row col] set to true
      $(column-count +(column-count)) :: if not increment the column
    =/  color=(unit piece)  (~(get by m.game-board) [row-count column-count]) :: get board value at [row col]
    =.  bool-board  (update-neighbors bool-board game-board row-count column-count color) :: update neighbors
    $(column-count +(column-count)) :: restart loop incrementing the column
  :: Updates neighbors on bool-board
  ++  update-neighbors
    |=  [bool-board=(map (pair @ud @ud) ?) game-board=board x=@ud y=@ud color=(unit piece)]
    ?~  color :: empty space
      =?  bool-board  (gth x 1)  (~(put by bool-board) [(dec x) y] &) :: left
      =?  bool-board  (gth y 1)  (~(put by bool-board) [x (dec y)] &) :: down
      =?  bool-board  (lte x n.game-board)  (~(put by bool-board) [+(x) y] &) :: right
      =?  bool-board  (lte y n.game-board)  (~(put by bool-board) [x +(y)] &) :: up
      bool-board :: return board
    =?  bool-board  &((gth x 1) =((~(get by m.game-board) [(dec x) y]) color))
      (~(put by bool-board) [(dec x) y] &) :: left
    =?  bool-board  &((gth y 1) =((~(get by m.game-board) [x (dec y)]) color))
      (~(put by bool-board) [x (dec y)] &) :: down
    =?  bool-board  &((lte x n.game-board) =((~(get by m.game-board) [+(x) y]) color))
      (~(put by bool-board) [+(x) y] &) :: right
    =?  bool-board  &((lte y n.game-board) =((~(get by m.game-board) [x +(y)]) color))
      (~(put by bool-board) [x +(y)] &) :: up
    bool-board :: return board
  --
::
++  pass :: pass transition function
  |=  game=go-game
  ^-  go-game :: output as go-game
  =.  history.game  [game-board.game history.game] :: append board to history
  =.  turn.game  +(turn.game) :: increment turn
  game :: return game
::
++  remove-dead-stones
  |=  game=go-game
  ^-  go-game
  =/  b=board  game-board.game
  =/  dead-stones=[@p (set (pair @ud @ud))]  (need dead-stones.game)
  =/  stones=(list (pair @ud @ud))  ~(tap in +3.dead-stones)
  |-
  ?~  stones
    =.  game-board.game  b
    game
  $(stones t.stones, m.b (~(del by m.b) i.stones))
::
++  set-handicap :: only supports 19x19 13x13 and 9x9 boards!
  |=  [b=board handicap=@ud]
  ^-  board
  =/  handicap-key=tape  (~(got by handicap-map) handicap) :: gets specific board spots as tape based on handicap number
  =|  handicap-positions=(list [@ud @ud])
  =?  handicap-positions  =(n.b 19)
    (turn handicap-key |=(x=@tD (~(got by default-handicap-19) x))) :: converts board spots to [x y] cells based on board-size
  =?  handicap-positions  =(n.b 13)
    (turn handicap-key |=(x=@tD (~(got by default-handicap-13) x))) :: ibid
  =?  handicap-positions  =(n.b 9)
    (turn handicap-key |=(x=@tD (~(got by default-handicap-9) x))) :: ibid
  |- :: loop
  ?~  handicap-positions  b :: exit condition - return board
  =.  b  (update-board b +2:i.handicap-positions +3:i.handicap-positions (some %black)) :: add handicap stones to board
  $(handicap-positions t.handicap-positions) :: loop condition - pop off top handicap [x y] cell
::
++  score-game :: scores using area-scoring - dead stones are determined prior to running this arm
  |=  game=go-game
  ^-  go-game
  |^
  =/  b=board  game-board.game
  =/  initial-scores=[black=@ud white=@ud]  (count-colors b) :: counts stones on board
  =/  graph=(set (pair @ud @ud))  (get-empty-positions b) :: initialize graph of all empty positions
  =|  black-count=@ud
  =|  white-count=@ud
  |- :: loop here
  =|  tree=n-tree
  =|  visited=(set (pair @ud @ud))
  ?:  =(~(wyt in graph) 0)  (update-game-result game initial-scores [black-count white-count]) :: when graph is empty - return counts
  =/  root=[@ud @ud]  (snag 0 ~(tap in graph)) :: get any position in graph
  =/  output=[(set (pair @ud @ud)) n-tree]  (create-tree b graph root visited tree) :: build a tree
  =/  area-count=[@tas @ud]  (traverse-tree +3.output root b) :: count the area in said tree
  ?:  =(+2.area-count %white) :: if white add to white and remove all visited positions from graph
    $(graph (~(dif in graph) +2.output), white-count (add white-count +3.area-count))
  ?:  =(+2.area-count %black) :: if black add to black and remove all visited positions from graph
    $(graph (~(dif in graph) +2.output), black-count (add black-count +3.area-count))
  $(graph (~(dif in graph) +2.output)) :: remove all visited positions from graph
  ::
  ++  traverse-tree
    |=  [tree=n-tree pos=[@ud @ud] b=board]
    ^-  [@tas @ud]
    :: get neighbors and check if they're occupied
    =|  neighbors=(list @tas)
    =.  neighbors  [(~(gut by m.b) [(dec +2.pos) +3.pos] %none) neighbors] :: left
    =.  neighbors  [(~(gut by m.b) [+(+2.pos) +3.pos] %none) neighbors] :: right
    =.  neighbors  [(~(gut by m.b) [+2.pos (dec +3.pos)] %none) neighbors] :: bot
    =.  neighbors  [(~(gut by m.b) [+2.pos +(+3.pos)] %none) neighbors] :: top
    =/  color=@tas  (check-if-neighbors-share-color neighbors)
    ?:  =(color %both)  [%both 0] :: mix of colors - abort!
    =/  sum=@ud  1
    =/  children=(list (pair @ud @ud))  (~(got by tree) pos) :: iterate through children of tree
    |-
    ?~  children  [color sum] :: when empty return [color sum]
    =/  child=[@tas @ud]  (traverse-tree tree i.children b)
    :: check if colors don't match
    ?:  ?|(=(+2.child %both) ?&(=(color %white) =(+2.child %black)) ?&(=(color %black) =(+2.child %white)))
      [%both 0] :: mix of colors - abort!
    =?  color  =(color %none)  +2.child :: if current color is empty - replace with child color
    $(sum (add sum +3.child), children t.children) :: otherwise add to sum and continue
  ::
  ++  check-if-neighbors-share-color :: a bit wordy
    |=  input=(list @tas)
    ^-  @tas :: returns %none %white %black or %both
    =|  white-count=@ud
    =|  black-count=@ud
    |- :: loop
    ?~  input :: when input is empty [~]
      ?:  ?&(=(white-count 0) =(black-count 0))  %none :: haven't found an edge yet
      ?:  ?&((gth white-count 0) =(black-count 0))  %white :: white's territory
      ?:  ?&((gth black-count 0) =(white-count 0))  %black :: black's territory
      %both :: otherwise it's both
    ?:  =(%black i.input)  $(black-count +(black-count), input t.input) :: increment black and loop
    ?:  =(%white i.input)  $(white-count +(white-count), input t.input) :: increment white and loop
    ?:  =(%both i.input)  %both :: already bad
    $(input t.input) :: just loop
  ::
  ++  create-tree
    |=  [b=board graph=(set (pair @ud @ud)) pos=[@ud @ud] tracker=[visited=(set (pair @ud @ud)) tree=n-tree]]
    ^-  [(set (pair @ud @ud)) n-tree]
    =.  visited.tracker  (~(put in visited.tracker) pos) :: add itself to visited
    =.  tree.tracker  (~(put by tree.tracker) pos [~]) :: add itself to the tree
    :: created faces for readability
    =/  left=[@ud @ud]  [(dec +2.pos) +3.pos]
    =/  right=[@ud @ud]  [+(+2.pos) +3.pos]
    =/  bot=[@ud @ud]  [+2.pos (dec +3.pos)]
    =/  top=[@ud @ud]  [+2.pos +(+3.pos)]
    :: conditions - bounds of table | occupied | visited
    =?  tracker  ?&((gte +2.left 1) ?!((~(has by m.b) left)) ?!((~(has in visited.tracker) left)))  :: left neighbor
      =/  sub-output=[(set (pair @ud @ud)) n-tree]  (create-tree b graph left tracker)
      =.  +3.sub-output  (~(put by +3.sub-output) pos [left (~(got by +3.sub-output) pos)]) :: add left to pos' connections
      sub-output
    =?  tracker  ?&((lte +2.right n.b) ?!((~(has by m.b) right)) ?!((~(has in visited.tracker) right)))  :: right neighbor
      =/  sub-output=[(set (pair @ud @ud)) n-tree]  (create-tree b graph right tracker)
      =.  +3.sub-output  (~(put by +3.sub-output) pos [right (~(got by +3.sub-output) pos)]) :: add right to pos' connections
      sub-output
    =?  tracker  ?&((gte +3.bot 1) ?!((~(has by m.b) bot)) ?!((~(has in visited.tracker) bot)))  :: bot neighbor
      =/  sub-output=[(set (pair @ud @ud)) n-tree]  (create-tree b graph bot tracker)
      =.  +3.sub-output  (~(put by +3.sub-output) pos [bot (~(got by +3.sub-output) pos)]) :: add bot to pos' connections
      sub-output
    =?  tracker  ?&((lte +3.top n.b) ?!((~(has by m.b) top)) ?!((~(has in visited.tracker) top)))  :: top neighbor
      =/  sub-output=[(set (pair @ud @ud)) n-tree]  (create-tree b graph top tracker)
      =.  +3.sub-output  (~(put by +3.sub-output) pos [top (~(got by +3.sub-output) pos)]) :: add top to pos' connections
      sub-output
    tracker
  ::
  ++  get-empty-positions
    |=  b=board
    ^-  (set (pair @ud @ud))
    =|  output=(set (pair @ud @ud))
    =/  x=@ud  1
    =/  y=@ud  1
    |-
    ?:  (gth x n.b)  output
    =?  output  ?!((~(has by m.b) [x y]))  (~(put in output) [x y]) :: if not on board - add to output
    ?:  =(y n.b)  $(x +(x), y 1) :: if we finish column, increment x and set y to 1
    $(y +(y)) :: otherwise increment y
  ::
  ++  update-game-result :: takes in number of stones and area controlled, and updates winner
    |=  [game=go-game initial-scores=[@ud @ud] added-scores=[@ud @ud]]
    ^-  go-game
    =/  black-total=@rs  (sun:rs (add +2.initial-scores +2.added-scores)) :: adds area and stones on board for black
    =/  white-total=@rs  (sun:rs (add +3.initial-scores +3.added-scores)) :: adds area and stones on board for white
    =.  white-total  (add:rs white-total komi.game) :: add white's komi
    ?:  (gth:rs black-total white-total) :: black wins
      =.  result.game  (some [black-score=black-total white-score=white-total result=(some black.game)])
      game
    =.  result.game  (some [black-score=black-total white-score=white-total result=(some white.game)]) :: otherwise white wins
    game
  --
--
