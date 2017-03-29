# How to make a competition
There was a group of users and several presents for them. To choose a winner I've modeled a 'competitions'.

# How to run
Before going deep into details, I'll tell how to run some examples:
```shell
perl ./compete.pl ./list1 kakerlaken
```
Perl-script gets 2 arguments: list of participants and type of challenge. There are playoff (like in Olympics games or football), round-robin (like normal 'table' competitions) and 'kakerlaken' (it emulates сockroach racing)

## Playoff
For more details you may read [wikipedia](https://en.wikipedia.org/wiki/Playoff_format). In the nutshell: there are 2^k players, split them in pairs and winners go further making next-round pairs. In the end there would be only one winner.

Inside every pair there is a little 'battle':
1. define, how many 'rounds' will be (random integer from 1 to 10, inclusive)
2. every round consists of atack and defence for both players:
    1. 1st player attacks (random integer from 1 to 100) and 2nd defends (from 1 to 100, too).
    2. If attack was powerfull and defence was not good enough - 1st player gets +1.
    3. 2nd player attacks and 1st defends.
    4. The same way for 2nd player to get +1.
3. if there is no winner in the pair, competitors should fight until someone will win.

## Round-robin
We built a chart where everyone should play with everyone just once. For better example got to [wikipedia](https://en.wikipedia.org/wiki/Round-robin_tournament) once more (part with 'Round-Robin Schedule'). It's longer than playoff but for us it has no restrictions on number of participants.

Every game between 2 players goes the same way as ni playoff (little battle).

## Kakerlaken
Every participant has it's own cockroach. They start at the same time and try to run up to the finish line. Every round (every 10 seconds) each player rolls 3 ['Fate' dice](https://en.wikipedia.org/wiki/Fate_(role-playing_game_system)) to change acceleration of his/her cockroach. So some cockroaches will get negative acceleration and, than, speed, and will run back to the start line and further. But some of them should come to finish.
