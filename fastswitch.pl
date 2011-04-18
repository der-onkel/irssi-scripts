use Irssi;
use Irssi::Irc;
use strict;
use vars qw($VERSION %IRSSI);

# fastswitch provides the possibility to switch between your windows
# and query just by type /<WINDOW_NUMBER> or /<channle_name|queryname>
#
# If channel_name miss the prefix character the script will try to find a
# channel with one of this prefixes "#, +, & or !".
# To switch of this behavior set "fastswitch_guess_prefix" to 0

$VERSION = "0.1";

%IRSSI = (
	authors		=>	'Juergen Jung',
	contact		=>	'juergen@winterkaelte.de',
	name		=>	'fastswitch',
	description	=>	'This script provides a fast channel switch',
	license		=>	'BSD',
	url		=>	''
);

sub switch_window {
	my $command = shift;
	$command = (split(/\//,$command))[-1];
	if( $command =~ /^[0-9]+$/ ){
		Irssi::command("window ". $command);
		Irssi::signal_stop();
	}
	elsif( $command =~ /^\S+$/){
		if (Irssi::Server->window_find_item($command) ){
        	Irssi::command("window goto ".$command);
        	Irssi::signal_stop();
		}elsif(Irssi::settings_get_bool('fastswitch_guess_prefix')){
			my $regex = qr/^[#+&\!]\Q$command\E/;
			foreach my $channel (Irssi::channels()) {
				my $channel_name = $channel->{name};
				if($channel_name =~ $regex ){
					if(Irssi::Irc::Server->channel_find($channel_name)){
						Irssi::command("window goto ". $channel_name);
						Irssi::signal_stop();
						last;
					}
				}
			}
		}
	}
}

Irssi::signal_add_first("default command" => \&switch_window);

Irssi::settings_add_bool('fastswitch', 'fastswitch_guess_prefix', 1);
