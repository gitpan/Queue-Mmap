package Queue::Mmap;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.04';

require XSLoader;
XSLoader::load('Queue::Mmap', $VERSION);

sub new {
	my $class = shift;
	my %p;
	unless(@_ % 2){
		%p = @_;
	}elsif(UNIVERSAL::isa($_[0],"HASH")){
		%p = %{$_[0]};
	}else{
		die "bad params"
	}
	unless($p{file}){
		die "need filename";
	}
	$p{queue} ||= 100;
	$p{length} ||= 100;
	return bless queue_new(@p{'file','queue','length'}),$class;
}
sub push {
	my ($self,$val) = @_;
	return $self->queue_push($val);
}
sub pop {
	my $self = shift;
	return $self->queue_pop();
}
sub stat {
	my $self = shift;
	return $self->queue_pos();
}
sub length {
	my $self = shift;
	return $self->queue_len();
}
sub DESTROY {
	my $self = shift;
	$self->queue_free;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Queue::Mmap - Perl extension for shared queue over mmap-ed file

=head1 SYNOPSIS

	use Queue::Mmap;
	my $q = new Queue::Mmap(
		file=> "file.dat",
		queue => 10,
		length => 20,
	);
	unless($q->push("abcdefghijklmnopqrstuvwxyz")){
		die "fail push";
	}

	print "length of queue is ",$q->length,"\n";

	while(defined(my $v = $q->pop)){
		print $v,"\n";
	}
	print "no data\n";

=head1 DESCRIPTION

Queue::Mmap - Shared circled queue over mmap-ed file.

Usefull for multy process task queue.
One process(es) push task message, and other process(es) pop and execute that tasks.
Access with locking(fcntl) guaranted right order.
If pushed data has size greater that capacity push has return undef.
Tested only on linux.

Length of record align for 4 bytes.
Length of file align for 4k.

=head2 EXPORT

None by default.

=head1 SEE ALSO


=head1 AUTHOR

Ildar Efremov, E<lt>iefremov@2reallife.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Ildar Efremov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
