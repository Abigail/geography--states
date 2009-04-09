package Geography::States;

#
# $Id: States.pm,v 1.6 2001/04/19 23:44:39 abigail Exp abigail $
#
# $Log: States.pm,v $
# Revision 1.6  2001/04/19 23:44:39  abigail
# Fixed syntax error in POD.
#
# Revision 1.5  2001/04/19 23:41:59  abigail
# + Document Australia is now supported.
# + Australia uses codes up to length 3, addapted _c_length for that.
# + Removed require, which was there for the INIT {}
#
# Revision 1.4  2001/04/19 23:33:32  abigail
# + Added data for Australia (Kirrily "Skud" Robert)
# + Removed INIT {}; doesn't work well with mod_perl (T.J. Mather)
# + Fixed typos/accents for Brazil (Steffen Beyer)
#
# Revision 1.3  2000/07/23 09:28:31  abigail
# Fixed dependency on hash ordering when mapping "Quebec" (it worked
#    in perl5.005, but failed in perl5.6).
# Fixed typos in state names (Ross Baker).
# Changed email address.
# Changed license to from free prose to X-style license.
#
# Revision 1.2  1999/09/10 17:12:05  abigail
# Added a 'require 5.005' due to the use of INIT.
#
# Revision 1.1  1999/09/09 07:33:54  abigail
# Initial revision
#
#


use strict;

use vars qw /$VERSION/;

($VERSION) = '$Revision: 1.6 $' =~ /([\d.]+)/;

my (%states);

sub _c_length ($) {
    lc $_ [0] eq "australia" ? 3 : 2
}

sub _norm ($$) {
    my ($str, $country) = @_;
    if (_c_length ($country) >= length $str) {
        $str =  uc $str;
    }
    else {
        $str =  join " " => map {ucfirst lc} split /\s+/ => $str;
        $str =~ s/\bOf\b/of/         if $country eq lc 'USA';
        $str =~ s/\bD([eo])\b/d$1/   if $country eq lc 'Brazil';
    }

    $str;
}

# This was originally wrapped in an INIT block, to avoid having it
# run when only compilation was wanted. However, that seems to fail
# when used in combination with mod_perl.
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
        foreach my $i (0 .. 1) {
            $self -> {cs} -> {$info -> [$i]} = $inf unless
                       exists $self -> {cs} -> {$info -> [$i]};
        }
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

    my  $name          =  $canada -> state ('NF');      # Newfoundland.
    my  $code          =  $canada -> state ('Ontario'); # ON.
    my ($code, $name)  =  $canada -> state ('BC');      # BC, British Columbia.
    my  @all_states    =  $canada -> state;             # List code/name pairs.


=head1 DESCRIPTION

This module lets you map states and provinces to their codes, and codes 
to names of provinces and states.

The C<Geography::States -> new ()> call takes 1 or 2 arguments. The
first, required, argument is the country we are interested in. Current
supported countries are I<USA>, I<Brazil>, I<Canada>, I<The Netherlands>,
and I<Australia>. If a second non-false argument is given, we use I<strict
mode>. In non-strict mode, we will map territories and alternative codes
as well, while we do not do that in strict mode. For example, if the
country is B<USA>, in non-strict mode, we will map B<GU> to B<Guam>,
while in strict mode, neither B<GU> and B<Guam> will be found.

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
    Revision 1.6  2001/04/19 23:44:39  abigail
    Fixed syntax error in POD.

    Revision 1.5  2001/04/19 23:41:59  abigail
    + Document Australia is now supported.
    + Australia uses codes up to length 3, addapted _c_length for that.
    + Removed require, which was there for the INIT {}

    Revision 1.4  2001/04/19 23:33:32  abigail
    + Added data for Australia (Kirrily "Skud" Robert)
    + Removed INIT {}; doesn't work well with mod_perl (T.J. Mather)
    + Fixed typos/accents for Brazil (Steffen Beyer)

    Revision 1.3  2000/07/23 09:28:31  abigail
    Fixed dependency on hash ordering when mapping "Quebec" (it worked
       in perl5.005, but failed in perl5.6).
    Fixed typos in state names (Ross Baker).
    Changed email address.
    Changed license to from free prose to X-style license.

    Revision 1.2  1999/09/10 17:12:05  abigail
    Added a 'require 5.005' due to the use of INIT.

    Revision 1.1  1999/09/09 07:33:54  abigail
    Initial revision


=head1 AUTHOR

This package was written by Abigail, abigail@foad.org.

=head1 COPYRIGHT and LICENSE

This package is copyright 1999, 2000, 2001 by Abigail.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

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
FM*     Federated States of Micronesia
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
NM	New Mexico
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
AP	Amapá
BA	Bahia
CE	Ceará
DF	Distrito Federal
ES	Espiríto Santo
FN	Fernando de Noronha
GO	Goiás
MA	Maranhão
MG	Minas Gerais
MS	Mato Grosso do Sul
MT	Mato Grosso
PA	Pará
PB	Paraíba
PE	Pernambuco
PI	Piauí
PR	Paraná
RJ	Rio de Janeiro
RN	Rio Grande do Norte
RO	Rondônia
RR	Roraima
RS	Rio Grande do Sul
SC	Santa Catarina
SE	Sergipe
SP	São Paulo
TO	Tocantins
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
# Supplied by Kirrily "Skud" Robert
<Australia>
ACT     Australian Capital Territory
NSW     New South Wales
QLD     Queensland
SA      South Australia
TAS     Tasmania
VIC     Victoria
WA      Western Australia
__END__
