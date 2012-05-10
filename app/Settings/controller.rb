require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'
$Start_time = Time.new 

$online_offline_flag = "false"

$userid = ""       # username
$password = ""     # password 
$length = 0
$cart = Array.new                           # Array for maintaining cart
$PublicIP = "122.181.128.146"
$LocalIP = "10.11.201.182"

$login_URL = "http://"+$PublicIP+":8080/JsonMobile/JsonLogin"
$register_URL = "http://"+$PublicIP+":8080/JsonMobile/UserRegistration.action"
$products_URL = "http://"+$PublicIP+":8080/JsonMobile/JsonProductsSender"

$productDetails_URL = "http://"+$PublicIP+":8080/JsonMobile/JsonProductDetailsSender"
$shipping_URL = "http://"+$PublicIP+":8080/JsonMobile/ConfirmOrderJson"
$payment_URL = "http://"+$PublicIP+":8080/JsonMobile/PaymentDetailProcessorJson"
$offline_quantvalidate_URL = "http://"+$PublicIP+":8080/JsonMobile/checkavailability"

$offlinecart =  Array.new
$finalofflineCart = Hash.new
$status = ""
$sessionTimeout = 300
$userDetails = Hash.new

#$idvalues = {"u0", "u1", "u2", "u3"}

class SettingsController < Rho::RhoController
 include BrowserHelper
 
 def index
  # @msg = @params['msg']
   render
 end

 def pagenavigation
   var = @params['0']
   
 end
 def about_us
   render
 end
 
 def login
   @msg = @params['msg']
   $cart.clear
   $finalCart.clear
   $productsCodeName.clear
   $productsCodeNameQuantity.clear
   $productsCodeNamePrice.clear
   $productTotalPrice.clear
   $totalPrice = 0.00
   render :action => :login, :back => '/app'
 end
 
 def goto_offline_cart
   $online_offline_flag = "true"
  # Alert.show_popup "loading offline cart"
   WebView.navigate ( url_for :controller => :Products, :action => :viewCart )
 end
 
 def offline
   $userid = ""
   $online_offline_flag = ""
   if ($cart.length > 0)
   $cart.clear
   end
   if($status == "deactive")
     Alert.show_popup "Your account is deactivated, Please contact your Admin"
     render :action => :login
   else
    render :action => :offline
   end
   
 end
  def login1
    @msg = @params['msg']
    
    render :action => :login, :back => '/app'
  end
  
 def shopping
   WebView.navigate ( url_for :controller => :Categories, :action => :index )
 end
 
 def offline_login
   $Start_time = Time.now
   if (System.get_property('has_network').to_s == "true")
     if(@params['login'] != "" && @params['password'] != "")
           $userid = @params['login']
           $password = @params['password']
           bodyString = Hash.new  
           bodyString = {:userid => $userid, :password => $password}   #"userid="+$userid+"password="+$password
         
           require 'json'
           dd = bodyString.to_json
           # "http://10.10.222.73:8080/JsonMobile/JsonLogin" ,
           # "http://10.10.222.73:8080/JsonMobileSecond/JsonLogin",
           # http://122.181.128.146:8080/JsonMobile/JsonLogin  ----------------  Public IP
           result = Rho::AsyncHttp.post( 
                                         :url => $login_URL,
                                         :body => dd )  
                                                    
           data1 = result['body']
       $userDetails = Rho::JSON.parse(data1) 
       $status = $userDetails['status']
         
         #      (0.. ($data.length - 1)).each do |i|
         #        Alert.show_popup $data[i]["categoryname"]
         #      end
          
           if(data1 == "{\"result\":\"false\"}" || data1 == "")                         
             Alert.show_popup "Login failed. Please try again."
             render :action => :index      
           elsif($status == "deactive")
             Alert.show_popup "Your account is deactivated, Please contact your Admin"
             @categories = Categories.find(:all)
             @categories.each do |categories|
               categories.destroy if categories
             end
             @productses = Products.find(:all)
             @productses.each do |products|
               products.destroy if products
             end
             # WebView.navigate(url_for :controller => :Categories, :action => :deactivate)
             render :action => :login     
           else
             WebView.navigate(url_for :controller => :Settings, :action => :offline_checkout)
           end
      else
           Alert.show_popup "Emailid and password cannot be empty" 
           render :action => :index
      end
     else
       Alert.show_popup "Please check your network and try again." 
       render :action => :index
     end
   
 end
 
 def offline_checkout
   $finalofflineCart = {"cart" => [ $offline_quant_validate] }
   require 'json'
   off_dd = $finalofflineCart.to_json
   #Alert.show_popup off_dd
   result = Rho::AsyncHttp.post( 
                                   :url => $offline_quantvalidate_URL,
                                   :body => off_dd )  
  validate_result = result['body']
   # Alert.show_popup validate_result
    WebView.navigate(url_for :controller => :Shippingaddress, :action => :choice)
 end
 
