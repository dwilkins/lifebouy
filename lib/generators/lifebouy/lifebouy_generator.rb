class LifebouyGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  desc "Generate a Rails service from a WSDL"
  def create_initializer_file
    create_file "config/initializers/lifebouy_initializer.rb", "# Add initialization content here"
  end
end
