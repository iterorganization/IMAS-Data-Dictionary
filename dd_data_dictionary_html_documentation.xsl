<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
<xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/*">
<xsl:result-document href="html_documentation/html_documentation.html">
    <html>
      <head>
       <title>Data Dictionary HTML documentation</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
      </head>
      <body>
              <p class="welcome">ITER Physics Data Model Documentation : Top level (list of all IDSs)</p>
              <p>This version <b><xsl:value-of select="./version"/></b> of the ITER Physics Data Model corresponds to COCOS = <xsl:value-of select="./cocos"/> coordinate convention. The COCOS conventions are defined in [O. Sauter and S.Yu. Medvedev, Computer Physics Communications 184 (2013) 293]</p>
              <p>For conversion between cylindrical (R,phi,Z) and Cartesian (X,Y,Z) coordinates, IMAS follows the <a href="https://en.wikipedia.org/wiki/ISO_31-11">ISO 31-11 standard</a>, namely the origin and Z axis align and the X axis corresponds to phi = 0</p>
			  <p>Mathematical operators :
			  <ul>
						<li><a href="https://wiki.fusion.ciemat.es/wiki/Flux_coordinates#Flux_Surface_Average">Flux surface average</a></li>
			  </ul>
			  </p>
       		  <p><a href="dd_versions.html">Data Dictionary version history</a></p>
<!-- First make a list of IDS with the Links-->
<table border="1">
        <thead style="color:#ff0000"><td>IDS name</td><td>Description</td><td>Max. occurrence number (limited in MDS+ backend only)</td></thead>
        
<xsl:for-each select="IDS">
<tr>
	<td><a href="{@name}.html"><xsl:value-of select="@name"/></a></td>
	<td><xsl:value-of select="@documentation"/></td>
	<td><xsl:value-of select="@maxoccur"/></td>
</tr>
</xsl:for-each>
        </table>
<!-- Second: write the list of reusable structures from Utilities -->
 <p class="welcome">List of available Generic Structures</p>
 <p>Generic structures are data structures that can be found in various places of the Physics Data Model, as they are useful in several contexts. Typical examples are lists of standard spatial coordinates, description of plasma ion species, traceability / provenance information, etc.</p>
<p>This list of available generic structures is not restrictive since it can be freely expanded by Data Model designers. Note that the structure name is not the name of a Data Model node, therefore the generic structure names do not appear in the Data Dictionary HTML documentation. They are primarily used for the design of the Data Dictionary, but also they can be used in Fortran codes where they are implemented as derived types.
</p>
<table border="1">
        <thead style="color:#ff0000"><td>Generic structure name</td><td>Description</td></thead>
<xsl:for-each select="document('schemas/utilities/dd_support.xsd')/*/xs:complexType">
<tr>
	<td><xsl:value-of select="@name"/></td>
	<td><xsl:value-of select="xs:annotation/xs:documentation"/></td>
</tr>
</xsl:for-each>
<xsl:for-each select="document('schemas/utilities/dd_support.xsd')/*/xs:element">
<tr>
	<td><xsl:value-of select="@name"/></td>
	<td><xsl:value-of select="./xs:annotation/xs:documentation"/></td>
</tr>
</xsl:for-each>
</table>
</body>
</html>
</xsl:result-document>

<!--Third: write the detailed documentation of each IDS-->
<xsl:for-each select="IDS">
<xsl:result-document href="html_documentation/{@name}.html">
<html>
      <head>
       <title>Data Dictionary HTML documentation</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
       	<link href="css/jquery.treetable.css" rel="stylesheet" type="text/css"/>
		<link href="css/maketree.css" rel="stylesheet"/>
      </head>
      <body>
        <p class="welcome">ITER Physics Data Model Documentation for <xsl:value-of select="@name"/></p>
        <p><xsl:value-of select="@documentation"/><xsl:if test="@url"> Click here for <a href="{@url}">further documentation</a>.</xsl:if></p> <!-- Write the IDS description -->
        <p>Notation of array of structure indices: itime indicates a time index; i1, i2, i3, ... indicate other indices with their depth in the IDS. This notation clarifies the path of a given node, but should not be used to compare indices of different nodes (they may have different meanings).</p>
        <p>Lifecycle status: <xsl:value-of select="@lifecycle_status"/> since version <xsl:value-of select="@lifecycle_version"/></p> <!-- Write the IDS Lifecycle information -->
        <p>Last change occured on version: <xsl:value-of select="@lifecycle_last_change"/></p> <!-- Write the IDS Lifecycle information -->
        <p><a href="html_documentation.html">Back to top IDS list</a></p>
   		<button onclick="window.location.href='{@name}_flat.html'">Flat display</button>
		<button onclick="ToggleErrorDisplay('body>table')">Show/Hide errorbar nodes</button>  By convention, only the upper error node should be filled in case of symmetrical error bars. The upper and lower errors are absolute and defined positive, and represent one standard deviation of the data. The effective values of the data (within one standard deviation) will be within the interval [data-data_error_lower, data+data_error_upper]. Thus whatever the sign of data, data_error_lower relates to the lower bound and data_error_upper to the upper bound of the error bar interval.
        <br/>   
        <br/>          
        <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description</td><td>Data Type</td><td>Coordinates</td></thead>
        <xsl:apply-templates select="field"/>
        </table>
        <p><a href="html_documentation.html">Back to top IDS list</a></p>
        <script src="js/jquery-1.12.4.min.js"></script>                
        <script src="js/jquery.treetable.js"></script>        
        <script src="js/treeView2.js"></script>
        <script>  makeTree('body>table');  </script>
