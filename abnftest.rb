#! /usr/bin/env ruby
require 'abnf'
notefmt = <<EOS
  expr  = note num | note
EOS
noteonlyfmt = <<EOS
  note  = 1("a" | "b" | "c" | "d" | "e" | "f" | "g")
EOS
numfmt = <<EOS
  num   = 1*("0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9")
EOS
r1  = ABNF.parse(notefmt)
r2  = ABNF.parse(noteonlyfmt)
r3  = ABNF.parse(numfmt)
r1.merge(r2)
r1.merge(r3)
reg = r1.regexp()
num = r3.regexp()
str = "c4 d ef"
str.gsub(reg) do |expr|
  p [:a, expr]
  expr.gsub(num) do |n|
    p [:b, n]
  end
end
