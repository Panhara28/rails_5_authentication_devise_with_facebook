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
 * provider
 * uid (string)
 * access_token (string)
 * access_token_secret (string)
 * refresh_token (string)
 * expired_at (date)
 * auth (text)


