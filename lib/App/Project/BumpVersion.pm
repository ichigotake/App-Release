package App::Project::BumpVersion;
use 5.008001;
use strict;
use warnings;
use ExtUtils::MakeMaker qw(prompt);
use version;
use Version::Next;
use App::Project::Logger;

sub new {
    my $class = shift;
    return bless {@_}, $class;
}

sub run {
    my ($self, $current_version, $opts) = @_;
    my $validate = $opts->{validate} || 0;
    $current_version //= '0.1';

    my $is_valid = version::is_lax($current_version);
    if ($validate) {
        return $is_valid ? $current_version : undef;
    }
    if (!$is_valid) {
        errorf("Sorry, version '%s' is invalid.  Stopping.\n", $current_version);
    }
    return $self->default_new_version($current_version);
}

sub default_new_version {
    my ($self, $version) = @_;
    @_ == 2 or die;

    if (not exists_tag($version)) {
        $version;
    } else {
        return Version::Next::next_version("$version");
    }
}

sub exists_tag {
    my ( $tag ) = @_;

    my $x = `git tag -l $tag`;
    chomp $x;
    return !!$x;
}


1;
