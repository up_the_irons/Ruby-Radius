require 'radius/packet.rb'
require 'radius/dictionary.rb'

describe Radius::Packet do
  before(:all) do
    @secret = 'mykey123'

    # RAD-Code = Access-Request
    # RAD-Identifier = 21
    # RAD-Authenticator = FwTtIrNw6W4PnKV6K4ghRg==
    # User-Password = bar
    # User-Name = foo
    # NAS-Port-Type =
    # NAS-Port = 9
    # NAS-IP-Address = 208.79.90.34

           #  1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
    data = ["0115003d1704ed22b370e96e0f9ca57a2b882146" +
            "0105666f6f021295cb02c163c6ab7bc5bf382198" +
            "7769310406d04f5a220506000000093d06000000" +
            "05"].pack("H*")

    @dictionary = Radius::Dict.new
    @dictionary.read(File.new("dictionary"))

    @packet = Radius::Packet.new(@dictionary)
    @packet.unpack(data)
  end

  it "should parse the packet code" do
    @packet.code.should == "Access-Request"
  end

  it "should parse the packet authenticator" do
    # From original packet, see above
    [@packet.authenticator].pack('m').chomp.should ==
      'FwTtIrNw6W4PnKV6K4ghRg=='
  end

  it "should parse the identifier" do
    @packet.identifier.should == 21
  end

  it "should parse the packet length" do
    @packet.length.should == 61
  end

  describe "Attributes" do
    it "should parse User-Name" do
      @packet.attr('User-Name').should == 'foo'
    end

    it "should parse User-Password" do
      @packet.password(@secret).should == 'bar'
    end

    it "should parse NAS-Port" do
      @packet.attr('NAS-Port').should == 9
    end
  end

  describe "Response Authenticator" do
    before do
      # Create an Access-Accept packet
      @response = Radius::Packet.new(@dictionary)
      @response.code = 'Access-Accept'
      @response.identifier = @packet.identifier
    end

    describe "access_response_authenticator()" do
      it "should return correct Response Authenticator" do
        # Verify Response Authenticator is valid
        resp_auth = @response.access_response_authenticator(@packet, @secret)
        base64_resp_auth = [resp_auth].pack('m').chomp

        base64_resp_auth.should == "XXaB2V6qi4LAypOdM+4yUw=="
        # This Response Authenticator was gathered by watching debug output of
        # this library interacting with a Cisco ASA (8.0).  It passed the
        # 'test aaa-server ...' command and confirmed valid.
      end
    end

    describe "set_access_response_authenticator!()" do
      it "should raise error if packet is not an Access-* type" do
        @response = Radius::Packet.new(@dictionary)
        @response.code = 'Accounting-Response'
        @response.identifier = @packet.identifier

        proc {
          @response.set_access_response_authenticator!(@packet, @secret)
        }.should raise_error(ArgumentError)
      end

      it "should set correct Response Authenticator" do
        @response.set_access_response_authenticator!(@packet, @secret)
        base64_resp_auth = [@response.authenticator].pack('m').chomp
        base64_resp_auth.should == "XXaB2V6qi4LAypOdM+4yUw=="
      end
    end
  end

  describe "generate_random_authenticator()" do
    describe "with /dev/urandom available" do
      before do
        @device = "/dev/urandom"
        File.stub!(:exist?).and_return(true)
      end

      it "should use /dev/urandom if available" do
        File.should_receive(:open).with(@device)
        @packet.generate_random_authenticator
      end
    end

    describe "without /dev/urandom" do
      before do
        File.stub!(:exist?).and_return(false)
      end

      it "should use rand()" do
        @packet.should_receive(:rand).with(65536).exactly(8).times.\
          and_return(1)
        @packet.generate_random_authenticator
      end
    end
  end
end
