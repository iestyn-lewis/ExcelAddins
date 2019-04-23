require 'c:\chemexcel\rip_sdf'

filename = ARGV[0]
outdir = ARGV[1]
width = ARGV[2]
height = ARGV[3]
gen_coords = ARGV[4]

ripper = SDFRipper.new(filename, outdir, width, height, gen_coords)
ripper.rip


