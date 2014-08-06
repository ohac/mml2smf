#! /usr/bin/env ruby
require 'abnf'
mmllinefmt = <<EOS
  mmlline = (line | commentline)
  line = 0*1(*track WSP) *(event | WSP) LF
  commentline = "#" *(WSP | VCHAR) LF
  track = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" |
          "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" |
          "W" | "X" | "Y" | "Z"
EOS
eventfmt = <<EOS
  event = tiednote | restlen | length | tempo | prog | ch | nexttrack |
          octave | octavechange | velocity | velocitynext | pan | volume |
          staccato
  tiednote = (code | notelen | notenum) 0*(tie (code | notelen | notenum))
  code = "{" 2*notelen "}"
  notelen = ( note num | note ) ["."]
  notenum = "n" num ["."]
  note = ["~" | "_"] 1("a" | "b" | "c" | "d" | "e" | "f" | "g")
         [("+" | "-" | "=")]
  restlen = ("r" num | "r") ["."]
  num = 1*("0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9")
  length = "l" num
  tempo = "t" num
  tie = "&"
  prog = "@" num
  ch = "ch" num
  nexttrack = ";"
  octave = "o" num
  octavechange = "<" | ">"
  velocity = "v" num
  velocitynext = "'" num
  pan = "p" num
  volume = "v" num
  staccato = "q" num
EOS

mmlline = ABNF.parse(mmllinefmt)
event = ABNF.parse(eventfmt)
mmlline.merge(event)
mmlliner = mmlline.regexp()
eventr = event.regexp()
str = <<EOS
c4 d ef r8 _g+a-8~b=16. a&a.&a n3&n3.
# test
;
EOS
str.gsub(mmlliner) do |line|
  next if /^#/ === line
  line.gsub(eventr) do |ev|
    p ev
  end
end
