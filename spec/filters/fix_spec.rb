require 'spec_helper'
require "logstash/filters/fix"

describe LogStash::Filters::Fix do
  describe "Parse FIX Message" do
    let(:config) do
      <<-CONFIG
      filter {
        fix {
          source => "message"
          target => "fixMessage"
        }
      }
      CONFIG
    end


    sample("message" => "8=FIX.4.39=24335=D49=UKBANK31=B3999999956=HELIXsysTrading34=20150429-0000152=20150429-06:51:3611=bceacad4-f2dc-4e79-bafb-ca1b74b8110a63=021=2110=15000111=15800044=34.8038=7900055=BA.L48=0002634922=154=140=115=USD59=060=20150429-06:51:3610=248") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.3", "@tag" => "8" }, "BodyLength" => { "value" => "243", "@tag" => "9" }, "MsgSeqNum" => { "value" => "20150429-00001", "@tag" => "34" }, "MsgType" => { "value" => "D", "@enum" => "NewOrderSingle", "@tag" => "35" }, "SenderCompID" => { "value" => "UKBANK3", "@tag" => "49" }, "SendingTime" => { "value" => "20150429-06:51:36", "@tag" => "52" }, "TargetCompID" => { "value" => "HELIXsysTrading", "@tag" => "56" } }, "body" => { "Account" => { "value" => "B39999999", "@tag" => "1" }, "ClOrdID" => { "value" => "bceacad4-f2dc-4e79-bafb-ca1b74b8110a", "@tag" => "11" }, "Currency" => { "value" => "USD", "@tag" => "15" }, "HandlInst" => { "value" => "2", "@enum" => "AUTOMATED_EXECUTION_ORDER_PUBLIC", "@tag" => "21" }, "SecurityIDSource" => { "value" => "1", "@enum" => "CUSIP", "@tag" => "22" }, "OrderQty" => { "value" => "79000", "@tag" => "38" }, "OrdType" => { "value" => "1", "@enum" => "MARKET", "@tag" => "40" }, "Price" => { "value" => "34.80", "@tag" => "44" }, "SecurityID" => { "value" => "00026349", "@tag" => "48" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "BA.L", "@tag" => "55" }, "TimeInForce" => { "value" => "0", "@enum" => "DAY", "@tag" => "59" }, "TransactTime" => { "value" => "20150429-06:51:36", "@tag" => "60" }, "SettlmntTyp" => { "value" => "0", "@enum" => "REGULAR", "@tag" => "63" }, "MinQty" => { "value" => "15000", "@tag" => "110" }, "MaxFloor" => { "value" => "158000", "@tag" => "111" } }, "trailer" => { "CheckSum" => { "value" => "248", "@tag" => "10" } } })
    end


    # sample data from http://fixparser.targetcompid.com
    sample("message" => "8=FIX.4.19=6135=A34=149=EXEC52=20121105-23:24:0656=BANZAI98=0108=3010=003") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "61", "@tag" => "9" }, "MsgSeqNum" => { "value" => "1", "@tag" => "34" }, "MsgType" => { "value" => "A", "@enum" => "Logon", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:06", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "EncryptMethod" => { "value" => "0", "@enum" => "NONE_OTHER", "@tag" => "98" }, "HeartBtInt" => { "value" => "30", "@tag" => "108" } }, "trailer" => { "CheckSum" => { "value" => "003", "@tag" => "10" } } })
    end


    sample("message" => "8=FIX.4.19=6135=A34=149=BANZAI52=20121105-23:24:0656=EXEC98=0108=3010=003") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({
                                              "header" => {
                                                  "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" },
                                                  "BodyLength" => { "value" => "61", "@tag" => "9" },
                                                  "MsgSeqNum" => { "value" => "1", "@tag" => "34" },
                                                  "MsgType" => { "value" => "A", "@enum" => "Logon", "@tag" => "35" },
                                                  "SenderCompID" => { "value" => "BANZAI", "@tag" => "49" },
                                                  "SendingTime" => { "value" => "20121105-23:24:06", "@tag" => "52" },
                                                  "TargetCompID" => { "value" => "EXEC", "@tag" => "56" }
                                              },
                                              "body" => {
                                                  "EncryptMethod" => { "value" => "0", "@enum" => "NONE_OTHER", "@tag" => "98" },
                                                  "HeartBtInt" => { "value" => "30", "@tag" => "108" }
                                              },
                                              "trailer" => {
                                                  "CheckSum" => { "value" => "003", "@tag" => "10" }
                                              }
                                          })
    end
    sample("message" => "8=FIX.4.19=4935=034=249=BANZAI52=20121105-23:24:3756=EXEC10=228") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "49", "@tag" => "9" }, "MsgSeqNum" => { "value" => "2", "@tag" => "34" }, "MsgType" => { "value" => "0", "@enum" => "Heartbeat", "@tag" => "35" }, "SenderCompID" => { "value" => "BANZAI", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:37", "@tag" => "52" }, "TargetCompID" => { "value" => "EXEC", "@tag" => "56" } }, "body" => nil, "trailer" => { "CheckSum" => { "value" => "228", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=4935=034=249=EXEC52=20121105-23:24:3756=BANZAI10=228") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "49", "@tag" => "9" }, "MsgSeqNum" => { "value" => "2", "@tag" => "34" }, "MsgType" => { "value" => "0", "@enum" => "Heartbeat", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:37", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => nil, "trailer" => { "CheckSum" => { "value" => "228", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=10335=D34=349=BANZAI52=20121105-23:24:4256=EXEC11=135215788257721=138=1000040=154=155=MSFT59=010=062") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "103", "@tag" => "9" }, "MsgSeqNum" => { "value" => "3", "@tag" => "34" }, "MsgType" => { "value" => "D", "@enum" => "NewOrderSingle", "@tag" => "35" }, "SenderCompID" => { "value" => "BANZAI", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:42", "@tag" => "52" }, "TargetCompID" => { "value" => "EXEC", "@tag" => "56" } }, "body" => { "ClOrdID" => { "value" => "1352157882577", "@tag" => "11" }, "HandlInst" => { "value" => "1", "@enum" => "AUTOMATED_EXECUTION_ORDER_PRIVATE_NO_BROKER_INTERVENTION", "@tag" => "21" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdType" => { "value" => "1", "@enum" => "MARKET", "@tag" => "40" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "MSFT", "@tag" => "55" }, "TimeInForce" => { "value" => "0", "@enum" => "DAY", "@tag" => "59" } }, "trailer" => { "CheckSum" => { "value" => "062", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=13935=834=349=EXEC52=20121105-23:24:4256=BANZAI6=011=135215788257714=017=120=031=032=037=138=1000039=054=155=MSFT150=2151=010=059") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "139", "@tag" => "9" }, "MsgSeqNum" => { "value" => "3", "@tag" => "34" }, "MsgType" => { "value" => "8", "@enum" => "ExecutionReport", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:42", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "AvgPx" => { "value" => "0", "@tag" => "6" }, "ClOrdID" => { "value" => "1352157882577", "@tag" => "11" }, "CumQty" => { "value" => "0", "@tag" => "14" }, "ExecID" => { "value" => "1", "@tag" => "17" }, "ExecTransType" => { "value" => "0", "@enum" => "NEW", "@tag" => "20" }, "LastPx" => { "value" => "0", "@tag" => "31" }, "LastShares" => { "value" => "0", "@tag" => "32" }, "OrderID" => { "value" => "1", "@tag" => "37" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdStatus" => { "value" => "0", "@enum" => "NEW", "@tag" => "39" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "MSFT", "@tag" => "55" }, "ExecType" => { "value" => "2", "@enum" => "FILL", "@tag" => "150" }, "LeavesQty" => { "value" => "0", "@tag" => "151" } }, "trailer" => { "CheckSum" => { "value" => "059", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=15335=834=449=EXEC52=20121105-23:24:4256=BANZAI6=12.311=135215788257714=1000017=220=031=12.332=1000037=238=1000039=254=155=MSFT150=2151=010=230") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "153", "@tag" => "9" }, "MsgSeqNum" => { "value" => "4", "@tag" => "34" }, "MsgType" => { "value" => "8", "@enum" => "ExecutionReport", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:42", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "AvgPx" => { "value" => "12.3", "@tag" => "6" }, "ClOrdID" => { "value" => "1352157882577", "@tag" => "11" }, "CumQty" => { "value" => "10000", "@tag" => "14" }, "ExecID" => { "value" => "2", "@tag" => "17" }, "ExecTransType" => { "value" => "0", "@enum" => "NEW", "@tag" => "20" }, "LastPx" => { "value" => "12.3", "@tag" => "31" }, "LastShares" => { "value" => "10000", "@tag" => "32" }, "OrderID" => { "value" => "2", "@tag" => "37" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdStatus" => { "value" => "2", "@enum" => "FILLED", "@tag" => "39" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "MSFT", "@tag" => "55" }, "ExecType" => { "value" => "2", "@enum" => "FILL", "@tag" => "150" }, "LeavesQty" => { "value" => "0", "@tag" => "151" } }, "trailer" => { "CheckSum" => { "value" => "230", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=10335=D34=449=BANZAI52=20121105-23:24:5556=EXEC11=135215789503221=138=1000040=154=155=ORCL59=010=047") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "103", "@tag" => "9" }, "MsgSeqNum" => { "value" => "4", "@tag" => "34" }, "MsgType" => { "value" => "D", "@enum" => "NewOrderSingle", "@tag" => "35" }, "SenderCompID" => { "value" => "BANZAI", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:55", "@tag" => "52" }, "TargetCompID" => { "value" => "EXEC", "@tag" => "56" } }, "body" => { "ClOrdID" => { "value" => "1352157895032", "@tag" => "11" }, "HandlInst" => { "value" => "1", "@enum" => "AUTOMATED_EXECUTION_ORDER_PRIVATE_NO_BROKER_INTERVENTION", "@tag" => "21" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdType" => { "value" => "1", "@enum" => "MARKET", "@tag" => "40" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "ORCL", "@tag" => "55" }, "TimeInForce" => { "value" => "0", "@enum" => "DAY", "@tag" => "59" } }, "trailer" => { "CheckSum" => { "value" => "047", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=13935=834=549=EXEC52=20121105-23:24:5556=BANZAI6=011=135215789503214=017=320=031=032=037=338=1000039=054=155=ORCL150=2151=010=049") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "139", "@tag" => "9" }, "MsgSeqNum" => { "value" => "5", "@tag" => "34" }, "MsgType" => { "value" => "8", "@enum" => "ExecutionReport", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:55", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "AvgPx" => { "value" => "0", "@tag" => "6" }, "ClOrdID" => { "value" => "1352157895032", "@tag" => "11" }, "CumQty" => { "value" => "0", "@tag" => "14" }, "ExecID" => { "value" => "3", "@tag" => "17" }, "ExecTransType" => { "value" => "0", "@enum" => "NEW", "@tag" => "20" }, "LastPx" => { "value" => "0", "@tag" => "31" }, "LastShares" => { "value" => "0", "@tag" => "32" }, "OrderID" => { "value" => "3", "@tag" => "37" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdStatus" => { "value" => "0", "@enum" => "NEW", "@tag" => "39" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "ORCL", "@tag" => "55" }, "ExecType" => { "value" => "2", "@enum" => "FILL", "@tag" => "150" }, "LeavesQty" => { "value" => "0", "@tag" => "151" } }, "trailer" => { "CheckSum" => { "value" => "049", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=15335=834=649=EXEC52=20121105-23:24:5556=BANZAI6=12.311=135215789503214=1000017=420=031=12.332=1000037=438=1000039=254=155=ORCL150=2151=010=220") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "153", "@tag" => "9" }, "MsgSeqNum" => { "value" => "6", "@tag" => "34" }, "MsgType" => { "value" => "8", "@enum" => "ExecutionReport", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:24:55", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "AvgPx" => { "value" => "12.3", "@tag" => "6" }, "ClOrdID" => { "value" => "1352157895032", "@tag" => "11" }, "CumQty" => { "value" => "10000", "@tag" => "14" }, "ExecID" => { "value" => "4", "@tag" => "17" }, "ExecTransType" => { "value" => "0", "@enum" => "NEW", "@tag" => "20" }, "LastPx" => { "value" => "12.3", "@tag" => "31" }, "LastShares" => { "value" => "10000", "@tag" => "32" }, "OrderID" => { "value" => "4", "@tag" => "37" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdStatus" => { "value" => "2", "@enum" => "FILLED", "@tag" => "39" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "ORCL", "@tag" => "55" }, "ExecType" => { "value" => "2", "@enum" => "FILL", "@tag" => "150" }, "LeavesQty" => { "value" => "0", "@tag" => "151" } }, "trailer" => { "CheckSum" => { "value" => "220", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=10835=D34=549=BANZAI52=20121105-23:25:1256=EXEC11=135215791235721=138=1000040=244=1054=155=SPY59=010=003") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "108", "@tag" => "9" }, "MsgSeqNum" => { "value" => "5", "@tag" => "34" }, "MsgType" => { "value" => "D", "@enum" => "NewOrderSingle", "@tag" => "35" }, "SenderCompID" => { "value" => "BANZAI", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:25:12", "@tag" => "52" }, "TargetCompID" => { "value" => "EXEC", "@tag" => "56" } }, "body" => { "ClOrdID" => { "value" => "1352157912357", "@tag" => "11" }, "HandlInst" => { "value" => "1", "@enum" => "AUTOMATED_EXECUTION_ORDER_PRIVATE_NO_BROKER_INTERVENTION", "@tag" => "21" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdType" => { "value" => "2", "@enum" => "LIMIT", "@tag" => "40" }, "Price" => { "value" => "10", "@tag" => "44" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "SPY", "@tag" => "55" }, "TimeInForce" => { "value" => "0", "@enum" => "DAY", "@tag" => "59" } }, "trailer" => { "CheckSum" => { "value" => "003", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=13835=834=749=EXEC52=20121105-23:25:1256=BANZAI6=011=135215791235714=017=520=031=032=037=538=1000039=054=155=SPY150=2151=010=252") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "138", "@tag" => "9" }, "MsgSeqNum" => { "value" => "7", "@tag" => "34" }, "MsgType" => { "value" => "8", "@enum" => "ExecutionReport", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:25:12", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "AvgPx" => { "value" => "0", "@tag" => "6" }, "ClOrdID" => { "value" => "1352157912357", "@tag" => "11" }, "CumQty" => { "value" => "0", "@tag" => "14" }, "ExecID" => { "value" => "5", "@tag" => "17" }, "ExecTransType" => { "value" => "0", "@enum" => "NEW", "@tag" => "20" }, "LastPx" => { "value" => "0", "@tag" => "31" }, "LastShares" => { "value" => "0", "@tag" => "32" }, "OrderID" => { "value" => "5", "@tag" => "37" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrdStatus" => { "value" => "0", "@enum" => "NEW", "@tag" => "39" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "SPY", "@tag" => "55" }, "ExecType" => { "value" => "2", "@enum" => "FILL", "@tag" => "150" }, "LeavesQty" => { "value" => "0", "@tag" => "151" } }, "trailer" => { "CheckSum" => { "value" => "252", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=10435=F34=649=BANZAI52=20121105-23:25:1656=EXEC11=135215791643738=1000041=135215791235754=155=SPY10=198") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "104", "@tag" => "9" }, "MsgSeqNum" => { "value" => "6", "@tag" => "34" }, "MsgType" => { "value" => "F", "@enum" => "OrderCancelRequest", "@tag" => "35" }, "SenderCompID" => { "value" => "BANZAI", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:25:16", "@tag" => "52" }, "TargetCompID" => { "value" => "EXEC", "@tag" => "56" } }, "body" => { "ClOrdID" => { "value" => "1352157916437", "@tag" => "11" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrigClOrdID" => { "value" => "1352157912357", "@tag" => "41" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "SPY", "@tag" => "55" } }, "trailer" => { "CheckSum" => { "value" => "198", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=8235=334=849=EXEC52=20121105-23:25:1656=BANZAI45=658=Unsupported message type10=000") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "82", "@tag" => "9" }, "MsgSeqNum" => { "value" => "8", "@tag" => "34" }, "MsgType" => { "value" => "3", "@enum" => "Reject", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:25:16", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "RefSeqNum" => { "value" => "6", "@tag" => "45" }, "Text" => { "value" => "Unsupported message type", "@tag" => "58" } }, "trailer" => { "CheckSum" => { "value" => "000", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=10435=F34=749=BANZAI52=20121105-23:25:2556=EXEC11=135215792530938=1000041=135215791235754=155=SPY10=197") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "104", "@tag" => "9" }, "MsgSeqNum" => { "value" => "7", "@tag" => "34" }, "MsgType" => { "value" => "F", "@enum" => "OrderCancelRequest", "@tag" => "35" }, "SenderCompID" => { "value" => "BANZAI", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:25:25", "@tag" => "52" }, "TargetCompID" => { "value" => "EXEC", "@tag" => "56" } }, "body" => { "ClOrdID" => { "value" => "1352157925309", "@tag" => "11" }, "OrderQty" => { "value" => "10000", "@tag" => "38" }, "OrigClOrdID" => { "value" => "1352157912357", "@tag" => "41" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "SPY", "@tag" => "55" } }, "trailer" => { "CheckSum" => { "value" => "197", "@tag" => "10" } } })
    end
    sample("message" => "8=FIX.4.19=8235=334=949=EXEC52=20121105-23:25:2556=BANZAI45=758=Unsupported message type10=002") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.1", "@tag" => "8" }, "BodyLength" => { "value" => "82", "@tag" => "9" }, "MsgSeqNum" => { "value" => "9", "@tag" => "34" }, "MsgType" => { "value" => "3", "@enum" => "Reject", "@tag" => "35" }, "SenderCompID" => { "value" => "EXEC", "@tag" => "49" }, "SendingTime" => { "value" => "20121105-23:25:25", "@tag" => "52" }, "TargetCompID" => { "value" => "BANZAI", "@tag" => "56" } }, "body" => { "RefSeqNum" => { "value" => "7", "@tag" => "45" }, "Text" => { "value" => "Unsupported message type", "@tag" => "58" } }, "trailer" => { "CheckSum" => { "value" => "002", "@tag" => "10" } } })
    end

    sample("message" => '8=FIX.4.29=15335=D49=BLP56=SCHB34=150=3073797=Y52=20000809-20:20:5011=900010081=1003000321=255=TESTA54=138=400040=259=044=3047=I60=20000809-18:20:3210=013') do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => { "BeginString" => { "value" => "FIX.4.2", "@tag" => "8" }, "BodyLength" => { "value" => "153", "@tag" => "9" }, "MsgSeqNum" => { "value" => "1", "@tag" => "34" }, "MsgType" => { "value" => "D", "@enum" => "NewOrderSingle", "@tag" => "35" }, "SenderCompID" => { "value" => "BLP", "@tag" => "49" }, "SenderSubID" => { "value" => "30737", "@tag" => "50" }, "SendingTime" => { "value" => "20000809-20:20:50", "@tag" => "52" }, "TargetCompID" => { "value" => "SCHB", "@tag" => "56" }, "PossResend" => { "value" => "Y", "@tag" => "97" } }, "body" => { "Account" => { "value" => "10030003", "@tag" => "1" }, "ClOrdID" => { "value" => "90001008", "@tag" => "11" }, "HandlInst" => { "value" => "2", "@enum" => "AUTOMATED_EXECUTION_ORDER_PUBLIC_BROKER_INTERVENTION_OK", "@tag" => "21" }, "OrderQty" => { "value" => "4000", "@tag" => "38" }, "OrdType" => { "value" => "2", "@enum" => "LIMIT", "@tag" => "40" }, "Price" => { "value" => "30", "@tag" => "44" }, "Rule80A" => { "value" => "I", "@enum" => "INDIVIDUAL_INVESTOR", "@tag" => "47" }, "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" }, "Symbol" => { "value" => "TESTA", "@tag" => "55" }, "TimeInForce" => { "value" => "0", "@enum" => "DAY", "@tag" => "59" }, "TransactTime" => { "value" => "20000809-18:20:32", "@tag" => "60" } }, "trailer" => { "CheckSum" => { "value" => "013", "@tag" => "10" } } })
    end
  end

  describe "Parse FIX Message with different source and target" do
    let(:config) do
      <<-CONFIG
      filter {
        fix {
          source => "fix"
          target => "parsedFix"
        }
      }
      CONFIG
    end

    sample("fix" => "8=FIX.4.39=24335=D49=UKBANK31=B3999999956=HELIXsysTrading34=20150429-0000152=20150429-06:51:3611=bceacad4-f2dc-4e79-bafb-ca1b74b8110a63=021=2110=15000111=15800044=34.8038=7900055=BA.L48=0002634922=154=140=115=USD59=060=20150429-06:51:3610=248") do
      expect(subject).to include("fix")
      expect(subject).to include("parsedFix")
      expect(subject['parsedFix']).to eq({
                                             "header" => {
                                                 "BeginString" => { "value" => "FIX.4.3", "@tag" => "8" },
                                                 "BodyLength" => { "value" => "243", "@tag" => "9" },
                                                 "MsgSeqNum" => { "value" => "20150429-00001", "@tag" => "34" },
                                                 "MsgType" => { "value" => "D", "@enum" => "NewOrderSingle", "@tag" => "35" },
                                                 "SenderCompID" => { "value" => "UKBANK3", "@tag" => "49" },
                                                 "SendingTime" => { "value" => "20150429-06:51:36", "@tag" => "52" },
                                                 "TargetCompID" => { "value" => "HELIXsysTrading", "@tag" => "56" } },
                                             "body" => {
                                                 "Account" => { "value" => "B39999999", "@tag" => "1" },
                                                 "ClOrdID" => { "value" => "bceacad4-f2dc-4e79-bafb-ca1b74b8110a", "@tag" => "11" },
                                                 "Currency" => { "value" => "USD", "@tag" => "15" },
                                                 "HandlInst" => { "value" => "2", "@enum" => "AUTOMATED_EXECUTION_ORDER_PUBLIC", "@tag" => "21" },
                                                 "SecurityIDSource" => { "value" => "1", "@enum" => "CUSIP", "@tag" => "22" },
                                                 "OrderQty" => { "value" => "79000", "@tag" => "38" },
                                                 "OrdType" => { "value" => "1", "@enum" => "MARKET", "@tag" => "40" },
                                                 "Price" => { "value" => "34.80", "@tag" => "44" },
                                                 "SecurityID" => { "value" => "00026349", "@tag" => "48" },
                                                 "Side" => { "value" => "1", "@enum" => "BUY", "@tag" => "54" },
                                                 "Symbol" => { "value" => "BA.L", "@tag" => "55" },
                                                 "TimeInForce" => { "value" => "0", "@enum" => "DAY", "@tag" => "59" },
                                                 "TransactTime" => { "value" => "20150429-06:51:36", "@tag" => "60" },
                                                 "SettlmntTyp" => { "value" => "0", "@enum" => "REGULAR", "@tag" => "63" },
                                                 "MinQty" => { "value" => "15000", "@tag" => "110" },
                                                 "MaxFloor" => { "value" => "158000", "@tag" => "111" } },
                                             "trailer" => {
                                                 "CheckSum" => { "value" => "248", "@tag" => "10" }
                                             }
                                         })
    end
  end
end

