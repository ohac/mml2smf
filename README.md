mml2smf
=======

Convert MML to Standard MIDI File

Install

    $ sudo gem install midilib

Convert

    $ ruby mml2smf.rb examples/test.mml

Play

    $ sudo apt-get install qjackctl pulseaudio-module-jack
    $ sudo apt-get install qsynth fluid-soundfont-gm pmidi
    $ qjackctl &
    $ qsynth &
    $ pmidi -l
     Port     Client name                       Port name
     14:0     Midi Through                      Midi Through Port-0
    128:0     Client-128                        qjackctl
    129:0     FLUID Synth (9127)                Synth input port (9127:0)
    131:0     VMPK Input                        VMPK Input
    $ pmidi -p 129:0 output.mid

Commands

* `[a-g]<+-><length>` length: 1,2,4,8,16,2.,4.,...
* `n<note>` note: 1 - 127
* `r<length>`
* `l<length>` length: 1,2,4,8,16,...
* `t<tempo>`
* `@<program change>`
* `ch<MIDI channel>`
* `;` next track
* `[<>]` octave up and down
* `o<octave>` octave: -1, 0, ..., 9
* `[~_]` octave up and down
* `v<velocity>` velocity: 0 - 127
* `'<velocity>` velocity: 0 - 127
* `# comment`

TODO

* `p<pan>` pan: 0 - 127
* `w<volume>` volume: 0 - 127
* `{code}`
* `&` tie
* `q<length>` `q`
* `%<num>.<control>`
* `|<pitch>` pitch: -8192 - 8191
* lyrics for Vocaloid: ignored
* `^[A-Z]` track
* `[` `]<repeat>`
* Ruby Template Engine
