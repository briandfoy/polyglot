# $Id$
package Polyglot;
use strict;
use vars qw($VERSION);

=head1 NAME

Polyglot - a little language interpreter

=head1 SYNOPSIS

	use Polyglot;

	my $interpreter = Polyglot->new();


	$interpreter->run();

=head1 DESCRIPTION

=cut

use autouse 'Data::Dumper' => 'Dumper';

use Carp qw(carp);
use Text::ParseWords qw( quotewords );

$VERSION = '0.05';

my $Debug = $ENV{DEBUG} || 0;

=head2 METHODS

=over 4

=item new



=cut

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

=item run


=cut

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

=item state


=cut

sub state  { 'state' }

=item action

=cut

sub action { 'action' }


=item add


=cut

sub add
	{
	my( $self, $name, $state, $sub, $value, $help ) = @_;

	$self->{$name} = [ $state, $sub, $help ];

	$self;
	}

=item value


=cut

sub value
	{
	my( $self, $name, $value ) = @_;
	carp "Setting $name with $value\n" if $Debug;

	return unless exists $self->{ $name };

	return $self->{$name}[2] unless defined $value;

	$self->{$name}[2] = $value;

	}

=item add_action


=cut

sub add_action
	{
	my $self = shift;
	my $name = uc shift;
	my( $sub, $value, $help ) = @_;

	$self->{$name} = [ $self->action, $sub, $value, $help ];

	$self;
	}

=item add_state


=cut

sub add_state
	{
	my $self = shift;
	my $name = uc shift;
	my( $value, $help ) = @_;

	$self->{$name} = [ $self->state,
		sub{ my $self = shift; $self->value( $name, @_ ) }, $value, $help ];

	$self;
	}

=item add_toggle

=cut

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

=item directives


=cut

sub directives
	{
	my $self = shift;

	return sort keys %$self;
	}

=back

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

        https://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, E<lt>bdfoy@cpan.orgE<gt>.

=head1 COPYRIGHT and LICENSE

Copyright 2003, brian d foy, All rights reserved

This software is available under the same terms as perl.

=cut

"ein";
