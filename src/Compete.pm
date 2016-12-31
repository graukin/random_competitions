package Compete;

use warnings;
use strict;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(pair_competition read_participants);
%EXPORT_TAGS = ( DEFAULT => [qw(&pair_competiion)] );

sub read_participants {
# in:
# path - path to file
# out:
# map - map of participants, ordered
    my ( $path ) = @_;
    open my $INFILE, $path or die "Couldn't open file $path.";
    my %participants;
    print "Participants:\n";
    while ( my $line = <$INFILE> ) {
        $line =~ /(\d+) (.*)/;
        print " [$1] - [$2]\n";
        $participants{$1} = $2;
    }
    return \%participants;
}

##################################################################################################
############################## Kakerlaken ########################################################
##################################################################################################

my @brick = qw( 1 -1 0 0 -1 1 );

sub next_accel {
    my ( $a ) = @_;
    my $msg = "";
    for my $i (1..3)
    {
        my $br = $brick[int(rand(6))];
        $msg .= "+ " if $br > 0;
        $msg .= "- " if $br < 0;
        $msg .= "0 " if $br eq 0;
        $a += 0.25 * $br;
    }
    printf (" %10s", $msg);
    return $a;
}

sub max ($$) { $_[$_[0] < $_[1]] }

sub kakerlaken {
# in:
# players - hash-ref, (id - player)
# out:
# winner
    my ( $p_ref ) = @_;
    print "Run!!!\n";
    
    my %table;
    my @keys = sort(keys $p_ref);

    printf ("%5s ", "name:");
    for my $key ( @keys )
    {
        printf ("%10s ", $p_ref->{$key});
        $table{$key}{a}=0;
        $table{$key}{v}=1;
        $table{$key}{x}=0;
    }
    for (my $i = 0; $i < 6; $i ++)
    {
        printf ("\n%5s ", "X:");
        printf ("%10d ", $table{$_}{x}) for @keys;
        printf ("\n%5s ", "v:");
        printf ("%10d ", $table{$_}{v}) for @keys;
        printf ("\n%5s ", "a:");
        printf ("%10.2f ", $table{$_}{a}) for @keys;
        printf ("\n%5s ", "a:");
        for my $key ( @keys )
        {
            my $dx = $table{$key}{v}*10 + $table{$key}{a}*50;
            $table{$key}{v} = $table{$key}{v} + $table{$key}{a}*10;
            $table{$key}{x} = $table{$key}{x} + $dx;
            $table{$key}{a} = next_accel($table{$key}{a});
        }
        sleep 1;
    }
    my $max_key = 0;
    my $max_d = 0;
    for my $key ( @keys )
    {
        if ( $table{$key}{x} > $max_d )
        {
            $max_d = $table{$key}{x};
            $max_key = $key;
        }
    }
    print "\n";
    return $p_ref->{$max_key};
}

##################################################################################################
############################## table competitions ################################################
##################################################################################################

sub pair_competition {
# in:
# p1 - 1st player's id
# p2 - 2nd player's id
# out:
# result struct
    my ( $p1, $p2 ) = @_;
    my %results;
#    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
#    my $seed = $p1.$sec.$min.$p2;
#    srand($seed);
    my $max_tour = 1 + int(rand(10));
    my $sc1 = 0;
    my $sc2 = 0;
    for ( my $i = 0; $i < $max_tour; $i++ )
    {
        my $a = rand(100);
        my $d = rand(100);
        if ( $a > 50 and $a > $d and $d < 50)
        {
            $sc1 ++;
        }
        $a = rand(100);
        $d = rand(100);
        if ( $a > 50 and $a > $d and $d < 50)
        {
            $sc2 ++;
        }
    }
    $results{$p1} = $sc1;
    $results{$p2} = $sc2;
    if ( $sc1 > $sc2 )
    {
        $results{$p1."s"} = "w";
        $results{$p2."s"} = "l";
    }
    else
    {
        if ( $sc1 == $sc2 )
        {
            $results{$p1."s"} = "n";
            $results{$p2."s"} = "n";
        }
        else
        {
            $results{$p1."s"} = "l";
            $results{$p2."s"} = "w";
        }
    }
    return \%results;
}

##################################################################################################
########################################### playoff ##############################################
##################################################################################################

sub is_power_of_2 {
  return 0 unless $_[0]>0; # to avoid log error
  log($_[0])/log(2) - int(log($_[0])/log(2)) ? 0 : 1; 
}

