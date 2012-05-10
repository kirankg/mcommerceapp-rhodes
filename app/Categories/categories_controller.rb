require 'rho/rhocontroller'
require 'helpers/browser_helper'

#$productName = String.new
$category_id = ""

$details = Hash.new                         # Hash containing product details
$image = String.new                         # String for storing product image url          
$finalCart = String.new                     # String containing final cart
$products = Hash.new                        # Hash containing product list belonging to a particular category
$video = String.new                         # Video string
$productstatus = Array.new                  # Array for saving product status
$productsCodeName = Hash.new                # Hash containing product name as KEY and product code as VALUE
$titleForProducts = String.new              # Title for product screen
$productsCodeNameQuantity = Hash.new        # Hash containing product code as KEY and product quantity as VALUE
$productsCodeNamePrice = Hash.new           # Hash containing product name as KEY and product price as VALUE
$productTotalPrice = Hash.new
$transID= Hash.new
$flag = 0
#$productist= Hash.new
class CategoriesController < Rho::RhoController
  include BrowserHelper

  # GET /Categories
  def index
    endTime = Time.new
       var = endTime - $Start_time 
       
       if (var < $sessionTimeout)
          @categorieses = Categories.find(:all)
          render
       else
          Alert.show_popup " Your Session Expired, Please login again"
          WebView.navigate ( url_for :controller =>:Settings,:action => :login1) 
       end
  end
 
  # Back to Categories
  def back_to_index
   
    SyncEngine.dosync
    WebView.navigate ( url_for :action => :index)
 
 end
 
  def offline
    @categorieses = Categories.find(:all)
    @productses = Products.find(:all)
    #Alert.show_popup @categorieses.length.to_s+"=="+@productses.length.to_s
    if (@categorieses.length > 0 && @productses.length > 0)
    #  Alert.show_popup "Not Empty"
    render :action => :offline
    else
      Alert.show_popup "Offline Data is Empty. Please login to get the offline data."
      WebView.navigate ( url_for :controller => :Settings, :action => :offline)
    end
  end
  # Display product list
  def showProducts
    endTime = Time.new
           var = endTime - $Start_time 
           
  if (var < $sessionTimeout)
     $category_id = @params['id']
    # Alert.show_popup $category_id.to_s
     var1 = $category_id
     var2= var1.slice(1,var1.length-2)
     $titleForProducts = var2
     var3 = Hash.new
     var3 = {"categoryname" => var2}
     require 'json'
     categoryJson = var3.to_json
     result = Rho::AsyncHttp.post( 
                                  :url => $products_URL , 
                                  :body => categoryJson)
     dataProducts = result['body']
     #Alert.show_popup dataProducts
     dataProducts1 = Rho::JSON.parse(dataProducts)
     $products = dataProducts1["products"]
     SyncEngine.dosync
     WebView.navigate( url_for :controller => :Products)
  else
      Alert.show_popup " Your Session Expired, Please login again"
      WebView.navigate ( url_for :controller =>:Settings,:action => :login1)
  end
 end
 
  # Display product details
  def productDetails
    endTime = Time.new
    var = endTime - $Start_time 
               
  if (var < $sessionTimeout)
    imagevar = "http://"+$PublicIP+":8080/JsonMobile/images/"
    videovar = "http://"+$PublicIP+":8080/JsonMobile/videos/"
     var1 = @params['id']
     var2= var1.slice(1,var1.length-2)
     var3 = Hash.new
       var3 = {"productcode" => var2}
         
         require 'json'
        productDetailJson = var3.to_json

     result = Rho::AsyncHttp.post( 
                                  :url => $productDetails_URL , 
                                  :body => productDetailJson) 
     dataDetails = result['body']
    dataDetails1 = Rho::JSON.parse(dataDetails)
     $details = dataDetails1["productdetails"]
     imagevar.concat($details[0]["productimage"])
       videovar.concat($details[0]["productvideo"])
       $image = imagevar
       $video = videovar
     WebView.navigate ( url_for :action => :productdetails )
  else
     Alert.show_popup " Your Session Expired, Please login again"
     WebView.navigate ( url_for :controller =>:Settings,:action => :login1)
  end
end
 
  
# Adding products to cart
def add_to_cart
  $Start_time = Time.now
    cartvar = @params['id']
      
