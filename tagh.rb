#!/usr/bin/env ruby

require 'open3'
require 'open-uri'
require 'rubygems'
require 'terminal-notifier'
require 'thor'
require 'yaml'

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end


class Tagger

	def list(options)

		if options[:source]
			source = options[:source]
		else
			source = Dir.pwd
		end

		options['min'] ? min = options['min'].to_i : min = 1
		options['max'] ? max = options['max'].to_i : max = 999999

		puts min

		puts "Listing tags in: " + source
		
		scanned = []
		tags = []
		tagsn = []

		dir = source + '/*.{txt,md,mmd,markdown,taskpaper}'

		# Scan for tags in the text of all files
		Dir.glob(dir) do |p|
				f = File.open(p)

				# Hashtags
				scanned << f.read.scan(/( #[\w\d-]+)(?=\s|$)/i)	

				#YAML meta data tags
				yaml = YAML.load_file(p)
				scanned << yaml['tags'] unless yaml['tags'] == nil

		end		


		# iterate over the array, counting duplicate entries and hash the result
		thash = Hash.new(0)
		scanned.flatten.map(&:lstrip).sort.each { |v| thash[v] += 1 }

		thash.each do |k, v|
			if v.between?(min,max) 
				tagsn << "#{k} (#{v})"
			 	tags << k
			end
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
			tagsn
		end
	end




	def find(tag, options)

		if options[:source]
			source = options[:source]
		else
			source = Dir.pwd
		end

		puts "Searching in: " + source

		scanned = []
		found = []
		dir = source + '/*.{txt,md,mmd,markdown,taskpaper}'

		# Scan for tags in the text of all files
		Dir.glob(dir) do |p|
				f = File.open(p)
				
				# Hashtags
				chunks = f.read.split(/\n\n[\-_\* ]{3,}\n|\n\n(?=#+.+\n)/)
				chunks.each do |chunk|
					if chunk  =~ / ##{tag}[\s$]/ 
						scanned << chunk + "\n\n[" + File.basename(p,File.extname(p))+ "](file://" + URI.escape(p) + ")"
						found << ("'" + p + "'")
					end
				end

				#YAML meta data tags
				yaml = YAML.load_file(p)
				if yaml['tags'].include? tag
					scanned << f.read
					found << ("'" + p + "'")
				end
		end

		if options[:open]
			founds = found.join(" ")
			`subl -n #{founds}`
		end
		
		if options[:file]
			File.open(options[:file], 'w') { |file| file.puts scanned.join("\n\n---\n\n")}
			puts "Result in file: " + options[:file]
		else
			founds = "- " + found.join("\n- ")
		end 

	end


	def merge(tags, options)

		if options[:source]
			source = options[:source]
		else
			source = Dir.pwd
		end

		puts "Merging tags #{tags[0..-2].join(', ')} into #{tags[-1]} in: " + source



	end


end


class Tagh < Thor
	desc "list [-s source]", "list tags."
	option :sourcel, :aliases => "-s"
	option :sublime, :aliases => "-u"
	option :file, :aliases => "-f"
	option :min
	option :max
	def list()
		r = Tagger.new
   		puts r.list(options)	
	end

	desc "find TAG [-s source]", "find items tagged TAG in [source]"
	option :source, :aliases => "-s"
	option :file, :aliases => "-f"
	option :open, :aliases => "-o"
	def find(tag)
		r = Tagger.new
   		puts r.find(tag, options)	
	end

	desc "merge TAGS", "merge all TAGS into the last one specified"
	option :source, :aliases => "-s"
	def merge(*tags)
		r = Tagger.new
   		puts r.merge(tags, options)
	end
end

Tagh.start(ARGV)


