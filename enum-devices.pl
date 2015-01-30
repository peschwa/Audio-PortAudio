use v6;

use Audio::PortAudio;
use NativeCall;

Pa_Initialize;

my int $num-devices = Pa_GetDeviceCount;
if $num-devices < 0 {
    die "no devices found";
}

my $dev = CArray[PaDeviceInfo].new;

for ^$num-devices {
    $dev = Pa_GetDeviceInfo($_);
    say "device numer: $_";
    say $dev[0].perl;
    say "=" x 12;
}
