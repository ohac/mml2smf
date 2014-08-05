#! /usr/bin/env ruby
require 'midilib/sequence'
require 'midilib/consts'
require 'erb'
include MIDI
@seq = Sequence.new()

if ARGV.size < 2
  puts "usage: ruby mml2smf.rb input.mml output.mid [-v]"
  exit
end
file = ARGV[0]
mml = File.open(file, 'r'){|fd|fd.read}
if /\.rmml/ === file
  mml = ERB.new(mml).result
end

alltracks = []
mmllines = mml.split(/\n/)
mmllines.each do |line|
  tracks = line.match(/^([A-Z]+) /)
  if tracks
    alltracks += tracks[1].split(//)
  else
    alltracks << 'x'
  end
end
alltracks = alltracks.uniq
if alltracks.size > 1
  mmllinesnew = []
  alltracks.each do |trackc|
    mmllines.each do |line|
      tracks = line.match(/^([A-Z]+) (.*)/)
      if trackc == 'x'
        mmllinesnew << line unless tracks
      elsif tracks
        mmllinesnew << tracks[2] if tracks[1].include?(trackc)
      end
    end
  end
  mmllinesnew << ''
  mml = mmllinesnew.join("\n")
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
@nextrest = 0
@pan = 64
@volume = 90
@staccato = 0
@tie = nil
@code = nil

def dopending
  case @pending
  when :tempo
    @track.events << Tempo.new(Tempo.bpm_to_mpq(@tempo))
  when :velocity
  when :nextvelocity
  when :prog
    @track.events << ProgramChange.new(@ch, @prog, 0)
  when :ch
    @ch -= 1
  when :rest
    @rest += @nextrest
  when :length
  when :octave
  when :staccato
  when :pan
    @track.events << Controller.new(@ch, 10, @pan, 0)
  when :volume
    @track.events << Controller.new(@ch, 7, @volume, 0)
  when nil
  else
    noteon = @pending[0]
    noteoff = @pending[1]
    if @staccato != 0
      len = @seq.length_to_delta(4.0 / @staccato.abs)
      noteon.delta_time = noteon.delta_time
      if @staccato > 0
        @rest = noteoff.delta_time - len
        noteoff.delta_time = len
      else
        noteoff.delta_time = noteoff.delta_time - len
        @rest = len
      end
    else
      @rest = 0
    end
    @track.events << noteon
    if @code
      @code = @code[1, @code.size - 2]
      @code.each do |note|
        anote = noteon.clone
        anote.delta_time = 0
        anote.note = note
        @track.events << anote
      end
    end
    @track.events << noteoff
    if @code
      @code.each do |note|
        anote = noteoff.clone
        anote.delta_time = 0
        anote.note = note
        @track.events << anote
      end
    end
    @nextrest = 0
    @lennum = 0
    @nextvelocity = nil
    @tie = nil
  end
  @pending = nil
end

mml.split(/\n/).each do |line|
  if /^#/ === line
    next
  end
  cs = line.split(//)
  cs.each_with_index do |c, i|
    unless @track
      @track = Track.new(@seq)
      @seq.tracks << @track
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
      @track = Track.new(@seq)
      @seq.tracks << @track
    when '&'
      if @pending != :rest
        @tie = @pending[1].delta_time
      end
    when /[cdefgabn]/
      nextnote = 0
      if c != 'n'
        nextnote = (@octave + @nextoctave + 1) * 12 + 'c d ef g a b'.index(c)
        @nextoctave = 0
      end
      if @tie
        nextc = cs[i + 1]
        sf = '- +'.index(nextc)
        sf = sf.nil? ? 0 : sf - 1
        if nextnote + sf != @pending[0].note
          dopending
        end
      elsif @code
        if @code.last == :end
          dopending
          @code = nil
        end
      else
        dopending
      end
      @note = nextnote
      @code << @note if @code
      if @code && @code.size > 1
      else
        @lennum = c == 'n' ? nil : 0
        @len = @seq.length_to_delta(4.0 / @deflen) + (@tie || 0)
        vel = @nextvelocity || @velocity
        @pending = [
          NoteOn.new(@ch, @note, vel, @rest),
          NoteOff.new(@ch, @note, vel, @len)
        ]
      end
    when 'h' # ch
      @pending = :ch
      @ch = 0
    when 'r' # rest
      dopending
      @lennum = 0
      @pending = :rest
      @nextrest = @seq.length_to_delta(4.0 / @deflen)
    when 'p' # pan
      dopending
      @pending = :pan
      @pan = 0
    when 'w' # volume
      dopending
      @pending = :volume
      @volume = 0
    when 'q'
      dopending
      @pending = :staccato
      @staccato = 0
    when '{'
      dopending
      @code = []
    when '}'
      @code << :end
    when /[<>]/
      dopending
      @octave += 1 if c == '>'
      @octave -= 1 if c == '<'
    when /[~_]/
      unless @tie
        dopending
      end
      @nextoctave = c == '~' ? 1 : -1
    when 'o'
      dopending
      @pending = :octave
    when 'l'
      dopending
      @pending = :length
      @deflen = 0
    when /[+-]/
      case @pending
      when :staccato
        @staccato = nil if c == '-'
      else
        @note += 1 if c == '+'
        @note -= 1 if c == '-'
        if @code && @code.size > 1
          @code[-1] = @note
        else
          vel = @nextvelocity || @velocity
          @pending = [
            NoteOn.new(@ch, @note, vel, @rest),
            NoteOff.new(@ch, @note, vel, @len)
          ]
        end
      end
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
      when :pan
        @pan *= 10
        @pan += c.to_i
      when :volume
        @volume *= 10
        @volume += c.to_i
      when :staccato
        if @staccato.nil? || @staccato < 0
          @staccato = 0 unless @staccato
          @staccato *= 10
          @staccato -= c.to_i
        else
          @staccato *= 10
          @staccato += c.to_i
        end
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
          len = @seq.length_to_delta(4.0 / @deflen) + (@tie || 0)
          @pending = [
            NoteOn.new(@ch, @note, vel, @rest),
            NoteOff.new(@ch, @note, vel, len)
          ]
        else
          @lennum *= 10
          @lennum += c.to_i
        end
        if @pending == :rest
          @nextrest = @seq.length_to_delta(4.0 / @lennum)
        elsif !@lennum.nil?
          @len = @seq.length_to_delta(4.0 / @lennum) + (@tie || 0)
          @pending[1].delta_time = @len
        end
      end
    when /[ \t\n]/
    end
  end
end
dopending

outputfile = ARGV[1]

File.open(outputfile, 'wb'){|fd| @seq.write(fd)}

if ARGV[2] == '-v'
  @seq.each do |track|
    track.each do |e|
      puts e
    end
  end
end
