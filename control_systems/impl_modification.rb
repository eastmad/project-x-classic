class ImplModification

  attr_reader :mods

  def initialize 
    @mods = []
  end
  
  def all_mod_cons
    
    para1 = "  Modifications\n\n"
    @mods.each do |mod|
      para1 << "  #{mod.name}\n" 
    end
  
    para1
  end
  
  def install modification_class
      raise "Not a module that can be installed" unless modification_class.superclass ==  Modification

      mod = modification_class.new
      @mods << mod
      
      mod
  end
  
  def mod_type_present? type
    @mods.each do |mod|
      info "mod.type == #{mod.type}"
      return true if mod.type == type
    end
    
    false
  end
end

