#!/usr/bin/perl


use strict;
use warnings;

package Product;
sub new{
	my ($class,$args) = @_;
	my $self = bless { serial => $args->{serial},
										 name   => $args->{name}  ,
										 price  => $args->{price}  
									 }, $class;
}

sub get_name{
	my $self = shift;		# always talks to @_?
	return $self->{name};
}

sub set_name{
	my ($self,$name) = @_;
	$self->{name} = ${name};
}
1;
