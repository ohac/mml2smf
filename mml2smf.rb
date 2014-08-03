#! /usr/bin/env ruby
require 'midilib/sequence'
require 'midilib/consts'
include MIDI
seq = Sequence.new()

mml = File.open('test.mml', 'r'){|fd|fd.read}

@track = nil
@tempo = 120
h = 4
prog = 1
velo = 90
octave = 5
@pending = nil
note = nil

def dopending
  case @pending
  when :tempo
    @track.events << Tempo.new(Tempo.bpm_to_mpq(@tempo))
  when nil
  else
    @track.events << @pending
  end
end

mml.split(/\n/).each do |line|
  line.chomp!
  line.split(//).each do |c|
    unless @track
      @track = Track.new(seq)
      seq.tracks << @track
      @track.events << MetaEvent.new(META_SEQ_NAME, 'MML2SMF')
      @track.events << ProgramChange.new(0, prog, 0)
    end
    case c
    when /t/
      @pending = :tempo
      @tempo = 0
    when /[cdefgab]/
      dopending
      note = octave * 12 + 'cdefgab'.index(c)
      @track.events << NoteOn.new(0, note, velo, 0)
      len = seq.length_to_delta(4.0 / h)
      @pending = NoteOff.new(0, note, velo, len)
    when /[0-9]/
      if @pending == :tempo
        @tempo *= 10
        @tempo += c.to_i
      else
        len = seq.length_to_delta(4.0 / c.to_i)
        @pending = NoteOff.new(0, note, velo, len)
        @track.events << @pending
        @pending = nil
      end
    when /[ \t\n]/
    end
  end
end
dopending

File.open('output.mid', 'wb'){|fd| seq.write(fd)}
