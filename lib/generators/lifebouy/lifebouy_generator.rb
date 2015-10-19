require 'rails/generators'
require 'open-uri'

class LifebouyGenerator < Rails::Generators::NamedBase
  attr_accessor :actions
  attr_accessor :wsdl
  source_root File.expand_path('../templates', __FILE__)
  desc File.read(File.expand_path('../USAGE', __FILE__))
  argument :wsdl, required: true,
           desc: "The file or URL of the WSDL for this service",
           banner: 'url_or_file_for_wsdl'
  check_class_collision suffix: "Controller"

  def create_lifebouy
    template 'controller.erb', File.join('app/controllers', class_path, "#{file_name}_controller.rb")
  end

  def actions
    @actions ||= wsdl_document.xpath('//wsdl:operation').collect do |operation|
      operation.attributes['name'].value.underscore
    end.uniq
  end

  private

  def wsdl_document
    @wsdl_document ||= Nokogiri::XML(open(wsdl).read)
  end

end
