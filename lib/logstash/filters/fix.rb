# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'quickfix'
require 'java'

class LogStash::Filters::Fix < LogStash::Filters::Base

  config_name "fix"
  
  config :source, :validate => :string, :required => true
  config :target, :validate => :string, :required => true


  public
  def register
    require 'xmlsimple'
    require 'nokogiri'
    require 'nori'

    @dd40 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX40.xml'))
    @dd41 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX41.xml'))
    @dd42 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX42.xml'))
    @dd43 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX43.xml'))
    @dd44 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX44.xml'))
    @dd50 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX50.xml'))
    @dd50SP1 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX50SP1.xml'))
    @dd50SP2 = quickfix.DataDictionary.new(quickfix.DataDictionary.java_class.resource_as_stream('/FIX50SP2.xml'))

    @template = Nokogiri::XSLT <<-eos
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="@*|node()">
      <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
      </xsl:copy>
  </xsl:template>

  <xsl:template match="field">

    <xsl:variable name="elementName">
      <xsl:choose>
        <xsl:when test="count(@name)=1">
          <xsl:value-of select="@name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="{$elementName}">
      <xsl:apply-templates select="(@*|*)[name() != 'name']" />
      <xsl:element name="value">
        <xsl:value-of select="text()"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
    eos

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

    if @target
      begin
        version = quickfix.MessageUtils.getStringField(event[@source], 8);
        parsedMsg = quickfix.Message.new(event[@source])

        case version
          when "FIX.4.0"
            dd = @dd40
          when "FIX.4.1"
            dd = @dd41
          when "FIX.4.2"
            dd = @dd42
          when "FIX.4.3"
            dd = @dd43
          when "FIX.4.4"
            dd = @dd44
          when "FIX.5.0"
            dd = @dd50
          when "FIX.5.0SP1"
            dd = @dd50SP1
          when "FIX.5.0SP2"
            dd = @dd50SP2
          else
            dd = nil
        end
        if dd.nil?
          parsedXml = parsedMsg.toXML()
        else
          parsedXml = parsedMsg.toXML(dd)
        end
        doc = @template.transform(doc = Nokogiri::XML(parsedXml, nil, parsedXml.encoding.to_s))

        event[@target] = Nori.new.parse(doc.to_s)["message"]

        matched = true
      rescue => e
        event.tag("_fixparsefailure")
        @logger.warn("Trouble parsing FIX with quickfix", :source => @source,
                     :value => value, :exception => e, :backtrace => e.backtrace)
        return
      end
    end # if @store_xml


    filter_matched(event) if matched
  end # def filter
end # class LogStash::Filters::Example
