#! /usr/bin/env ruby
require 'midilib/sequence'
require 'midilib/consts'
include MIDI
seq = Sequence.new()

mml = File.open('test.mml', 'r'){|fd|fd.read}

@track = nil
@tempo = 120
deflen = 4
@prog = 1
@velo = 90
@octave = 4
@pending = nil
@note = nil
@len = deflen
@ch = 0
@rest = 0

def dopending
  case @pending
  when :tempo
    @track.events << Tempo.new(Tempo.bpm_to_mpq(@tempo))
  when :prog
    @track.events << ProgramChange.new(@ch, @prog, 0)
  when :ch
  when :rest
  when :octave
  when nil
  else
    @track.events << @pending[0]
    @track.events << @pending[1]
    @rest = 0
  end
  @pending = nil
end

mml.split(/\n/).each do |line|
  line.chomp!
  line.split(//).each do |c|
    unless @track
      @track = Track.new(seq)
      seq.tracks << @track
    end
    case c
    when /t/
      dopending
      @pending = :tempo
      @tempo = 0
    when /@/
      dopending
      @pending = :prog
      @prog = 0
    when /;/
      dopending
      @track = Track.new(seq)
      seq.tracks << @track
    when /[cdefgab]/
      dopending
      @note = (@octave + 1) * 12 + 'c d ef g a b'.index(c)
      @len = seq.length_to_delta(4.0 / deflen)
      @pending = [
        NoteOn.new(@ch, @note, @velo, @rest),
        NoteOff.new(@ch, @note, @velo, @len)
      ]
    when 'h' # ch
      @pending = :ch
      @ch = 0
    when 'r' # rest
      dopending
      @pending = :rest
      @rest = seq.length_to_delta(4.0 / deflen)
    when /[<>]/
      dopending
      @octave += 1 if c == '<'
      @octave -= 1 if c == '>'
    when 'o'
      dopending
      @pending = :octave
    when /[+-]/
      @note += 1 if c == '+'
      @note -= 1 if c == '-'
      @pending = [
        NoteOn.new(@ch, @note, @velo, @rest),
        NoteOff.new(@ch, @note, @velo, @len)
      ]
    when /[0-9]/
      case @pending
      when :tempo
        @tempo *= 10
        @tempo += c.to_i
      when :prog
        @prog *= 10
        @prog += c.to_i
      when :ch
        @ch *= 10
        @ch += c.to_i
      when :octave
        @octave = c.to_i
      when :rest
        @rest = seq.length_to_delta(4.0 / c.to_i)
      else
        @len = seq.length_to_delta(4.0 / c.to_i)
        @pending[1] = NoteOff.new(@ch, @note, @velo, @len)
      end
    when /[ \t\n]/
    end
  end
end
dopending

File.open('output.mid', 'wb'){|fd| seq.write(fd)}
