require 'nokogiri'
require 'ostruct'
require 'active_support/core_ext/string'
require 'active_support/core_ext/date'

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
      target_namespace_url = @wsdl.root['targetNamespace']
      target_namespace = @wsdl.namespaces.select { |k,v| v == target_namespace_url}.first

      @schema_prefix = schema_namespace.first.split(/:/).last
      schema_root = @wsdl.at_xpath("//#{@schema_prefix}:schema").dup
      schema_root.add_namespace_definition(target_namespace.first.split(/:/).last, target_namespace.last)
      # Create a document to store the schema and the parse it into a Schema for validation
      @schema_doc = Nokogiri::XML::Document.new
      @schema_doc.namespaces[target_namespace.first] = target_namespace.last
      binding.pry
      @schema_doc << schema_root
      binding.pry
      @schema = Nokogiri::XML::Schema(@schema_doc.to_xml)
      
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
    
    def request_data
      @request_data ||= build_request_data
    end
    
    private
    def build_request_data
      @request_data = node_to_ostruct(@request_doc.first_element_child)
    end
    
    def node_to_ostruct(node)
      ret = OpenStruct.new
      ret[:name] = node.node_name
      node.element_children.each do |ele|
        if ele.element_children.count > 0
          ret[ele.node_name.underscore.to_sym] = node_to_ostruct(ele)
        else
          ret[ele.node_name.underscore.to_sym] = xml_to_type(ele)
        end
      end
      
      ret
    end
    
    def xml_to_type(node)
      return nil if node.text.blank?
      # find the type in the WSDL
      t_node = @schema_doc.at_xpath("//#{@schema_prefix}:element[@name='#{node.node_name}']")
      case t_node[:type].gsub(/#{@schema_prefix}:/, '')
      when 'decimal' || 'float'
        Float.parse(node.text)
      when 'integer'
        Integer.parse(node.text)
      when 'boolean'
        node.text == 'true'
      when 'date' || 'time' || 'dateTime'
        Date.parse(node.text)
      else
        node.text
      end
    end
  end
end