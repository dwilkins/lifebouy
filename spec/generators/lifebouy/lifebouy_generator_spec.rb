require 'spec_helper'
require "generator_spec"

describe LifebouyGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)
#  arguments %w(GlobalWeather http://www.webservicex.net/globalweather.asmx?WSDL )
  arguments [ 'GlobalWeather', File.expand_path('../../../fixtures/service_definitions/globalweather.wsdl',__FILE__) ]
  it 'creates a controller file' do
    prepare_destination
    run_generator
    assert_file('app/controllers/global_weather_controller.rb',/class GlobalWeatherController < LifebouyController/)
    assert_file('app/controllers/global_weather_controller.rb',/def get_weather/)
    assert_file('app/controllers/global_weather_controller.rb',/def get_cities_by_country/)
  end
end
