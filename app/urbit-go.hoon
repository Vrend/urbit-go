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

/+  default-agent, dbug, urbit-go
=,  urbit-go
!:
|%
+$  versioned-state
    $%  state-0
    ==
+$  card  card:agent:gall
+$  state-0 :: TODO Add a new map between @dau IDs and their host ship
  $:  %0
      active-games=(map @dau go-game)
      archived-games=(map @dau go-game)
      challenges=(list go-challenge)
  ==
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this     .
    default   ~(. (default-agent this %|) bowl)
::
++  on-init
  ~&  >  'urbit-go initialized'
  ^-  (quip card _this)
  `this
++  on-save
  ^-  vase
  !>(state)
  :: on-save:default
++  on-load
  |=  old-state-vase=vase
  ^-  (quip card _this)
  ~&  >  'urbit-go reloaded'
  =/  old-state  !<(versioned-state old-state-vase)
  ?-  -.old-state
    %0  `this(state old-state)
  ==
  :: on-load:default
++  on-poke
|=  [=mark =vase]
^-  (quip card _this)
?+  mark  (on-poke:default mark vase)
  %noun
  ?+  q.vase  (on-poke:default mark vase)
    %zap
    =|  act=(map @dau go-game)
    =.  active-games  act
    =|  arch=(map @dau go-game)
    =.  archived-games  arch
    =.  challenges  [~]
    =/  kicks=(list path)  (turn ~(val by sup.bowl) |=(x=(pair @p path) +3.x)) :: takes every subscription in sup.bowl, which returns [@p path] and takes only the paths
    :_  this
    :~  [%give %kick kicks ~] :: kick all ships from all paths
    ==
  ==
  %urbit-go-action :: NEED TO ADD SUBSCRIPTION STUFF AND UPDATE SAID SUBSCRIPTION
  =/  action  !<(go-action vase)
  ~&  >  action
  ?-  -.action
    %challenge
    =|  challenge=go-challenge :: build go-challenge object from poke input
    =.  name.challenge  name.action
    =.  game-id.challenge  now.bowl
    =.  challenger.challenge  src.bowl
    =.  challenged.challenge  who.action
    =.  komi.challenge  komi.action
    =.  handicap.challenge  handicap.action
    =.  board-size.challenge  size.action
    =.  goes-first.challenge  order.action
    :_  this
    :~  [%pass /challenge %agent [who.action %urbit-go] %poke %urbit-go-action !>([%send-challenge challenge])]
      [%pass /challenge %agent [src.bowl %urbit-go] %poke %urbit-go-action !>([%send-challenge challenge])]
    ==
    %send-challenge
    ?:  (check-existing-challenge challenges challenger.challenge.action challenged.challenge.action) :: check if challenge already exists
      =.  challenges  (weld challenges ~[challenge.action])
      `this
    =.  challenges  (withdraw challenges challenger.challenge.action challenged.challenge.action) :: if it does, remove it - we don't know whether or not its on our end or theres
    =.  challenges  (withdraw challenges challenged.challenge.action challenger.challenge.action)
    =.  challenges  (weld challenges ~[challenge.action]) :: and then add the new one
    `this
    %accept-challenge
    ?>  =(src.bowl our.bowl) :: only the local ship should poke with this
    =/  challenge=go-challenge :: try to find challenge
      |- :: START LOOP
      ?~  challenges  !!  :: If we can't find the ID, crash
      ?:  ?&(=(our.bowl challenged.i.challenges) =(who.action challenger.i.challenges))  i.challenges :: if we find challenge with given players, set that to challenge
      $(challenges t.challenges) :: END LOOP :: check if a challenge exists
    =/  game-id=@dau  game-id.challenge
    =.  challenges  (oust [(need (find ~[challenge] challenges)) 1] challenges) :: remove challenge from our challenge list
    :_  this
    :~  [%pass /game/active/(scot %dau game-id)/wire %agent [who.action %urbit-go] %watch /game/active/(scot %dau game-id)]
    ==
    %decline-challenge
    ?.  =(our.bowl who.action) :: check if this is being sent to us or if this is a local poke
      ?>  =(src.bowl our.bowl) :: in this case we didnt make the challenge, make sure we sent this
      =.  challenges  (withdraw challenges who.action src.bowl) :: withdraw and decline are the same thing
      :_  this
      :~  [%pass /decline/challenge %agent [who.action %urbit-go] %poke %urbit-go-action !>([%decline-challenge who.action])] :: send same poke to other player
      ==
    =.  challenges  (withdraw challenges who.action src.bowl) :: otherwise just remove the challenge if it exists
    `this
    %withdraw-challenge
    ?.  =(our.bowl who.action) :: check if this is being sent to us or if this is a local poke
      ?>  =(src.bowl our.bowl) :: in this case we didnt make the challenge, make sure we sent this
      =.  challenges  (withdraw challenges src.bowl who.action) :: withdraw and decline are the same thing
      :_  this
      :~  [%pass /withdraw/challenge %agent [who.action %urbit-go] %poke %urbit-go-action !>([%withdraw-challenge who.action])] :: send same poke to other player
      ==
    =.  challenges  (withdraw challenges src.bowl who.action) :: otherwise just remove the challenge if it exists
    `this
    %resign
    =/  game-candidate=(unit go-game)  (~(get by active-games) id.action) :: Find game with said ID
    ?~  game-candidate  !!  :: If it doesn't exist crash
    =/  game=go-game  (need game-candidate)
    ?>  (check-in-game game src.bowl) :: sender needs to be in the game
    ?:  =(our.bowl host.game)  :: if we are the host...
      =.  game  (resign id.action active-games archived-games src.bowl)
      =.  active-games  (~(del by active-games) id.action)
      =.  archived-games  (~(put by archived-games) id.action game)
      :_  this
      :~  [%give %fact ~[/game/active/(scot %dau id.action)] %urbit-go-game !>(game)] :: send finished game to other player
      ==
    :_  this
    :~  [%pass /resign %agent [host.game %urbit-go] %poke %urbit-go-action !>([%resign id.action])] :: send to host
    ==
    %move
    =/  game-candidate=(unit go-game)  (~(get by active-games) id.action)
    ?~  game-candidate  !! :: No active game with that ID
    =/  game=go-game  (need game-candidate)
    ?>  (check-in-game game src.bowl) :: requesting ship must be playing the game
    ?:  =(our.bowl host.game)  :: if we are the host...
      ?:  =(pass.game 2)  ~|  %game-over  !! :: when pass.game is 2, that means the game is over and needs to have dead stones removed
      =/  color=piece  %black :: default black
      =?  color  =(white.game src.bowl)  %white :: if moving player is white, change color to white
      =/  output=[@tas (unit go-game)]  (make-move game position.action color)
      ?~  +3.output
        ~|  +2.output  !! :: output error
      =.  game  (need +3.output)
      =.  pass.game  0 :: set pass to 0 since a move was done
      =.  active-games  (~(put by active-games) id.action game) :: otherwise update game state
      :_  this
      :~  [%give %fact ~[/game/active/(scot %dau id.action)] %urbit-go-game !>(game)] :: send update
      ==
    :_  this
    :~  [%pass /move %agent [host.game %urbit-go] %poke %urbit-go-action !>([%move id.action position.action])] :: send to host
    ==
    %pass
    =/  game-candidate=(unit go-game)  (~(get by active-games) id.action) :: check if valid active game
    ?~  game-candidate  !! :: it isn't - return
    =/  game=go-game  (need game-candidate)
    ?>  ?&((check-in-game game src.bowl) =((get-player-color game src.bowl) (get-turn-player game))) :: if not in game or not your turn - return
    ?:  =(our.bowl host.game)  :: if we are the host...
      ?:  =(pass.game 2)  ~|  %game-over  !! :: when pass.game is 2, that means the game is over and needs to have dead stones removed
      =.  game  (pass game) :: update game-state with pass
      =.  pass.game  +(pass.game) :: increment pass.game
      =.  active-games  (~(put by active-games) id.action game)
      :_  this
      :~  [%give %fact ~[/game/active/(scot %dau id.action)] %urbit-go-game !>(game)]
      ==
    :_  this
    :~  [%pass /pass %agent [host.game %urbit-go] %poke %urbit-go-action !>([%pass id.action])] :: send to host
    ==
    %dead-stones
    =/  game-candidate=(unit go-game)  (~(get by active-games) id.action) :: check if valid active game
    ?~  game-candidate  !! :: it isn't - return
    =/  game=go-game  (need game-candidate)
    ?>  (check-in-game game src.bowl) :: sender not in game - dont care - crash
    ?>  (validate-stone-removal game stones.action) :: make sure stones to remove are actually on the board
    ?:  =(our.bowl host.game)  :: if we are the host...
      ?:  =(dead-stones.game ~) :: if dead-stones hasn't been put in yet, let sender put theirs in
        =.  dead-stones.game  (some [src.bowl stones.action]) ::player and their dead-stones get proposed
        =.  active-games  (~(put by active-games) id.action game) :: game in active-games gets updated
        :_  this
        :~  [%give %fact ~[/game/active/(scot %dau id.action)] %urbit-go-game !>(game)] :: update game
        ==
      =/  dead-stones=[@p (set (pair @ud @ud))]  (need dead-stones.game)
      ?:  =(+2.dead-stones src.bowl)  ~|  %not-your-turn  !! :: already submitted last - crash
      ?:  =(stones.action +3.dead-stones) :: submitted same dead stones - consensus reached
        =.  game  (remove-dead-stones game)
        =.  game  (score-game game) :: game over - time to score
        =.  archived-games  (~(put by archived-games) id.action game) :: put game in archives
        =.  active-games  (~(del by active-games) id.action) :: remove game from active
        :_  this
        :~  [%give %fact ~[/game/active/(scot %dau id.action)] %urbit-go-game !>(game)] :: send finished game to other player
        ==
      =.  dead-stones.game  (some [src.bowl stones.action])  ::player and their dead-stones get proposed
      =.  active-games  (~(put by active-games) id.action game) :: game in active-games gets updated
      :_  this
      :~  [%give %fact ~[/game/active/(scot %dau id.action)] %urbit-go-game !>(game)] :: send updated game to other player
      ==
    :_  this
    :~  [%pass /dead/stones %agent [host.game %urbit-go] %poke %urbit-go-action !>([%dead-stones id.action stones.action])] :: send to host
    ==
  ==
