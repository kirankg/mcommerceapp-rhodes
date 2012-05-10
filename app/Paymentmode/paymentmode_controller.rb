require 'rho/rhocontroller'
require 'helpers/browser_helper'

$isPayAtStore = "false"

class PaymentmodeController < Rho::RhoController
  include BrowserHelper

  # GET /Paymentmode
  def index
    $Start_time = Time.now
    @paymentmodes = Paymentmode.find(:all)
    render :back => '/app'
  end
  
  def back_Terms
    WebView.navigate ( url_for :controller => Terms)
   end
   
  def payment
    $Start_time = Time.now
    mode = @params['PaymentMode'].to_i
      if (mode > 0 && mode < 3)
        WebView.navigate ( url_for :controller => :Payment, :action => :new)
      elsif(mode == 3)
        $isPayAtStore = "true"
        WebView.navigate ( url_for :controller => :Payment, :action => :completePayment)
      else
        Alert.show_popup "Please select mode of Payment"
        WebView.navigate ( url_for :controller => :Paymentmode, :action => :index)
      end    
  end
  # GET /Paymentmode/{1}
  def show
    @paymentmode = Paymentmode.find(@params['id'])
    if @paymentmode
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Paymentmode/new
  def new
    @paymentmode = Paymentmode.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Paymentmode/{1}/edit
  def edit
    @paymentmode = Paymentmode.find(@params['id'])
    if @paymentmode
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Paymentmode/create
  def create
    @paymentmode = Paymentmode.create(@params['paymentmode'])
    redirect :action => :index
  end

  # POST /Paymentmode/{1}/update
  def update
    @paymentmode = Paymentmode.find(@params['id'])
    @paymentmode.update_attributes(@params['paymentmode']) if @paymentmode
    redirect :action => :index
  end

  # POST /Paymentmode/{1}/delete
  def delete
    @paymentmode = Paymentmode.find(@params['id'])
    @paymentmode.destroy if @paymentmode
    redirect :action => :index  
  end
end
