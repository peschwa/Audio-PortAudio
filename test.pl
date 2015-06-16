use v6;

use NativeCall;
use Audio::PortAudio;

constant SAMPLE_RATE = 44100e0;
constant FRAMES_PER_BUFFER = 256;

constant TABLE_SIZE = 200;

my $err = Pa_Initialize;
say "init: " ~ Pa_GetErrorText($err);
my $stream = CArray[OpaquePointer].new;
$stream[0] = OpaquePointer.new;

# say "device id: " ~ Pa_GetDefaultOutputDevice;
# say "device count: " ~ Pa_GetDeviceCount;

#`[[
sub callback(OpaquePointer $in, OpaquePointer $out, int $frames,
    OpaquePointer $timeinfo, int $flags, OpaquePointer $userdata) returns int {
    my $outarr = nativecast(CArray[num32], $out);
    for ^$frames {
        my num32 $x = (-.5 + $_ / $frames);
        $outarr[$_] = $x;
    }
    0;
}
]]

# $err = Pa_OpenDefaultStream($stream, 0, 2, paFloat32 +| paNonInterleaved, SAMPLE_RATE, FRAMES_PER_BUFFER, Nil, Nil);

my $out-params = PaStreamParameters.new(:device(Pa_GetDefaultOutputDevice), :channel-count(2), 
    :sample-format(paFloat32 +| paNonInterleaved),
    :suggested-latency(0.05e0));
    #:suggested-latency(Pa_GetDeviceInfo(Pa_GetDefaultOutputDevice).default-low-output-latency));

$err = Pa_OpenStream($stream, PaStreamParameters, $out-params, SAMPLE_RATE, FRAMES_PER_BUFFER, paClipOff, CArray[Pointer]);
say "open: " ~ Pa_GetErrorText($err);

say "stream is $stream, stream[0] is $stream[0]";

$err = Pa_StartStream($stream[0]);
say "start: " ~ Pa_GetErrorText($err);

my CArray[num32] $wave .= new;

# sine
for ^TABLE_SIZE {
    my $v = sin( ($_ / TABLE_SIZE) * pi * 2);
    $wave[$_] = Num($v);
}

my Int $left-phase = 0;
my Int $right-phase = 0;

my CArray[CArray[num32]] $buffer .= new;
my CArray[num32] $left .= new;
my CArray[num32] $right .= new;

$buffer[0] = $left;
$buffer[1] = $right;

my Int $j = 0;
my Int $i = 0;
while $j < (2 * SAMPLE_RATE / FRAMES_PER_BUFFER) {
    while $i < FRAMES_PER_BUFFER {
        my $n-l = Num($wave[$left-phase]);
        $left[$i] = $n-l;
        $right[$i] = Num($wave[$right-phase]);
        $left-phase -= TABLE_SIZE if $left-phase >= TABLE_SIZE;
        $right-phase -= TABLE_SIZE if $right-phase >= TABLE_SIZE;
        $left-phase += 1;
        $right-phase += 3;

        $i += 1;
    }
    $i = 0;

    $err = Pa_WriteStream($stream[0], $buffer, FRAMES_PER_BUFFER);
    # say "write: " ~ Pa_GetErrorText($err) if $err != 0;
    $j += 1;
}


$err = Pa_CloseStream( $stream[0] );
say "close: " ~ Pa_GetErrorText($err);

$err = Pa_Terminate;
say "terminate: " ~ Pa_GetErrorText($err);
