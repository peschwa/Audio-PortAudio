use v6;

use NativeCall;

module Audio::PortAudio;

constant FRAMES_PER_BUFFER = 256;
constant SAMPLE_RATE = 44100e0;

constant paFloat32 is export        = 0x00000001;
constant paInt32 is export          = 0x00000002;
constant paInt24 is export          = 0x00000004;
constant paInt16 is export          = 0x00000008;
constant paInt8 is export           = 0x00000010;
constant paUInt8 is export          = 0x00000020;
constant paCustomFormat is export   = 0x00010000;
# constant paNonInterleaved is export = 0x80000000;

constant paInputUnderflow is export     = 0x00000001;
constant paInputOverflow is export      = 0x00000002;
constant paOutputUnderflow is export    = 0x00000004;
constant paOutputOverflow is export     = 0x00000008;
constant paPrimingOutput is export      = 0x00000010;

enum PaErrorCode is export (
    "paNoError" => 0,
    "paNotInitialized" => -10000,
    "paUnanticipatedHostError", 
    "paInvalidChannelCount",
    "paInvalidSampleRate",
    "paInvalidDevice",
    "paInvalidFlag",
    "paSampleFormatNotSupported",
    "paBadIODeviceCombination",
    "paInsufficientMemory",
    "paBufferTooBig",
    "paBufferTooSmall", # 9990
    "paNullCallback",
    "paBadStreamPtr",
    "paTimedOut",
    "paInternalError",
    "paDeviceUnavailable",
    "paIncompatibleHostApiSpecificStreamInfo",
    "paStreamIsStopped",
    "paStreamIsNotStopped",
    "paInputOverflowed",
    "paOutputUnderflowed", # 9980
    "paHostApiNotFound",
    "paInvalidHostApi",
    "paCanNotReadFromACallbackStream",
    "paCanNotWriteToACallbackStream",
    "paCanNotReadFromAnOutputOnlyStream",
    "paCanNotWriteToAnInputOnlyStream",
    "paIncompatibleStreamHostApi",
    "paBadBufferPtr"
);

enum PaHostApiTypeId is export (
    paInDevelopment => 0,
    paDirectSound => 1,
    paMME => 2,
    paASIO => 3,
    paSoundManager => 4,
    paCoreAudio => 5,
    paOSS => 7,
    paALSA => 8,
    paAL => 9,
    paBeOS => 10,
    paWDMKS => 11,
    paJACK => 12,
    paWASAPI => 13,
    paAudioScienceHPI => 14
);

enum PaStreamCallbackResult is export (
    paContinue => 0,
    paComplete => 1,
    paAbort => 2
);

class PaStreamCallbackTimeInfo is export is repr('CStruct') {
    has num $.inputBufferAdcTime;
    has num $.currentTime;
    has num $.outputBufferDacTime;
}

class PaStreamParameters is export is repr('CStruct') {
    has int $.device;
    has int $.channel-count;
    has int $.sample-format;
    has num $.suggestedLatency;
    has CArray $.hostApiSpecificStreaminfo;
}

sub Pa_Initialize() returns int is export is native('libportaudio') {...}
sub Pa_Terminate() returns int is export is native('libportaudio') {...}
sub Pa_GetDeviceCount() returns int is export is native('libportaudio') {...}

sub Pa_GetErrorText(int $errcode) returns Str is export is native('libportaudio') {...}

sub Pa_GetDefaultOutputDevice() returns int is export is native('libportaudio') {...}

sub Pa_OpenDefaultStream(CArray $stream is rw, 
                         int $input = 0, 
                         int $output = 2, 
                         int $format = 0,
                         num $sample-rate = SAMPLE_RATE, 
                         int $frames-per-buffer = FRAMES_PER_BUFFER, 
                         &callback (OpaquePointer $inputbuf, OpaquePointer $ouputbuf, int $framecount, 
                             PaStreamCallbackTimeInfo $callback-time-info, int $flags --> int) = Nil, 
                         CArray $user-data = OpaquePointer.new)
    returns int is export is native('libportaudio') {...}

sub Pa_OpenStream(CArray $stream is rw,
                  PaStreamParameters $inParams,
                  PaStreamParameters $outParams,
                  num $sample-rate,
                  int $frames-per-buffer,
                  int $flags,
                  CArray $user-data) 
    returns int is export is native('libportaudio') {...}
                  

sub Pa_StartStream(CArray $stream is rw) returns int is export is native('libportaudio') {...}
sub Pa_CloseStream(CArray $stream is rw) returns int is export is native('libportaudio') {...}
