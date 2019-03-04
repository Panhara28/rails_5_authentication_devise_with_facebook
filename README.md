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
### step 1 
you need to generate devise scope user controller with omniauth_callbacks_controller.rb and write this code below
```
rails g devise:controllers users
```
and you will have this file ```/controllers/users/omniauth_callbacks_controller.rb```
after that add this
```
  before_action :set_service
  before_action :set_user
  
  attr_reader :service, :user

  def facebook
    handle_auth "Facebook"
  end

  private

  def handle_auth(kind)
    if service.present?
      service.update(service_attrs)
    else
      user.services.create(service_attrs)
    end

    if user_signed_in?
      flash[:notice] = "Your #{kind} account was connected."
      redirect_to edit_user_registration_path
    else
      sign_in_and_redirect user, event: :authentication
      set_flash_message :notice, :success, kind: kind
    end
  end

  def auth
    request.env['omniauth.auth']
  end

  def set_service
    @service = Service.where(provider: auth.provider, uid: auth.uid).first
  end

  def set_user
    if user_signed_in?
      @user = current_user
    elsif service.present?
      @user = service.user
    elsif User.where(email: auth.info.email).any?
      # 5. User is logged out and they login to a new account which doesn't match their old one
      flash[:alert] = "An account with this email already exists. Please sign in with that account before connecting your #{auth.provider.titleize} account."
      redirect_to new_user_session_path
    else
      @user = create_user
    end
  end

  def service_attrs
    expires_at = auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
    {
        provider: auth.provider,
        uid: auth.uid,
        expires_at: expires_at,
        access_token: auth.credentials.token,
        access_token_secret: auth.credentials.secret,
    }
  end

  def create_user
    User.create(
      email: auth.info.email,
      #name: auth.info.name,
      password: Devise.friendly_token[0,20]
    )
  end
```

# Finale
If you have home controller as root page you need to defined to you action
```
 def index
   facebook = current_user.services.facebook.last
   if facebook.present?
     @graph = facebook.client
     page_params = params.permit!.to_h[:page]
     @results = params[:page] ? @graph.get_page(page_params) : @graph.get_connections("me", "feed")
   else
     @results = []
   end
 end
```
# Conclusion
You need to create facebook app to get app_id and app_secret and then add this code to secrets.yml
~~~
/config/screts.yml
development:
  ...
  facebook_app_id: your_app_id
  facebook_app_secret: your_app_secret
~~~


