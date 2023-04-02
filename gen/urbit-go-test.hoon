:: Copyright (C) 2023 Vrend
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

/+  urbit-go
=,  urbit-go
!:
|=  n=@ud :: n=board-size h=handicap k=komi
=/  potential-game=[@tas (unit go-game)]  (initialize-game *@dau 'blah' ~zod ~winner-mittec n 0 .7.5)
:: ^^ initialize with ~zod playing ~winner-mittec
?~  +3.potential-game  +2:potential-game :: if game returned is null, return the error
=/  game=go-game  (need +3:potential-game) :: get the game object otherwise
=.  game  +3:(need (make-move game [2 2] %black)) :: black makes the first move at [2 2]
=.  game  +3:(need (make-move game [2 3] %white)) :: continues.....
=.  game  +3:(need (make-move game [2 4] %black))
=.  game  +3:(need (make-move game [7 7] %white))
=.  game  +3:(need (make-move game [3 3] %black))
=.  game  +3:(need (make-move game [7 8] %white))
=.  game  +3:(need (make-move game [1 3] %black))
=.  game  (score-game game)
(need result.game)
