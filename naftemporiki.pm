#!/usr/bin/perl -w
#########################################################################
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################
require 5.005;

use strict;

package Finance::Quote::NAFTEMPORIKI;

use vars qw( $WEBQUERY_URL);

use Encode;
use LWP::UserAgent;
use HTTP::Request::Common;

our $VERSION = '1.0'; # VERSION

my $WEBQUERY_URL = 'http://www.naftemporiki.gr/finance/UpdateQuoteValues.ashx?symbols=_QUOTE%2C&fields=qaEnhLastHTML%2CqaTradeDateTime24Big%2CPMain_h1SymbolName%2CqaBuyHTML%2CqaSellHTML%2CqaEnhNetChange%2CqaEnhPctChange';


sub methods {
	return (
		naftemporiki	=> \&naftemporiki,
		greece			=> \&naftemporiki,
		europe			=> \&naftemporiki
	);
}
{
	my @labels = qw/name last date isodate p_change open high low close volume currency method exchange/;

	sub labels {
		return (
			greece 		 => \@labels,
			naftemporiki => \@labels,
			europe 		 => \@labels
		);
	}
}

sub naftemporiki {

	my $quoter = shift;
	my @stocks = @_;
	my (%info, $reply, $url, $q, $id);
	my $ua = $quoter->user_agent();

	$url = $WEBQUERY_URL ;

	foreach my $stocks (@stocks)
	{
		$url = $WEBQUERY_URL =~ s/_QUOTE/$stocks/r;
		
		$reply = $ua->request(GET $url);
		
		if ($reply->is_success)
		{
			my @words = split /~/, $reply->content =~ s/\|//r;
			
			$info{$stocks, "success"}   = 1;
			$info{$stocks, "exchange"}  = "ASE";
			$info{$stocks, "method"}    = "naftemporiki";
			$info{$stocks, "symbol"}    = @words[8];
			($info{$stocks, "last"}     = @words[9]) =~ s/,/./g;
			($info{$stocks, "bid"}      = @words[10]) =~ s/,/./g;
			($info{$stocks, "ask"}      = @words[11]) =~ s/,/./g;
			($info{$stocks, "change"}   = @words[12]) =~ s/,/./g;
			($info{$stocks, "p_change"} = @words[13]) =~ s/,/./g;
			($info{$stocks, "cap"}      = @words[14]) =~ s/,/./g;
			
			$quoter->store_date(\%info, $stocks, {eurodate => @words[10]});

			$info{$stocks,"currency"}="EUR";

		} else {
     		$info{$stocks, "success"}=0;
			$info{$stocks, "errormsg"}="Error retreiving $stocks ";
		}
 }
 return wantarray() ? %info : \%info;
 return \%info;
}
1;

=head1 NAME

Finance::Quote::NAFTEMPORIKI Obtain quotes from www.naftemporiki.gr.

=head1 SYNOPSIS

    use Finance::Quote;

    $q = Finance::Quote->new;

    %info = Finance::Quote->fetch("naftemporiki","ALFDD.MTF");  # Only query naftemporiki
    %info = Finance::Quote->fetch("greece","ALFDD.MTF"); # Failover to other sources OK.

=head1 DESCRIPTION

This module fetches information from "Naftemporiki",
http://www.naftemporiki.gr. All stocks are available.

This module is loaded by default on a Finance::Quote object. It's
also possible to load it explicity by placing "NAFTEMPORIKI" in the argument
list to Finance::Quote->new().

This module provides both the "naftemporiki" and "greece" fetch methods.
Please use the "greece" fetch method if you wish to have failover
with future sources for Greek stocks. Using the "naftemporiki" method
will guarantee that your information only comes from www.naftemporiki.gr.

Information obtained by this module may be covered by www.naftemporiki.gr
terms and conditions See http://www.naftemporiki.gr for details.

=head1 LABELS RETURNED

The following labels may be returned by Finance::Quote::NAFTEMPORIKI :
name, last, date, p_change, open, high, low, close,
volume, currency, method, exchange.

=head1 SEE ALSO

Naftemporiki, http://www.naftemporiki.gr

=cut
