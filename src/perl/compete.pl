#! /bin/perl

use Compete;
use Switch;

my $in_path = shift;

if ( $in_path eq "help" )
{
    print "Game types:\n".
          "  playoff (2^k participants)\n".
          "  roundrobin (k participants)\n".
          "  kakerlaken (k participants)\n";
    exit 0;
}

$participants_ref = Compete::read_participants( $in_path );

srand();

my $winner;
switch ( shift ) {
    case "playoff"    { $winner = Compete::playoff( $participants_ref ); }
    case "roundrobin" { $winner = Compete::roundrobin( $participants_ref ); }
    case "kakerlaken" { $winner = Compete::kakerlaken( $participants_ref ); }
    else              { print "Wrong competition type.\n"; exit 1; }
}

print "Winner is: $winner\n";

