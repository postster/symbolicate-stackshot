#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'json'

class SymbolicateStackshot
  include Commander::Methods

  def run
    program :name, 'Symbolicate Stackshot'
    program :version, '0.0.1'
    program :description, 'Command-line utility to symbolicate stackshots from iOS applications.'

    global_option('-s', '--stackshot FILE', 'Path to stackshot file')
    global_option('-p', '--proc PROC', 'Process name')
    global_option('-d', '--dsym DSYM', 'Path to app dSYM')

    default_command :symbolicate

    command :symbolicate do |c|
      c.description = 'Symbolicates a stackshot'
      c.action do |args, options|
        filename = options.stackshot
        procname = options.proc
        dsym = options.dsym

        if filename.nil? or procname.nil? or dsym.nil?
          STDERR.puts 'Must specify stackshot, proc, and dsym.'
          exit 1
        end

        self.symbolicate(filename, procname, dsym)
      end
    end
  end

  def symbolicate(filename, procname, dsym)
    # Skip first line; it's not valid JSON and not useful
    input = ''
    File.readlines(filename).drop(1).each do |line|
      input += line
    end

    hash = JSON.parse('[' + input + ']')

    binaryImageOffsets = []
    for element in hash[0]['binaryImages']
      binaryImageOffsets.push(element[1].to_i)
    end

    for element in hash[0]['processByPid']
      pid, piddata = element

      if piddata['procname'] == procname
        puts "************************************************************************************"
        puts "************************************************************************************"
        puts "Process #{pid}"

        for thread in piddata['threadById']
          threadid, threaddata = thread

          puts "===================================================================================="
          puts "Thread #{threadid}"

          for userframe in threaddata['userFrames']
            imgidx, addr = userframe
            loadaddr = binaryImageOffsets[imgidx]
            puts `atos -arch arm64 -o "#{dsym}" -l "#{loadaddr.to_s(16)}" "#{(addr+loadaddr).to_s(16)}"`
          end
          puts
        end
        puts
      end
    end
  end
end

SymbolicateStackshot.new.run if $0 == __FILE__
