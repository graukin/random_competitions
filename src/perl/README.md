# How to make a competition
There was a group of users and several gifts for them. To choose a winner I've modeled a 'competitions'.

# How to run
Before going deep into details, I'll tell how to run some examples:
```
perl ./compete.pl ./list1 kakerlaken
```
Perl-script gets 2 arguments: list of participants and type of challenge. There are 'playoff' (like in Olympics games or football), 'round-robin' (like normal 'table' competitions) and 'kakerlaken' (it emulates сockroach racing)

## Playoff
```
perl ./compete.pl ./users_list playoff
```
For more details you may read [wikipedia](https://en.wikipedia.org/wiki/Playoff_format). In the nutshell: there are 2^k players, split them in pairs and winners go further making next-round pairs. In the end there would be only one winner.

### Battle in pair
Inside every pair there is a little 'battle':
1. define, how many 'rounds' will be (random integer from 1 to 10, inclusive)
2. every round consists of attack and defence for both players:
    1. 1st player attacks (random integer from 1 to 100) and 2nd defends (from 1 to 100, too).
    2. If attack was powerfull and defence was not good enough - 1st player gets +1.
    3. 2nd player attacks and 1st defends.
    4. The same way for 2nd player to get +1.
3. if there is no winner in the pair, competitors should fight until someone will win.

## Round-robin
```
perl ./compete.pl ./users_list roundrobin
```
We build a chart where everyone should play with everyone just once. For better example go to [wikipedia](https://en.wikipedia.org/wiki/Round-robin_tournament) once more (part with 'Round-Robin Schedule'). It's longer than playoff but for us it has no restrictions on number of participants.

Every game between 2 players goes the same way as in playoff (see 'Battle in pair' chapter).

## Cockroaches
```
perl ./compete.pl ./users_list kakerlaken
```
Every participant has it's own cockroach. They start at the same time and try to run up to the finish line. Every round (every 10 seconds) each player rolls 3 ['Fate' dice](https://en.wikipedia.org/wiki/Fate_(role-playing_game_system)) to change acceleration of his/her cockroach. So some cockroaches will get negative acceleration and, than, speed, and will run back to the start line and further. But some of them should come to finish.