==
::
++  on-watch  ::on-watch:default
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:default path)
    [%game %active @ ~]
    =/  game-id=@dau  (slav %da i.t.t.path)
    ?:  (~(has by active-games) game-id) :: game exists - either this ship is subscribing for the first time or either player got kicked due to networking
      =/  game=go-game  (~(got by active-games) game-id) :: retrieve game
      :: ?>  (check-in-game game src.bowl) :: subscriber must be either black or white (IE in the game) LINE NOT NEEDED AS FRONTEND NEEDS TO SUBSCRIBE
      :_  this
      :~  [%give %fact ~ %urbit-go-game !>(game)] :: give the current game state
      ==
    =/  challenge=go-challenge :: otherwise try to find challenge
      |- :: START LOOP
      ?~  challenges  !!  :: If we can't find the ID, crash
      ?:  =(game-id.i.challenges game-id)  i.challenges :: if we find challenge with given ID, set that to challenge
      $(challenges t.challenges) :: END LOOP
    ?>  ?&(=(challenger.challenge our.bowl) =(challenged.challenge src.bowl)) :: make sure we are the challenger and the subscriber is the challenged
    ?>  ?|(=(goes-first.challenge %random) =(goes-first.challenge %challenger) =(goes-first.challenge %challenged)) :: has to be one of these 3 values
    =/  turn-order=[@p @p]  (determine-turn-order goes-first.challenge challenger.challenge challenged.challenge eny.bowl) :: determines who gets black or white
    =/  potential-game=[@tas (unit go-game)]  (initialize-game game-id.challenge name.challenge +2.turn-order +3.turn-order board-size.challenge handicap.challenge komi.challenge) :: generate starting game
    ?~  +3.potential-game :: if game is bad it'll be null
      ~|  +2.potential-game
      !! :: bad game - abort
    =/  game=go-game  (need +3.potential-game)
    =.  host.game  our.bowl
    =.  challenges  (oust [(need (find ~[challenge] challenges)) 1] challenges) :: remove challenge from our challenge list
    =.  active-games  (~(put by active-games) game-id.challenge game) :: add game to active games
    :_  this
    :~  [%give %fact ~ %urbit-go-game !>(game)] :: give the initial game state
    ==
  ==
