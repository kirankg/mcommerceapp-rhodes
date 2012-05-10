require 'rho/rhocontroller'
require 'helpers/browser_helper'

class RegistrationController < Rho::RhoController
  include BrowserHelper
  $var1 = ""
  $var2 = ""
  $emailid = ""
  $checkavail_URL = "http://10.11.201.100:8080/JsonMobile/checkusername"
  $availability = ""
  $register_URL = "http://10.11.201.100:8080/JsonMobile/JsonUserReg"
  $registration = ""
  
  $var4 = ""
  $var5 = ""
  $var6 = ""
  $var7 = ""
  $var8 = ""
  $var9 = ""
  $var10 = ""
  $var11 = ""
  $var12 = ""
  $var13 = ""
  $var14 = ""
  
  def checkavailability
    render :action => :checkavailability
  end
  
  # GET /Registration
  def index
    @registrations = Registration.find(:all)
    render :back => '/app'
  end

  # GET /Registration/{1}
  def show
    @registration = Registration.find(@params['id'])
    if @registration
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Registration/new
  def new
    @registration = Registration.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Registration/{1}/edit
  def edit
    @registration = Registration.find(@params['id'])
    if @registration
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Registration/create
#  def create
#    @registration = Registration.create(@params['registration'])
#    redirect :action => :index
#  end

  # POST /Registration/{1}/update
  def update
    @registration = Registration.find(@params['id'])
    @registration.update_attributes(@params['registration']) if @registration
    redirect :action => :index
  end

  # POST /Registration/{1}/delete
  def delete
    @registration = Registration.find(@params['id'])
    @registration.destroy if @registration
    redirect :action => :index  
  end
  
  
  def create
  @registration = Registration.create(@params['registration'])
  #    redirect :action => :index
      $var1 = @registration.firstname
      $var2 = @registration.lastname
      $emailid = @registration.emailid
      if(!mandatoryFieldsCheck())
            Alert.show_popup "Please enter all Mandatory fields"
        render :action => :checkavailability
          elsif(!validate_email())
            Alert.show_popup "Please enter valid emailid."
            render :action => :checkavailability
      else
        redirect :action => :check
      end
    end
    
  def mandatoryFieldsCheck
       #@register = Register.create(@params['register'])
       if($var1 != "" && $var2 != "" && $emailid != "" )
       return true
       else
       return false
       end
     end
  
    def validate_email
      email = /^[a-z0-9_\+-]+(\.[a-z0-9_\+-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.([a-z]{2,4})/
        return (email.match($emailid))? true : false
    end
  
  def check
    @registration = Registration.find(:all, :conditions => {:firstname => $var1})
#      @registration.each in |reg|
#      
#      end
#    Alert.show_popup @registration.emailid
      checkdetails = Hash.new
         checkdetails = {"username" => $emailid}
           
         require 'json' 
         checkavil = checkdetails.to_json
         
         result = Rho::AsyncHttp.post( 
                                           :url => $checkavail_URL, 
                                           :body => checkavil )             
             data1 = result['body']
             data2 = Rho::JSON.parse(data1) 
             $availability = data2["result"]
               if $availability == "true"      
                 Alert.show_popup "Hello "+$var1+", please provide more details for registration"
                 redirect :action => :new
               else
                 Alert.show_popup "The emailid is already registered. Please try with different emailid"
                 Registration.delete_all(:conditions => {:emailid => $emailid})
                 render :action => :checkavailability
               end
    end
    
    def apply
      @registration = Registration.create(@params['registration'])
        
         @@var1 = @registration.firstname
         @@var2 =@registration.lastname
         @@var3 = @registration.emailid 
         $var4 = @registration.confirmemailid
         $var5 = @registration.password
         $var6 = @registration.confirmpassword
      address1 = @registration.address1
      $var7 = address1.gsub(/[,]/, ".")
         $var8 = @registration.zipcode
         $var9 = @registration.phonenumber
         $var10 = @registration.city
         $var11 = @registration.state
         $var12 = @registration.country
           if(@registration.companyname != "")
               $var13 = @registration.companyname
           else
             $var13 = "NA"
           end
       $var14 = @registration.address2
     # @registration = Registration.find(:all, :conditions => {:firstname => @@var1})
      if(!mandatoryFieldsCheck1())
            Alert.show_popup "Please enter all mandatory fields"
        Registration.delete_all(:conditions => {:emailid => @@var3})
            redirect :action => :new
      elsif(!validate_email1())
            Alert.show_popup "The emailids does not match, please enter again"
        Registration.delete_all(:conditions => {:emailid => @@var3})
            redirect :action => :new
      elsif(!validate_password())
            Alert.show_popup "The password you entered is not in the correct format, please enter again"
        Registration.delete_all(:conditions => {:emailid => @@var3})
            redirect :action => :new
      elsif(!password_check())
            Alert.show_popup "The passwords does not match, please enter again"
        Registration.delete_all(:conditions => {:emailid => @@var3})
            redirect :action => :new
      elsif(!zipCodeCheck())
            Alert.show_popup "invalid postal code, please enter again"
        Registration.delete_all(:conditions => {:emailid => @@var3})
            redirect :action => :new
      elsif(!phonenumber())
            Alert.show_popup "invalid phone number, please enter again"
        Registration.delete_all(:conditions => {:emailid => @@var3})
            redirect :action => :new
      else
            redirect :action => :registerDetails
            
          end
           
    end
    
    
  def registerDetails
    @registration = Registration.find(:all, :conditions => {:firstname => @@var1})
      userdetails = Hash.new
      userdetails = { :userid => @@var3,
                     :firstname => @@var1,
                     :lastname => @@var2,
                     :companyname => $var13,
                     :address1 => $var7,
                     :address2 => $var14,
                     :password => $var5,
                     :city => $var10,
                     :state => $var11,
                     :country => $var12,
                     :zipcode => $var8,
                     :phonenumber => $var9}
                    
      
      require 'json'
      register_request = userdetails.to_json
     
      result = Rho::AsyncHttp.post( 
                                    :url => $register_URL, 
                                    :body => register_request)             
      data1 = result['body']
      data2 = Rho::JSON.parse(data1) 
      $registration = data2["registration"]
  
        if $registration == "true"      
          Alert.show_popup "Hello "+@@var1+", Thank You for registering. Please Login for Shopping"
          #@register.destroy
          WebView.navigate ( url_for :controller=>:Settings,:action => :login1)
        else
          Alert.show_popup "Registration failed. Please try again"
          Registration.delete_all(:conditions => {:emailid => @@var3})
          redirect :action => :registration #, :id => @register.object  
        end
      
    end
    
    
  def mandatoryFieldsCheck1
        #@register = Register.create(@params['register'])
        if(@@var1 != "" && @@var2 != "" && @@var3 != ""  && $var4 != "" && $var5 != "" && $var6 != "" && $var7 != "" && $var8 !="" && $var9 !="" && $var10 !="" && $var11 !="" && $var12 !="")
        return true
        else
        return false
        end
      end
    
    
    def validate_email1    
  #email = /^[a-z0-9_\+-]+(\.[a-z0-9_\+-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.([a-z]{2,4})/
  #return (email.match($userid))? true : false
      if(@@var3 == $var4)
        return true
      else
        return false
      end
    end
    
    def validate_password
       reg = /^(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){8,12}$/
       return (reg.match($var5))? true : false
    end
    
    def password_check
      if ($var5 == $var6)
        return true
      else
        return false
      end
    end
    
    def zipCodeCheck
        #@register = Register.create(@params['register'])
        if($var8.length == 6)
          zipArray = $var8.split("")
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
    
    
  def phonenumber
      #@register = Register.create(@params['register'])
      if($var9.length == 10)
        phoneArray = $var9.split("")
         flagZip = 0
         (0.. (phoneArray.length - 1)).each do |i|
             if (phoneArray[i].ord < 48 || phoneArray[i].ord > 57)
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
    
    
  
end
