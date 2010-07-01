require 'spec_helper'

describe Card do
  
  should_belong_to :owner
  should_validate_presence_of :first_name, :last_name, :expiration, :number, :verification_value, :zip #, :subscription_id

  before :each do
    owner = Factory.build :owner
    @card = Factory.build :card, :owner => owner
  end

  describe "should set display fields" do
    before do
      @card.number = "1234567891234567"
      @card.expiration = '01/2030'
      @card.save
    end
    
    it ": number" do
      @card.display_number.should == "XXXX-XXXX-XXXX-4567"
    end

    it ": expiration date" do
      @card.display_expiration_date.should == Date.new(2030, 01, 01)
    end
    
  end

  it "should create ExtCreditCard" do
    @card.save
    @card.credit_card.should be_an_instance_of ExtCreditCard
  end
  
  describe "payment system" do 

    it "should create recuring" do
      PaymentSystem.should_receive(:recurring)
      @card.save
    end

    it "should update recuring" do
      @card.save
      @card.first_name = "Another name"

      PaymentSystem.should_receive(:cancel_recurring)
      PaymentSystem.should_receive(:recurring)
      @card.save
    end

    it "should cancel recuring" do
      @card.save

      PaymentSystem.should_receive(:cancel_recurring)
      @card.destroy
    end
    
  end
  
  describe "should has error" do

    context ":credit_card is invalid " do
             
      before :each do         
        @card.expiration = "10/2000"
      end    
                              
      it "when recurring and got PaymentSystemError" do
        p @card.valid?
        @card.should_receive(:recurring).and_return(false)
        @card.save
      end
      
    end
    
  end

end
