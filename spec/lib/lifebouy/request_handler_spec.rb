require 'spec_helper'

module Lifebouy
  describe RequestHandler do
    let(:fixture_path) { File.expand_path(File.join('..', '..', '..', 'fixtures'), __FILE__) }
    let(:globalweather_wsdl) { File.join(fixture_path, 'service_definitions', 'globalweather.wsdl') }
    let(:valid_globalweather_request_1) { File.read(File.join(fixture_path, 'sample_requests', 'globalweather', 'get_cities_by_country_good.xml')) }
    let(:valid_globalweather_request_2) { File.read(File.join(fixture_path, 'sample_requests', 'globalweather', 'get_cities_by_country_bad.xml')) }

    it 'creates an instance without blowing up' do
      expect { RequestHandler.new(globalweather_wsdl) }.to_not raise_error
    end

    describe 'validate_request_xml!' do
      let(:request_validator) { RequestHandler.new(globalweather_wsdl) }

      it 'does not raise an error with a valid request' do
        expect {
          request_validator.validate_request_xml!(valid_globalweather_request_1)
        }.to_not raise_error
      end
      
      it 'does raise a MalformedRequestXml error with an invalid request and indicate the line of the error' do
        expect {
          request_validator.validate_request_xml!(valid_globalweather_request_2)
        }.to raise_error(MalformedRequestXml, /Line 7:/)
      end
    end
  end
end