#Async http post method for login
def postAsynchttp
  $online_offline_flag = "false"
  $Start_time = Time.now
  if (System.get_property('has_network').to_s == "true")
    
    if(@params['login'] != "" && @params['password'] != "")
        $userid = @params['login']
        $password = @params['password']
        bodyString = Hash.new  
        bodyString = {:userid => $userid, :password => $password}   #"userid="+$userid+"password="+$password
      
        require 'json'
        dd = bodyString.to_json
        # "http://10.10.222.73:8080/JsonMobile/JsonLogin" ,
        # "http://10.10.222.73:8080/JsonMobileSecond/JsonLogin",
        # http://122.181.128.146:8080/JsonMobile/JsonLogin  ----------------  Public IP
        result = Rho::AsyncHttp.post( 
                                      :url => $login_URL,
                                      :body => dd )  
                                                 
        data1 = result['body']
      $userDetails = Rho::JSON.parse(data1) 
        $status = $userDetails['status']
          
      #      (0.. ($data.length - 1)).each do |i|
      #        Alert.show_popup $data[i]["categoryname"]
      #      end
       
        if(data1 == "{\"result\":\"false\"}" || data1 == "")                         
        Alert.show_popup "Login failed. Please try again." 
          render :action => :login           
        elsif($status == "deactive")
          Alert.show_popup "Your account is deactivated, Please contact your Admin"
          @categories = Categories.find(:all)
          @categories.each do |categories|
            categories.destroy if categories
          end
          @productses = Products.find(:all)
          @productses.each do |products|
            products.destroy if products
          end
        # WebView.navigate(url_for :controller => :Categories, :action => :deactivate)
          render :action => :login
        else
       #   $userDetails = {:firstname => data2['firstname'],:lastname => data2['lastname'],:emailid => data2['emailaddress'],:comapnyname =>data2['comapnyname'],:address1 => data2['address1'], :address2 => data2['address2'],:city => data2['city'],:state => data2['state'],:country => data2['country'],:zipcode => data2['zip'],:phonenumber => data2['phonenumber']}

          WebView.navigate(url_for :controller => :Settings, :action => :do_login)
        end
        
      else
           Alert.show_popup "Emailid and password cannot be empty" 
           render :action => :login
      end
      
  else
    Alert.show_popup "Please check your network and try again." 
    render :action => :login
  end
end

