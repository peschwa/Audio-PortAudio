use v6;

use NativeCall;
use Audio::PortAudio; 

my $err = Pa_Initialize; 
say "init: " ~ Pa_GetErrorText($err);
my $stream = CArray[OpaquePointer].new;
$stream[0] = OpaquePointer.new;

say "device id: " ~ Pa_GetDefaultOutputDevice;
say "device count: " ~ Pa_GetDeviceCount;

sub callback(CArray[num] $in, CArray[num] $out, int $frames, PaStreamCallbackTimeInfo $timeinfo, int $flags, CArray $userdata) {
    for ^$frames {
        $out[$_] = -.5 + $_ / $frames;
    }
}

$err = Pa_OpenDefaultStream($stream, 0, 2, 1, 44100e0, 256, &callback, CArray.new);
say "open: " ~ Pa_GetErrorText($err);

say "stream is $stream, stream[0] is $stream[0]";

$err = Pa_StartStream($stream);
say "start: " ~ Pa_GetErrorText($err);

sleep 5;

# do things here

$err = Pa_CloseStream( $stream );
say "close: " ~ Pa_GetErrorText($err);

$err = Pa_Terminate;
say "terminate: " ~ Pa_GetErrorText($err);

