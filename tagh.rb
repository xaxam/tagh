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

	def list(source, options)

		scanned = []
		tags = []
		tagsn = []

		dir = source + '*.{txt,md,mmd,markdown,taskpaper}'

		# Scan for hashtags in the text of all files
		Dir.glob(dir) do |p|
				f = File.open(p)
				scanned << f.read.scan(/( #[\w\d-]+)(?=\s|$)/i)				
		end		


		# iterate over the array, counting duplicate entries and hash the result
		thash = Hash.new(0)
		scanned.flatten.map(&:lstrip).sort.each { |v| thash[v] += 1 }

		thash.each do |k, v|
		  tagsn << "#{k} (#{v})"
		  tags << k
		end


		if options[:sublime]
			#create/update JSON file for Sublime Text autocompletion
			sublime = '{"scope": "text","completions":[' + tags.map { |e| '"' + e.strip + '"'}.join(",") + ']}'
			fpath = ENV['HOME'] + '/Library/Application Support/Sublime Text 2/Packages/User/tags.sublime-completions'
			File.open(fpath , 'w') { |file| file.puts sublime }
			puts "Sublime Text autocompletion list updated"
		end

		if options[:file]
			File.open(options[:file], 'w') { |file| file.puts tags}
			puts "List of tags writen to: " + options[:file]
		else
			#standard output
			tagsn
		end
	end

	def find(source, options)

		scanned = []

		dir = source + '*.{txt,md,mmd,markdown,taskpaper}'

		# Scan for hashtags in the text of all files
		Dir.glob(dir) do |p|
				f = File.open(p)
				
				chunks = f.read.split(/\n\n[\-_\* ]{3,}\n|\n\n(?=#+.+\n)/)
				chunks.each do |chunk|
					if chunk  =~ / ##{options[:tag]}[\s$]/ 
						scanned << chunk + "\n\n[" + File.basename(p,File.extname(p))+ "](file://" + URI.escape(p) + ")"
					end
				end
		end
		
		if options[:file]
			File.open(options[:file], 'w') { |file| file.puts scanned.join("\n\n---\n\n")}
			puts "Result in file: " + options[:file]
		else
			#standard output
			scanned.join("\n\n---\n\n")
		end 
	end

end


class Tagh < Thor
	desc "list source", "list all tags in 'source' (directory)"
	option :sublime, :aliases => "-s"
	option :file, :aliases => "-f"
	def list(source)
		r = Tagger.new
   		puts r.list(source, options)	
	end

	desc "find -t tag source", "find snippets tagged tag in 'source' (directory)"
	option :tag, :aliases => "-t"
	option :file, :aliases => "-f"
	def find(source)
		r = Tagger.new
   		puts r.find(source, options)	
	end
end

Tagh.start(ARGV)


