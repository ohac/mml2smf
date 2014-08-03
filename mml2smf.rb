#! /usr/bin/env ruby
require 'midilib/sequence'
require 'midilib/consts'
include MIDI
seq = Sequence.new()

mml = File.open('test.mml', 'r'){|fd|fd.read}

track = nil
tempo = 120
reso = 480
h = 4
prog = 1
velo = 90
octave = 5
pending = nil
note = nil

mml.split(/\n/).each do |line|
  line.chomp!
  line.split(//).each do |c|
    unless track
      track = Track.new(seq)
      seq.tracks << track
      track.events << Tempo.new(Tempo.bpm_to_mpq(tempo))
      track.events << MetaEvent.new(META_SEQ_NAME, 'MML2SMF')
      track.events << ProgramChange.new(0, prog, 0)
    end
    case c
    when /[cdefgab]/
      track.events << pending if pending
      note = octave * 12 + 'cdefgab'.index(c)
      track.events << NoteOn.new(0, note, velo, 0)
      len = seq.length_to_delta(4.0 / h)
      pending = NoteOff.new(0, note, velo, len)
    when /[0-9]/
      len = seq.length_to_delta(4.0 / c.to_i)
      pending = NoteOff.new(0, note, velo, len)
      track.events << pending
      pending = nil
    when /[ \t\n]/
    end
  end
end
track.events << pending if pending

File.open('output.mid', 'wb'){|fd| seq.write(fd)}
