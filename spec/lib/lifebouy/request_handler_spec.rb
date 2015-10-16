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
    
    describe 'request_data' do
      it 'builds the expected request data' do
        request_data = request_handler_valid.request_data
        expect(request_data).to_not be_nil
        expect(request_data.name).to eq('GetCitiesByCountry')
        expect(request_data.country_name).to eq('United States')
      end
      
      it 'builds request data with more than one parameter' do
        wsdl_file = File.join(fixture_path, 'service_definitions', 'mortgage.wsdl')
        request_text = File.read(File.join(fixture_path, 'sample_requests', 'mortgage', 'get_mortgage_payment_good.xml'))
        handler = RequestHandler.new(wsdl_file, request_text)
        expect(handler.validate_request_xml?).to be_truthy
        request_data = handler.request_data
        expect(request_data).to_not be_nil
        expect(request_data.years).to eq(30)
        expect(request_data.interest).to eq(3.5)
        expect(request_data.loan_amount).to eq(150000.00)
        expect(request_data.annual_tax).to eq(2000.00)
        expect(request_data.annual_insturance).to eq(750.00)
      end
    end
  end
end
