# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'quickfix'
require 'java'


# This example filter will replace the contents of the default 
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Fix < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "fix"
  
  config :source, :validate => :string, :required => true
  config :target, :validate => :string, :required => true


  public
  def register
    require "xmlsimple"
    @dd40 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX40.xml'))
    @dd41 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX41.xml'))
    @dd42 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX42.xml'))
    @dd43 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX43.xml'))
    @dd44 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX44.xml'))
    @dd50 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX50.xml'))
    @dd50SP1 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX50SP1.xml'))
    @dd50SP2 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX50SP2.xml'))
  end # def register

  public
  def filter(event)
    return unless filter?(event)

    matched = false

    return unless event.include?(@source)

    value = event[@source]

    if value.is_a?(Array) && value.length > 1
      @logger.warn("FIX filter only works on fields of length 1",
                   :source => @source, :value => value)
      return
    end

    return if value.strip.length == 0

    begin
      version = quickfix.MessageUtils.getStringField(event[@source], 8);
      parsedMsg = quickfix.Message.new(event[@source])
      case version
        when "FIX.4.0"
          event[@target] = parsedMsg.toXML(@dd40)
        when "FIX.4.1"
          event[@target] = parsedMsg.toXML(@dd41)
        when "FIX.4.2"
          event[@target] = parsedMsg.toXML(@dd42)
        when "FIX.4.3"
          event[@target] = parsedMsg.toXML(@dd43)
        when "FIX.4.4"
          event[@target] = parsedMsg.toXML(@dd44)
        when "FIX.5.0"
          event[@target] = parsedMsg.toXML(@dd50)
        when "FIX.5.0SP1"
          event[@target] = parsedMsg.toXML(@dd50SP1)
        when "FIX.5.0SP2"
          event[@target] = parsedMsg.toXML(@dd50SP2)
        else
          event[@target] = parsedMsg.toXML()
      end

      matched = true
    rescue => e
      event.tag("_fixparsefailure")
      puts "Trouble parsing FIX with quickfix"
      puts e

      #event["error"] = [:err => "Trouble parsing FIX with quickfix", :source => @source,
      #             :value => value, :exception => e, :backtrace => e.backtrace]
      return
    end if @target # if @store_xml


    filter_matched(event) if matched
  end # def filter
end # class LogStash::Filters::Example
