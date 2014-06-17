require 'spec_helper'

describe OutboundCaller do
  describe '#new' do
    context 'when necessary environment variables are set' do
      let(:fake_good_env) do
        { 'TWILIO_SID' => 'fakesid',
          'TWILIO_AUTH' => 'fakeauth',
          'TWILIO_NUMBER' => '+15005550006' }
      end
      let(:outbound_caller) { OutboundCaller.new }

      before(:each) do
        stub_const('ENV', fake_good_env)
      end

      it 'initializes a Twilio client' do
        expect(outbound_caller.client).to be_a(Twilio::REST::Client)
      end

      it 'contains a properly-configured client' do
        expect(outbound_caller.client.account_sid).to eq(fake_good_env['TWILIO_SID'])
        expect(outbound_caller.client.instance_variable_get("@auth_token")).to eq(fake_good_env['TWILIO_AUTH'])
      end
    end

    context 'when necessary environment variables are NOT set' do
      let(:fake_bad_env) do
        { 'TWILIO_SID' => 'fakesid',
          'TWILIO_NUMBER' => '12223334444' }
      end

      before(:each) do
        stub_const('ENV', fake_bad_env)
      end

      it 'raises StandardError and says the missing env var(s)' do
        expect { OutboundCaller.new }.to raise_error(StandardError, "Missing environment variable(s): [\"TWILIO_AUTH\"]")
    end
  end

  describe '#call' do
    let(:fake_good_env) do
      { 'TWILIO_SID' => 'AC96b99a489a8045a0cfac2c1857af81e9',
        'TWILIO_AUTH' => 'cd3e727407ed725851e8163b8a022f41',
        'TWILIO_NUMBER' => '+15005550006' }
    end
    let(:outbound_caller) { OutboundCaller.new }
    let(:fake_outbound_number) { '+14108675309' }
    let(:fake_twiml_url) { 'https://example.com/fake.xml' }

    before do
      stub_const('ENV', fake_good_env)
    end

    it 'makes an outbound Twilio call with the correct info' do
      VCR.use_cassette('twilio-outbound-test') do
        outbound_call = outbound_caller.call(fake_outbound_number, fake_twiml_url)
        expect(outbound_call).to be_a(Twilio::REST::Call)
        expect(outbound_call.to).to eq(fake_outbound_number)
        expect(outbound_call.from).to eq(fake_good_env['TWILIO_NUMBER'])
        # Note: response doesn't contain URL or method sent, so not testing here
      end
    end
  end
  end
end
