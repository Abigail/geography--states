use ExtUtils::MakeMaker;
require 5.005;  # Silly hack.  Can I have that in WriteMakefile somehow?
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Geography::States',
    'VERSION_FROM' => 'States.pm', # finds $VERSION
);
