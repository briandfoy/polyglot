# $Id$
package Polyglot;

use strict;
use vars qw($VERSION);

use autouse 'Data::Dumper' => 'Dumper';

use Carp qw(carp);
use Text::ParseWords qw( quotewords );

$VERSION = '0.05';

my $Debug = $ENV{DEBUG} || 0;
	
sub new
	{
	my( $class, @args )  = @_;
	
	my $self = bless {}, $class;
	
	$self->add_action( 'HELP', sub { my $self = shift; $self->help( @_ ) } );
	$self->add_action( 'EXIT', sub { exit } );
	$self->add_action( 'REFLECT', sub { print Dumper( $_[0] ) } );
	$self->add_action( 'SHOW', sub { 
		my( $self, $name ) = ( shift, uc shift ); 
		print "$name = ", $self->value($name), "\n";
		$self; } );
	}
	
sub run
	{
	my $self = shift;
	
	my $prompt = "$0> ";
	
	print "Waiting for commands on standard input\n$prompt" unless @ARGV;
	
	while( <> )
		{
		chomp;
		next if /^\s*#?$/;
		my( $directive, $string ) = split /\s+/, $_, 2;
		
		$directive = uc $directive;
		carp "DEBUG: directive is $directive\n" if $Debug;
		
		my @arguments = quotewords( '\s+', 0, $string );
		carp "DEBUG: arguments are @arguments\n" if $Debug;
		
		eval {
			die "Undefined subroutine" unless exists $self->{$directive};
			$self->{$directive}[1]( $self, @arguments );
			};
			
		warn "Not a valid directive: [$directive] at $ARGV line $.\n"
			if $@ =~ m/Undefined subroutine/;
			
		print "$prompt" if $ARGV eq '-';
		}
	}
	
sub state  { 'state' }
sub action { 'action' }
sub rule   { '-' x 73 . "\n" }
	
sub add
	{
	my( $self, $name, $state, $sub, $value, $help ) = @_;
	
	$self->{$name} = [ $state, $sub, $help ];
	
	$self;
	}
	
sub value
	{
	my( $self, $name, $value ) = @_;
	carp "Setting $name with $value\n" if $Debug;
	
	return unless exists $self->{ $name };
		
	return $self->{$name}[2] unless defined $value;
		
	$self->{$name}[2] = $value;
	
	}
	
sub add_action 
	{ 
	my $self = shift;
	my $name = uc shift;
	my( $sub, $value, $help ) = @_;
	 
	$self->{$name} = [ $self->action, $sub, $value, $help ];
	
	$self;
	}
	
sub add_state  
	{ 
	my $self = shift;
	my $name = uc shift; 
	my( $value, $help ) = @_;

	$self->{$name} = [ $self->state, 
		sub{ my $self = shift; $self->value( $name, @_ ) }, $value, $help ]; 
	
	$self;
	}

sub add_toggle
	{
	my $self = shift;
	my $name = uc shift;
	my( $value, $help ) = @_;
	
	my $code = sub {
			my $self = shift;
			
			return $self->{$name}[2] unless @_;
			my $value = lc shift;
			warn "saw $name with value [$value]\n";
			
			unless( $value eq 'on' or $value eq 'off' )
				{
				warn "$name can be only 'on' or 'off', line $.\n";
				return
				}
				
			$self->{$name}[2] = $value;
			
			print "$name is [$$self{$name}[2]]\n";
			};
	
	$self->{$name} = [ $self->state, $code, $value, $help ];
	
	$self;
	}
	
sub help
	{
	my $self = shift;
	my $name = uc shift;
	
	print "This is a help message for [$name]\n";
	
	$self;
	}

sub directives
	{
	my $self = shift;
	
	return sort keys %$self;
	}
