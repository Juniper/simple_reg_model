Gem::Specification.new do |s|
  s.name = 'srm'
  s.version = '1.0.0'
  s.summary = "Simple Reg Model"
  s.description = "This has utilities required to specify and generate srm regsiter model for uvm testbenches"
  s.authors = 'Sanjeev Singh'
  s.email = "snjvsingh123@gmail.com"
  s.homepage = "http://github.com/sanjeevs"
  s.files = ["lib/srm.rb", "lib/field.rb", "lib/register_array.rb", "lib/register.rb", "lib/reg_block.rb"]
  s.executables << 'rgen'
  s.license = 'MIT'
end