++  on-leave  on-leave:default
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  (on-peek:default path)
    [%x %game @ ~]
    =/  game-id=@dau  (slav %da i.t.t.path)
    =/  game=(unit go-game)  (~(get by active-games) game-id) :: check if ID in active games
    ?~  game
      =/  ogame=(unit go-game)  (~(get by archived-games) game-id) :: Check if ID in archived games
      ?~  ogame  [~ ~] :: Not a valid ID
      :^  ~  ~  %urbit-go-game
      !>(`go-game`(need ogame))
    :^  ~  ~  %urbit-go-game
    !>(`go-game`(need game))
    [%x %challenges ~]
    =|  our-challenges=(list go-challenge)
    |-
    ?~  challenges
      :^  ~  ~  %urbit-go-challenges
      !>(`(list go-challenge)`our-challenges)
    ?:  ?|(=(src.bowl challenger.i.challenges) =(src.bowl challenged.i.challenges))
      $(challenges t.challenges, our-challenges (weld ~[i.challenges] our-challenges))
    $(challenges t.challenges)
    [%x %active-games ~]
    =|  our-games=(list go-game)
    :^  ~  ~  %urbit-go-games
    !>(`(list go-game)`~(val by active-games))
  ==
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:default wire sign)
    [%challenge ~]
    ?.  ?=(%poke-ack -.sign)
      (on-agent wire sign)
    ?~  p.sign  `this
    =.  challenges  (withdraw challenges src.bowl our.bowl)
    =.  challenges  (withdraw challenges our.bowl src.bowl)
    ~&  >  'Challenge was rejected by ship'
    `this
    [%game %active @ %wire ~]
    ?+  -.sign  (on-agent:default wire sign)
      %fact
      ?+  p.cage.sign  (on-agent:default wire sign)
        %urbit-go-game
        =/  game=go-game  !<(go-game q.cage.sign)
        ?~  result.game :: if the result isn't decided: game still going
          =.  active-games  (~(put by active-games) game-id.game game) :: add/update game to active games
          :_  this
          :~  [%give %fact ~[/game/active/(scot %dau game-id.game)] %urbit-go-game !>(game)] :: give the current game state
          ==
        =.  archived-games  (~(put by archived-games) game-id.game game) :: add game to archive
        =.  active-games  (~(del by active-games) game-id.game) :: removes game from active-games
        :_  this
        :~  [%pass /game/active/(scot %dau game-id.game)/wire %agent [host.game %urbit-go] %leave ~]
            [%give %kick ~[/game/active/(scot %dau game-id.game)] ~]
        ==
      ==
      %kick
      =/  game-id=@dau  (slav %da i.t.t.wire)
      ~&  >  'kicked. attempting to resubscribe...'
      :_  this
      :~  [%pass /game/active/(scot %dau game-id)/wire %agent [src.bowl %urbit-go] %watch /game/active/(scot %dau game-id)]
      ==
    ==
  ==
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
|%
++  check-in-game :: checks if ship is participating in game
  |=  [game=go-game who=@p]
  ^-  ?
  ?|(=(black.game who) =(white.game who))
