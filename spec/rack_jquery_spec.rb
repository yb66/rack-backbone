# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/rack/backbone.rb"

describe "The class methods" do
  let(:env) { {} }
  subject { Rack::Backbone.cdn env, :organisation => organisation }

  context "Given the organisation option" do
    context "of nil (the default)" do
      let(:organisation) { nil }
      it { should == "<script src='#{Rack::Backbone::CDN::CLOUDFLARE}'></script>\n#{Rack::Backbone::FALLBACK}" }
    end
    context "of :jsdelivr" do
      let(:organisation) { :jsdelivr }
      it { should == "<script src='#{Rack::Backbone::CDN::JSDELIVR}'></script>\n#{Rack::Backbone::FALLBACK}" }
    end
    context "of :cloudflare" do
      let(:organisation) { :cloudflare }
      it { should == "<script src='#{Rack::Backbone::CDN::CLOUDFLARE}'></script>\n#{Rack::Backbone::FALLBACK}" }
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
      let(:expected) { Rack::Backbone::CDN::JSDELIVR }
      it { should include expected }
    end
    context "Unspecified CDN" do
      before do
        get "/unspecified-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { Rack::Backbone::CDN::CLOUDFLARE }
      it { should include expected }
    end
    context "Cloudflare CDN" do
      before do
        get "/cloudflare-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { Rack::Backbone::CDN::CLOUDFLARE }
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
      let(:expected) { Rack::Backbone::CDN::JSDELIVR }
      it { should include expected }
    end
    context "Unspecified CDN" do
      before do
        get "/unspecified-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { Rack::Backbone::CDN::MEDIA_TEMPLE }
      it { should include expected }
    end
    context "Cloudflare CDN" do
      before do
        get "/cloudflare-cdn"
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      let(:expected) { Rack::Backbone::CDN::CLOUDFLARE }
      it { should include expected }
    end
  end
end


require 'timecop'
require 'time'

describe "Serving the fallback backbone" do
  include_context "All routes"
  before do
    get "/js/backbone-#{Rack::Backbone::BACKBONE_VERSION}-min.js"
  end
  it_should_behave_like "Any route"
  subject { last_response.body }
  it { should start_with "/*! Backbone v#{Rack::Backbone::BACKBONE_VERSION}" }

  context "Re requests" do
    before do
      at_start = Time.parse(Rack::Backbone::BACKBONE_VERSION_DATE) + 60 * 60 * 24 * 180
      Timecop.freeze at_start
      get "/js/backbone-#{Rack::Backbone::BACKBONE_VERSION}-min.js"
      Timecop.travel Time.now + 86400 # add a day
      get "/js/backbone-#{Rack::Backbone::BACKBONE_VERSION}-min.js", {}, {"HTTP_IF_MODIFIED_SINCE" => Rack::Utils.rfc2109(at_start) }
    end
    subject { last_response }
    its(:status) { should == 304 }
    
  end
end