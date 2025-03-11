#!/usr/bin/env ruby
require 'fileutils'
require 'pathname'
require 'shellwords'

SAMPSHELL_ROOTDIR=File.dirname $0
ENV['HOME']=ENV['PWD'] + '/deleteme-tmp.ignore' and (FileUtils.rm_r ENV['HOME']; FileUtils.mkdir_p ENV['HOME'])
HOME = Pathname ENV.fetch 'HOME' # If you can't find home, it's over.

class Pathname
	def append(msg) = write(msg, mode: 'a+')
	def append_unless_exists(msg)
		open mode: 'a+' do |file|
			unless file.size.zero?
				file.seek 0, File::SEEK_SET
				file.read.include? msg and return
				file.seek -1, File::SEEK_END
				file.getc == "\n" or file.putc "\n"
			end

			file.write msg
		end
	end
end

HOME.join('.irbrc').append_unless_exists <<~RUBY
	begin
	  load ENV.fetch('SampShell_ROOTDIR', #{SAMPSHELL_ROOTDIR.inspect}) + "/config/.irbrc"
	rescue Exception => err
	  warn "Cant load SampShell .irbrc: \#{err}"
	end
RUBY

HOME.join('.zshrc').append_unless_exists <<~SHELL
	export SampShell_TMPDIR=$HOME/tmp
	. #{SAMPSHELL_ROOTDIR.shellescape}/.rc
SHELL

HOME.join('.zshenv').append_unless_exists <<~SHELL
	. #{SAMPSHELL_ROOTDIR.shellescape}/env.sh
SHELL

HOME.join('.gitignore_global').append_unless_exists <<~EOS
.DS_Store
*.ignore
EOS

# TODO: remove `~/.gitignore_global` and get subliem to like it
HOME.join('.gitconfig').append_unless_exists <<~GITCONFIG
[core]
	include = #{SAMPSHELL_ROOTDIR}/config.gitconfig
GITCONFIG