# # Required only for Rhosync 
# def httpget_callback
#     puts "httpget_callback: #{@params}"
# 
#     if @params['status'] != 'ok'
#         http_error = @params['http_error'].to_i if @params['http_error']
#         if http_error == 301 || http_error == 302 #redirect
#             
#             Rho::AsyncHttp.get(
#               :url => @params['headers']['location'],
#               :callback => (url_for :action => :httpget_callback),
#               :callback_param => "" )
#             
#         else
#             @@error_params = @params
#             WebView.navigate ( url_for :action => :show_error )        
#         end    
#     else
#         @@get_result = @params['body']
#
#       WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
#     end
#   end
# 
 # Required only for Rhosync 
 def login_callback
   errCode = @params['error_code'].to_i
       if errCode == 0
         # run sync if we were successful
         SyncEngine.dosync
         WebView.navigate ( url_for :action => :home, :query => {:msg => @msg} ) 
       else
         if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
           @msg = @params['error_message']
         end
           
         if !@msg || @msg.length == 0   
           @msg = Rho::RhoError.new(errCode).message
         end
         
         WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
       end  
   end

   
   def offlogin
     $Start_time = Time.now
     if($userid == "")
     render :action=> :index
     else
       WebView.navigate ( url_for :controller => :Shippingaddress ,:action => :choice )
     end  
   end
   
   def back_off_home
     render :action => :offline
   end
 # Required only for Rhosync 
 def do_login
   if $userid  and  $password
         begin
           SyncEngine.login( $userid,$password, (url_for :action => :login_callback) )
           @response['headers']['Wait-Page'] = 'true'
           render :action => :wait
         rescue Rho::RhoError => e
           @msg = e.message
           render :action => :login
         end
       else
         @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
         render :action => :login
       end
 end
 
 def logout
   SyncEngine.logout
   $userid = ""
   @msg = "You have been logged out."
   render :action => :login
 end
 
 def reset
   render :action => :reset
 end
 
 def do_reset
   Rhom::Rhom.database_full_reset
   SyncEngine.dosync
   @msg = "Database has been reset."
   redirect :action => :index, :query => {:msg => @msg}
 end
 
 def back_home
   $offlinecart.clear
   $cart.clear
   render :action => :home
 end
 
 def do_sync
   SyncEngine.dosync
   @msg =  "Sync has been triggered."
   redirect :action => :index, :query => {:msg => @msg}
 end
 
  def mapview
#    Alert.show_popup GeoLocation.latitude.to_s+GeoLocation.longitude.to_s
#    i = 0
#    while (i == 0)
#    if (GeoLocation.latitude.to_s != "0.0" && GeoLocation.longitude != "0.0")
#      break
#    end
#    end
 #   Alert.show_popup "Map View - Enter"
    
     file_name = File.join(Rho::RhoApplication::get_model_path('app','Settings'), 'storeMaps.json')
    # Alert.show_popup file_name
     content = File.read(file_name)
   # Alert.show_popup content
     parsed = Rho::JSON.parse(content)
     details = parsed['StoreDetails']
                
          if System::get_property('platform') != 'Blackberry'
              GeoLocation.set_notification "", ""
          end
   # Alert.show_popup "Lat ====  "+GeoLocation.latitude.to_s
    myannotations = []
      
          for i in 0..(details.length - 1) 
               myannotations << {:latitude => details[i]['lat'], :longitude => details[i]['long'], :title => details[i]['title'], :subtitle => details[i]['subtitle']}
                 #Alert.show_popup i.to_s+"=="+details[i]['lat']+details[i]['long']+details[i]['title']+details[i]['subtitle']
          end
   
       # region = [GeoLocation.latitude, GeoLocation.longitude, 1.0, 1.0]   # Current Location
      #  region = [GeoLocation.latitude, GeoLocation.longitude, 1.0, 1.0]    # Bangalore
       region = [59.951551,10.7654, 1.0, 1.0]    # EVERY, Norway

#59.927496, 10.763855
        
         if System::get_property('platform') == 'ANDROID'
           provider = "RhoGoogle"
         else
           provider = "Google"
          end
          
        
          map_params = {
                :provider => provider,
                :settings => {:map_type => "roadmap", :region => region,
                              :zoom_enabled => true, :scroll_enabled => true, :shows_user_location => true, :api_key => '0jDNua8T4Teq0RHDk6_C708_Iiv45ys9ZL6bEhw'},
            :annotations => myannotations
            }
 
               MapView.set_file_caching_enable(1)
              
           MapView.create map_params
          WebView.navigate( url_for :controller => :Settings, :action => :home )
 
    
  end

end