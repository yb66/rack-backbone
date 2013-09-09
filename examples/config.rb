require 'sinatra/base'
require 'haml'
require 'rack/backbone'

class App < Sinatra::Base

  enable :inline_templates
  use Rack::Lodash
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
    = Rack::Lodash.cdn( env )
    = Rack::Backbone.cdn( env, :organisation => :jsdelivr )
  = yield

@@cloudflare
%html
  %head
    = Rack::Lodash.cdn( env )
    = Rack::Backbone.cdn( env, :organisation => :cloudflare )
  = yield

@@unspecified
%html
  %head
    = Rack::Lodash.cdn( env )
    = Rack::Backbone.cdn(env)
  = yield

@@index
  
%input{ type: "text" placeholder: "Enter friend's name" id: "input"}
%button#add-input
  Add Friend

%ul#friends-list

:javascript
  $(function() {

  FriendList = Backbone.Collection.extend({
      initialize: function(){
  
      }
  });
  
  FriendView = Backbone.View.extend({
  
      tagName: 'li',
  
      events: {
          'click #add-input':  'getFriend',
      },
  
      initialize: function() {
          var thisView = this;
          this.friendslist = new FriendList;
          _.bindAll(this, 'render');
          this.friendslist.bind("add", function( model ){
              alert("hey");
              thisView.render( model );
          })
      },
  
      getFriend: function() {
          var friend_name = $('#input').val();
          this.friendslist.add( {name: friend_name} );
      },
  
      render: function( model ) {
          $("#friends-list").append("<li>"+ model.get("name")+"</li>");
          console.log('rendered')
      },
  
  });
  
  var view = new FriendView({el: 'body'});
  });
