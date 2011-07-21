require_relative "input_state"
require_relative "control_systems/system_test_helper"
include TestHelper

describe InputState do
  context "from a :start state" do
    before (:each) do
      @is = InputState.new(:start)
      @is.state.should == :start
    end
    
    it "Should accept letters in the start state" do
      @is.accept('a').should == true
      @is.state.should == :word
      @is.change?.should == true      
    end
  
    it "Should accept letters in the start state" do
      @is.accept('v').should == true
      @is.state.should == :word
      @is.change?.should == true      
    end
    
    it "Should not accept return key" do
      @is.accept("\n").should == false
      @is.state.should == :start
      @is.change?.should == false
    end
    
    it "Should not accept space key" do
      @is.accept(:space).should == false
      @is.state.should == :start
      @is.change?.should == false
    end
    
    it "Should not accept arroww key" do
      @is.accept(:up).should == false
      @is.state.should == :start
      @is.change?.should == false
    end
  end

  context "from a :word state" do
    before (:each) do
      @is = InputState.new(:word)
      @is.state.should == :word
    end
    
    it "Should accept letters in the word state" do
      @is.accept('a').should == true
      @is.state.should == :word
      @is.change?.should == true      
    end
    
    it "Should accept delete in the word state" do
      @is.accept(:backspace).should == true
      @is.state.should == :word
      @is.change?.should == true      
    end
    
    it "Should accept return key" do
      @is.accept("\n").should == true
      @is.state.should == :start
      @is.change?.should == true
    end
    
    it "Should accept space key" do
      @is.accept(' ').should == true
      @is.state.should == :next
      @is.change?.should == true
    end
    
    it "Should accept arrow key, but not chnage state" do
      @is.accept(:down).should == true
      @is.state.should == :word
      @is.change?.should == false
    end
  end
  
  context "from a :next state" do
    before (:each) do
      @is = InputState.new(:next)
      @is.state.should == :next
    end
    
    it "Should accept letters in the next state" do
      @is.accept('a').should == true
      @is.state.should == :word
      @is.change?.should == true
    end
    
    it "Should accept return key" do
      @is.accept("\n").should == true
      @is.state.should == :start
      @is.change?.should == true
    end
    
    it "Should accept space key" do
      @is.accept(:space).should == false
      @is.state.should == :next
      @is.change?.should == false
    end
    
    it "Should accept arrow key, but not chnage state" do
      @is.accept(:down).should == false
      @is.state.should == :next
      @is.change?.should == false
    end
  end
end
