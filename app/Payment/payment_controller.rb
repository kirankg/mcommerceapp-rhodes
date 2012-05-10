require 'rho/rhocontroller'
require 'helpers/browser_helper'

$cardVar = Hash.new

class PaymentController < Rho::RhoController
  include BrowserHelper

  # GET /Payment
  def index
    @payments = Payment.find(:all)
    render :back => '/app'
  end
  
  def back_home
    $cart.clear
    $finalCart.clear
    $productsCodeName.clear
    $productsCodeNameQuantity.clear
    $productsCodeNamePrice.clear
    $productTotalPrice.clear
    $totalPrice = 0.00
    $isPayAtStore == "false"
    WebView.navigate ( url_for :controller => :Settings, :action => :back_home)
  end
  def back_paymentmode
    #WebView.refresh
    WebView.navigate ( url_for :controller => Paymentmode)
  end
  
  def completePayment
    
    if($isPayAtStore == "true")
          cardVar1 = Hash.new
          cardVar1 = {:carddetails => {:cardtype => "NA", :cardnumber => "NA", :cardexpirydate => "NA"}}
          $cardVar = $finalOrderHash.merge(cardVar1)
      
    else        
          cardVar2 = Hash.new                                                              
          @payment = Payment.find(@params['id'])
              if (@payment.cardnumber == "")
                  Alert.Show_popup "Enter Valid Card Number"
                  WebView.navigate ( url_for :action => :edit, :id => @payment.object)
              else
                    finalPaymentHash = Hash.new
                        finalPaymentHash = {"userid" => $userid}
                        
                        
                              cardVar2 = {:carddetails => {:cardtype => @payment.cardtype, 
                                                           :cardnumber => @payment.cardnumber, 
                                                           :cardexpirydate => @payment.cardexpmonth+"-"+@payment.cardexpyear}}
                                                           
                  $cardVar = $finalOrderHash.merge(cardVar2)
              end
      end
      
        require 'json'
        
          cardJson = $cardVar.to_json
          result = Rho::AsyncHttp.post( 
                                            :url => $payment_URL , 
                                            :body => cardJson ) 
          
          paymentReply = result['body']
          
             $payment = Rho::JSON.parse(paymentReply)
             if($payment["transactionstatus"] == "success")
             
                    Alert.show_popup(
                        :message=>"Your Transaction Number :  "+$payment["transactionid"].to_s,
                        :title=>"Payment Success",
                        :buttons => ["Ok"],
                        :callback => url_for(:action => :on_payment_success)
                     )
 
                     if($isPayAtStore != "true")
                            @payment.destroy
                     end

               else
                 Alert.show_popup "Transaction failed. Try again."
                 WebView.navigate ( url_for :controller => :Payment, :action => :new )
               end
  
  end
 
  def on_payment_success
    if ($online_offline_flag == "true" || $online_offline_flag == "")
      WebView.navigate ( url_for :action => :offline_order_report )
    else
      WebView.navigate ( url_for :action => :orderreport )
    end
  end
  
  def back_to_categories
    $cart.clear
    $finalCart.clear
    $productsCodeName.clear
    $productsCodeNameQuantity.clear
    $productsCodeNamePrice.clear
    $productTotalPrice.clear
    $totalPrice = 0.00
    WebView.navigate ( url_for :controller => :Categories, :action => :index )
  end
  # GET /Payment/{1}
  def show
    @payment = Payment.find(@params['id'])
    if @payment
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Payment/new
  def new
    @payment = Payment.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Payment/{1}/edit
  def edit
    @payment = Payment.find(@params['id'])
    if @payment
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Payment/create
  def create
    @payment = Payment.create(@params['payment'])
    $Start_time = Time.now 
    if(!cardNumberCheck())
      Alert.show_popup "Invalid Card Number"
      render :action => :edit, :back => url_for(:action => :index)
    else
      render :action => :show, :id => @payment.object
    end

  end

  def cardNumberCheck
    @payment = Payment.create(@params['payment'])
     if(@payment.cardnumber.length == 16)
       cardNumberArray = @payment.cardnumber.split("")
        flagCardNumber = 0
        (0.. (cardNumberArray.length - 1)).each do |i|
            if (cardNumberArray[i].ord < 48 || cardNumberArray[i].ord > 57)
              flagCardNumber = 1
            end
        end
        if (flagCardNumber == 1)
          return false
        else
          return true
        end
     else
     return false
     end
  end
  
  # POST /Payment/{1}/update
  def update
    @payment = Payment.find(@params['id'])
    @payment.update_attributes(@params['payment']) if @payment
    redirect :action => :show, :id => @payment.object
  end

  # POST /Payment/{1}/delete
  def delete
    @payment = Payment.find(@params['id'])
    @payment.destroy if @payment
    redirect :action => :index  
  end
end
