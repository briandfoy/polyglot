# $Id$
use ExtUtils::MakeMaker;

sub ExtUtils::MM_Any::test_via_harness
		{
		my($self, $perl, $tests) = @_;

		return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
		}

WriteMakefile(
    'NAME'		    => 'Polyglot',
    'VERSION_FROM'	=> 'lib/Polyglot.pm',

    'PREREQ_PM'		=> {
		'File::Find::Rule' => '0',
		'Test::Manifest'   => '0.91',
		'Test::More'       => '0',
		'Test::Pod'        => '0.90',
    	},
    
    'MAN3PODS'      => {
    	'lib/Polyglot.pm'  => '$(INST_MAN3DIR)/Polyglot.3',
    	},
    	
    'clean' => { FILES => 'Polyglot-*' },
	);
