# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Shippingaddress
  include Rhom::PropertyBag
  belongs_to :firstname, 'Registration'
  # Uncomment the following line to enable sync with Shippingaddress.
   enable :sync

  #add model specifc code here
end
