#! /usr/bin/env ruby
require 'abnf'
mmlfmt = <<EOS
  mml = 1*(notelen | restlen)
EOS
notelenfmt = <<EOS
  notelen = note num | note
EOS
notefmt = <<EOS
  note = 1("a" | "b" | "c" | "d" | "e" | "f" | "g") [("+" | "-" | "=")]
EOS
restlenfmt = <<EOS
  restlen = rest num | rest
EOS
restfmt = <<EOS
  rest = "r"
EOS
numfmt = <<EOS
  num = 1*("0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9")
EOS
mml = ABNF.parse(mmlfmt)
notelen = ABNF.parse(notelenfmt)
note = ABNF.parse(notefmt)
restlen = ABNF.parse(restlenfmt)
rest = ABNF.parse(restfmt)
num = ABNF.parse(numfmt)
notelen.merge(num)
notelen.merge(note)
restlen.merge(num)
restlen.merge(rest)
mml.merge(notelen)
mml.merge(restlen)
mmlr = mml.regexp()
notelenr = notelen.regexp()
noter = note.regexp()
restlenr = restlen.regexp()
restr = rest.regexp()
numr = num.regexp()
str = "c4 d ef r8 g+a-8b=16"
str.gsub(mmlr) do |expr|
  p [:a, expr]
  expr.gsub(notelenr) do |n|
    p [:b, n]
  end
end
