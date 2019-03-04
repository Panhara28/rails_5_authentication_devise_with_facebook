# Getting Started
Starting with version 1.2, Devise supports integration with OmniAuth. This tutorial will cover the basics of using the OAuth provider for this integration.

Starting with version 1.5, Devise supports OmniAuth 1.0 forwarding, which will be the version covered in this tutorial

# Installation
first of all, you need to know how to install and configure these gem below before you're getting started

```
gem "devise"
gem "omniauth-facebook"
gem "koala"
```
then ``` bundle install ```
# Configuration
If you install devise gem you will have devise.rb file and then add this line to that file locate at: 
~~~ruby
/config/initialize/devise.rb
config.omniauth :facebook, Rails.application.secrets.facebook_app_id, Rails.application.secrets.facebook_app_secret, scope: 'email,user_posts'
~~~
If you install koala you will also have that configuration file locate at: 
~~~ruby
/config/initialize/koala.rb
config.app_id = Rails.application.secrets.facebook_app_id
config.app_secret = Rails.application.secrets.facebook_app_secret
~~~
after you configure these two files you need to go to routes.rb to defined route like this: 
~~~ruby
devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
~~~
# Model
after you install devise gem you will need to generate for model call user
```
rails g devise user
```
and then make sure that code is added to the user.rb file locate at: 
~~~ruby
devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable
~~~
after you added this code you need to generate this model call service that have these attributes:
 * provider (string)
 * uid (string)
 * access_token (string)
 * access_token_secret (string)
 * refresh_token (string)
 * expired_at (date)
 * auth (text)
after you generate model service you need to add this huge code
~~~ruby
%w{ facebook twitter }.each do |provider|
    scope provider, ->{ where(provider: provider) }
  end

  def client
    send("#{provider}_client")
  end

  def expired?
    expires_at? && expires_at <= Time.zone.now
  end

  def access_token
    send("#{provider}_refresh_token!", super) if expired?
    super
  end

  def facebook_client
    Koala::Facebook::API.new(access_token)
  end

  def facebook_refresh_token!(token)
    new_token_info = Koala::Facebook::OAuth.new.exchange_access_token_info(token)
    update(access_token: new_token_info["access_token"], expires_at: Time.zone.now + new_token_info["expires_in"])
  end
~~~

# Controller
If you have done the step below you need to write code to controller so
### step 1 (you need to generate devise scope user controller with omniauth_callbacks_controller.rb and write this code below)


