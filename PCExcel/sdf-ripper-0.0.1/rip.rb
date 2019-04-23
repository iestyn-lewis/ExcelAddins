require 'rubygems'
require_gem 'rcdk'
require 'rcdk/util'
require 'sdfgz'
require 'erb'

class SDFRipper

  def initialize(sdfgz_filename, output_dir, image_width, image_height)
    @filename = sdfgz_filename
    @output_dir = output_dir
    @image_width = image_width
    @image_height = image_height

    begin
      Dir.mkdir(output_dir)
      Dir.mkdir("#{@output_dir}/images")

      puts "Created image directories."
    rescue
      puts "Re-using image directories."
    end
  end

  def rip(start_cid, end_cid)
    @start_cid = start_cid
    @end_cid = end_cid

    rip_png
    rip_html
  end

  def rip_png
    puts "Scanning..."

    file = File.new(@filename)
    splitter = SDFGZSplitter.new(file)

    splitter.each_record do |record|
      cid = Extractor.extract_data(record, 'PUBCHEM_COMPOUND_CID')

      if (cid.to_i <= @end_cid)
        if (cid.to_i >= @start_cid)
          write_image(Extractor.extract_data(record, 'PUBCHEM_OPENEYE_CAN_SMILES'), cid)
        end
      else
        break
      end
    end

    file.close
  end

  def rip_html
    template = IO.read('template.rhtml')
    erb = ERB.new(template)

    File.open("#{@output_dir}/index.html", 'w+') do |file|
      file << erb.result(binding)
    end
  end

  def write_image(smiles, cid)
    begin
      RCDK::Util::Image.smiles_to_png(smiles, "#{@output_dir}/images/#{cid}.png", @image_width, @image_height)

      puts "Wrote CID-#{cid}"
    rescue
      puts "CDK Error: Skipping CID-#{cid} for SMILES-#{smiles}"
    end
  end
end