sub playoff {
# in:
# players - hash-ref, (id - player)
# out:
# winner
    my ( $p_ref ) = @_;
    print "Use playoff.\n";
    my @keys = sort(keys $p_ref);

    if ( not is_power_of_2 ( scalar @keys ) )
    {
        die "ERROR: ".( scalar @keys )." is not power of 2\n";
    }

    do
    {
        print "Next round. Participants: @keys\n";
        sleep 1;
        my @winners;
        while ( scalar @keys > 0 )
        {
            my $id1 = shift @keys;
            my $id2 = shift @keys;
            print "$id1 vs $id2: ";
            my $winner = 0;
            while ( $winner == 0 )
            {
                my $result = pair_competition( $id1, $id2 );
                $winner = $id1 if $result->{$id1."s"} eq "w";
                $winner = $id2 if $result->{$id2."s"} eq "w";
                print "$result->{$id1}-$result->{$id2} ";
            }
            print "\n";
            push @winners, $winner;
        }
        @keys = @winners;
    } while ( scalar @keys > 1 );
    return $p_ref->{$keys[0]};
}

##################################################################################################
########################################### roundrobin ###########################################
##################################################################################################

sub roundrobin_tour {
# in:
# l1, l2 - lists of ids
# out:
# winners, ordered
    my ( $l1, $l2 ) = @_;
    my %results;
    for ( my $idx = 0; $idx < scalar @$l1; $idx ++)
    {
        my $g1 = $l1->[$idx];
        my $g2 = $l2->[$idx];
        if ( not exists $results{$g1} )
        {
            $results{$g1}{"+"} = 0;
            $results{$g1}{"-"} = 0;
            $results{$g1}{st_w} = 0;
            $results{$g1}{st_n} = 0;
            $results{$g1}{st_l} = 0;
        }
        if ( not exists $results{$g2} )
        {
            $results{$g2}{"+"} = 0;
            $results{$g2}{"-"} = 0;
            $results{$g2}{st_w} = 0;
            $results{$g2}{st_n} = 0;
            $results{$g2}{st_l} = 0;
        }
        my $res = pair_competition( $g1, $g2 );

        printf( "%2d vs %2d :: %2d - %-2d\n", $g1, $g2, $res->{$g1}, $res->{$g2});

        $results{$g1}{"+"} += $res->{$g1};
        $results{$g1}{"-"} += $res->{$g2};
        $results{$g2}{"+"} += $res->{$g2};
        $results{$g2}{"-"} += $res->{$g1};
        $results{$g1}{"st_".$res->{$g1."s"}} ++;
        $results{$g2}{"st_".$res->{$g2."s"}} ++;
    }
    return \%results;
}

sub roundrobin {
# in:
# players - hash-ref, (id - player)
# out:
# winner
    my ( $p_ref ) = @_;
    print "Use roundrobin.\n";
    my %table;
    my @keys1 = sort(keys $p_ref);
    my @keys2 = sort(keys $p_ref);
    for my $key ( @keys1 )
    {
        $table{$key}{"+"} = 0;
        $table{$key}{"-"} = 0;
        $table{$key}{st_w} = 0;
        $table{$key}{st_n} = 0;
        $table{$key}{st_l} = 0;
    }

    do
    {
        push @keys2,(shift @keys2); # rotate 1
        my $results = roundrobin_tour( \@keys1, \@keys2 );
        for my $key ( @keys1 )
        {
            my $map = $results->{$key};
            $table{$key}{"+"} += $map->{"+"};
            $table{$key}{"-"} += $map->{"-"};
            $table{$key}{st_w} += $map->{st_w};
            $table{$key}{st_n} += $map->{st_n};
            $table{$key}{st_l} += $map->{st_l};
        }
        sleep 1;
    } while ( $keys1[0] != $keys2[1] );

    printf( "%2s. %10s | %2s | %2s | %2s | %3s - %3s | %3s\n", "#", "name", "w", "n", "l", "g", "f", "b");
    my $max_key = "";
    my $max_value = 0;
    for my $key ( @keys1 )
    {
        $table{$key}{b} = 3*$table{$key}{st_w} + 1*$table{$key}{st_n};
        if ( $table{$key}{b} > $max_value )
        {
            $max_key = $key;
            $max_value = $table{$key}{b};
        }
        else
        {
            if ( $table{$key}{b} == $max_value )
            {
                if ( $table{$key}{st_w} > $table{$max_key}{st_w} )
                {
                    $max_key = $key;
                    $max_value = $table{$key}{b};
                }
                else
                {
                    my $d1 = $table{$key}{"+"} - $table{$key}{"-"};
                    my $d2 = $table{$max_key}{"+"} - $table{$max_key}{"-"};
                    if ( $d1 > $d2 )
                    {
                        $max_key = $key;
                        $max_value = $table{$key}{b};
                    }
                }
            }
        }
        printf( "%2d. %10s | %2d | %2d | %2d | %3d - %3d | %3d\n", $key, $p_ref->{$key}, $table{$key}{st_w}, $table{$key}{st_n}, $table{$key}{st_l}, $table{$key}{"+"}, $table{$key}{"-"}, $table{$key}{b});
    }
    return $p_ref->{$max_key};
}

1;
