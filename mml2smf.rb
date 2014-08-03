#! /usr/bin/env ruby
require 'midilib/sequence'
require 'midilib/consts'
require 'erb'
include MIDI
seq = Sequence.new()

if ARGV.empty?
  p :usage
  exit
end
file = ARGV[0]
mml = File.open(file, 'r'){|fd|fd.read}
if /\.rmml/ === file
  mml = ERB.new(mml).result
end

@track = nil
@tempo = 120
@deflen = 4
@prog = 1
@velocity = 90
@nextvelocity = nil
@octave = 4
@nextoctave = 0
@pending = nil
@note = nil
@len = @deflen
@lennum = 0
@ch = 0
@rest = 0

def dopending
  case @pending
  when :tempo
    @track.events << Tempo.new(Tempo.bpm_to_mpq(@tempo))
  when :velocity
  when :nextvelocity
  when :prog
    @track.events << ProgramChange.new(@ch, @prog, 0)
  when :ch
  when :rest
  when :length
  when :octave
  when :nextoctave
  when nil
  else
    @track.events << @pending[0]
    @track.events << @pending[1]
    @rest = 0
    @lennum = 0
    @nextvelocity = nil
    @nextoctave = 0
  end
  @pending = nil
end

mml.split(/\n/).each do |line|
  line.chomp!
  if /^#/ === line
    next
  end
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
    when /v/
      dopending
      @pending = :velocity
      @velocity = 0
    when "'"
      dopending
      @pending = :nextvelocity
      @nextvelocity = 0
    when /@/
      dopending
      @pending = :prog
      @prog = 0
    when /;/
      dopending
      @track = Track.new(seq)
      seq.tracks << @track
    when /[A-Z]/ # TODO ignore
    when '&' # TODO ignore
    when /[cdefgabn]/
      dopending
      if c == 'n'
        @note = 0
        @lennum = nil
      else
        @note = (@octave + @nextoctave + 1) * 12 + 'c d ef g a b'.index(c)
        @lennum = 0
      end
      @len = seq.length_to_delta(4.0 / @deflen)
      vel = @nextvelocity || @velocity
      @pending = [
        NoteOn.new(@ch, @note, vel, @rest),
        NoteOff.new(@ch, @note, vel, @len)
      ]
    when 'h' # ch
      @pending = :ch
      @ch = 0
    when 'r' # rest
      dopending
      @pending = :rest
      @rest = seq.length_to_delta(4.0 / @deflen)
    when /[<>]/
      dopending
      @octave += 1 if c == '>'
      @octave -= 1 if c == '<'
    when /[~_]/
      dopending
      @pending = :nextoctave
      @nextoctave = c == '~' ? 1 : -1
    when 'o'
      dopending
      @pending = :octave
    when 'l'
      dopending
      @pending = :length
      @deflen = 0
    when /[+-]/
      @note += 1 if c == '+'
      @note -= 1 if c == '-'
      vel = @nextvelocity || @velocity
      @pending[1] = NoteOff.new(@ch, @note, vel, @len)
      @pending = [
        NoteOn.new(@ch, @note, vel, @rest),
        NoteOff.new(@ch, @note, vel, @len)
      ]
    when /[0-9.]/
      case @pending
      when :tempo
        @tempo *= 10
        @tempo += c.to_i
      when :velocity
        @velocity *= 10
        @velocity += c.to_i
      when :nextvelocity
        @nextvelocity *= 10
        @nextvelocity += c.to_i
      when :prog
        @prog *= 10
        @prog += c.to_i
      when :ch
        @ch *= 10
        @ch += c.to_i
      when :octave
        @octave = c.to_i
      when :length
        if c == '.'
          @deflen *= 1.5
        else
          @deflen *= 10
          @deflen += c.to_i
        end
      else
        vel = @nextvelocity || @velocity
        if c == '.'
          @lennum = @deflen if @lennum == 0 || @lennum.nil?
          @lennum /= 1.5
        elsif @lennum.nil?
          @note *= 10
          @note += c.to_i
          len = seq.length_to_delta(4.0 / @deflen)
          @pending = [
            NoteOn.new(@ch, @note, vel, @rest),
            NoteOff.new(@ch, @note, vel, len)
          ]
        else
          @lennum *= 10
          @lennum += c.to_i
        end
        if @pending == :rest
          @rest = seq.length_to_delta(4.0 / @lennum)
        elsif !@lennum.nil?
          @len = seq.length_to_delta(4.0 / @lennum)
          @pending[1] = NoteOff.new(@ch, @note, vel, @len)
        end
      end
    when /[ \t\n]/
    end
  end
end
dopending

File.open('output.mid', 'wb'){|fd| seq.write(fd)}
