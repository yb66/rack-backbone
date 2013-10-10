# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/rack/backbone.rb"

class Rack::Backbone # for clarity!

describe "The class methods" do
  let(:path) {::File.join(DEFAULT_OPTIONS[:http_path],BACKBONE_FILE_NAME)}
  let(:env) { {"rack.backbone.http_path" => path} }
  subject(:cdn) { Rack::Backbone.cdn env, :organisation => organisation }

  context "Given the organisation option" do
    context "of nil (the default)" do
      let(:organisation) { nil }
      it { should == "<script src='#{CDN::CLOUDFLARE}'></script>\n#{FALLBACK_TOP}#{path}#{FALLBACK_BOTTOM}" }
    end
    context "of :jsdelivr" do
      let(:organisation) { :jsdelivr }
      it { should == "<script src='#{CDN::JSDELIVR}'></script>\n#{FALLBACK_TOP}#{path}#{FALLBACK_BOTTOM}" }
    end
    context "of :cloudflare" do
      let(:organisation) { :cloudflare }
      it { should == "<script src='#{CDN::CLOUDFLARE}'></script>\n#{FALLBACK_TOP}#{path}#{FALLBACK_BOTTOM}" }
    end
  end

  context "Given no Rack env argument" do
    it "should fail and give a message" do
      expect{ Rack::Backbone.cdn nil }.to raise_error(ArgumentError)
    end
    
    context "and an organisation option" do
      it "should fail and give a message" do
        expect{ Rack::Backbone.cdn nil, {:organisation => :jsdelivr} }.to raise_error(ArgumentError)
      end
    end
  end
end

describe "Inserting the CDN" do

  # These check the default is overriden
  # when `cdn` is given a value
  # but when not, the default is used.
  context "When given a default" do
    include_context "All routes" do
      let(:app){ AppWithDefaults }
    end
    context "Check the examples run at all" do
      before do
        get "/"
      end
      it_should_behave_like "Any route"
    end
    context "jsdelivr CDN" do
      before do
        get "/jsdelivr-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { CDN::JSDELIVR }
      it { should include expected }
    end
    context "Unspecified CDN" do
      before do
        get "/unspecified-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { CDN::CLOUDFLARE }
      it { should include expected }
    end
    context "Cloudflare CDN" do
      before do
        get "/cloudflare-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { CDN::CLOUDFLARE }
      it { should include expected }
    end
  end
  context "When not given a default" do
    include_context "All routes"
    context "Check the examples run at all" do
      before do
        get "/"
      end
      it_should_behave_like "Any route"
    end
    context "jsdelivr CDN" do
      before do
        get "/jsdelivr-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { CDN::JSDELIVR }
      it { should include expected }
    end
    context "Unspecified CDN" do
      before do
        get "/unspecified-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { CDN::CLOUDFLARE }
      it { should include expected }
    end
    context "Cloudflare CDN" do
      before do
        get "/cloudflare-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { CDN::CLOUDFLARE }
      it { should include expected }
    end
  end
end


require 'timecop'
require 'time'

describe "Serving the fallback backbone" do
  before do
    get path
  end
  subject { last_response.body }
  let(:path){ ::File.join(http_path, BACKBONE_FILE_NAME) }

  context "With the default :http_path (none given)" do
    include_context "All routes"
    let(:http_path) { DEFAULT_OPTIONS[:http_path] }

    it_should_behave_like "Any route"
    it { should start_with "(function(){var t=this;var e=t.Backbone;" }

    context "Re requests" do
      before do
        at_start = Time.parse(BACKBONE_VERSION_DATE) + 60 * 60 * 24 * 180
        Timecop.freeze at_start
        get path
        Timecop.travel Time.now + 86400 # add a day
        get path, {}, {"HTTP_IF_MODIFIED_SINCE" => Rack::Utils.rfc2109(at_start) }
      end
      subject { last_response }
      its(:status) { should == 304 }
    end
  end
  context "Given a different http_path via the options" do
    include_context "All routes" do
      let(:app) {
        Sinatra.new do
          use Rack::JQuery
          use Rack::Lodash
          use Rack::Backbone, :http_path => "/assets/javascripts"
        end
      }
    end
    context "That is valid" do
      let(:http_path) { "/assets/javascripts" }

      it_should_behave_like "Any route"
      it { should start_with "(function(){var t=this;var e=t.Backbone;" }
    end
    context "That is not valid" do
      let(:http_path) { "/this/is/not/the/path/it/was/setup/with" }
      subject { last_response }
      it { should_not be_ok }
    end
  end
end

end