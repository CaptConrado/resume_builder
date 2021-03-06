require 'rubygems' # for pdf/reader inside prawn

require 'prawn'
require "prawn/measurement_extensions"


class Header
  def initialize(name, address, phone_number)
    @name = name
    @address = address
    @phone_number = phone_number
  end 

  def title_name
    @name
  end
  def address
    @address
  end
  def phone
    @phone_number
  end
end




module Resume
  Experience = Struct.new(:company, :role, :time, :location, :summary, :points)
  FILE = 'ottey_resume'
  
  def self.convert
    reader = Reader.new(FILE + '.txt')
    Writer.new(FILE + '.pdf', reader)
    `open #{FILE + '.pdf'}`
  end
  
  class Reader
    def initialize(filename)
      @filename = filename
      @str = File.read(filename)
      @experiences = []
      parse(@str)
    end
    attr_accessor :str
    
    attr_reader :name, :phone, :email, :groups, :experiences
    attr_reader :objective, :languages, :frameworks, :strengths, :education
    
    def parse(str)
      # get the '~ ~ ~ ...' experience line seperator:
      experience_delimeter = str[/^([\s~]+)$\n/, 1]
      
      # get top resume, and array of experiences:
      about_me, *experiences = str.split(experience_delimeter)
      
      # parse sections:
      @top = parse_top(about_me)
      @experiences = parse_experiences(experiences)
    end
    
    # quick and dirty for now:
    def parse_top(top)
      @name, @phone, @email, *rest = top.split("\n")

      _, @objective, _, @languages, @frameworks, @strengths, *rest2 = rest
      @education = rest2[1..3].join("\n")
      
      [@objective, @languages, @frameworks, @strengths, @education].each {|s| 
        s.gsub!(/^\w+:/, '')
      }
    end
    
    def parse_experiences(experiences)
      many_spaces = /\s{5,}/
      experiences.map do |experience|
        meta, summary, points = experience.strip.split("\n\n")
        
        # extract metadata about the job
        role_and_time, company_and_location = meta.split("\n")
        role, time = role_and_time.split(many_spaces)
        company, location = company_and_location.split(many_spaces)
        
        # cleanup summary and experience points
        summary = cleanup(summary)
        points = points.split(/-\s/)[1..-1].map {|point| cleanup(point)}
        
        Experience.new(company, role, time, location, summary, points)
      end
    end
    
    # Remove newlines
    # Remove multiple spaces not following a period
    def cleanup(str)
      str.gsub(/\n/, '').gsub(/[^.]\s{2,}/, ' ')
    end
  end
  
  class Writer
    def initialize(filename, data)
      @filename, @data = filename, data
      pdf = PDF.new { @data = data }
      pdf.render_file(filename)
    end
  end

  @header = Header.new("Conrado","8233 Calle De Humo San Diego, CA 92126","858.213.3362 Ottey001@gmail.com")
    puts @header.title_name
  
  class PDF < Prawn::Document
    attr_accessor :data
    
    def render
      font_size 10
      # font "/System/Library/Fonts/HelveticaNeue.dfont"
      # font "/System/Library/Fonts/BigCaslon.ttf"
      
      # top
      text @data.name, :align => :left, :size => 30
      move_up 29
      text @data.phone, :align => :right, :size => 10
      text @data.email, :align => :right, :size => 10
      stroke_horizontal_rule
      move_down 4
      
      left_width = 70
      right_width = bounds.width - left_width
      
      # quick and dirty:
      table([
        ['Objective:', @data.objective],
        [nil, nil],
        [nil, nil],
        [nil, nil],
        ['Languages:', @data.languages],
        ['Frameworks:', @data.frameworks],
        ['Strengths:', @data.strengths],
        ['Education:', @data.education],
        ['Experience:', nil],
        [nil, nil],
        [nil, nil],
        [nil, nil]
      ], :column_widths => [left_width, right_width], :cell_style => {:borders => [], :padding => 1})

      @data.experiences.each {|e| render_experience(e) }
      super
    end
          
    def render_experience(experience)
       # start new page, kinda hacky:
      bounds.move_past_bottom if cursor < 100
      
      stroke_horizontal_rule
      move_down 9
      
      edges_text(experience.role, experience.time)
      edges_text(experience.company, experience.location)
      move_down 5
      
      text experience.summary
      move_down 3
      
      experience.points.each do |point|
        bullet(point)
      end
      move_down 10
    end
    
    def nbsp(count=1)
      Prawn::Text::NBSP * count
    end
    
    def bullet(text)
      bullet_width = 10
      table([
        ["#{nbsp}-#{nbsp}", text],
      ], :column_widths => [bullet_width, bounds.width - bullet_width], :cell_style => {:borders => [], :padding => [2,0,0,0]})
    end
    
    # draw left and right aligned text on the same line
    def edges_text(left_aligned_text, right_aligned_text)
      y = cursor
      text left_aligned_text, :align => :left
      move_cursor_to y
      text right_aligned_text, :align => :right
    end
  end
end


if $0 == __FILE__
  Resume.convert
end
