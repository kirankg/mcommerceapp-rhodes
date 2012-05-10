require 'rho/rhocontroller'
require 'helpers/browser_helper'

$order = Hash.new
$finalCart = Hash.new    # Hash containing final cart
$addressvar = Hash.new
$totalPrice = 0.00
$shoplist = Hash.new
$mode = 0
$finalOrderHash = Hash.new
class ShippingaddressController < Rho::RhoController
 include BrowserHelper

 # GET /Shippingaddress
 def index
   @shippingaddresses = Shippingaddress.find(:all)
   render :back => '/app'
 end

 # GET /Shippingaddress/{1}
 def show
   @shippingaddress = Shippingaddress.find(@params['id'])
   if @shippingaddress
     render :action => :show, :back => url_for(:action => :index)
   else
     redirect :action => :index
   end

 end

 def back_to_Electronics
   WebView.navigate ( url_for :controller => :Categories, :action => :index)
 end
 
 def address
   endTime = Time.new
    var = endTime - $Start_time 
    if(var < $sessionTimeout)
             @shippingaddress = Shippingaddress.find(@params['id'])
             
             $finalOrderHash = {"userid" => $userid}
             
             $addressvar = {"shippingaddress" => {"firstname" => @shippingaddress.name, 
                                                  "lastname" =>$userDetails['lastname'] , 
                                                  "companyname" => $userDetails['companyname'], 
                                                 "address1" => @shippingaddress.apartment, 
                                                 "address2" => @shippingaddress.street,
                                                 "city" => @shippingaddress.city,
                                                 "state" => $userDetails['state'],
                                                 "country" =>$userDetails['country'] ,
                                                 "zip" => @shippingaddress.zipcode, 
                                                 "phonenumber" => @shippingaddress.phone}}
                                                 
            #Alert.show_popup $addressvar.to_json
            tempCart = Hash.new
            if ($online_offline_flag == "true" || $online_offline_flag == "")
              #   offtempCart = Hash.new
     
                  for i in 0.. ($offlinecart.length - 1)
                    tempCart[i] = {"productcode" => $productcode[i], "quantity" => $productquantity[i]}
                  end
            else
                productCodeArray = $productsCodeName.keys
                
                         
                (0.. (productCodeArray.length - 1)).each do |i|
                  tempCart[i] = {"productcode" => productCodeArray[i], "quantity" => $productsCodeNameQuantity[productCodeArray[i]]}
                  $totalPrice = $totalPrice + ($productsCodeNameQuantity[productCodeArray[i]].to_f * $productsCodeNamePrice[productCodeArray[i]].to_f)
                end
            end
          
             
             $finalCart = {"cart" => [tempCart] }
          
             $finalOrderHash = $finalOrderHash.merge($addressvar)
             $finalOrderHash = $finalOrderHash.merge($finalCart)
             require 'json'
             orderJson = $finalOrderHash.to_json
           # Alert.show_popup orderJson 
            #10.10.208.222:8080
            result = Rho::AsyncHttp.post( 
                                           :url => $shipping_URL , 
                                           :body => orderJson )
                                           
             orderReply = result['body']
            #   Alert.show_popup orderReply
             $order = Rho::JSON.parse(orderReply)
             if($order["orderstatus"] == "cofirmed")  
             WebView.navigate ( url_for :controller => :Terms, :action => :index )
             else
               availability = $order["availability"]
               popupString = String.new
               popupString = "Only "
               (0.. (availability.length-1)).each do |i| 
               pCode = availability[i]["productcode"]
               popupString = popupString+availability[i]["quantity"]+" "+$productsCodeName[pCode]+"(s),"
              # Alert.show_popup availability[i]["quatity"]+$productsCodeName[pCode]+"(s),"
             end
             popupString = popupString+"available."  
               Alert.show_popup popupString
             WebView.navigate ( url_for :controller => :Categories, :action => :viewcart )  
             $totalPrice = 0.0
             end
           @shippingaddress.destroy
    else
          Alert.show_popup " Your Session Expired, Please login again"
          WebView.navigate ( url_for :controller =>:Settings,:action => :login1) 
    end
