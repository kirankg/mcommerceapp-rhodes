# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Products
  include Rhom::PropertyBag
  belongs_to :categoryname, 'Categories'
  # Uncomment the following line to enable sync with Products.
   enable :sync

  #add model specifc code here
end
