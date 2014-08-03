mml2smf
=======

Convert MML to Standard MIDI File

* `[a-g]<+-><length>` length: 1,2,4,8,16,...
* `r<length>`
* `t<tempo>`
* `@<program change>`
* `ch<MIDI channel>`
* `;` next track
* `[<>]` octave up and down
* `o<octave>` octave: -1, 0, ..., 9
* `v<velocity>` velocity: 0 - 127
* `'<velocity>` velocity: 0 - 127

TODO

* `p<pan>` pan: 0 - 127
* `w<volume>` volume: 0 - 127
* `{code}`
* `.` x1.5
* `&` tie
* `l<length>` length: 1,2,4,8,16,...
* `[~_]` octave up and down
* `n<note>` note: 1 - 127
* `q<length>` `q`
* `%<num>.<control>`
* `|<pitch>` pitch: -8192 - 8191
* `/* comment */`
* lyrics for Vocaloid: ignored
