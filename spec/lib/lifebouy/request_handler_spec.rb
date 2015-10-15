require 'spec_helper'

module Lifebouy
  describe RequestHandler do
    let(:fixture_path) { File.expand_path(File.join('..', '..', '..', 'fixtures'), __FILE__) }
    let(:globalweather_wsdl) { File.join(fixture_path, 'service_definitions', 'globalweather.wsdl') }
    let(:valid_globalweather_request_1) { File.read(File.join(fixture_path, 'sample_requests', 'globalweather', 'get_cities_by_country_good.xml')) }
    let(:valid_globalweather_request_2) { File.read(File.join(fixture_path, 'sample_requests', 'globalweather', 'get_cities_by_country_bad.xml')) }
    let(:request_handler_valid) { RequestHandler.new(globalweather_wsdl, valid_globalweather_request_1) }
    let(:request_handler_invalid) { RequestHandler.new(globalweather_wsdl, valid_globalweather_request_2) }

    it 'creates an instance without blowing up' do
      expect { RequestHandler.new(globalweather_wsdl, valid_globalweather_request_1) }.to_not raise_error
    end

    describe 'validate_request_xml!' do
      

      it 'does not raise an error with a valid request' do
        expect {
          request_handler_valid.validate_request_xml!
        }.to_not raise_error
      end
      
      it 'does raise a MalformedRequestXml error with an invalid request and indicate the line of the error' do
        expect {
          request_handler_invalid.validate_request_xml!
        }.to raise_error(MalformedRequestXml, /Line 7:/)
      end
    end
    
    describe 'validate_request_xml?' do
      it 'returns true with a valid request' do
        expect(
          request_handler_valid.validate_request_xml?
        ).to be_truthy
      end
      
      it 'returns false with an invalid request' do
        expect(
          request_handler_invalid.validate_request_xml?
        ).to be_falsey
        
        expect(request_handler_invalid.request_error).to_not be_nil
      end
    end
  end
end
