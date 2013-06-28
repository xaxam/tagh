#!/usr/bin/env ruby

require 'open3'
require 'open-uri'
require 'rubygems'
require 'terminal-notifier'
require 'thor'

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end


class Tagger

	def list(source)

		tags = []
		source = '/Users/sx/Dropbox/Notes/'
		dir = source + '*.{txt,md,mmd,markdown,taskpaper}'

		Dir.glob(dir) do |p|

			# Scan for hashtags in the text of all files
				f = File.open(p)
				tags << f.read.scan(/( #[\w\d-]+)(?=\s|$)/i)	
			
		end

		tags = tags.delete_if(&:empty?).flatten.map(&:lstrip).sort.uniq
		

			# if options[:sublime]
			# 	sublime = '{"scope": "text","completions":[' + tags.map { |e| '"' + e.strip + '"'}.join(",") + ']}'
			# 	fpath = ENV['HOME'] + '/Library/Application Support/Sublime Text 2/Packages/User/tags.sublime-completions'
			# 	File.open(fpath , 'w') { |file| file.puts sublime }
			# end
	end

end


class Tagh < Thor
	desc "list source", "list all tags in 'source' (directory)"
	option :sublime, :aliases => "-s"
	def list(source)
		r = Tagger.new
   		puts r.list(source)	
	end
end

Tagh.start(ARGV)


