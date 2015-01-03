use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.14";

WriteMakefile(
    'NAME'		    => 'Polyglot',
	'ABSTRACT'      => 'a little language interpreter',
    'VERSION_FROM'	=> 'lib/Polyglot.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',

    'PREREQ_PM'		=> {
		'Test::More'       => '0',
    	},

    'MAN3PODS'      => {
    	'lib/Polyglot.pm'  => '$(INST_MAN3DIR)/Polyglot.3',
    	},

    'clean' => { FILES => 'Polyglot-*' },
	);
