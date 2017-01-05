# FinanceQuoteNaftemporiki
Module for the Perl Finance::Quote module that retrieves quotes from http://www.naftemporiki.gr.

To make this work within GnuCash, you need to:

1/add the naftemporiki.pm file in the Finance/Quote/ folder within your perl modules directory

2/add an environment variable named FQ_LOAD_QUOTELET with the value "-defaults NAFTEMPORIKI"

As an example the following should work at the command line if all is installed correctly:

    perl gnc-fq-dump naftemporiki ALFDD.MTF

Within GnuCash, in the security editor, select Get Online Quotes and then Other, "naftemporiki" should be an option.