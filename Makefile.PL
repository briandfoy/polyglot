# $Id$
use ExtUtils::MakeMaker;

eval "use Test::Manifest";

unless( $@ )
	{
	*ExtUtils::MM_Any::test_via_harness = sub
		{
		my($self, $perl, $tests) = @_;
		
		return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
		}
	}
	
WriteMakefile(
    'NAME'		    => 'Polyglot',
    'VERSION_FROM'	=> 'lib/Polyglot.pm',

    'PREREQ_PM'		=> {
		'Test::More'       => '0',
    	},
    
    'MAN3PODS'      => {
    	'lib/Polyglot.pm'  => '$(INST_MAN3DIR)/Polyglot.3',
    	},
    	
    'clean' => { FILES => 'Polyglot-*' },
	);
