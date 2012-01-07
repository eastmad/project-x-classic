require_relative "../spec_helper.rb"

describe ImplContact do
  
  before :each do
    @impl = ImplContact.new
    @contact = mock "Contact", :details => {}
    @cargo = mock "Cargo"
  end
 
  context "Where contact unknown" do
    it "impl returns not contacted" do 
      @impl.contacted?(@contact).should be_false
      
    end
    it "impl returns not met" do 
      @impl.met?(@contact).should be_false
    end
    
    context "where no interests" do
    	it "impl returns interested" do 
    	  @impl.interested?(@contact, @cargo).should be_true
    	end
    end
    
    context "where no interests match" do
      it "impl returns not interested" do 
        @contact = mock "Contact", :details => {:interest => :venison}
        @item = mock "Item", :conditions => [:fish]
        @consignment = mock "Consignment", :item => @item
        @cargo = [@consignment]
        @impl.interested?(@contact, @cargo).should be_false
      end
    end
    
    context "where interests match" do
      it "impl returns interested" do 
        @contact = mock "Contact", :details => {:interest => :venison}
        @item = mock "Item", :conditions => [:venison]
        @consignment = mock "Consignment", :item => @item
        @cargo = [@consignment]
        @impl.interested?(@contact, @cargo).should be_true
      end
    end
  end
  
  context "Where contact added" do
  
    before :each do
      @impl.contact_made(@contact)
    end 

    it "impl returns not contacted" do 
      @impl.contacted?(@contact).should be_true   
    end

    it "impl returns not met" do 
      @impl.met?(@contact).should be_false
    end    
  end
  
  context "Where contact made" do
    
    before :each do
      @impl.contact_made(@contact)
      @impl.contact_met(@contact)
    end 
       
    it "impl returns not contacted" do 
      @impl.contacted?(@contact).should be_true   
    end
    
    it "impl returns not met" do 
       @impl.met?(@contact).should be_true
    end    
  end
end