#  Alert.show_popup cartvar
    @@quantityvar = @params['quantity']
   # Alert.show_popup  @@quantityvar
    if( @@quantityvar == "")
     Alert.show_popup "Quantity is empty" 
      WebView.navigate ( url_for  :action => :showProducts,:id=>$category_id)
    elsif(!qvalidation())
      Alert.show_popup "Quantity should be positive integer value"
      WebView.navigate ( url_for :action => :showProducts,:id=>$category_id)
    else 
   cartvar= cartvar.slice(1,cartvar.length-2)
     cartflag = 0
     
      (0.. ($products.length - 1)).each do |i| 
        if($products[i]["productname"] == cartvar) 
            
            if($products[i]["productstatus"].to_i > @@quantityvar.to_i )
                  (0.. ($cart.length)).each do |j|
                         if ($cart[j] == cartvar)
                           cartflag = 1
                           break
                          end
                       end
                       
                       if (cartflag == 1)
                          Alert.show_popup cartvar+" Already added to Cart"
                       else
                         $cart.push(cartvar)
                         #$quantity.push(quantityvar)
                         localCodeName = Hash.new
                         localCodeQuantity = Hash.new
                         localCodeNamePrice = Hash.new
                         (0.. ($products.length - 1)).each do |i|
                            if (cartvar == $products[i]["productname"])
                            localCodeName = {$products[i]["productcode"] => $products[i]["productname"]}
                            localCodeQuantity = {$products[i]["productcode"] => @@quantityvar, $products[i]["productname"] => @@quantityvar}
                            localCodeNamePrice = {$products[i]["productname"] => $products[i]["productprice"], $products[i]["productcode"] => $products[i]["productprice"]}
                             end
                          end
                           $productsCodeName = $productsCodeName.merge(localCodeName)
                           $productsCodeNameQuantity = $productsCodeNameQuantity.merge(localCodeQuantity)
                           $productsCodeNamePrice = $productsCodeNamePrice.merge(localCodeNamePrice)
                         #  price = $productsNamePrice[cartvar].to_f * $productsCodeNameQuantity[cartvar].to_f
                           #$productTotalPrice = $productTotalPrice.merge(price)
                           Alert.show_popup @@quantityvar.to_s+" "+cartvar+" Added to Cart"
                       end
                      WebView.navigate ( url_for :controller=>:Products,:action => :index,:id=>$category_id)
                      
            elsif($products[i]["productstatus"].to_i < @@quantityvar.to_i )
                      Alert.show_popup "Only "+$products[i]["productstatus"].to_s+" "+$products[i]["productname"].to_s+"'s"+" are available"
                      WebView.navigate ( url_for :controller=>:Products,:action => :index,:id=>$category_id)
            end
         end
      end
     
    end
end

def qvalidation
    quantArray =@@quantityvar.split("")
    flagZip = 0
    #Alert.show_popup "kiran"
    
    (0..(quantArray.length - 1)).each do |i|
       if (quantArray[i].ord < 48 || quantArray[i].ord > 57)
            flagZip = 1
            break
       else
         flagZip=0 
     end
end

if ( flagZip == 0 )
  (0..(quantArray.length - 1)).each do |i|
  if(quantArray[i].ord == 48)
    flagZip = 1
else
    flagZip = 0
    break
  end
  end
end
 
          if (flagZip == 1)
            return false
          else
            return true
          end
end   


  # Dispaly products currently on cart
  def viewCart
    if $cart.empty?
      Alert.show_popup "Cart is Empty"
      WebView.navigate ( url_for :controller=>:Products,:action => :index,:id=>$category_id)
    else
      WebView.navigate ( url_for :action => :viewcart )
    end
      
  end
  
  # Delete product from cart
  def delete_from_cart
    deletevar = @params['id']
    deletevar= deletevar.slice(1,deletevar.length-2)
    $cart.delete(deletevar)
    key = $productsCodeName.index(deletevar)
      $productsCodeName.delete(key)
      
    if $cart.empty?
          Alert.show_popup "Cart is Empty"
          WebView.navigate ( url_for :controller=>:Products,:action => :index,:id=>$category_id)
    else
          WebView.navigate ( url_for :action => :viewcart )
    end
  end
  
  # GET /Categories/{1}
  def show
    @categories = Categories.find(@params['id'])
    if @categories
      render :action => :show
         else
           redirect :action => :index
         end
  end

  # GET /Categories/new
  def new
    @categories = Categories.new
    render :action => :new
  end

  # GET /Categories/{1}/edit
  def edit
    @categories = Categories.find(@params['id'])
    if @categories
      render :action => :edit
         else
           redirect :action => :index
         end
  end
  
  # POST /Categories/create
  def create
    @categories = Categories.create(@params['categories'])
    redirect :action => :index
  end

  # POST /Categories/{1}/update
  def update
    @categories = Categories.find(@params['id'])
    @categories.update_attributes(@params['categories']) if @categories
    redirect :action => :index
  end

  # POST /Categories/{1}/delete
  def deactivate
    @categories = Categories.find(:all)
    @categories.destroy if @categories
    WebView.navigate( url_for :controller => :Settings, :action => :login1 )
  end
  
def previoustrans 
if($userid == "")
  $flag = 0
else
  $flag = 1
end
  WebView.navigate( url_for :controller => :JsonTest, :action => :filetest )
  
end
  
#def product_details
#  $category_id = @params['id']
#  SyncEngine.dosync
#   WebView.navigate( url_for :controller => :Products) 
#end
    


  #def previoustrans1
   #  $userid = @params['login']
    # bodyString1 = Hash.new  
     #bodyString1= {:userid => $userid}   
    #require 'json'
     # dd1 = bodyString.to_json
      
      #result = Rho::AsyncHttp.post( 
       #                             :url => ,
        #                            :body => dd1 )  
 #data1 = result['body']
      #data2 = Rho::JSON.parse(data1) 
      #Alert.show_popup data1
    #$transID= data2["t_id"]
    #if(data1 == "{\"result\":\"false\"}" || data1 == "")                         
     # Alert.show_popup "No records found" 
      #  render :action => :index
   # else 
     
    #WebView.navigate ( url_for :action => : previoustrans)
   # end
  #end
 
 # def productlist1
   # $transID=params['transid']
  # idstring= Hash.new
  #  idstring= {:transid => $transid}
    #require 'json'
   # iddata= idstring.to_json
   # result = Rho::AsyncHttp.post( 
                                        #:url => ,
                                        #:body => dd1 )  
   # data1 = result['body']
   # data2 = Rho::JSON.parse(data1)
   # $productlist= data2["productname"]
   # if(data1 == "{\"result\":\"false\"}" || data1 == "")                         
         # Alert.show_popup "No records found" 
            #render :action => :index
        #else 
         
       # WebView.navigate ( url_for :action => : previoustrans)
       # end
                                                      

end