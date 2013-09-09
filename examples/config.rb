require 'sinatra/base'
require 'haml'
require 'rack/backbone'
require 'rack/lodash'
require 'rack/jquery'

class App < Sinatra::Base

  enable :inline_templates
  use Rack::JQuery    # << These are just here for the example.
  use Rack::Lodash    # << Just make sure any dependencies are
                      # available, however you decide to do that.
  use Rack::Backbone

  get "/" do
    output = <<STR
!!!
%body
  %ul
    %li
      %a{ href: "/jsdelivr-cdn"} jsdelivr-cdn
    %li
      %a{ href: "/cloudflare-cdn"} cloudflare-cdn
    %li
      %a{ href: "/unspecified-cdn"} unspecified-cdn
STR
    haml output
  end

  get "/jsdelivr-cdn" do
    haml :index, :layout => :jsdelivr
  end

  get "/cloudflare-cdn" do
    haml :index, :layout => :cloudflare
  end

  get "/unspecified-cdn" do
    haml :index, :layout => :unspecified
  end
end


class AppWithDefaults < Sinatra::Base

  enable :inline_templates
  use Rack::JQuery
  use Rack::Lodash
  use Rack::Backbone, :organisation => :cloudflare

  get "/" do
    output = <<STR
!!!
%body
  %ul
    %li
      %a{ href: "/jsdelivr-cdn"} jsdelivr-cdn
    %li
      %a{ href: "/cloudflare-cdn"} cloudflare-cdn
    %li
      %a{ href: "/unspecified-cdn"} unspecified-cdn
STR
    haml output
  end

  get "/jsdelivr-cdn" do
    haml :index, :layout => :jsdelivr
  end

  get "/cloudflare-cdn" do
    haml :index, :layout => :cloudflare
  end

  get "/unspecified-cdn" do
    haml :index, :layout => :unspecified
  end
end

__END__

@@jsdelivr
%html
  %head
    = Rack::JQuery.cdn( env )
    = Rack::Lodash.cdn( env )
    = Rack::Backbone.cdn( env, :organisation => :jsdelivr )
  = yield

@@cloudflare
%html
  %head
    = Rack::JQuery.cdn( env )
    = Rack::Lodash.cdn( env )
    = Rack::Backbone.cdn( env, :organisation => :cloudflare )
  = yield

@@unspecified
%html
  %head
    = Rack::JQuery.cdn( env )
    = Rack::Lodash.cdn( env )
    = Rack::Backbone.cdn(env)
  = yield

@@index
  
%input{ type: "text", placeholder: "Enter friend's name", id: "input"}
%button#add
  Add Friend

%ul#friends

:javascript
  $(function() {

  FriendList = Backbone.Collection.extend({
      initialize: function(){
      }
  });

  FriendView = Backbone.View.extend({
      tagName: 'li',
      events: {
          'click #add':  'getFriend',
      },
      initialize: function() {
          var thisView = this;
          this.friendslist = new FriendList;
          _.bindAll(this, 'render');
          this.friendslist.bind("add", function( model ){
              thisView.render( model );
          })
      },
      getFriend: function() {
          var friend_name = $('#input').val();
          this.friendslist.add( {name: friend_name} );
      },
      render: function( model ) {
          $("#friends").append("<li>"+ model.get("name")+"</li>");
      },
  });

  var view = new FriendView({el: 'body'});
  });
