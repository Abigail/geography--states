package Geography::States;

#
# $Id: States.pm,v 1.2 1999/09/10 17:12:05 abigail Exp abigail $
#
# $Log: States.pm,v $
# Revision 1.2  1999/09/10 17:12:05  abigail
# Added a 'require 5.005' due to the use of INIT.
#
# Revision 1.1  1999/09/09 07:33:54  abigail
# Initial revision
#
#


use strict;

require 5.005;  # Because of the INIT.

use vars qw /$VERSION/;

($VERSION) = '$Revision: 1.2 $' =~ /([\d.]+)/;

my (%states);

sub _c_length ($) {2}  # Might change for other countries.

sub _norm ($$) {
    my ($str, $country) = @_;
    if (_c_length ($country) == length $str) {
        $str =  uc $str;
    }
    else {
        $str =  join " " => map {ucfirst lc} split /\s+/ => $str;
        $str =~ s/\bOf\b/of/         if $country eq lc 'USA';
        $str =~ s/\bD([eo])\b/d$1/   if $country eq lc 'Brazil';
    }

    $str;
}

INIT {
    my $country;
    while (<DATA>) {
        chomp;
        last if $_ eq '__END__';
        s/#.*//;
        next unless /\S/;
        if (/^<(.*)>/) {
            $country =  lc $1;
            $country =~ s/\s+/ /g;
            next;
        }
        my ($code, $state) = split /\s+/ => $_, 2;
        next unless defined $state;
        my $fake = $code =~ s/\*$//;
        my $info = [$code, $state, $fake];
        $states {$country} -> {_norm ($code,  $country)} = $info;
        $states {$country} -> {_norm ($state, $country)} = $info;
    }
}

sub new {
    die "Not enough arguments for Geography::States -> new ()\n" unless @_ > 1;

    my $proto   =  shift;
    my $class   =  ref $proto || $proto;

    my $country =  lc shift;
       $country =~ s/\s+/ /g;

    die "No such country $country\n" unless $states {$country};

    my $strict  =  shift;

    my $self;
    my ($cs, $info);
    while (($cs, $info) = each %{$states {$country}}) {
        next unless $cs eq $info -> [0];
        next if $strict && $info -> [2];
        my $inf = [@$info [0, 1]];
        $self -> {cs} -> {$info -> [0]} = $inf;
        $self -> {cs} -> {$info -> [1]} = $inf;
    }
    $self -> {country} = $country;

    bless $self => $class;
}


sub state {
    my $self = shift;
    unless (@_) {
        my %h;
        return grep {!$h {$_} ++} values %{$self -> {cs}};
    }
    my $query  =  _norm shift, $self -> {country};
    my $answer =  $self -> {cs} -> {$query} or return;
    return @$answer if wantarray;
    $answer -> [$answer -> [0] eq $query ? 1 : 0];
}

    
<<'=cut'
=pod

=head1 NAME

Geography::States  --  Map states and provinces to their codes, and vica versa.

=head1 SYNOPSIS

    use Geography::States;

    my $obj = Geography::States -> new (COUNTRY [, STRICT]);


=head1 EXAMPLES

    my $canada = Geography::States -> new ('Canada');

    my  $name          =  $canada -> state 'NF';      # Newfoundland.
    my  $code          =  $canada -> state 'Ontario'; # ON.
    my ($code, $name)  =  $canada -> state 'BC';      # BC, British Columbia.
    my  @all_states    =  $canada -> state;           # List of code/name pairs.


=head1 DESCRIPTION

This module lets you map states and provinces to their codes, and codes 
to names of provinces and states.

The C<Geography::States -> new ()> call takes 1 or 2 arguments. The first,
required, argument is the country we are interested in. Current supported
countries are I<USA>, I<Brazil>, I<Canada>, and I<The Netherlands>. If a
second non-false argument is given, we use I<strict mode>. In non-strict
mode, we will map territories and alternative codes as well, while we do
not do that in strict mode. For example, if the country is B<USA>, in 
non-strict mode, we will map B<GU> to B<Guam>, while in strict mode, neither
B<GU> and B<Guam> will be found.

=head2 The state() method

All queries are done by calling the C<state> method in the object. This method
takes an optional argument. If an argument is given, then in scalar context,
it will return the name of the state if a code of a state is given, and the
code of a state, if the argument of the method is a name of a state. In list
context, both the code and the state will be returned.

If no argument is given, then the C<state> method in list context will return
a list of all code/name pairs for that country. In scalar context, it will
return the number of code/name pairs. Each code/name pair is a 2 element
anonymous array.

