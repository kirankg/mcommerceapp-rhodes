require 'rho/rhocontroller'
require 'helpers/browser_helper'
$productid=""
$indexArray= Array.new 
$offlinecart = Array.new
$offlineProductsCodeNameQuantity = Hash.new 
$off_catg_id = ""
$offline_quant_validate = Hash.new
$productcode = Array.new
$productquantity = Array.new
$totalprice = Array.new
$finalprice = 0.0
$i = 0
class ProductsController < Rho::RhoController
  include BrowserHelper

  # GET /Products
  def index
    j=0
    k=0
#    SyncEngine.dosync
     @productses = Products.find(:all)
       @productses.each do |products|
         if($category_id == "{"+products.categoryid+"}" )
           
           (0.. ($products.length - 1)).each do |i| 
             
               if( products.productname.to_s == $products[i]["productname"] )
                  k=i
                break
               end 
            end 
 #           Alert.show_popup k
            $indexArray[j] = k
            j=j+1
         end
       end 
     render 
  end
  
  def getDetails
    $productid = @params['id']
    WebView.navigate( url_for :controller => :Categories, :action => :showProducts )
  end
  # GET /Products/{1}
  
def offline_add_to_cart
  
    @productses = Products.find(@params['id'])
    cartvar =  @productses.productname
    @@quantityvar = @params['quantity']
    price =  @productses.productprice.to_i
        $totalprice[$i] =  price *  @@quantityvar.to_i 
    if( @@quantityvar == "")
      Alert.show_popup "Please mention the quantity" 
      WebView.navigate ( url_for :controller=>:Products,:action => :offlineProducts,:id=>$off_catg_id)
    elsif(!qvalidation())
      Alert.show_popup "Quantity should be positive integer value"
      WebView.navigate ( url_for :controller=>:Products,:action => :offlineProducts,:id=>$off_catg_id)
    else 
       
         cartflag = 0
         
         (0.. ($offlinecart.length)).each do |j|
           if ($offlinecart[j] == cartvar)
             cartflag = 1
             break
            end
         end
         
         if (cartflag == 1)
            Alert.show_popup cartvar+" Already added to Cart"
           render :action => :offlineProducts
         else
           $offlinecart.push(cartvar)
           Alert.show_popup @@quantityvar.to_s+" "+cartvar+" Added to Cart"
           localquantity = Hash.new
           local_quant_validate =  Hash.new
           @productses = Products.find(:all)
           @productses.each do |products|
             if($off_catg_id == products.categoryid )
               if(cartvar == products.productname)
                 localquantity = {products.productid => @@quantityvar,products.productname => @@quantityvar}
                 #local_quant_validate = {"productcode" => products.productid,"quantity" => @@quantityvar}
               $productcode.push(products.productid)
               $productquantity.push(@@quantityvar)
               end
             end
           end
          $offlineProductsCodeNameQuantity = $offlineProductsCodeNameQuantity.merge(localquantity)#for display
          require 'json'
          
        #  $offline_quant_validate = $offline_quant_validate.merge(local_quant_validate)#for quantity validation request
          tempCart = Hash.new
          for i in 0..($productcode.length - 1)
            tempCart[i] = {"productcode" => $productcode[i], "quantity" => $productquantity[i]}
          end
            $offline_quant_validate = tempCart
           #render :action => :offlineProducts
            WebView.navigate ( url_for :controller=>:Products,:action => :offlineProducts,:id=>$off_catg_id)
            $i = $i + 1
         end
    end
end

def goto_offlogin
  
  for i in 0.. $i
    $finalprice = $finalprice+$totalprice[i].to_i
  end
  #Alert.show_popup $finalprice.to_s
  WebView.navigate ( url_for :controller => :Settings, :action => :offlogin)
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

def viewCart
  if ($userid != "")
    $userid.clear
  end
    if $offlinecart.empty?
#      if($off_catg_id == "")
#        Alert.show_popup "Cart is Empty"
#        WebView.navigate ( url_for :controller=>:Settings,:action => :offline)
#      else
      Alert.show_popup "Cart is Empty"
      WebView.navigate ( url_for :controller=>:Products,:action => :offlineProducts,:id=>$off_catg_id)
#      end
    else
      WebView.navigate ( url_for :action => :offlineCart )
    end
  end

  def delete_from_cart
    @productses = Products.find(:all)
    deletevar = @params['id']
    deletevar= deletevar.slice(1,deletevar.length-2)
    product_id = ""
   @productses.each do |products|
     if( products.productname ==  deletevar)
       product_id = products.productid
     end 
    end
    $offlinecart.delete(deletevar)
    i = $productcode.index(product_id)
    $productcode.delete(product_id)
    $productquantity.delete_at(i)
    if $offlinecart.empty?
          Alert.show_popup "Cart is Empty"
          
          WebView.navigate ( url_for :controller=>:Products,:action => :offlineProducts,:id=>$off_catg_id)
    else
          WebView.navigate ( url_for :action => :offlinecart )
    end
  end 
  
  def show
    @products = Products.find(@params['id'])
    if @products
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end
  
  def offlineProducts
    if ($online_offline_flag == "true")
     # Alert.show_popup "home page"+$online_offline_flag
      WebView.navigate ( url_for :controller => :Settings, :action => :back_home )
    
  else
    $off_catg_id = @params['id']
    $off_catg_id = $off_catg_id.slice(1,$off_catg_id.length-2)
 #   Alert.show_popup  $off_catg_id
    @products = Products.find(:all)
    
#    WebView.navigate ( url_for :action => :offlineProducts )
    render :action => :offlineProducts
    end
  end
  
  def offback
    @productses = Products.find(:all)
    WebView.navigate ( url_for :action => :offlineProducts )
  end
    
  # GET /Products/new
  def new
    @products = Products.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Products/{1}/edit
  def edit
    @products = Products.find(@params['id'])
    if @products
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end
  
  # POST /Products/create
  def create
    @products = Products.create(@params['products'])
    redirect :action => :index
  end

  # POST /Products/{1}/update
  def update
    @products = Products.find(@params['id'])
    @products.update_attributes(@params['products']) if @products
    redirect :action => :index
  end

  # POST /Products/{1}/delete
  def delete
    @products = Products.find(@params['id'])
    @products.destroy if @products
    redirect :action => :index  
  end


end
