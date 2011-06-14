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
end
