require_relative "../spec_helper.rb"

describe ImplTrade do
  
  before :each do
    @impl = ImplTrade.new
    @item = mock "Torpedo", :type => :torpedo
    @other = mock "Elephant", :type => :elephant
  end
 
  context "Where service is not offered" do
 
    before :each do
      garage = mock "garage", :services => []
      garagelp = mock "garage", :body => garage
      cp = mock "lps", :find_linked_location => [garagelp]
      @station = mock "station", :centrePoint => cp
    end

    it "impl returns nil" do
      service = @impl.service_module_offered(@station, @item.type)
      service.should be_nil
    end
  end
  
  context "Where service is offered but not selected" do
 
    before :each do
      garage = mock "garage", :services => [@item, @other]
      garagelp = mock "garage", :body => garage
      cp = mock "lps", :find_linked_location => [garagelp]
      @station = mock "station", :centrePoint => cp
    end

    it "impl returns nil" do
      service = @impl.service_module_offered(@station, :giraffe)
      service.should be_nil
    end
  end
  
  context "Where service is offered" do
 
    before :each do
      garage = mock "garage", :services => [@item]
      garagelp = mock "garage", :body => garage
      cp = mock "lps", :find_linked_location => [garagelp]
      @station = mock "station", :centrePoint => cp
    end

    it "impl returns torpedo" do
      service = @impl.service_module_offered(@station, :torpedo)
      service.should == @item
    end
  end 
end