::
++  check-existing-challenge :: checks if challenge between players already exists - returns true if there ISN'T one
  |=  [challenges=(list go-challenge) who=@p whom=@p]
  ^-  ?
  |-
  ?~  challenges  &
  =/  challenge=go-challenge  i.challenges
  ?:  ?|(?&(=(challenger.challenge who) =(challenged.challenge whom)) ?&(=(challenger.challenge whom) =(challenged.challenge who)))  |
  $(challenges t.challenges)
::
++  validate-stone-removal :: checks that all stones to remove actually exist
  |=  [game=go-game stones=(set (pair @ud @ud))]
  ^-  ?
  =/  stones-list=(list (pair @ud @ud))  ~(tap in stones) :: convert to a list
  |-
  ?~  stones-list  & :: if all is well, return TRUE
  ?:  (board-occupied game-board.game +2.i.stones-list +3.i.stones-list) :: board-occupied returns true if the space is empty
    | :: return false if space is empty
  $(stones-list t.stones-list)
::
++  withdraw :: removes any challenge from the list matching challenger=who and challenged=whom
  |=  [challenges=(list go-challenge) who=@p whom=@p]
  ^-  (list go-challenge)
  (murn challenges |=(c=go-challenge ?:(?&(=(who challenger.c) =(whom challenged.c)) ~ (some c))))
::
++  resign :: resign from a game
  |=  [id=@dau active-games=(map @dau go-game) archived-games=(map @dau go-game) who=@p]
  ^-  go-game
  =/  game=go-game  (~(got by active-games) id) :: get game with that ID
  =|  gr=game-result :: create default result
  =/  winner=(unit @p)  (some black.game) :: by default assume resigner is playing white
  =?  winner  =(black.game who)  (some white.game) :: if resigner is playing black, set winner to white
  =.  result.gr  winner :: set game-result result to winner
  =.  result.game  (some gr) :: assign game-result to the go-game
  game :: return
::
++  determine-turn-order :: takes in the order (%random %challenger %challenged) and players, and returns a cell of [first second]
  |=  [order=@tas challenger=@p challenged=@p seed=@]
  ^-  [@p @p] :: return order
  ?+  order  [challenger challenged] :: by default challenger goes first
    %random
    =/  rand-num=@ud  (~(rad og seed) 2) :: generate number between 0 and 1
    ?:  =(rand-num 0)  [challenger challenged]  [challenged challenger] :: if 0 - challenger goes first, otherwise challenged goes first
    %challenged  [challenged challenger] :: challenged goes first
  ==
--
