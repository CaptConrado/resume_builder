require 'prawn'


@job = gets



Prawn::Document.generate('ottey_coverletter.pdf') do 
  



text "Hello #{@job}"



end