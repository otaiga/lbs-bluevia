class BlueviaController < ApplicationController

rescue_from Bluevia::ServerError, :with => :rescue_calllocation

 CONSUMER_KEY = ENV['BLUEVIA_KEY']
 CONSUMER_SECRET = ENV['BLUEVIA_SECRET']

require 'bluevia'
require 'open-uri'
require 'json'
require 'httparty'
include Bluevia



def geonames
           places_nearby = Geonames::WebService.find_nearby_place_name @lat, @lon
            
            @here = places_nearby.first.name   #this is the one to use.
            @here2 = places_nearby.first.country_name
            
            session[:location] = @here
            return
  end


  def auth
     bc = BlueviaClient.new(
               { :consumer_key   => CONSUMER_KEY,
                 :consumer_secret=> CONSUMER_SECRET,
                 :uri            => "https://api.bluevia.com"
               })
               
                 
     service = bc.get_service(:oAuth)
     token, secret, url = service.get_request_token({:callback =>"http://" + request.host_with_port + "/callbackblue"})
     
         
       $request_token = token
       $request_secret = secret
      
      redirect_to url 
  end


    def callbackblue
    oauth_verifier = params[:oauth_verifier]

      @bc = BlueviaClient.new(
               { :consumer_key   => CONSUMER_KEY,
                 :consumer_secret=> CONSUMER_SECRET
               })

       @bc.set_commercial

      @service = @bc.get_service(:oAuth)
      @token, @token_secret = @service.get_access_token($request_token, $request_secret, oauth_verifier)
      
      session[:token] = @token
      session[:token_secret] = @token_secret

      $token = session[:token]
      $token_secret = session[:token_secret]

      #  @user = User.find(current_user.id)
      #   if @user.auths == []
      #   @user.auths.create(:bluevia_token => "#{@token}", :bluevia_secret => "#{@token_secret}")
      # else
      #   mod=@user.auths.first
      #   mod.update_attributes(:bluevia_token => "#{@token}", :bluevia_secret => "#{@token_secret}")
      # end

      
      # redirect_to root_path
      calllocation
    end


   def calllocation

     @bc = BlueviaClient.new(
               { :consumer_key   => CONSUMER_KEY,
                 :consumer_secret=> CONSUMER_SECRET,
                 # :token          => session[:token],
                 # :token_secret   => session[:token_secret],
                 :token          => $token,
                 :token_secret   => $token_secret,
                 :uri            => "https://api.bluevia.com"
               })
   
       @bc.set_commercial
   
     @service = @bc.get_service(:Location)
     location = @service.get_location

     if latlong = location['terminalLocation']['currentLocation']['coordinates']
   
     @lat = latlong['latitude']
     @lon = latlong['longitude']
     # @contact = session[:contact]
     
     session[:lat] = @lat
     session[:lon] = @lon

     geonames

   else 
    # redirect_to root_path 
    redirect_to "/bluevia/calllocation"
	end


end




   def rescue_calllocation
   	puts "Rescued!!!"
   	sleep 5
   	redirect_to "/bluevia/calllocation"
end




end
