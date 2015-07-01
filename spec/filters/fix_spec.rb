require 'spec_helper'
require "logstash/filters/fix"

describe LogStash::Filters::Fix do
  describe "Parse Fix Message" do
    let(:config) do <<-CONFIG
      filter {
        fix {
          source => "message"
          target => "fixMessage"
        }
      }
    CONFIG
    end

    expected = <<-EOS
<?xml version="1.0" encoding="ISO-8859-1" standalone="no"?>
<message>
<header>
<field name="BeginString" tag="8"><![CDATA[FIX.4.3]]></field>
<field name="BodyLength" tag="9"><![CDATA[243]]></field>
<field name="MsgSeqNum" tag="34"><![CDATA[20150429-00001]]></field>
<field enum="NewOrderSingle" name="MsgType" tag="35"><![CDATA[D]]></field>
<field name="SenderCompID" tag="49"><![CDATA[UKBANK3]]></field>
<field name="SendingTime" tag="52"><![CDATA[20150429-06:51:36]]></field>
<field name="TargetCompID" tag="56"><![CDATA[HELIXsysTrading]]></field>
</header>
<body>
<field name="Account" tag="1"><![CDATA[B39999999]]></field>
<field name="ClOrdID" tag="11"><![CDATA[bceacad4-f2dc-4e79-bafb-ca1b74b8110a]]></field>
<field name="Currency" tag="15"><![CDATA[USD]]></field>
<field enum="AUTOMATED_EXECUTION_ORDER_PUBLIC" name="HandlInst" tag="21"><![CDATA[2]]></field>
<field enum="CUSIP" name="SecurityIDSource" tag="22"><![CDATA[1]]></field>
<field name="OrderQty" tag="38"><![CDATA[79000]]></field>
<field enum="MARKET" name="OrdType" tag="40"><![CDATA[1]]></field>
<field name="Price" tag="44"><![CDATA[34.80]]></field>
<field name="SecurityID" tag="48"><![CDATA[00026349]]></field>
<field enum="BUY" name="Side" tag="54"><![CDATA[1]]></field>
<field name="Symbol" tag="55"><![CDATA[BA.L]]></field>
<field enum="DAY" name="TimeInForce" tag="59"><![CDATA[0]]></field>
<field name="TransactTime" tag="60"><![CDATA[20150429-06:51:36]]></field>
<field enum="REGULAR" name="SettlmntTyp" tag="63"><![CDATA[0]]></field>
<field name="MinQty" tag="110"><![CDATA[15000]]></field>
<field name="MaxFloor" tag="111"><![CDATA[158000]]></field>
</body>
<trailer>
<field name="CheckSum" tag="10"><![CDATA[248]]></field>
</trailer>
</message>
EOS

    sample("message" => "8=FIX.4.39=24335=D49=UKBANK31=B3999999956=HELIXsysTrading34=20150429-0000152=20150429-06:51:3611=bceacad4-f2dc-4e79-bafb-ca1b74b8110a63=021=2110=15000111=15800044=34.8038=7900055=BA.L48=0002634922=154=140=115=USD59=060=20150429-06:51:3610=248") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq(expected)
    end
  end
end
