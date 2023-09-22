require 'prawn'

Prawn::Fonts::AFM.hide_m17n_warning = true

def main
	check_args
	create_pdf
end

def check_args
	@md_file_path = ARGV[0]
	if @md_file_path.nil? or !@md_file_path.match? Regexp.new(".md$")
		puts 'use: ruby md_to_pdf.rb MARKDOWN_FILE'
		exit 1
	end
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
				@pdf.text line, align: :left
				@pdf.move_down 2
			end
			move_y 10
		end
	end

	@pdf.render_file("output.pdf")
end

def hr
	@pdf.line [ 0, @pdf.cursor ], [ 550, @pdf.cursor ]
end

def header(line)
	levels_str, text = line.split(" ", 2)
	levels = levels_str.count('#')

	case levels
	when 1
		@pdf.font_size 24
		@pdf.text text, align: :left, style: :bold
		@pdf.move_down 8
	when 2
		@pdf.font_size 18
		@pdf.text text, align: :left, style: :bold
		hr
		@pdf.move_down 6
	when 3
		@pdf.font_size 14
		@pdf.text text, align: :left
		@pdf.move_down 4
	when 4
		@pdf.font_size 12
		@pdf.text text, align: :left
		@pdf.move_down 2
	else
		@pdf.font_size 24
		@pdf.text text, align: :left
		@pdf.move_down 8
	end
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

def	move_y(i)
	@y -= i
end

main


