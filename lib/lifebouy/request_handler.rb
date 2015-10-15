require 'nokogiri'

module Lifebouy
  class MalformedRequestXml < StandardError
    def initialize(xml_errors)
      @xml_errors = xml_errors
    end

    def message
      "The request contains the following errors:\n\t#{@xml_errors.join("\n\t")}"
    end
  end

  class RequestHandler
    attr_reader :request_error, :schema, :request_doc

    def initialize(wsdl_file, request_xml)
      @wsdl = Nokogiri::XML(File.read(wsdl_file))
      # Find the root schema node
      schema_namespace = @wsdl.namespaces.select { |k,v| v =~ /XMLSchema/ }.first
      schema_prefix = schema_namespace.first.split(/:/).last
      schema_root = @wsdl.at_xpath("//#{schema_prefix}:schema")

      # Create a document to store the schema and the parse it into a Schema for validation
      schema_doc = Nokogiri::XML::Document.new
      schema_doc << schema_root
      @schema = Nokogiri::XML::Schema(schema_doc.to_xml)
      
      envelope = Nokogiri::XML(request_xml)
      request_data = envelope.at_xpath("//#{envelope.root.namespace.prefix}:Body").first_element_child
      @request_doc = Nokogiri::XML::Document.new
      @request_doc << request_data
    end

    def validate_request_xml?
      begin
        validate_request_xml!
        return true
      rescue MalformedRequestXml => e
        @request_error = e
        return false
      end
    end

    def validate_request_xml!
      request_errors = []

      @schema.validate(request_doc).each do |error|
        request_errors << "Line #{error.line}: #{error.message}"
      end

      raise MalformedRequestXml.new(request_errors) unless request_errors.empty?
    end
  end
end