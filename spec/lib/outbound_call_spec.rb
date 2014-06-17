require 'spec_helper'

describe OutboundCaller do
  describe '#new' do
    context 'when necessary environment variables are set' do
      let(:fake_good_env) do
        { 'TWILIO_SID' => 'fakesid',
          'TWILIO_AUTH' => 'fakeauth',
          'TWILIO_NUMBER' => '12223334444' }
      end
      let(:caller) { OutboundCaller.new }

      before(:each) do
        stub_const('ENV', fake_good_env)
      end

      it 'initializes a Twilio client' do
        expect(caller.client).to be_a(Twilio::REST::Client)
      end

      it 'contains a properly-configured client' do
        expect(caller.client.account_sid).to eq(fake_good_env['TWILIO_SID'])
        expect(caller.client.instance_variable_get("@auth_token")).to eq(fake_good_env['TWILIO_AUTH'])
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
      { 'TWILIO_SID' => 'fakesid',
        'TWILIO_AUTH' => 'fakeauth',
        'TWILIO_NUMBER' => '12223334444' }
    end
    let(:caller) { OutboundCaller.new }
    let(:fake_outbound_number) { '19998887777' }
    let(:fake_twiml_url) { 'https://example.com/fake.xml' }

    before do
      stub_const('ENV', fake_good_env)
    end

    it 'makes an outbound Twilio call' do
      caller.client.stub_chain(:account, :calls, :create)
      #caller.client.account.calls.stub(:create)
      caller.call(fake_outbound_number, fake_twiml_url)
      expect(caller.client.account.calls).to receive(:create).with(
        { from: fake_good_env['TWILIO_NUMBER'],
        to: fake_outbound_number,
        url: fake_twiml_url,
        method: 'GET' } )
    end
  end
  end
end