end
 
 def terms
   WebView.navigate ( url_for :controller => :Terms, :action => :index)
 end
 
 def choice
   $Start_time = Time.now
   render :action => :modeofdeivery
 end
 
 def payment
   $mode = @params['DeliveryMethod'].to_i
  #Alert.show_popup mode
   $Start_time = Time.now 
     if($mode == 1)
       WebView.navigate ( url_for :action => :new)
     elsif($mode == 2)
       WebView.navigate ( url_for :action => :filetest)
     elsif($mode == 0)
       Alert.show_popup "Please select mode of delivery."
       WebView.navigate ( url_for :action => :modeofdeivery)
     end
end
def filetest
  $Start_time = Time.now

       file_name = File.join(Rho::RhoApplication::get_model_path('app','Shippingaddress'), 'shoplist.json')
       puts "file_name : #{file_name}"

       content = File.read(file_name)
       puts "content : #{content}"
     
       parsed = Rho::JSON.parse(content)
       puts "parsed : #{parsed}"

       gen = ::JSON.generate(parsed)
       puts "gen : #{gen}"
       
      $shoplist = parsed["StoreDetails"]
      render  :action => :display
   #rescue Exception => e
   #    puts "Error: #{e}"
   #    @@get_result = "Uncomment in build.yml:<br/> extensions: [\"json\"]<br/>"
   #    @@get_result += "Error: #{e}"
   #end
       
 end
 # GET /Shippingaddress/news
 def new
   @shippingaddress = Shippingaddress.new
   @registration = Registration.find(:all, :conditions => {:emailid => $userid})

#  @registration.each do |reg|
#     var = reg.firstname
#    Alert.show_popup reg.firstname
#    end
   render :action => :new, :back => url_for(:action => :index)
 end

 # GET /Shippingaddress/{1}/edit
 def edit
   @shippingaddress = Shippingaddress.find(@params['id'])
   if @shippingaddress
     render :action => :edit, :back => url_for(:action => :index)
   else
     redirect :action => :index
   end
 end

 # POST /Shippingaddress/create

def create
  @shippingaddress = Shippingaddress.create(@params['shippingaddress'])
  @registration = Registration.find(:all, :conditions => {:emailid => $userid})
  $Start_time = Time.now
    if(!mandatoryFieldsCheck())
      Alert.show_popup "Mandatory fields cannot be Blank"
      render :action => :new, :back => url_for(:action => :index)
    elsif(!nameCheck())
        Alert.show_popup "Invalid Name"
        render :action => :new, :back => url_for(:action => :index)
    elsif(!zipCodeCheck())
      Alert.show_popup "Invalid zipcode"
      render :action => :new, :back => url_for(:action => :index)
    elsif(!phoneCheck())
      Alert.show_popup "Invalid Phone Number"
      render :action => :new, :back => url_for(:action => :index)
    else
      render :action => :show, :id => @shippingaddress.object
    end

end
 
def mandatoryFieldsCheck
  @shippingaddress = Shippingaddress.create(@params['shippingaddress'])
  if(@shippingaddress.name == "" || @shippingaddress.apartment == "" || @shippingaddress.street == "" || @shippingaddress.city == "" || @shippingaddress.zipcode == "" || @shippingaddress.phone =="")
  return false
  else
  return true
  end
end

def zipCodeCheck
   @shippingaddress = Shippingaddress.create(@params['shippingaddress'])
   if(@shippingaddress.zipcode.length == 6)
     zipArray = @shippingaddress.zipcode.split("")
      flagZip = 0
      (0.. (zipArray.length - 1)).each do |i|
          if (zipArray[i].ord < 48 || zipArray[i].ord > 57)
            flagZip = 1
          end
      end
      if (flagZip == 1)
        return false
      else
        return true
      end
   else
   return false
   end
