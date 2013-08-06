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

@header = Header.new("Conrado","8233 Calle De Humo San Diego, CA 92126","858.213.3362 Ottey001@gmail.com")
