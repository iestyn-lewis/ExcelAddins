
# A simple splitter for *.sdf.gz files available
# from PubChem's FTP-server.
class SDFSplitter
  @@stop = "$$$$\n"
  @@blank = ""

  # Configures this SDFGZSplitter using the <tt>IO</tt>
  # object <tt>io</tt>.
  def initialize(filename)
    @gzip = File.open(filename, "r")
  end

  # Yield a sequence of SDFile records.
  def each_record
    record = get_record

    while record != @@blank
      yield record
      record = get_record
    end
  end

  # Gets the next record, or an empty string if
  # none is available.
  def get_record
    line = read_line
    record = [line]

    while !(@@stop.eql?(line) || nil == line)
      line = read_line
      record << line
    end

    record.join
  end

  private

  # Reads the next line in the SDFGZ file.
  def read_line
    begin
      line = @gzip.readline
    rescue EOFError
      return nil
    end

    line
  end
end

# Utility class for getting data out of a SDFile record.
class Extractor
  # Gets the data from <tt>record</tt> associated with
  # <tt>key</tt>.
  def self.extract_data(record, key)
    record.match(/> <#{key}>\n(.+)\n/)
    $1
  end

  # Gets the molfile for <tt>record</tt>.
  def self.extract_molfile(record)
    record.match(/M  END$/).pre_match + "M  END\n"
  end
end 
