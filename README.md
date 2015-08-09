mml2smf
=======

Convert MML to Standard MIDI File

[![Build Status](https://travis-ci.org/ohac/mml2smf.svg?branch=master)](https://travis-ci.org/ohac/mml2smf)

Install

    $ bundle install --path vendor/bundle

Convert

    $ bundle exec bin/mml2smf test/test.mml test.mid
    $ bundle exec bin/mml2smf examples/erb.rmml erb.mid

Play

    $ sudo apt-get install qsynth fluid-soundfont-gm pmidi
    $ qsynth &
    (Setup qsynth: e.g. Use pulseaudio. Set soundfont and buffer size. etc.)
    $ pmidi -l
     Port     Client name                       Port name
     14:0     Midi Through                      Midi Through Port-0
    129:0     FLUID Synth (9127)                Synth input port (9127:0)
    $ pmidi -p 129:0 output.mid

Record

    $ sudo apt-get install sox
    $ pactl load-module module-null-sink
    (Set qsynth output to Null Output)
    $ parec | sox -t raw -r 44100 -e signed-integer -L -b 16 -c 2 - output.flac
    (Set parec input to Null Input)
    $ pmidi -p 129:0 output.mid

Edit

    $ sudo apt-get install audacious
    $ audacious output.flac
    (Edit and export)
    $ sox exported.flac master.mp3

Commands

* `[a-g]<+-><length>` length: 1,2,4,8,16,2.,4.,...
* `n<note>` note: 1 - 127
* `&` tie
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
* `p<pan>` pan: 0 - 127
* `w<volume>` volume: 0 - 127
* `q<length>` `q` staccato
* `{code}`

Preprocessor

* `^[A-Z] ` track

TODO

* `%<num>.<control>`
* `|<pitch>` pitch: -8192 - 8191
* lyrics for Vocaloid: ignored
* `[` `]<repeat>`
