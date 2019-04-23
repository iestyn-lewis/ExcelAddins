require 'rip'

filename = 'Compound_00000001_00025000.sdf.gz'
ripper = SDFRipper.new(filename, 'rip', 150, 150)

ripper.rip(1, 500)


