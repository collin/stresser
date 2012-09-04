require_relative "./../spec_helper"

describe Httperf do

  describe "merging httperf outputs" do
    before(:each) do
      pipe1 = File.open("spec/httperf_session_based_output.txt")
      pipe2 = File.open("spec/httperf_session_based_output_2.txt")
      Time.stub!(:now).and_return "Tue Nov 30 15:49:08 0100 2010"

      @result = Httperf.merge pipe1, pipe2
    end

    it "should merge the 'Total' line correctly" do
      @result['conns'].should    == 500 * 2
      @result['requests'].should == 600 * 2
      @result['replies'].should  == 300 * 2
      @result['duration'].should == 50.354 # not sure what to do with duration
    end

    it "should merge the 'Connection rate' line correctly" do
      @result['conn/s'].should == (9.9 + 10.1) / 2
      @result['ms/connection'].should == (100.7 + 200.0) / 2
      @result['concurrent connections max'].should == 16
    end
    
    it "should merge the 'Connection time' line correctly" do
      @result['conn time min'].should    == 200.7
      @result['conn time avg'].should    == (465.1 + 500.3) / 2 # avg could be a dirty lie
      @result['conn time max'].should    == 2856.6
      @result['conn time median'].should == 451.5 # not sure what to do with median
      @result['conn time stddev'].should == (132.1 + 145.2) / 2 # std dev could be a dirty lie
    end

    it "should merge the second 'Connection time' line correctly" do
      @result['conn time connect'].should == 74.1 # not sure what to do with conn time connect
    end

    it "should merge the 'Connection length' line correctly" do
      @result['conn length replies/conn'].should == (1.0 + 2.0) / 2
    end

    it "should merge the 'Request rate' line correctly" do
      @result['req/s'].should == (9.9 + 19.9) / 2
      @result['ms/req'].should == (100.7 + 200.7) / 2
    end

    it "should merge the 'Request size' line correctly" do
      @result['request size'].should == 65.0 # not sure what to do with request size
    end

    it "should merge the 'Reply rate' line correctly" do
      @result['replies/s min'].should    == 8.2
      @result['replies/s avg'].should    == (9.9 + 10.9) / 2 # avg could be a dirty lie
      @result['replies/s max'].should    == 10.0
      @result['replies/s stddev'].should == (0.3 + 0.5) / 2 # std dev could be a dirty lie
    end

    it "should merge the 'Reply time' line correctly" do
      @result['reply time response'].should == 88.1 # not sure what to do
      @result['reply time transfer'].should == 302.9 # not sure what to do
    end

    it "should merge the 'Reply size' line correctly" do
      @result['reply size header'].should  == 274.0  # not sure what to do
      @result['reply size content'].should == 54744.0 # not sure what to do
      @result['reply size footer'].should  == 2.0     # not sure what to do
      @result['reply size total'].should   == 55020.0 # not sure what to do
    end

    it "should merge the 'Reply status' line correctly" do
      @result['status 1xx'].should == 1 * 2 
      @result['status 2xx'].should == 500 * 2
      @result['status 3xx'].should == 3 * 2
      @result['status 4xx'].should == 4 * 2
      @result['status 5xx'].should == 5 * 2
    end
    
    it "should merge the 'CPU time' line correctly" do
      @result['cpu time user'].should     == (15.65 + 25.65 ) / 2
      @result['cpu time system'].should   == (34.65 + 44.65 ) / 2
      @result['cpu time user %'].should   == (31.1 + 41.1 ) / 2
      @result['cpu time system %'].should == (68.8 + 78.8 ) / 2
      @result['cpu time total %'].should  == (99.9 + 89.9 ) / 2
    end

    it "should merge the 'Net I/O' line correctly" do
      @result['net i/o (KB/s)'].should == 534.1 * 2
    end

    it "should merge the first 'Errors' line correctly" do
      @result['errors total'].should       == 1234 * 2
      @result['errors client-timo'].should == 2345 * 2
      @result['errors socket-timo'].should == 3456 * 2
      @result['errors connrefused'].should == 4567 * 2
      @result['errors connreset'].should   == 5678 * 2
    end

    it "should merge the second 'Errors' line correctly" do
      @result['errors fd-unavail'].should  == 1 * 2
      @result['errors addrunavail'].should == 2 * 2
      @result['errors ftab-full'].should   == 3 * 2
      @result['errors other'].should       == 4 * 2
    end
  
    # Not sure what to do with session info.
    # it "should merge the 'Session rate' line correctly" do
    #   @result['session rate min'].should    == 35.80
    #   @result['session rate avg'].should    == 37.04
    #   @result['session rate max'].should    == 38.20
    #   @result['session rate stddev'].should == 0.98
    #   @result['session rate quota'].should  == "1000/1000"
    # end 

    # it "should merge the 'Session' line correctly" do
    #   @result['session avg conns/sess'].should == 2.00
    # end

    # it "should merge the 'Session lifetime' line correctly" do
    #   @result['session lifetime [s]'].should == 0.3
    # end

    # it "should merge the 'Session failtime' line correctly" do
    #   @result['session failtime [s]'].should == 0.0
    # end

    # it "should merge the 'Session length histogram' correctly" do
    #   @result['session length histogram'].should == "0 0 1000" 
    # end

    # it "should add a started at timestamp for each rate" do
    #   @result['started at'].should == "Tue Nov 30 15:49:08 0100 2010" 
    # end

  end

  describe "parsing httperf output" do

    before(:each) do
      @pipe = File.open("spec/httperf_session_based_output.txt") 
      Time.stub!(:now).and_return "Tue Nov 30 15:49:08 0100 2010"
      
      #
      # The friendly snail is greeting you!
      #
      IO.should_receive(:popen).and_yield @pipe
      @result = Httperf.run({})
    end

    it "should parse the 'Total' line correctly" do
      @result['conns'].should    == 500
      @result['requests'].should == 600
      @result['replies'].should  == 300
      @result['duration'].should == 50.354
    end

    it "should parse the 'Connection rate' line correctly" do
      @result['conn/s'].should == 9.9
      @result['ms/connection'].should == 100.7
      @result['concurrent connections max'].should == 8
    end
    
    it "should parse the 'Connection time' line correctly" do
      @result['conn time min'].should    == 449.7
      @result['conn time avg'].should    == 465.1
      @result['conn time max'].should    == 2856.6
      @result['conn time median'].should == 451.5
      @result['conn time stddev'].should == 132.1
    end

    it "should parse the second 'Connection time' line correctly" do
      @result['conn time connect'].should == 74.1
    end

    it "should parse the 'Connection length' line correctly" do
      @result['conn length replies/conn'].should == 1.0
    end

    it "should parse the 'Request rate' line correctly" do
      @result['req/s'].should == 9.9
      @result['ms/req'].should == 100.7
    end

    it "should parse the 'Request size' line correctly" do
      @result['request size'].should == 65.0 
    end

    it "should parse the 'Reply rate' line correctly" do
      @result['replies/s min'].should    == 9.2
      @result['replies/s avg'].should    == 9.9
      @result['replies/s max'].should    == 10.0
      @result['replies/s stddev'].should == 0.3
    end

    it "should parse the 'Reply time' line correctly" do
      @result['reply time response'].should == 88.1
      @result['reply time transfer'].should == 302.9
    end

    it "should parse the 'Reply size' line correctly" do
      @result['reply size header'].should  == 274.0
      @result['reply size content'].should == 54744.0
      @result['reply size footer'].should  == 2.0
      @result['reply size total'].should   == 55020.0
    end

    it "should parse the 'Reply status' line correctly" do
      @result['status 1xx'].should == 1 
      @result['status 2xx'].should == 500
      @result['status 3xx'].should == 3 
      @result['status 4xx'].should == 4
      @result['status 5xx'].should == 5
    end
    
    it "should parse the 'CPU time' line correctly" do
      @result['cpu time user'].should     == 15.65
      @result['cpu time system'].should   == 34.65
      @result['cpu time user %'].should   == 31.1
      @result['cpu time system %'].should == 68.8
      @result['cpu time total %'].should  == 99.9
    end

    it "should parse the 'Net I/O' line correctly" do
      @result['net i/o (KB/s)'].should == 534.1
    end

    it "should parse the first 'Errors' line correctly" do
      @result['errors total'].should       == 1234
      @result['errors client-timo'].should == 2345
      @result['errors socket-timo'].should == 3456
      @result['errors connrefused'].should == 4567
      @result['errors connreset'].should   == 5678
    end

    it "should parse the second 'Errors' line correctly" do
      @result['errors fd-unavail'].should  == 1
      @result['errors addrunavail'].should == 2
      @result['errors ftab-full'].should   == 3
      @result['errors other'].should       == 4
    end
   
    it "should parse the 'Session rate' line correctly" do
      @result['session rate min'].should    == 35.80
      @result['session rate avg'].should    == 37.04
      @result['session rate max'].should    == 38.20
      @result['session rate stddev'].should == 0.98
      @result['session rate quota'].should  == "1000/1000"
    end 

    it "should parse the 'Session' line correctly" do
      @result['session avg conns/sess'].should == 2.00
    end

    it "should parse the 'Session lifetime' line correctly" do
      @result['session lifetime [s]'].should == 0.3
    end

    it "should parse the 'Session failtime' line correctly" do
      @result['session failtime [s]'].should == 0.0
    end

    it "should parse the 'Session length histogram' correctly" do
      @result['session length histogram'].should == "0 0 1000" 
    end

    it "should add a started at timestamp for each rate" do
      @result['started at'].should == "Tue Nov 30 15:49:08 0100 2010" 
    end

  end
end

