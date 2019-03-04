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
If you install devise gem you will have devise.rb file and then add this line to that file
~~~ruby
config.omniauth :facebook, Rails.application.secrets.facebook_app_id, Rails.application.secrets.facebook_app_secret, scope: 'email,user_posts'
~~~


