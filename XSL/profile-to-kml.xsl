<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns="http://www.opengis.net/kml/2.2"
                xmlns:re="http://xmlns.eiendomsprofil.no/realestate" 
                xmlns:atom="http://www.w3.org/2005/Atom"
                targetNamespace="http://www.opengis.net/kml/2.2" 
                version="1.1">
  <xsl:output indent="no" method="xml" encoding="utf-8" omit-xml-declaration="no"/>
  <xsl:key name="poitype" match="poitype" use="@name"/>
  <xsl:template match="/">
    <kml>
      <Document>
        <xsl:apply-templates select="//pois/poigroup"/>
      </Document>
    </kml>
  </xsl:template>
  <xsl:template match="//pois/poigroup">
    <Folder>
      <name><xsl:value-of select="@name"/></name>
      <xsl:for-each select="poitype[generate-id(.)=generate-id(key('poitype', @name)[1])]">      
        <xsl:variable name="current">
          <xsl:value-of select="@name"/>
        </xsl:variable>
        <xsl:apply-templates select="../poitype[@name=$current]/poi">
          <xsl:with-param name="type"><xsl:value-of select="$current"/></xsl:with-param>
        </xsl:apply-templates>        
      </xsl:for-each>
    </Folder>
  </xsl:template>

  <xsl:template match="poi">
    <xsl:param name="type"/>    
    <Placemark>
      <name><xsl:value-of select="@name"/></name>
      <Point>
        <coordinates><xsl:value-of select="@long"/>,<xsl:value-of select="@lat"/>,0</coordinates>
      </Point>
      <ExtendedData>        
        <re:distance>
          <xsl:attribute name="approx">
            <xsl:value-of select="contains(text(), '*')"/>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </re:distance>
        <re:poitype><xsl:value-of select="$type"/></re:poitype>
      </ExtendedData>      
    </Placemark>    
  </xsl:template>
  
</xsl:stylesheet>