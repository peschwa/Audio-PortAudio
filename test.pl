use v6;

use NativeCall;
use Audio::PortAudio;

constant SAMPLE_RATE = 48000e0;
constant FRAMES_PER_BUFFER = 256;

constant TABLE_SIZE = 100;
my num32 $numTS = 100e0;
my num32 $piapp = 3.14159e0;
my num32 $two = 2e0;

my $err = Pa_Initialize;
say "init: " ~ Pa_GetErrorText($err);
my $stream = CArray[OpaquePointer].new;
$stream[0] = OpaquePointer.new;

say "device id: " ~ Pa_GetDefaultOutputDevice;
say "device count: " ~ Pa_GetDeviceCount;

sub callback(OpaquePointer $in, OpaquePointer $out, int $frames,
    OpaquePointer $timeinfo, int $flags, OpaquePointer $userdata) returns int {
    my $outarr = nativecast(CArray[num32], $out);
    for ^$frames {
        my num32 $x = (-.5 + $_ / $frames);
        $outarr[$_] = $x;
    }
    0;
}

$err = Pa_OpenDefaultStream($stream, 0, 2, 1, SAMPLE_RATE, FRAMES_PER_BUFFER, Nil, Nil);
say "open: " ~ Pa_GetErrorText($err);

say "stream is $stream, stream[0] is $stream[0]";

$err = Pa_StartStream($stream[0]);
say "start: " ~ Pa_GetErrorText($err);

my CArray[num32] $sine .= new;
for ^TABLE_SIZE {
    my num32 $v = sin( $piapp * $two * $_ / $numTS );
    $sine[$_] = $v;
}

my int $left-phase = 0;
my int $right-phase = 0;

my CArray[num32] $left .= new;
my CArray[num32] $right .= new;

my CArray[CArray[num32]] $buffer .= new;
$buffer[0] = $left;
$buffer[1] = $right;

my CArray[CArray[CArray[num32]]] $ptr .= new;
$ptr[0] = $buffer;

my int $j = 0;
my int $i = 0;
while $j < (2 * SAMPLE_RATE / FRAMES_PER_BUFFER) {
    while $i < FRAMES_PER_BUFFER {
        $left[$i] = $sine[$left-phase];
        $right[$i] = $sine[$right-phase];
        $left-phase += 1;
        $right-phase += 3;
        $left-phase -= TABLE_SIZE if $left-phase >= TABLE_SIZE;
        $right-phase -= TABLE_SIZE if $right-phase >= TABLE_SIZE;
        $i += 1;
    }

    $err = Pa_WriteStream($stream[0], $ptr, FRAMES_PER_BUFFER);
    say "write: " ~ Pa_GetErrorText($err) if $err != 0;
    $j += 1;
}


$err = Pa_CloseStream( $stream[0] );
say "close: " ~ Pa_GetErrorText($err);

$err = Pa_Terminate;
say "terminate: " ~ Pa_GetErrorText($err);

