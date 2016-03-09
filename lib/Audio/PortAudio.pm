use v6;

use NativeCall;

class Audio::PortAudio {

    constant FRAMES_PER_BUFFER = 256;
    constant SAMPLE_RATE = 44100e0;
    
    constant paFloat32 is export        = 0x00000001;
    constant paInt32 is export          = 0x00000002;
    constant paInt24 is export          = 0x00000004;
    constant paInt16 is export          = 0x00000008;
    constant paInt8 is export           = 0x00000010;
    constant paUInt8 is export          = 0x00000020;
    constant paCustomFormat is export   = 0x00010000;
    constant paNonInterleaved is export = 0x80000000;
    
    constant paInputUnderflow is export     = 0x00000001;
    constant paInputOverflow is export      = 0x00000002;
    constant paOutputUnderflow is export    = 0x00000004;
    constant paOutputOverflow is export     = 0x00000008;
    constant paPrimingOutput is export      = 0x00000010;
    
    constant paClipOff is export                    = 0x00000001;
    constant paDitherOff is export                  = 0x00000002;
    constant paNeverDropInput is export             = 0x00000004;
    constant paPrimeOutputBufferUsingStreamCallback = 0x00000008;
    constant paPlatformSpecificFlags                = 0xFFFF0000;
    
    enum ErrorCode is export (
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
    
    enum HostApiTypeId is export (
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
    
    enum StreamCallbackResult is export (
        paContinue => 0,
        paComplete => 1,
        paAbort => 2
    );
    
    class StreamCallbackTimeInfo is repr('CStruct') {
        has num $.inputBufferAdcTime;
        has num $.currentTime;
        has num $.outputBufferDacTime;
    }
    
    class StreamParameters is repr('CStruct') {
        has int32 $.device;
        has int32 $.channel-count;
        has int $.sample-format;
        has num $.suggested-latency;
        has CArray[OpaquePointer] $.host-api-specific-streaminfo;
    }
    
    class DeviceInfo is repr('CStruct') {
        has int32 $.struct-version;
        has Str $.name;
        has int32 $.api-version;
        has int32 $.max-input-channels;
        has int32 $.max-output-channels;
        has num $.default-low-input-latency;
        has num $.default-low-output-latency;
        has num $.default-high-input-latency;
        has num $.default-high-output-latency;
        has num $.default-sample-rate;
    
        method perl() {
            "DeviceInfo.new(struct-version => $.struct-version, name => $.name, api-version => $.api-version, " ~
            "max-input-channels => $.max-input-channels, max-output-channels => $.max-output-channels, default-low-input-latency => $.default-low-input-latency, "~
            "default-low-output-latency => $.default-low-output-latency, default-high-input-latency => $.default-high-input-latency, " ~
            "default-high-output-latency => $.default-high-output-latency, default-sample-rate => $.default-sample-rate"
        }
    }

    class Stream is repr('CPointer') {
        sub Pa_StartStream(Stream $stream) returns int32 is native('portaudio',v2) {...}

        method start() returns Int {
            Pa_StartStream(self);
        }

        sub Pa_CloseStream(Stream $stream) returns int32 is native('portaudio',v2) {...}

        method close() returns Int {
            Pa_CloseStream(self);
        }

        sub Pa_WriteStream(Stream $stream, CArray $buf, int32 $frames) returns int32 is native('portaudio',v2) {...}

        method write(CArray $buf, Int $frames) returns Int {
            Pa_WriteStream(self, $buf, $frames);
        }

        sub Pa_IsStreamStopped(Stream $stream) returns int32 is native('portaudio', v2) { * }

        method stopped() returns Bool {
            Bool(Pa_IsStreamStopped(self));
        }

        sub Pa_IsStreamActive(Stream $stream) returns int32 is native('portaudio', v2) { * }

        method active() returns Bool {
            Bool(Pa_IsStreamActive(self));
        }

    }

    submethod BUILD() {
        self.initialize();
    }
    
    sub Pa_Initialize() returns int32 is native('portaudio',v2) {...}

    method initialize() returns Int {
        Pa_Initialize();
    }
    sub Pa_Terminate() returns int32 is native('portaudio',v2) {...}

    method terminate() returns Int {
        Pa_Terminate();
    }

    sub Pa_GetDeviceCount() returns int32 is native('portaudio',v2) {...}

    method device-count() returns Int {
        Pa_GetDeviceCount();
    }

    
    sub Pa_GetDeviceInfo(int32 $device-number) returns DeviceInfo is export is native('portaudio',v2) {...}

    method device-info(Int $device-number) returns DeviceInfo {
        Pa_GetDeviceInfo($device-number);
    }

    method devices() {
        my Int $no-devices = self.device-count();
        gather {
            for ^$no-devices -> $device-number {
                take self.device-info($device-number);
            }

        }
    }

    sub Pa_GetErrorText(int32 $errcode) returns Str is native('portaudio',v2) {...}

    method error-text(Int $error-code) returns Str {
        Pa_GetErrorText($error-code);
    }
    
    sub Pa_GetDefaultOutputDevice() returns int32 is native('portaudio',v2) {...}

    method default-output-device() returns DeviceInfo {
        my Int $device-number = Pa_GetDefaultOutputDevice();
        self.device-info($device-number);
    }
    
    sub Pa_OpenDefaultStream(CArray[Stream] $stream,
                             int32 $input,
                             int32 $output,
                             int32 $format,
                             num64 $sample-rate,
                             int32 $frames-per-buffer ,
                             &callback (CArray $inputbuf, CArray $outputbuf, int32 $framecount, StreamCallbackTimeInfo $callback-time-info, int32 $flags, CArray $cb-user-data --> int32),
                             CArray $user-data)
        returns int32 is native('portaudio',v2) {...}

    method open-default-stream(Int $input = 0, Int $output = 2, Int $format = 1, Int $sample-rate = 44100, Int $frames-per-buffer = 256) returns Stream {
        my CArray[Stream] $stream = CArray[Stream].new;
        $stream[0] = Stream.new;
        say Pa_OpenDefaultStream($stream,$input,$output,$format, Num($sample-rate), $frames-per-buffer, Code, CArray);
        $stream[0];
    }
    
    sub Pa_OpenStream(Pointer[Stream] $stream,
                      StreamParameters $inParams,
                      StreamParameters $outParams,
                      num64 $sample-rate,
                      int32 $frames-per-buffer,
                      int32 $flags,
                      CArray[OpaquePointer] $user-data)
        returns int32 is native('portaudio',v2) {...}
}
# vim: expandtab shiftwidth=4 ft=perl6