end


def phoneCheck
   @shippingaddress = Shippingaddress.create(@params['shippingaddress'])
   if(@shippingaddress.phone.length == 10)
     phoneArray = @shippingaddress.phone.split("")
      flagPhone = 0
      (0.. (phoneArray.length - 1)).each do |i|
          if (phoneArray[i].ord < 48 || phoneArray[i].ord > 57)
            flagPhone = 1
          end
      end
      if (flagPhone == 1)
        return false
      else
        return true
      end
   else
   return false
   end
end

def nameCheck
   @shippingaddress = Shippingaddress.create(@params['shippingaddress'])
   #Alert.show_popup @shippingaddress.name
     nameArray = @shippingaddress.name.split("")
      flagName = 0
     (0.. (nameArray.length - 1)).each do |i|
        if (nameArray[i].ord < 65 || nameArray[i].ord  > 122)
          flagName = 1
        elsif (nameArray[i].ord  > 90 && nameArray[i].ord < 97)
          flagName = 1
        end
     end
    if (flagName == 1)
      return false
    else
      return true
    end
end
def shopAddress
  endTime = Time.new
     var = endTime - $Start_time 
     if(var < $sessionTimeout)
          var = @params['id']
            var1= var.slice(1,var.length-2).to_i
          #  Alert.show_popup var1
              finalOrderHash = Hash.new
              $finalOrderHash = {"userid" => $userid}
               
               $addressvar = {"shippingaddress" => {"firstname" =>$userDetails['firstname'] , 
                                                    "lastname" => $userDetails['lastname'],
                                                    "companyname" => $userDetails['companyname'],
                                                  "address1" =>$shoplist[var1]["name"].to_s+$shoplist[var1]["apartment"].to_s, 
                                                  "address2" => $shoplist[var1]["street"],
                                                  "city" => $shoplist[var1]["city"],
                                                  "state" => $userDetails['state'],
                                                  "country" => $userDetails['country'],
                                                  "zip" => $shoplist[var1]["zipcode"], 
                                                  "phonenumber" => $shoplist[var1]["phone"]}}
               
               productCodeArray = $productsCodeName.keys
               tempCart = Hash.new
            
               
               (0.. (productCodeArray.length - 1)).each do |i|
                 tempCart[i] = {"productcode" => productCodeArray[i], "quantity" => $productsCodeNameQuantity[productCodeArray[i]]}
                 $totalPrice = $totalPrice + ($productsCodeNameQuantity[productCodeArray[i]].to_f * $productsCodeNamePrice[productCodeArray[i]].to_f)
               end
            
               
               $finalCart = {"cart" => [tempCart] }
            
               $finalOrderHash = $finalOrderHash.merge($addressvar)
              $finalOrderHash = $finalOrderHash.merge($finalCart)
               require 'json'
               orderJson = $finalOrderHash.to_json
          #    #10.10.208.222:8080
              result = Rho::AsyncHttp.post( 
                                             :url => $shipping_URL , 
                                            :body => orderJson )
                                             
               orderReply = result['body']
          #       Alert.show_popup orderReply
               $order = Rho::JSON.parse(orderReply)
               if($order["orderstatus"] == "cofirmed")  
               WebView.navigate ( url_for :controller => :Terms, :action => :index )
               end
    else
         Alert.show_popup " Your Session Expired, Please login again"
         WebView.navigate ( url_for :controller =>:Settings,:action => :login1) 
    end
end
# POST /Shippingaddress/{1}/update
 def update
   @shippingaddress = Shippingaddress.find(@params['id'])
   @shippingaddress.update_attributes(@params['shippingaddress']) if @shippingaddress
   redirect :action => :show, :id => @shippingaddress.object
 end

 # POST /Shippingaddress/{1}/delete
 def delete
   @shippingaddress = Shippingaddress.find(@params['id'])
   @shippingaddress.destroy if @shippingaddress
   redirect :action => :show, :id => @shippingaddress.object  
 end
end