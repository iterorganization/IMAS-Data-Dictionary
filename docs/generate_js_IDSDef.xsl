<xsl:stylesheet version="2.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="/">const xmlString=`<xsl:apply-templates/>`;</xsl:template>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="utilities"/>
  <xsl:template match="version"/>
  <xsl:template match="cocos"/>

</xsl:stylesheet>
