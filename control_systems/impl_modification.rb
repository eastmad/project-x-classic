class ImplModification

  attr_reader :mods

  def initialize 
    @mods = []
  end
  
  def install modification_class
      raise "Not a module that can be installed" unless modification_class.superclass ==  Modification

      mod = modification_class.new
      @mods << mod
      
      mod
  end

end

