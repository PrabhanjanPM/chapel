#!/usr/bin/perl

use File::Basename;

$utildirname = dirname($0);

my $flag = $ARGV[0];

$preset_launcher=$ENV{'CHPL_LAUNCHER'};

if ($preset_launcher eq "") {
    $comm = `$utildirname/comm.pl --target`; chomp($comm);
    $substrate = `$utildirname/commSubstrate.pl`; chomp($substrate);
    $platform = `$utildirname/platform.pl --target`; chomp($platform);

    $launcher = "none";
    if ($comm eq "gasnet") {
        if ($substrate eq "udp") {
            $launcher = "amudprun";
        } elsif ($substrate eq "portals") {
            $launcher = "aprun";
        } elsif ($substrate eq "ibv") {
	    if ($platform eq "pwr6") {
#
# our loadleveler launcher is not yet portable/stable/flexible enough
# to serve as a good default
#
#		$launcher = "loadleveler";
                $launcher = "none";
	    } else {
		$launcher = "gasnetrun_ibv";
	    }
	} elsif ($substrate eq "lapi") {
#
# our loadleveler code doesn't seem compatible with a pwr5 version
# of loadleveler yet
#
#	    $launcher = "loadleveler";
            $launcher = "none";
	}
    } elsif ($comm eq "armci") {
        if ($substrate eq "mpi") {
            $launcher = "mpirun";
        }
    } elsif ($platform eq "xmt-sim") {
	$launcher = "zebra";
    } elsif ($platform eq "x1-sim" || $platform eq "x2-sim") {
      $launcher = "apsim";
    } elsif ($comm eq "mpi") {
        $launcher = "mpirun";
    } elsif ($comm eq "pvm") {
	$launcher = "pvm";
    }
} else {
    $launcher = $preset_launcher;
}

print "$launcher\n";
exit(0);
