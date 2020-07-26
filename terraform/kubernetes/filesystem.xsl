<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/interface[@type='network']/model/@type">
    <xsl:attribute name="type">
      <xsl:value-of select="'e1000'"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="rng">
    <xsl:copy-of select="."/>
      <filesystem type='mount' accessmode='mapped'>
        <source dir='/mnt/data'/>
        <target dir='data'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
      </filesystem>
   </xsl:template>

</xsl:stylesheet>
