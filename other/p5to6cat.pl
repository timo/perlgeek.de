#!/usr/bin/perl
use strict;
use warnings;
use Pod::Simple::HTML;
use File::Slurp qw(slurp);
use Encode qw(encode_utf8 decode_utf8);
use CGI qw(escapeHTML);
use autodie;

my $dest = '../source/article/5-to-6.html.en';
open my $out, '>:encoding(utf-8)', $dest;

print $out <<HEADER;
[% setvar section article %]
[% setvar title Perl 5 to Perl 6 %]
[% menu main article 5to6 %]

<h1>[% readvar title %]</h1>

<p>This collection of articles started out as a <a
href="http://perlgeek.de/blog-en/perl-5-to-6/">series of blog
posts</a>, and has been assembled here because it's easier to
read in the chronological order.</p> 

HEADER

my @titles;
my $content;
open my $body, '>', \$content;

for my $source (glob 'perl-5-to-6/*.pod'){
    next if $source =~ m{/10-where};
    my $num;
    if ($source =~ m{/(\d{2})}) {
        $num = $1;
    } else {
        die "Can't extract number from filename '$source'";
    }
    my $timestamp;
    my $html;
    my $parser = Pod::Simple::HTML->new();
    my $pod = decode_utf8(slurp($source));
    if ($pod =~ m/^=for\s+time\s+(\d{5,})/m) {
        $timestamp = $1;
    } else {
        die "No timestamp found for file '$source'";
    }
    $pod =~ s/^=for.*$//mg;
    $pod =~ s/^=head(\d)/'=head' . (2+$1)/meg;
    $parser->set_source(\$pod);
    $parser->output_string(\$html);
    $parser->do_middle();
    my $title = get_title($source);
    $titles[$num] = $title;
    print $body qq[<h2 id="post_$num">], escapeHTML($title), "</h2>\n";
    print $body qq[<p>]. gmtime($timestamp). qq[</p>\n];
    print $body $html;
    print $body "\n\n";
}

print $out qq[<h2>Table of Contents</h2>\n];
print $out qq[<ul>\n];
for (1..$#titles) {
    my $n = sprintf '%02d', $_;
    print $out qq[    <li><a href="#post_$n">],
               escapeHTML($titles[$_]), "</a></li>\n";

}
print $out qq[</ul>\n\n];
print $out $content;

print $out <<FOOTER;

[% comment vim: set ft=html nomodifiable : %]
FOOTER

sub get_title {
    my $fn = shift;
    open my $file, '<', $fn or die "Can't open '$fn' for reading: $!";
    while (<$file>) {
        chomp;
        if (m/ - /) {
            return +(split m/ - /, $_, 2)[1];
        }
    }
}

