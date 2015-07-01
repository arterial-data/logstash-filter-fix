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
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.3" }, { "name" => "BodyLength", "tag" => "9", "content" => "243" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "20150429-00001" }, { "enum" => "NewOrderSingle", "name" => "MsgType", "tag" => "35", "content" => "D" }, { "name" => "SenderCompID", "tag" => "49", "content" => "UKBANK3" }, { "name" => "SendingTime", "tag" => "52", "content" => "20150429-06:51:36" }, { "name" => "TargetCompID", "tag" => "56", "content" => "HELIXsysTrading" }] }], "body" => [{ "field" => [{ "name" => "Account", "tag" => "1", "content" => "B39999999" }, { "name" => "ClOrdID", "tag" => "11", "content" => "bceacad4-f2dc-4e79-bafb-ca1b74b8110a" }, { "name" => "Currency", "tag" => "15", "content" => "USD" }, { "enum" => "AUTOMATED_EXECUTION_ORDER_PUBLIC", "name" => "HandlInst", "tag" => "21", "content" => "2" }, { "enum" => "CUSIP", "name" => "SecurityIDSource", "tag" => "22", "content" => "1" }, { "name" => "OrderQty", "tag" => "38", "content" => "79000" }, { "enum" => "MARKET", "name" => "OrdType", "tag" => "40", "content" => "1" }, { "name" => "Price", "tag" => "44", "content" => "34.80" }, { "name" => "SecurityID", "tag" => "48", "content" => "00026349" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "BA.L" }, { "enum" => "DAY", "name" => "TimeInForce", "tag" => "59", "content" => "0" }, { "name" => "TransactTime", "tag" => "60", "content" => "20150429-06:51:36" }, { "enum" => "REGULAR", "name" => "SettlmntTyp", "tag" => "63", "content" => "0" }, { "name" => "MinQty", "tag" => "110", "content" => "15000" }, { "name" => "MaxFloor", "tag" => "111", "content" => "158000" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "248" }] }] })
    end

    # sample data from http://fixparser.targetcompid.com
    sample("message" => "8=FIX.4.19=6135=A34=149=EXEC52=20121105-23:24:0656=BANZAI98=0108=3010=003") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "61" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "1" }, { "enum" => "Logon", "name" => "MsgType", "tag" => "35", "content" => "A" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:06" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "enum" => "NONE_OTHER", "name" => "EncryptMethod", "tag" => "98", "content" => "0" }, { "name" => "HeartBtInt", "tag" => "108", "content" => "30" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "003" }] }] })
    end
    sample("message" => "8=FIX.4.19=6135=A34=149=BANZAI52=20121105-23:24:0656=EXEC98=0108=3010=003") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [
                                              { "field" => [
                                                  { "name" => "BeginString",
                                                    "tag" => "8",
                                                    "content" => "FIX.4.1" },
                                                  { "name" => "BodyLength", "tag" => "9", "content" => "61" },
                                                  { "name" => "MsgSeqNum", "tag" => "34", "content" => "1" },
                                                  { "enum" => "Logon", "name" => "MsgType", "tag" => "35", "content" => "A" },
                                                  { "name" => "SenderCompID", "tag" => "49", "content" => "BANZAI" },
                                                  { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:06" },
                                                  { "name" => "TargetCompID", "tag" => "56", "content" => "EXEC" }
                                              ] }
                                          ],
                                            "body" => [
                                                { "field" => [
                                                    { "enum" => "NONE_OTHER", "name" => "EncryptMethod", "tag" => "98", "content" => "0" },
                                                    { "name" => "HeartBtInt", "tag" => "108", "content" => "30" }
                                                ] }
                                            ],
                                            "trailer" => [
                                                { "field" => [
                                                    { "name" => "CheckSum", "tag" => "10", "content" => "003" }
                                                ] }
                                            ] })
    end
    sample("message" => "8=FIX.4.19=4935=034=249=BANZAI52=20121105-23:24:3756=EXEC10=228") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "49" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "2" }, { "enum" => "Heartbeat", "name" => "MsgType", "tag" => "35", "content" => "0" }, { "name" => "SenderCompID", "tag" => "49", "content" => "BANZAI" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:37" }, { "name" => "TargetCompID", "tag" => "56", "content" => "EXEC" }] }], "body" => [{}], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "228" }] }] })
    end
    sample("message" => "8=FIX.4.19=4935=034=249=EXEC52=20121105-23:24:3756=BANZAI10=228") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "49" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "2" }, { "enum" => "Heartbeat", "name" => "MsgType", "tag" => "35", "content" => "0" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:37" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{}], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "228" }] }] })
    end
    sample("message" => "8=FIX.4.19=10335=D34=349=BANZAI52=20121105-23:24:4256=EXEC11=135215788257721=138=1000040=154=155=MSFT59=010=062") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "103" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "3" }, { "enum" => "NewOrderSingle", "name" => "MsgType", "tag" => "35", "content" => "D" }, { "name" => "SenderCompID", "tag" => "49", "content" => "BANZAI" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:42" }, { "name" => "TargetCompID", "tag" => "56", "content" => "EXEC" }] }], "body" => [{ "field" => [{ "name" => "ClOrdID", "tag" => "11", "content" => "1352157882577" }, { "enum" => "AUTOMATED_EXECUTION_ORDER_PRIVATE_NO_BROKER_INTERVENTION", "name" => "HandlInst", "tag" => "21", "content" => "1" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "MARKET", "name" => "OrdType", "tag" => "40", "content" => "1" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "MSFT" }, { "enum" => "DAY", "name" => "TimeInForce", "tag" => "59", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "062" }] }] })
    end
    sample("message" => "8=FIX.4.19=13935=834=349=EXEC52=20121105-23:24:4256=BANZAI6=011=135215788257714=017=120=031=032=037=138=1000039=054=155=MSFT150=2151=010=059") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "139" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "3" }, { "enum" => "ExecutionReport", "name" => "MsgType", "tag" => "35", "content" => "8" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:42" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "name" => "AvgPx", "tag" => "6", "content" => "0" }, { "name" => "ClOrdID", "tag" => "11", "content" => "1352157882577" }, { "name" => "CumQty", "tag" => "14", "content" => "0" }, { "name" => "ExecID", "tag" => "17", "content" => "1" }, { "enum" => "NEW", "name" => "ExecTransType", "tag" => "20", "content" => "0" }, { "name" => "LastPx", "tag" => "31", "content" => "0" }, { "name" => "LastShares", "tag" => "32", "content" => "0" }, { "name" => "OrderID", "tag" => "37", "content" => "1" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "NEW", "name" => "OrdStatus", "tag" => "39", "content" => "0" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "MSFT" }, { "enum" => "FILL", "name" => "ExecType", "tag" => "150", "content" => "2" }, { "name" => "LeavesQty", "tag" => "151", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "059" }] }] })
    end
    sample("message" => "8=FIX.4.19=15335=834=449=EXEC52=20121105-23:24:4256=BANZAI6=12.311=135215788257714=1000017=220=031=12.332=1000037=238=1000039=254=155=MSFT150=2151=010=230") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "153" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "4" }, { "enum" => "ExecutionReport", "name" => "MsgType", "tag" => "35", "content" => "8" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:42" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "name" => "AvgPx", "tag" => "6", "content" => "12.3" }, { "name" => "ClOrdID", "tag" => "11", "content" => "1352157882577" }, { "name" => "CumQty", "tag" => "14", "content" => "10000" }, { "name" => "ExecID", "tag" => "17", "content" => "2" }, { "enum" => "NEW", "name" => "ExecTransType", "tag" => "20", "content" => "0" }, { "name" => "LastPx", "tag" => "31", "content" => "12.3" }, { "name" => "LastShares", "tag" => "32", "content" => "10000" }, { "name" => "OrderID", "tag" => "37", "content" => "2" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "FILLED", "name" => "OrdStatus", "tag" => "39", "content" => "2" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "MSFT" }, { "enum" => "FILL", "name" => "ExecType", "tag" => "150", "content" => "2" }, { "name" => "LeavesQty", "tag" => "151", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "230" }] }] })
    end
    sample("message" => "8=FIX.4.19=10335=D34=449=BANZAI52=20121105-23:24:5556=EXEC11=135215789503221=138=1000040=154=155=ORCL59=010=047") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "103" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "4" }, { "enum" => "NewOrderSingle", "name" => "MsgType", "tag" => "35", "content" => "D" }, { "name" => "SenderCompID", "tag" => "49", "content" => "BANZAI" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:55" }, { "name" => "TargetCompID", "tag" => "56", "content" => "EXEC" }] }], "body" => [{ "field" => [{ "name" => "ClOrdID", "tag" => "11", "content" => "1352157895032" }, { "enum" => "AUTOMATED_EXECUTION_ORDER_PRIVATE_NO_BROKER_INTERVENTION", "name" => "HandlInst", "tag" => "21", "content" => "1" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "MARKET", "name" => "OrdType", "tag" => "40", "content" => "1" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "ORCL" }, { "enum" => "DAY", "name" => "TimeInForce", "tag" => "59", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "047" }] }] })
    end
    sample("message" => "8=FIX.4.19=13935=834=549=EXEC52=20121105-23:24:5556=BANZAI6=011=135215789503214=017=320=031=032=037=338=1000039=054=155=ORCL150=2151=010=049") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "139" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "5" }, { "enum" => "ExecutionReport", "name" => "MsgType", "tag" => "35", "content" => "8" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:55" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "name" => "AvgPx", "tag" => "6", "content" => "0" }, { "name" => "ClOrdID", "tag" => "11", "content" => "1352157895032" }, { "name" => "CumQty", "tag" => "14", "content" => "0" }, { "name" => "ExecID", "tag" => "17", "content" => "3" }, { "enum" => "NEW", "name" => "ExecTransType", "tag" => "20", "content" => "0" }, { "name" => "LastPx", "tag" => "31", "content" => "0" }, { "name" => "LastShares", "tag" => "32", "content" => "0" }, { "name" => "OrderID", "tag" => "37", "content" => "3" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "NEW", "name" => "OrdStatus", "tag" => "39", "content" => "0" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "ORCL" }, { "enum" => "FILL", "name" => "ExecType", "tag" => "150", "content" => "2" }, { "name" => "LeavesQty", "tag" => "151", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "049" }] }] })
    end
    sample("message" => "8=FIX.4.19=15335=834=649=EXEC52=20121105-23:24:5556=BANZAI6=12.311=135215789503214=1000017=420=031=12.332=1000037=438=1000039=254=155=ORCL150=2151=010=220") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "153" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "6" }, { "enum" => "ExecutionReport", "name" => "MsgType", "tag" => "35", "content" => "8" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:24:55" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "name" => "AvgPx", "tag" => "6", "content" => "12.3" }, { "name" => "ClOrdID", "tag" => "11", "content" => "1352157895032" }, { "name" => "CumQty", "tag" => "14", "content" => "10000" }, { "name" => "ExecID", "tag" => "17", "content" => "4" }, { "enum" => "NEW", "name" => "ExecTransType", "tag" => "20", "content" => "0" }, { "name" => "LastPx", "tag" => "31", "content" => "12.3" }, { "name" => "LastShares", "tag" => "32", "content" => "10000" }, { "name" => "OrderID", "tag" => "37", "content" => "4" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "FILLED", "name" => "OrdStatus", "tag" => "39", "content" => "2" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "ORCL" }, { "enum" => "FILL", "name" => "ExecType", "tag" => "150", "content" => "2" }, { "name" => "LeavesQty", "tag" => "151", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "220" }] }] })
    end
    sample("message" => "8=FIX.4.19=10835=D34=549=BANZAI52=20121105-23:25:1256=EXEC11=135215791235721=138=1000040=244=1054=155=SPY59=010=003") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "108" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "5" }, { "enum" => "NewOrderSingle", "name" => "MsgType", "tag" => "35", "content" => "D" }, { "name" => "SenderCompID", "tag" => "49", "content" => "BANZAI" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:25:12" }, { "name" => "TargetCompID", "tag" => "56", "content" => "EXEC" }] }], "body" => [{ "field" => [{ "name" => "ClOrdID", "tag" => "11", "content" => "1352157912357" }, { "enum" => "AUTOMATED_EXECUTION_ORDER_PRIVATE_NO_BROKER_INTERVENTION", "name" => "HandlInst", "tag" => "21", "content" => "1" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "LIMIT", "name" => "OrdType", "tag" => "40", "content" => "2" }, { "name" => "Price", "tag" => "44", "content" => "10" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "SPY" }, { "enum" => "DAY", "name" => "TimeInForce", "tag" => "59", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "003" }] }] })
    end
    sample("message" => "8=FIX.4.19=13835=834=749=EXEC52=20121105-23:25:1256=BANZAI6=011=135215791235714=017=520=031=032=037=538=1000039=054=155=SPY150=2151=010=252") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "138" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "7" }, { "enum" => "ExecutionReport", "name" => "MsgType", "tag" => "35", "content" => "8" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:25:12" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "name" => "AvgPx", "tag" => "6", "content" => "0" }, { "name" => "ClOrdID", "tag" => "11", "content" => "1352157912357" }, { "name" => "CumQty", "tag" => "14", "content" => "0" }, { "name" => "ExecID", "tag" => "17", "content" => "5" }, { "enum" => "NEW", "name" => "ExecTransType", "tag" => "20", "content" => "0" }, { "name" => "LastPx", "tag" => "31", "content" => "0" }, { "name" => "LastShares", "tag" => "32", "content" => "0" }, { "name" => "OrderID", "tag" => "37", "content" => "5" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "enum" => "NEW", "name" => "OrdStatus", "tag" => "39", "content" => "0" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "SPY" }, { "enum" => "FILL", "name" => "ExecType", "tag" => "150", "content" => "2" }, { "name" => "LeavesQty", "tag" => "151", "content" => "0" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "252" }] }] })
    end
    sample("message" => "8=FIX.4.19=10435=F34=649=BANZAI52=20121105-23:25:1656=EXEC11=135215791643738=1000041=135215791235754=155=SPY10=198") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "104" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "6" }, { "enum" => "OrderCancelRequest", "name" => "MsgType", "tag" => "35", "content" => "F" }, { "name" => "SenderCompID", "tag" => "49", "content" => "BANZAI" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:25:16" }, { "name" => "TargetCompID", "tag" => "56", "content" => "EXEC" }] }], "body" => [{ "field" => [{ "name" => "ClOrdID", "tag" => "11", "content" => "1352157916437" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "name" => "OrigClOrdID", "tag" => "41", "content" => "1352157912357" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "SPY" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "198" }] }] })
    end
    sample("message" => "8=FIX.4.19=8235=334=849=EXEC52=20121105-23:25:1656=BANZAI45=658=Unsupported message type10=000") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "82" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "8" }, { "enum" => "Reject", "name" => "MsgType", "tag" => "35", "content" => "3" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:25:16" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "name" => "RefSeqNum", "tag" => "45", "content" => "6" }, { "name" => "Text", "tag" => "58", "content" => "Unsupported message type" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "000" }] }] })
    end
    sample("message" => "8=FIX.4.19=10435=F34=749=BANZAI52=20121105-23:25:2556=EXEC11=135215792530938=1000041=135215791235754=155=SPY10=197") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "104" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "7" }, { "enum" => "OrderCancelRequest", "name" => "MsgType", "tag" => "35", "content" => "F" }, { "name" => "SenderCompID", "tag" => "49", "content" => "BANZAI" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:25:25" }, { "name" => "TargetCompID", "tag" => "56", "content" => "EXEC" }] }], "body" => [{ "field" => [{ "name" => "ClOrdID", "tag" => "11", "content" => "1352157925309" }, { "name" => "OrderQty", "tag" => "38", "content" => "10000" }, { "name" => "OrigClOrdID", "tag" => "41", "content" => "1352157912357" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "SPY" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "197" }] }] })
    end
    sample("message" => "8=FIX.4.19=8235=334=949=EXEC52=20121105-23:25:2556=BANZAI45=758=Unsupported message type10=002") do
      expect(subject).to include("message")
      expect(subject).to include("fixMessage")
      expect(subject['fixMessage']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.1" }, { "name" => "BodyLength", "tag" => "9", "content" => "82" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "9" }, { "enum" => "Reject", "name" => "MsgType", "tag" => "35", "content" => "3" }, { "name" => "SenderCompID", "tag" => "49", "content" => "EXEC" }, { "name" => "SendingTime", "tag" => "52", "content" => "20121105-23:25:25" }, { "name" => "TargetCompID", "tag" => "56", "content" => "BANZAI" }] }], "body" => [{ "field" => [{ "name" => "RefSeqNum", "tag" => "45", "content" => "7" }, { "name" => "Text", "tag" => "58", "content" => "Unsupported message type" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "002" }] }] })
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
      expect(subject['parsedFix']).to eq({ "header" => [{ "field" => [{ "name" => "BeginString", "tag" => "8", "content" => "FIX.4.3" }, { "name" => "BodyLength", "tag" => "9", "content" => "243" }, { "name" => "MsgSeqNum", "tag" => "34", "content" => "20150429-00001" }, { "enum" => "NewOrderSingle", "name" => "MsgType", "tag" => "35", "content" => "D" }, { "name" => "SenderCompID", "tag" => "49", "content" => "UKBANK3" }, { "name" => "SendingTime", "tag" => "52", "content" => "20150429-06:51:36" }, { "name" => "TargetCompID", "tag" => "56", "content" => "HELIXsysTrading" }] }], "body" => [{ "field" => [{ "name" => "Account", "tag" => "1", "content" => "B39999999" }, { "name" => "ClOrdID", "tag" => "11", "content" => "bceacad4-f2dc-4e79-bafb-ca1b74b8110a" }, { "name" => "Currency", "tag" => "15", "content" => "USD" }, { "enum" => "AUTOMATED_EXECUTION_ORDER_PUBLIC", "name" => "HandlInst", "tag" => "21", "content" => "2" }, { "enum" => "CUSIP", "name" => "SecurityIDSource", "tag" => "22", "content" => "1" }, { "name" => "OrderQty", "tag" => "38", "content" => "79000" }, { "enum" => "MARKET", "name" => "OrdType", "tag" => "40", "content" => "1" }, { "name" => "Price", "tag" => "44", "content" => "34.80" }, { "name" => "SecurityID", "tag" => "48", "content" => "00026349" }, { "enum" => "BUY", "name" => "Side", "tag" => "54", "content" => "1" }, { "name" => "Symbol", "tag" => "55", "content" => "BA.L" }, { "enum" => "DAY", "name" => "TimeInForce", "tag" => "59", "content" => "0" }, { "name" => "TransactTime", "tag" => "60", "content" => "20150429-06:51:36" }, { "enum" => "REGULAR", "name" => "SettlmntTyp", "tag" => "63", "content" => "0" }, { "name" => "MinQty", "tag" => "110", "content" => "15000" }, { "name" => "MaxFloor", "tag" => "111", "content" => "158000" }] }], "trailer" => [{ "field" => [{ "name" => "CheckSum", "tag" => "10", "content" => "248" }] }] })
    end
  end
end