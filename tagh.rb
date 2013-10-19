#!/usr/bin/env ruby

require 'rubygems'
require 'open3'
require 'open-uri'
require 'thor'
require 'yaml'

if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end


class Tagger

	def list(options)

		if options[:source]
			sources = options[:source]
		else
			sources = [Dir.pwd]
		end

		options['min'] ? min = options['min'].to_i : min = 1
		options['max'] ? max = options['max'].to_i : max = 999999

		puts "Listing tags in: " + sources.join(', ')
		
		scanned = []
		tags = []
		tagsn = []

		sources.each do |source|

			dir = source + '/*.{txt,md,mmd,markdown,taskpaper}'

			# Scan for tags in the text of all files
			Dir.glob(dir) do |p|
					f = File.open(p)

					# Hashtags
					scanned << f.read.scan(/( #[\w\d-]+)(?=\s|$)/i)

					# YAML meta data tags
					yaml = YAML.load_file(p)
					scanned << yaml['tags'] unless yaml['tags'] == nil

			end		

		end


		# iterate over the array, counting duplicate entries and hash the result
		thash = Hash.new(0)
		scanned.flatten.map(&:lstrip).map { |t| t.sub('#','')}.sort.each { |v| thash[v] += 1 }

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
		elsif options[:flat]
			"'" + tags.join("' '") + "'"
		else
			tagsn
		end
	end




	def find(tag, options)

		if options[:source]
			sources = options[:source]
		else
			sources = [Dir.pwd]
		end

		puts "Searching in: " + sources.join(', ')

		scanned = []
		found = []

		sources.each do |source|

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

				# YAML meta data tags
				yaml = YAML.load_file(p)
				if yaml['tags']
					if yaml['tags'].include? tag
						scanned << f.read
						found << ("'" + p + "'")
					end
				end
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
			sources = options[:source]
		else
			sources = [Dir.pwd]
		end

		stdin, stdout, stderr = Open3.popen3("git status -s")
		r = stdout.read

		if r == '' 
			merge = tags[0..-2]
			target = tags[-1]
			puts "Merging tags #{merge.join(', ')} into #{target} in: " + sources.join(', ')

			scanned = []
			found = []

			sources.each do |source|

				dir = source + '/*.{txt,md,mmd,markdown,taskpaper}'

				# Scan for tags in the text of all files
				Dir.glob(dir) do |p|
					f = File.open(p)
					doc = f.read
					
					# YAML (with dirty check for YAML metadata header)
					if doc[0..3] == "---\n"

						contents = doc.split('---')[2].lstrip
						meta = YAML.load(doc)

						merge.each do |t|
							if meta['tags'].include?(t)
								meta['tags'].delete(t)
								meta['tags'] << target
							end
						end	

						meta['tags'].uniq!

						# new markdow file
						doc = YAML.dump(meta) + "---\n" + contents

					end

					# Hashtags
					tags.each { |t| doc.gsub!("##{t}", "##{target}")}

					File.open(p, 'w') { |file| file.write(doc) }

				end
			end

		else
			puts "No clean git repository! Setup git and/or commit changes before merging tags." 
		end

	end

	def delete(tags, options)

		if options[:source]
			sources = options[:source]
		else
			sources = [Dir.pwd]
		end

		stdin, stdout, stderr = Open3.popen3("git status -s")
		r = stdout.read

		if r == '' 
			puts "Deleting tags #{tags.join(', ')} in: " + sources.join(', ')

			scanned = []
			found = []

			sources.each do |source|

				dir = source + '/*.{txt,md,mmd,markdown,taskpaper}'

				# Scan for tags in the text of all files 
				Dir.glob(dir) do |p|
					f = File.open(p)
					doc = f.read
					
					# YAML (with dirty check for YAML metadata header)
					if doc[0..3] == "---\n"

						contents = doc.split('---')[2].lstrip
						meta = YAML.load(doc)

						tags.each do |t|
							meta['tags'].delete(t)
						end

						# strip potential double values
						meta['tags'].uniq!

						# new markdow file
						doc = YAML.dump(meta) + "---\n" + contents

					end

					# Hashtags
					tags.each { |t| doc.gsub!("##{t}", '')}

					File.open(p, 'w') { |file| file.write(doc) }
				end
			end

		else
			puts "No clean git repository! Setup git and/or commit changes before deleting tags." 
		end

	end

end


class Tagh < Thor
	desc "list [arguments]", "List tags."
	option :source, :type => :array, :aliases => "-s"
	option :sublime, :aliases => "-u"
	option :file, :aliases => "-f"
	option :min
	option :max
	option :flat
	def list()
		r = Tagger.new
   		puts r.list(options)	
	end

	desc "find TAG [arguments]", "Find items tagged TAG in [source]"
	option :source, :type => :array, :aliases => "-s"
	option :file, :aliases => "-f"
	option :open, :aliases => "-o"
	def find(tag)
		r = Tagger.new
   		puts r.find(tag, options)	
	end

	desc "merge TAGS [arguments]", "Merge all TAGS into the last one specified."
	option :source, :type => :array, :aliases => "-s"
	def merge(*tags)
		r = Tagger.new
   		puts r.merge(tags, options)
	end

	desc "delete TAGS [arguments]", "Delete TAGS."
	option :source, :type => :array, :aliases => "-s"
	def delete(*tags)
		r = Tagger.new
   		puts r.delete(tags, options)
	end
end

Tagh.start(ARGV)


