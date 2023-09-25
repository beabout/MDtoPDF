require 'prawn'
require 'yaml'

Prawn::Fonts::AFM.hide_m17n_warning = true

def main
	check_args
	load_styles
	create_pdf
end

def check_args
	@md_file_path = ARGV[0]
	if @md_file_path.nil? or !@md_file_path.match? Regexp.new(".md$")
		puts 'use: ruby md_to_pdf.rb MARKDOWN_FILE'
		exit 1
	end
end

def load_styles
	styles = YAML.load_file("styles.yml")
	@styles = styles["styles"]
end

def create_pdf
	file = File.open(@md_file_path)
	# TODO: catch FileNotFound errors
	@md_data = file.readlines.map(&:chomp)

	@pdf = Prawn::Document.new
	@pdf.font_size 10
	@pdf.font 'Helvetica'
	@y = 720
	#@pdf.stroke_axis

	@pdf.bounding_box([0, 720], width: 525, height: 720) do
		#@pdf.stroke_bounds
		@md_data.each do |line|
			if line.start_with?("#")
				header(line)
			elsif line.start_with?("-")
				list_item(line)
			elsif line.start_with?("\t-")
				list_item(line, 1)
			else
				paragraph(text)

			end
			move_y 10
		end
	end

	# todo, implement
	# - italics
	# - bold
	# - tables
	# - underline
	# - links


	@pdf.render_file("output.pdf")
end

def paragraph(text)
	@pdf.text line, align: :left
	@pdf.move_down 2
end

def hr
	@pdf.line [ 0, @pdf.cursor ], [ 550, @pdf.cursor ]
	@pdf.stroke
end

def header(line)
	levels_str, text = line.split(" ", 2)
	levels = levels_str.count('#')
	header_class = begin
		if (1..4).include? levels
			("h" + levels.to_s)
		else
			'h2'
		end
	end
	@pdf.font_size @styles[header_class]['fontSize']
	@pdf.move_down 8
	@pdf.text text, align: :left, style: @styles[header_class]['fontStyle']
	@pdf.move_down 8
	@pdf.font_size 10
end

def list_item(line, level=0)
	dash, text = line.split("-", 2)
	offset = level.eql?(0) ? 0 : (level * 15)

	@pdf.float do
		@pdf.bounding_box [15 + offset, @pdf.cursor], width: 10 do 
			@pdf.text "•"
		end
	end
	@pdf.bounding_box [25 + offset, @pdf.cursor], width: (500 - offset) do
		@pdf.text text, align: :left
	end
end
	
def link(text)
	title, link = text.gsub("[", "").gsub("]", "").split("|")
	@pdf.text "<u><link href='#{link}'><color rgb='#{@styles['link']['color']}'>#{title}</color></link></u>", inline_format: true
end

def	move_y(i)
	@y -= i
end

main


