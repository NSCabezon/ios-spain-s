#!C:\Program Files\Git\usr\bin\perl.exe
use strict;
use warnings;
use File::Path;
use JSON::Create 'create_json';
use Switch;
use Try::Catch;
use REST::Client;

################
#  Variables   #
################

# Common
my $line;
my $prefix;
my $out;
my $argumentsNumber = $#ARGV+1;

my $feature = "feature";
my $fix = "fix";
my $hotfix = "hotfix";
my $refactor = "refactor";

my @prefixes = ($feature, $fix, $hotfix, $refactor);

# Local
my $partialUrl = "- https://jira.alm.europe.cloudcenter.corp/browse/SANMOVPAR-";

my %headersMap = (
	$feature => "\n### User Story\n",
	$fix => "\n### Fix\n",
	$hotfix => "\n### Hotfix\n",
	$refactor => "\n### Refactor\n"
);

# API
my $jiraPrefix = "SANMOVPAR-";
my $jiraUser = "X310824";
my $jiraPassword = "2!WorlTo";

my $apiHost = "http://10.4.0.52:8082";
my $postChangeLog = "/api/changelog";

my %apiHeadersMap = (
	$feature => "Historias de usuario",
	$fix => "Fix",
	$hotfix => "Hotfix",
	$refactor => "Refactor"
);

my @features = ();
my @fixes = ();
my @hotfixes = ();
my @refactors = ();


################
#     Script   #
################

if ($argumentsNumber != 2){
			die "USAGE ERROR: Use 'gitMergeLogScript.pl <pathToLogs> <outputFileName>'";
}

print "\nSTARTING CHANGELOG SCRIPT ...\n";

if (-e $ARGV[0]){
	  try {
				generateApiChangelog();
		} catch {
				generateLocalChangelog();
		}
} else {
		print "ERROR: File doesn't exist, can't generate merge log code from  " . $ARGV[0] . "\n";
		abortScript();
}

print "\nCHANGELOG SCRIPT FINISHED\n\n";

################
#    Methods   #
################

sub generateApiChangelog(){
		foreach $prefix (@prefixes){
				my $printHeader = 1;
				open(my $in, '<', $ARGV[0]) or die "Can't read file: $!";

				while( defined (my $line = <$in>) ){
						#chomp delete scape simbols
						chomp $line;
						if ($line =~ m/Merge branch.+into.*(?:master|develop|release\/empleados)/){
									if ($line =~ /\b$prefix\b\/((?:#{0,1}\d+[_|-])+)+/g){
											 if ($printHeader){
													$printHeader = 0;
											 }
											 my $ids = $1;
											 $ids =~ s/#//g;
											 my @ids = split(/[_|-]/, $ids);
											 foreach (@ids){
													switch($prefix) {
															case ($feature) { push @features, $jiraPrefix . $_ }
															case ($fix) { push @fixes, $jiraPrefix . $_ }
															case ($hotfix) { push @hotfixes, $jiraPrefix . $_ }
															case ($refactor) { push @refactors, $jiraPrefix . $_ }
													}
											 }
									}
						}
				}
		}

		my %json = (
		  authentication => {
				user => $jiraUser,
				password => $jiraPassword
			},
			items => {
				$apiHeadersMap{$feature} => [@features],
				$apiHeadersMap{$fix} => [@fixes],
				$apiHeadersMap{$hotfix} => [@hotfixes],
				$apiHeadersMap{$refactor} => [@refactors]
		});

		my $client = REST::Client->new({
			host    => $apiHost,
			timeout => 30
    	});
		$client->addHeader("Content-Type", "application/json");
		my $response = $client->POST($postChangeLog, create_json (\%json));

		if ($response->responseCode() == 200){
			my $responseContent = $response->responseContent();
			print $responseContent;

			open(my $out, '>', $ARGV[1]) or die "Can't write new file: $!";
			print $out $responseContent;
			print $out "\n";
			close $out;
		} else {
			generateLocalChangelog()
		}
}

sub generateLocalChangelog {
		print "\nAPI Error -> generateLocalChangelog";

		open(my $out, '>', $ARGV[1]) or die "Can't write new file: $!";
		foreach $prefix (@prefixes){
				my $printHeader = 1;
				open(my $in, '<', $ARGV[0]) or die "Can't read file: $!";

				while( defined (my $line = <$in>) ){
						#chomp delete scape simbols
						chomp $line;
						if ($line =~ m/Merge branch.+into.*(?:master|develop|release\/empleados)/){
									if ($line =~ /\b$prefix\b\/((?:#{0,1}\d+[_|-])+)+/g){
											if ($printHeader){
													$printHeader = 0;
													print $headersMap{$prefix};
													print $out $headersMap{$prefix};
											}

											 my $ids = $1;
											 $ids =~ s/#//g;
											 my @ids = split(/[_|-]/, $ids);
											 foreach (@ids){
													print  $partialUrl . $_ . "\n";
													print  $out $partialUrl . $_ . "\n";
											 }
									}
						}
				}
		}
		close $out;
}

################
#     Utils    #
################

sub abortScript {
	die "... ABORTING SCRIPT ...";
}
