require 'pathname'

class SimCfiles
  attr_reader :src_files, :files, :incdirs, :src_incdirs, :unit_tests, :src_unit_tests,
              :unit_test_pkg

  def initialize(cfg_file)
    @files = []
    @src_files = []
    @incdirs = []
    @src_incdirs = []
    @unit_tests = []
    @src_unit_tests = []

    # Read the file list treating each entry as a glob pattern.
    # Convert the relative path to absolute path.
    prefix = File.dirname(cfg_file)
    Dir.chdir(prefix) do
      eval(File.read(File.basename(cfg_file)))
      files.each do |pattern|
        Dir.glob(pattern).each do |f|
          @src_files << get_absolute_path(f)
        end
      end

      incdirs.each do |d|
        @src_incdirs << get_absolute_path(d)
      end

      unit_tests.each do |pattern|
        Dir.glob(pattern).each do |f|
          @src_unit_tests << File.basename(f, ".*")
        end
      end
    end
    abort "Must define the unit test packet" unless unit_test_pkg
  end

  def get_absolute_path(fname)
    File.expand_path(fname)
  end

  def get_binding
    binding()
  end

end