Arguments can be given in a case insensitive way; if a name consists of 
multiple parts, the number of spaces does not matter, as long as there is
some whitespace. (That is "NewYork" is wrong, but S<"new    YORK"> is fine.)

=head1 ODDITIES AND OPEN QUESTIONS

I found conflicting abbreviations for the US I<Northern Mariana Islands>,
listed as I<NI> and I<MP>. I picked I<MP> from the USPS site. 

One site listed I<Midway Islands> as having code I<MD>. It is not listed by
the USPS site, and because it conflicts with I<Maryland>, it is not put in
this listing.

The USPS also has so-called I<Military "States">, with non-unique codes.
Those are not listed here.

Canada's I<Quebec> has two codes, the older I<PQ> and the modern I<QC>. Both
I<PQ> and I<QC> will map to I<Quebec>, but I<Quebec> will only map to I<QC>.
With strict mode, I<PQ> will not be listed.

=head1 REVISION HISTORY

    $Log: States.pm,v $
    Revision 1.2  1999/09/10 17:12:05  abigail
    Added a 'require 5.005' due to the use of INIT.

    Revision 1.1  1999/09/09 07:33:54  abigail
    Initial revision


=head1 AUTHOR

This package was written by Abigail, abigail@delanet.com.

=head1 COPYRIGHT and LICENSE

This package is copyright 1999 by Abigail.

This program is free and open software. You may use, copy, modify,
distribute and sell this program (and any modified variants) in any way
you wish, provided you do not restrict others to do the same.

=cut

__DATA__
# Information from USPS Abbreviations.
<USA>
AK	Alaska
AL	Alabama
AR	Arkansas
AS*     American Samoa
AZ	Arizona
CA	California
CO	Colorado
CT	Connecticut
DC*     District of Columbia
DE	Delaware
FL	Florida
FM*     Federate States of Micronesia
GA	Georgia
GU*     Guam
HI	Hawaii
IA	Iowa
ID	Idaho
IL	Illinois
IN	Indiana
KS	Kansas
KY	Kentucky
LA	Louisiana
MA	Massachusetts
MD	Maryland
ME	Maine
MH*     Marshall Islands
MI	Michigan
MN	Minnesota
MO	Missouri
# I found this listed as NI as well; which makes more sense.
MP*     Northern Mariana Islands
MS	Mississippi
MT	Montana
# The USPS site doesn't list this, and MD is already taken.
# MD*     Midway Islands
NC	North Carolina
ND	North Dakota
NE	Nebraska
NH	New Hampshire
NJ	New Jersey
NM	New Nexico
NV	Nevada
NY	New York
OH	Ohio
OK	Oklahoma
OR	Oregon
PA	Pennsylvania
PR*     Puerto Rico
PW*     Palau
RI	Rhode Island
SC	South Carolina
SD	South Dakota
TN	Tennessee
TX	Texas
UT	Utah
VA	Virginia
VI*     Virgin Islands
VT	Vermont
WA	Washington
WI	Wisconsin
WV	West Virginia
WY	Wyoming
<Brazil>
AC	Acre
AL	Alagoas
AM	Amazonas
AP	Amapa
BA	Baia
CE	Ceara
DF	Distrito Federal
ES	Espirito Santo
FN	Fernando de Noronha
GO	Goias
MA	Maranhao
MG	Minas Gerais
MS	Mato Grosso do Sul
MT	Mato Grosso
PA	Para
PB	Paraiba
PE	Pernambuco
PI	Piaui
PR	Parana
RJ	Rio de Janeiro
RN	Rio Grande do Norte
RO	Rondonia
RR	Roraima
RS	Rio Grande do Sul
SC	Santa Catarina
SE	Sergipe
SP	Sao Paulo
TO	Tocatins
<Canada>
AB	Alberta
BC	British Columbia
MB	Manitoba
NB	New Brunswick
NF	Newfoundland
NS	Nova Scotia
NT	Northwest Territories
ON	Ontario
PE	Prince Edward Island
PQ*     Quebec
QC	Quebec
SK	Saskatchewan
YT	Yukon Territory
<The Netherlands>
DR      Drente
FL      Flevoland
FR      Friesland
GL      Gelderland
GR      Groningen
LB      Limburg
NB      Noord Brabant
NH      Noord Holland
OV      Overijssel
UT      Utrecht
ZH      Zuid Holland
ZL      Zeeland
__END__
