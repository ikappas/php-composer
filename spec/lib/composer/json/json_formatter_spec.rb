require_relative '../../../spec_helper'

describe ::Composer::Json::JsonFormatter do

  context '::format' do

    it 'succeeds on unicode with prepended slash' do
      data = '"' + 92.chr + 92.chr + 92.chr + 'u0119"'
      encoded_data = described_class::format(data, true, true)
      expected = '34+92+92+196+153+34'
      expect( encoded_data.bytes.join('+') ).to be == expected
    end

  end

end