</body>
</html>
</xsl:result-document>
<xsl:result-document href="html_documentation/{@name}_flat.html">
<html>
      <head>
       <title>Data Dictionary HTML documentation</title>
        <style type="text/css">
			p {color:black;font-size:12pt;font-weight:normal;}
			p.name {color:red;font-size:18pt;font-weight:bold;}
			p.welcome {color:#3333aa; font-size:20pt; font-weight:bold; text-align:center;}
			span.head {color:#3333aa; font-size:12pt; font-weight:bold; }
       </style>
       	<link href="css/jquery.treetable.css" rel="stylesheet" type="text/css"/>
		<link href="css/maketree.css" rel="stylesheet"/>
      </head>
      <body>
        <p class="welcome">ITER Physics Data Model Documentation for <xsl:value-of select="@name"/></p>
        <p><xsl:value-of select="@documentation"/><xsl:if test="@url"> Click here for <a href="{@url}">further documentation</a>.</xsl:if></p> <!-- Write the IDS description -->
        <p>Notation of array of structure indices: itime indicates a time index; i1, i2, i3, ... indicate other indices with their depth in the IDS. This notation clarifies the path of a given node, but should not be used to compare indices of different nodes (they may have different meanings).</p>
        <p>Lifecycle status: <xsl:value-of select="@lifecycle_status"/> since version <xsl:value-of select="@lifecycle_version"/></p> <!-- Write the IDS Lifecycle information -->
        <p>Last change occured on version: <xsl:value-of select="@lifecycle_last_change"/></p> <!-- Write the IDS Lifecycle information -->
        <p><a href="html_documentation.html">Back to top IDS list</a></p>
   		<button onclick="window.location.href='{@name}.html'">Expandable display</button> You are now in flat display mode, note that errorbars are not visible in this mode
        <br/>   
        <br/>          
        <table border="1">
        <thead style="color:#ff0000"><td>Full path name</td><td>Description</td><td>Data Type</td><td>Coordinates</td></thead>
        <xsl:apply-templates select="field"/>
        </table>
        <p><a href="html_documentation.html">Back to top IDS list</a></p>
</body>
</html>
</xsl:result-document>
</xsl:for-each>

  </xsl:template>
  
  <xsl:template match="int">
  <!-- Construction of a table for the identifier documentation (doc_identifier)-->
  <tr><td><xsl:value-of select="@name"/></td><td><xsl:value-of select="."/></td><td><xsl:value-of select="@description"/></td></tr>
  </xsl:template>

 <xsl:template match="field">
<tr>
<xsl:if test="ends-with(@name,'error_upper') or ends-with(@name,'error_lower') or ends-with(@name,'error_index')">
<xsl:attribute name='class'>errorbar</xsl:attribute>
<xsl:attribute name='style'>display:none;</xsl:attribute>  <!-- Hide errorbars in the documentation by default-->
</xsl:if> 
<td><span class="pathname"><xsl:value-of select="@path_doc"/></span>

<xsl:if test="@maxOccurs>1 or @maxOccurs='unbounded'">{1:<xsl:value-of select="@maxOccurs"/>}</xsl:if>
<xsl:if test="@lifecycle_status"><br/>Lifecycle status: <font color="red"><xsl:value-of select="@lifecycle_status"/></font> since version <xsl:value-of select="@lifecycle_version"/></xsl:if></td>

           <td><xsl:value-of select="@documentation"/>
           <xsl:if test="@url"> Click here for <a href="{@url}">further documentation</a>.</xsl:if>
           <xsl:if test="@url_protected"> Click here for <a href="{@url_protected}">further documentation</a> (or contact imas@iter.org if you can't access this page).</xsl:if>
           <xsl:if test="@type"> {<xsl:value-of select="@type"/>}</xsl:if>
           <xsl:if test="@Type"> {<xsl:value-of select="@Type"/>}</xsl:if>
           <xsl:if test="@units"> [<xsl:value-of select="@units"/>]</xsl:if>
                    <xsl:if test="@Units"> [<xsl:value-of select="@Units"/>]</xsl:if>
           <xsl:if test="@introduced_after_version">. Introduced after DD version <xsl:value-of select="@introduced_after_version"/></xsl:if> 
           <xsl:if test="@doc_identifier">. Available options (refer to the children of this identifier structure) :
                <table border="1">
                      <thead><td>Name</td><td>Index</td><td>Description</td></thead>
                      <xsl:apply-templates select="document(concat('schemas/',@doc_identifier))/*/int"/>
                      <tr>
        </tr>
        </table>
           </xsl:if>
           <!--<xsl:if test="@cocos_label_transformation">. This quantity is COCOS-dependent, with the following transformation :
                <table border="1">
                      <thead><td>Label</td><td>Expression</td></thead>
                      <tr><td><xsl:value-of select="@cocos_label_transformation"/></td><td><xsl:value-of select="@cocos_transformation_expression"/></td></tr>
        </table>
           </xsl:if>
	   -->
           </td>
           <td>
<xsl:choose>
<xsl:when test="@data_type='flt_type'">FLT_0D</xsl:when>
<xsl:when test="@data_type='flt_1d_type'">FLT_1D</xsl:when>
<xsl:when test="@data_type='int_type'">INT_0D</xsl:when>
<xsl:when test="@data_type='int_1d_type'">INT_1D</xsl:when>
<xsl:when test="@data_type='str_type'">STR_0D</xsl:when>
<xsl:when test="@data_type='str_1d_type'">STR_1D</xsl:when>
<xsl:when test="@data_type='struct_array'">array of structures<xsl:if test="@maxoccur and (@maxoccur!='unbounded')"> [max_size=<xsl:value-of select="@maxoccur"/> (limited in MDS+ backend only)]</xsl:if></xsl:when>
<xsl:otherwise><xsl:value-of select="@data_type"/></xsl:otherwise>
</xsl:choose>        
           </td>
           
  
<td>
<xsl:if test="@coordinate1"> <!--If there is at least one axis-->
<xsl:choose>
<xsl:when test="@alternative_coordinate1"> <!-- the node is itself a primary coordinate and has alternatives -->
1- 1...N, alternative coordinates can be : <xsl:value-of select="replace(@alternative_coordinate1,';','; ')"/><br/>
</xsl:when>
<xsl:when test="ancestor::IDS//field[@alternative_coordinate1 and not(contains(@name,'error_'))]"> <!-- scan all fields with alternative coordinates within the IDS (potential primary coordinates) -->
<xsl:apply-templates mode="print_alternative_coordinate" select="ancestor::IDS//field[@alternative_coordinate1 and not(contains(@name,'error_'))]"><xsl:with-param name="coordinate"><xsl:value-of select="@coordinate1"/></xsl:with-param><xsl:with-param name="calling_field"><xsl:value-of select="substring-before(@path_doc,'(:)')"/></xsl:with-param></xsl:apply-templates>
</xsl:when>
<xsl:otherwise>1- <xsl:value-of select="@coordinate1"/><br/></xsl:otherwise> <!-- Regular treatment -->
</xsl:choose>
<!--1- <xsl:value-of select="@coordinate1"/><xsl:apply-templates mode="print_alternative_coordinate" select="ancestor::IDS//field[@alternative_coordinate1 and not(contains(@name,'error_'))]"><xsl:with-param name="coordinate"><xsl:value-of select="@coordinate1"/></xsl:with-param></xsl:apply-templates>-->
<xsl:if test="@coordinate2">
2- <xsl:value-of select="@coordinate2"/><br/>
<xsl:if test="@coordinate3">
3- <xsl:value-of select="@coordinate3"/><br/>
<xsl:if test="@coordinate4">
4- <xsl:value-of select="@coordinate4"/><br/>
<xsl:if test="@coordinate5">
5- <xsl:value-of select="@coordinate5"/><br/>
<xsl:if test="@coordinate6">
6- <xsl:value-of select="@coordinate6"/><br/>
</xsl:if>
</xsl:if>
</xsl:if>
</xsl:if>
</xsl:if>
</xsl:if>
</td>
  </tr>
  <!-- Recursively process the children -->
  <xsl:apply-templates select="field"/>
 </xsl:template>

<!-- This template verifies whether the scanned field (having alternative_coordinate1 attribute) is the primary coordinate of the current node scanned in the main template. If so, append the list of alternative coordinates to the primary coordinate, separated by an extra semicolumn -->
<xsl:template mode="print_alternative_coordinate" match="field">  
    <xsl:param name="coordinate"/>
    <xsl:param name="calling_field"/>
    <xsl:choose>
		<xsl:when test="substring-before(@path_doc,'(:)')=$coordinate">
		<xsl:choose>
			<xsl:when test="contains(@alternative_coordinate1,$calling_field)"> <!-- We are processing a secondary coordinate -->
1- 1...N, alternative coordinates can be : <xsl:value-of select="$coordinate"/>; <xsl:value-of select="replace(substring-before(@alternative_coordinate1,$calling_field),';','; ')"/><xsl:value-of select="replace(substring-after(@alternative_coordinate1,concat($calling_field,';')),';','; ')"/>
			</xsl:when>
			<xsl:otherwise>
1- any of <xsl:value-of select="$coordinate"/>; <xsl:value-of select="replace(@alternative_coordinate1,';','; ')"/> <!-- We are processing a field that is not related to the primary coordinate for which this template is launched -->
			</xsl:otherwise>
		</xsl:choose>
		</xsl:when>
<xsl:otherwise>1- <xsl:value-of select="$coordinate"/><br/></xsl:otherwise>
</xsl:choose>
</xsl:template>
</xsl:stylesheet>
