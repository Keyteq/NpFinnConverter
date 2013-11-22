<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.opengis.net/kml/2.2"
                xmlns:re="http://xmlns.eiendomsprofil.no/realestate"
                xmlns:xal="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"
                version="1.1">
  <xsl:output indent="no" method="xml" encoding="utf-8" omit-xml-declaration="no"/>
  <xsl:key name="poitype" match="poitype" use="@name"/>
  <xsl:template match="/">
    <kml>
      <Document>
        <xsl:apply-templates select="//site"/>
        <xsl:apply-templates select="//pois/poigroup"/>
      </Document>
    </kml>
  </xsl:template>
  <xsl:template match="//site">
    <xal:AddressDetails>
      <xal:PostalServiceElements>
        <xal:AddressLatitude><xsl:value-of select="lat"/></xal:AddressLatitude>
        <xal:AddressLongditude><xsl:value-of select="long"/></xal:AddressLongditude>
      </xal:PostalServiceElements>
      <xal:Country>
        <xal:CountryName>Norway</xal:CountryName>
        <xsl:if test="count(kommune) > 0">
          <xal:AdministrativeArea Type="Municipality">
            <xsl:for-each select="descriptions/description[@target = 'Kommune']">
              <description><xsl:value-of select="."/></description>
            </xsl:for-each>
            <xal:AdministrativeAreaName><xsl:value-of select="kommune"/></xal:AdministrativeAreaName>
            <xsl:if test="count(kirkesogn) > 0">
              <xal:SubAdministrativeArea Type="Church">
                <xal:SubAdministrativeAreaName><xsl:value-of select="kirkesogn"/></xal:SubAdministrativeAreaName>
              </xal:SubAdministrativeArea>
            </xsl:if>
            <xal:Locality>
              <xsl:if test="count(poststed) > 0">
                <xal:LocalityName><xsl:value-of select="poststed"/></xal:LocalityName>
              </xsl:if>
              <xal:DependentLocality Type="District">
                <xsl:if test="count(bydel) > 0">
                  <xal:DependentLocalityName><xsl:value-of select="bydel"/></xal:DependentLocalityName>
                  <xsl:for-each select="descriptions/description[@target = 'Bydel']">
                    <description><xsl:value-of select="."/></description>
                  </xsl:for-each>
                </xsl:if>
                <xsl:if test="count(grunnkrets) > 0">
                  <xal:DependentLocality Type="LocalArea">
                    <xal:DependentLocalityName><xsl:value-of select="grunnkrets"/></xal:DependentLocalityName>
                    <xsl:for-each select="descriptions/description[@target = 'Grunnkrets' or @target = 'Delområde']">
                      <description><xsl:value-of select="."/></description>
                    </xsl:for-each>
                  </xal:DependentLocality>
                </xsl:if>
              </xal:DependentLocality>
            </xal:Locality>
          </xal:AdministrativeArea>
        </xsl:if>
        <xsl:if test="count(poststed) > 0">
          <xal:PostalCode>
            <xsl:if test="count(adresse) > 0">
              <xal:AddressLine><xsl:value-of select="adresse"/></xal:AddressLine>
            </xsl:if>
            <xal:PostalCodeNumber><xsl:value-of select="postnr"/></xal:PostalCodeNumber>
            <xal:PostTown>
              <xal:PostTownName><xsl:value-of select="poststed"/></xal:PostTownName>
            </xal:PostTown>
          </xal:PostalCode>
        </xsl:if>
      </xal:Country>
    </xal:AddressDetails>
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
        <xsl:if test="count(@childrens) > 0">
          <re:count name="children">@childrens</re:count>
        </xsl:if>
        <xsl:if test="count(@classes) > 0">
          <re:count name="years">@classes</re:count>
        </xsl:if>
      </ExtendedData>
    </Placemark>
  </xsl:template>

</xsl:stylesheet>
