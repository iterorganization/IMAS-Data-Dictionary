<?xml version="1.0" encoding="UTF-8"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
	<!-- -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="DD_GIT_DESCRIBE" as="xs:string" required="yes"/>
	<!-- This script transforms the collection of XSD files forming the Data Dictionary into a single XML file describing explicitly all nodes with their characteristics-->
	<!-- The resulting XML file makes further work on the data dictionary much easier, since it describes explicitely the whole schema (includes and references are solved) -->
	<!-- Author:F. Imbeaux, CEA, adapted from xsd2CPODef7 of EU-ITM -->
	<!-- 05/02/2014: Introduced a new attribute path_doc which marks arrays of structure by inserting (:) in the path, used only for documentation purposes (the original path attribute is left unchanged since it is used in the high level UAL generation). NB the method for filling path_doc could be used in the future to remove the limitation of location of the coordinates below struct_arrays -->
	<!-- CAUTION: Coordinate_path must also be written in the XSD with the (:) convention for arrays of structure -->
	<xsl:function name="local:getAbsolutePath" as="xs:string">
		<!-- Given a path resolves any ".." or "." terms 
	  to produce an absolute path -->
		<!-- Kindly taken from Eliot Kimber, http://www.dpawson.co.uk/xsl/sect2/N6052.html#d8250e163, Path between two nodes -->
		<xsl:param name="sourcePath" as="xs:string"/>
		<xsl:variable name="pathTokens" select="tokenize($sourcePath, '/')" as="xs:string*"/>
		<xsl:if test="false()">
			<xsl:message> + 
	  DEBUG local:getAbsolutePath(): Starting</xsl:message>
			<xsl:message> +       
	  sourcePath="<xsl:value-of select="$sourcePath"/>"</xsl:message>
		</xsl:if>
		<xsl:variable name="baseResult" select="string-join(local:makePathAbsolute($pathTokens, ()), 
	  '/')" as="xs:string"/>
		<xsl:variable name="result" as="xs:string" select="if (starts-with($sourcePath, '/') and 
	  not(starts-with($baseResult, '/')))
                  then concat('/', $baseResult)
                  else $baseResult
               "/>
		<xsl:if test="false()">
			<xsl:message> + 
DEBUG: 	  result="<xsl:value-of select="$result"/>"</xsl:message>
		</xsl:if>
		<xsl:value-of select="$result"/>
	</xsl:function>
	<xsl:function name="local:makePathAbsolute" as="xs:string*">
		<xsl:param name="pathTokens" as="xs:string*"/>
		<xsl:param name="resultTokens" as="xs:string*"/>
		<xsl:if test="false()">
			<xsl:message> + 
	  DEBUG: local:makePathAbsolute(): Starting...</xsl:message>
			<xsl:message> + 
	  DEBUG:    pathTokens="<xsl:value-of select="string-join($pathTokens, 
	  ',')"/>"</xsl:message>
			<xsl:message> + 
	  DEBUG:    resultTokens="<xsl:value-of select="string-join($resultTokens, 
	  ',')"/>"</xsl:message>
		</xsl:if>
		<xsl:sequence select="if (count($pathTokens) = 0)
	  then $resultTokens
	  else 
	  if ($pathTokens[1] = '.')
	  then local:makePathAbsolute($pathTokens[position() > 1], 
	  $resultTokens)
	  else 
	  if ($pathTokens[1] = '..')
	  then local:makePathAbsolute($pathTokens[position() > 1], 
	  $resultTokens[position() &lt; last()])
	  else local:makePathAbsolute($pathTokens[position() > 1], 
	  ($resultTokens, $pathTokens[1]))
	  "/>
	</xsl:function>
	<!-- A first scan is performed on the top-level elements to find out the IDS components and to declare them each time a IDS is found, its elements are scanned via apply'templates in IMPLEMENT mode -->
	<xsl:template match="/*">
		<IDSs>
			<!-- Stores version of DD -->
			<version>
				<xsl:value-of select="$DD_GIT_DESCRIBE"/>
			</version>
			<!-- Stores COCOS choice for this version of DD -->
			<cocos>
				<xsl:value-of select="./xs:element/xs:annotation/xs:appinfo/cocos"/>
			</cocos>
			<utilities>
				<!-- Declare complex types from Utilities -->
				<xsl:for-each select="document('schemas/utilities/dd_support.xsd')/*/xs:complexType">
					<field>
						<xsl:attribute name="name" select="@name"/>
						<xsl:attribute name="data_type" select="'structure'"/>
						<xsl:attribute name="structure_reference" select="'self'"/>
						<xsl:attribute name="documentation" select="xs:annotation/xs:documentation"/>
						<xsl:call-template name="doImplementType">
							<xsl:with-param name="thisType" select="@name"/>
							<xsl:with-param name="currPath" select="''"/>
							<!-- Overloading of this parameter to pass the information that we are processing the utilities section -->
							<xsl:with-param name="currPath_doc" select="''"/>
							<xsl:with-param name="aosLevel" select="1"/>
							<xsl:with-param name="aos3Parent" select="xs:annotation/xs:appinfo/aos3Parent"/>
							<xsl:with-param name="structure_reference" select="'self'"/>
						</xsl:call-template>
					</field>
				</xsl:for-each>
				<!-- Declare Elements from Utilities (only those being the root of a structure, simple elements are not needed in IDSDef.xml)-->
				<xsl:apply-templates select="document('schemas/utilities/dd_support.xsd')/*/xs:element[./xs:complexType]" mode="IMPLEMENT">
					<xsl:with-param name="structure_reference" select="'self'"/>
					<xsl:with-param name="aosLevel" select="1"/>
					<xsl:with-param name="aos3Parent" select="xs:annotation/xs:appinfo/aos3Parent"/>
				</xsl:apply-templates>
			</utilities>
			<!-- Scan for top-level elements (IDSs) -->
			<xsl:apply-templates select="*/*/*/xs:element" mode="DECLARE">
				<xsl:with-param name="currPath" select="''"/>
				<xsl:with-param name="currPath_doc" select="''"/>
				<xsl:with-param name="maxOcc" select="''"/>
				<xsl:with-param name="parentCoordinate1" select="''"/>
				<xsl:with-param name="parentCoordinate2" select="''"/>
				<xsl:with-param name="parentCoordinate3" select="''"/>
				<xsl:with-param name="parentCoordinate4" select="''"/>
				<xsl:with-param name="parentCoordinate5" select="''"/>
				<xsl:with-param name="parentCoordinate6" select="''"/>
			</xsl:apply-templates>
		</IDSs>
	</xsl:template>
	<xsl:template match="xs:element" mode="DECLARE">
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="maxOcc"/>
		<xsl:param name="parentCoordinate1"/>
		<xsl:param name="parentCoordinate2"/>
		<xsl:param name="parentCoordinate3"/>
		<xsl:param name="parentCoordinate4"/>
		<xsl:param name="parentCoordinate5"/>
		<xsl:param name="parentCoordinate6"/>
		<xsl:choose>
			<xsl:when test="@name">
				<xsl:choose>
					<!-- If it is declared as a IDS -->
					<xsl:when test="*/*/xs:element[@ref='ids_properties']">
						<IDS>
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="$maxOcc">
									<!-- Case of ref (most IDSs are in a separate xsd file and are implemented by the doRefdeclare template, maxoccurs is passed through the maxOcc parameter -->
									<xsl:attribute name="maxoccur"><xsl:value-of select="$maxOcc"/></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="maxoccur">1</xsl:attribute>
									<!-- In all other cases, maxoccurs is not defined, meaning 1 by default (W3C schema convention) -->
								</xsl:otherwise>
							</xsl:choose>
							<!-- Replicate DOCUMENTATION as an attribute-->
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<xsl:for-each select="xs:annotation/xs:appinfo/*">
								<!-- Generic method for declaring all appinfo as attributes-->
								<xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
						    </xsl:for-each>
							<!-- Indicate whether the IDS is purely constant or contains dynamic quantities -->							
							<xsl:choose>
								<xsl:when test="*/*/xs:element[@ref='time']">
									<xsl:attribute name="type">dynamic</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="type">constant</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<!-- Scan its components in IMPLEMENT mode -->
							<xsl:apply-templates select="xs:complexType" mode="IMPLEMENT">
								<xsl:with-param name="currPath" select="''"/>
								<xsl:with-param name="currPath_doc" select="''"/>
								<xsl:with-param name="aosLevel" select="1"/>
							</xsl:apply-templates>
							<xsl:choose>
								<xsl:when test="@name and @type">
									<xsl:call-template name="doImplementType">
										<xsl:with-param name="thisType" select="@type"/>
										<xsl:with-param name="currPath" select="''"/>
										<xsl:with-param name="currPath_doc" select="''"/>
										<xsl:with-param name="aosLevel" select="1"/>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>
						</IDS>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<!-- Scan all external references declared -->
			<xsl:when test="@ref">
				<xsl:call-template name="doRefDeclare">
					<xsl:with-param name="thisRef" select="@ref"/>
					<xsl:with-param name="maxOcc" select="@maxOccurs"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Handle include template in IMPLEMENT mode -->
	<xsl:template match="xs:include" mode="IMPLEMENT">
		<xsl:param name="actRef"/>
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:apply-templates select="document(@schemaLocation)/*/xs:element[@name=$actRef]" mode="IMPLEMENT">
			<xsl:with-param name="currPath" select="$currPath"/>
			<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
			<xsl:with-param name="aosLevel" select="$aosLevel"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Handle ComplexType definition in IMPLEMENT mode -->
	<xsl:template match="xs:complexType" mode="IMPLEMENT">
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:param name="aos3Parent"/>
		<xsl:param name="structure_reference"/>
		<xsl:param name="parentCoordinate1"/>
		<xsl:param name="parentCoordinate2"/>
		<xsl:param name="parentCoordinate3"/>
		<xsl:param name="parentCoordinate4"/>
		<xsl:param name="parentCoordinate5"/>
		<xsl:param name="parentCoordinate6"/>
		<xsl:param name="parentUnits"/>
		<!-- Start implementing all child elements of the complexType -->
		<xsl:apply-templates select="*/xs:element" mode="IMPLEMENT">
			<xsl:with-param name="currPath" select="$currPath"/>
			<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
			<xsl:with-param name="aosLevel" select="$aosLevel"/>
			<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
			<xsl:with-param name="structure_reference" select="$structure_reference"/>
			<xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/>
			<xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/>
			<xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/>
			<xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/>
			<xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/>
			<xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/>
			<xsl:with-param name="parentUnits" select="$parentUnits"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- Handle element definition in implement mode. Here all data types are checked -->
	<xsl:template match="xs:element" mode="IMPLEMENT">
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:param name="aos3Parent"/>
		<xsl:param name="parentCoordinate1"/>
		<xsl:param name="parentCoordinate2"/>
		<xsl:param name="parentCoordinate3"/>
		<xsl:param name="parentCoordinate4"/>
		<xsl:param name="parentCoordinate5"/>
		<xsl:param name="parentCoordinate6"/>
		<xsl:param name="parentUnits"/>
		<xsl:param name="structure_reference"/>
		<xsl:choose>
			<!-- If it is an external reference -->
			<xsl:when test="@ref">
				<xsl:call-template name="doRefImplement">
					<xsl:with-param name="thisRef" select="@ref"/>
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@name">
				<xsl:choose>
					<!-- if the node is a leaf defined as a simple type (then it won't have errorbars) -->
					<xsl:when test="ends-with(@type,'_type') and (starts-with(@type,'int') or starts-with(@type,'flt') or starts-with(@type,'str') or starts-with(@type,'cpx'))">
						<field>
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="$currPath=''">
									<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="@name"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="@type"/></xsl:call-template></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="@type"/></xsl:call-template></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<xsl:attribute name="data_type"><xsl:call-template name="ConvertDataType"><xsl:with-param name="data_type" select="@type"/></xsl:call-template></xsl:attribute>
							<xsl:for-each select="xs:annotation/xs:appinfo/*">
								<!-- Generic method for declaring all appinfo as attributes-->
								<xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
								<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
								<xsl:if test="contains(lower-case(name(.)),'coordinate') and (ends-with(.,'time') or ../../../@name='time')">
									<xsl:attribute name="timebasepath"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="''"/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="''"/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
								</xsl:if>
							</xsl:for-each>
						</field>
					</xsl:when>
					<xsl:when test="xs:complexType/xs:group">
						<!-- if the node is a leaf defined with a complexType/Group -->
						<field>
							<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="$currPath=''">
									<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="@name"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
									<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
							<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:group/@ref"/></xsl:attribute>
							<xsl:for-each select="xs:annotation/xs:appinfo/*">
								<!-- Generic method for declaring all appinfo as attributes-->
								<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when>
								<!-- Resolve as_parent(_level_2) units -->
								<xsl:when test="name(.) = 'units' and contains(., 'as_parent') and $parentUnits != ''"><xsl:value-of select="$parentUnits"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
								<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
								<xsl:if test="contains(lower-case(name(.)),'coordinate') and ends-with(.,'time')">
									<xsl:attribute name="timebasepath"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/><xsl:with-param name="utilities_aoscontext" select="../utilities_aoscontext"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
								</xsl:if>
							</xsl:for-each>
						</field>
						<!-- Then we test if the type is real or complex, if so add *_error nodes to the structure for the errorbars -->
						<xsl:if test="(contains(xs:complexType/xs:group/@ref,'FLT') or contains(xs:complexType/xs:group/@ref,'CPX')) and not(contains(@name,'_limit_'))">
							<field>
								<!-- _error_upper field -->
								<xsl:attribute name="name"><xsl:value-of select="concat(@name,'_error_upper')"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="$currPath=''">
										<xsl:attribute name="path"><xsl:value-of select="concat(@name,'_error_upper')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'_error_upper')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'_error_upper')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'_error_upper')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="documentation"><xsl:value-of select="concat('Upper error for &quot;',@name,'&quot;')"/></xsl:attribute>
								<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:group/@ref"/></xsl:attribute>
								<xsl:for-each select="xs:annotation/xs:appinfo/*[not(contains(name(.),'alternative_coordinate'))]">
									<!-- Generic method for declaring all appinfo as attributes, but don't propagate the alternative_coordinate attribute to the errorbar nodes -->
									<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_upper'"/></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_upper'"/></xsl:when>
									<!-- Resolve as_parent(_level_2) units -->
									<xsl:when test="name(.) = 'units' and contains(., 'as_parent') and $parentUnits != ''"><xsl:value-of select="$parentUnits"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
									<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
									<xsl:if test="contains(lower-case(name(.)),'coordinate') and (ends-with(.,'time') or ../../../@name='time')">
										<xsl:attribute name="timebasepath"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/><xsl:with-param name="utilities_aoscontext" select="../utilities_aoscontext"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
									</xsl:if>
									<!-- Add a coordinate_same_as attribute when the physical quantity has coordinate 1...N, to allow checking that the size of the errorbar is consistent with the size of the physical quantity see IMAS-5280 -->
									<xsl:if test="contains(lower-case(name(.)),'coordinate') and contains(.,'...')">
									<xsl:attribute name="{concat(lower-case(name(.)),'_same_as')}"><xsl:choose>
										<xsl:when test="$currPath_doc=''"><xsl:value-of select="../../../@name"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="concat($currPath_doc,'/',../../../@name)"/></xsl:otherwise>
									</xsl:choose></xsl:attribute>
									</xsl:if>
								</xsl:for-each>
							</field>
							<field>
								<!-- _error_lower field -->
								<xsl:attribute name="name"><xsl:value-of select="concat(@name,'_error_lower')"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="$currPath=''">
										<xsl:attribute name="path"><xsl:value-of select="concat(@name,'_error_lower')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat(@name,'_error_lower')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name,'_error_lower')"/></xsl:attribute>
										<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name,'_error_lower')"/><xsl:call-template name="AddToPathDoc"><xsl:with-param name="data_type" select="xs:complexType/xs:group/@ref"/></xsl:call-template></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:attribute name="documentation"><xsl:value-of select="concat('Lower error for &quot;',@name,'&quot;')"/></xsl:attribute>
								<xsl:attribute name="data_type"><xsl:value-of select="xs:complexType/xs:group/@ref"/></xsl:attribute>
								<xsl:for-each select="xs:annotation/xs:appinfo/*[not(contains(name(.),'alternative_coordinate'))]">
									<!-- Generic method for declaring all appinfo as attributes, but don't propagate the alternative_coordinate attribute to the errorbar nodes -->
									<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:when test="contains(name(.),'change_nbc_previous_name')"><xsl:value-of select="."/><xsl:value-of select="'_error_lower'"/></xsl:when>
									<!-- Resolve as_parent(_level_2) units -->
									<xsl:when test="name(.) = 'units' and contains(., 'as_parent') and $parentUnits != ''"><xsl:value-of select="$parentUnits"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
									<!-- Write a timebasepath attribute (coordinate path relative to the nearest AoS parent) in case the appinfo is a coordinate to a timebase -->
									<xsl:if test="contains(lower-case(name(.)),'coordinate') and (ends-with(.,'time') or ../../../@name='time')">
										<xsl:attribute name="timebasepath"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/><xsl:with-param name="utilities_aoscontext" select="../utilities_aoscontext"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildRelativeAosParentPath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="aosLevel" select="$aosLevel - 1"/><xsl:with-param name="structure_reference" select="$structure_reference"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:attribute>
									</xsl:if>
									<!-- Add a coordinate_same_as attribute when the physical quantity has coordinate 1...N, to allow checking that the size of the errorbar is consistent with the size of *_error_upper see IMAS-5280 -->
									<xsl:if test="contains(lower-case(name(.)),'coordinate') and contains(.,'...')">
									<xsl:attribute name="{concat(lower-case(name(.)),'_same_as')}"><xsl:choose>
										<xsl:when test="$currPath_doc=''"><xsl:value-of select="concat(../../../@name,'_error_upper')"/></xsl:when>
										<xsl:otherwise><xsl:value-of select="concat($currPath_doc,'/',../../../@name,'_error_upper')"/></xsl:otherwise>
									</xsl:choose></xsl:attribute>
									</xsl:if>
								</xsl:for-each>
							</field>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-- Otherwise the type is a complex type (structure or struct_array defined by its @type), or a root element defined in dd_support.xsd (e.g. ids_properties)  -->
						<xsl:choose>
							<xsl:when test="@type">
								<!-- It is a complex type (structure or struct_array defined by its @type) -->
								<field>
									<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
									<xsl:attribute name="structure_reference"><xsl:value-of select="@type"/></xsl:attribute>
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
									<xsl:choose>
										<!-- It is an array of structures -->
										<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
											<xsl:attribute name="data_type">struct_array</xsl:attribute>
											<xsl:attribute name="maxoccur"><xsl:value-of select="@maxOccurs"/></xsl:attribute>
											<xsl:if test="contains(xs:annotation/xs:appinfo/coordinate1,'time')">
												<xsl:attribute name="timebasepath">time</xsl:attribute>
											</xsl:if>
											<xsl:choose>
												<xsl:when test="$currPath_doc=''">
													<xsl:attribute name="path_doc"><xsl:value-of select="@name"/><xsl:call-template name="aosIndex"><xsl:with-param name="aosLevel" select="$aosLevel"/></xsl:call-template></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/><xsl:call-template name="aosIndex"><xsl:with-param name="aosLevel" select="$aosLevel"/></xsl:call-template></xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:for-each select="xs:annotation/xs:appinfo/*">
												<!-- Generic method for declaring all appinfo as attributes. There is a long, special treatement for coordinates because the path is indicated, otherwise treatment is just copying the attribute (see the value-of select . at the very end ...) -->
												<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="../type='dynamic'"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'(itime)')"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name,'(itime)')"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat(../../../@name,'($aosLevel)')"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name,'($aosLevel)')"/><xsl:with-param name="coordinatePath" select="."/><xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/><xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/><xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/><xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/><xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/><xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose></xsl:when>
												<!-- Resolve as_parent(_level_2) units -->
												<xsl:when test="name(.) = 'units' and contains(., 'as_parent') and $parentUnits != ''"><xsl:value-of select="$parentUnits"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
											</xsl:for-each>
										</xsl:when>
										<!-- It is a regular structure -->
										<xsl:otherwise>
											<xsl:attribute name="data_type">structure</xsl:attribute>
											<xsl:choose>
												<xsl:when test="$currPath_doc=''">
													<xsl:attribute name="path_doc"><xsl:value-of select="@name"/></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/></xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:for-each select="xs:annotation/xs:appinfo/*">
												<!-- Generic method for declaring all appinfo as attributes. There is a long, special treatement for coordinates because the path is indicated, otherwise treatment is just copying the attribute (see the value-of select . at the very end ...) -->
												<xsl:attribute name="{lower-case(name(.))}"><xsl:choose><xsl:when test="contains(lower-case(name(.)),'coordinate')"><xsl:choose><xsl:when test="$currPath=''"><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="../../../@name"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="BuildAbsolutePath"><xsl:with-param name="coordinate" select="lower-case(name(.))"/><xsl:with-param name="currPath" select="concat($currPath_doc,'/',../../../@name)"/><xsl:with-param name="coordinatePath" select="."/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:when>
												<!-- Resolve as_parent(_level_2) units -->
												<xsl:when test="name(.) = 'units' and contains(., 'as_parent') and $parentUnits != ''"><xsl:value-of select="$parentUnits"/></xsl:when><xsl:otherwise><xsl:value-of select="."/></xsl:otherwise></xsl:choose></xsl:attribute>
											</xsl:for-each>
										</xsl:otherwise>
									</xsl:choose>
									<!-- select the units that (grand) children use when their unit is 'as_parent': -->
									<xsl:variable name="parentUnitsForChild">
										<xsl:choose>
											<xsl:when test="contains(xs:annotation/xs:appinfo/units, 'as_parent') or string(xs:annotation/xs:appinfo/units) = ''">
												<xsl:value-of select="$parentUnits"/> <!-- propagate parent units to grandchildren -->
											</xsl:when>
											<xsl:otherwise> <!-- propagate current node units children -->
												<xsl:value-of select="xs:annotation/xs:appinfo/units"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<!-- Handle type definition via template doImplementType. Need to pass an appropriate path definition -->
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:choose>
												<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
													<xsl:choose>
														<xsl:when test="xs:annotation/xs:appinfo/type='dynamic'">
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="@name"/>
																<xsl:with-param name="currPath_doc" select="concat(@name,'(itime)')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
																<xsl:with-param name="parentCoordinate1" select="xs:annotation/xs:appinfo/coordinate1"/>
																<xsl:with-param name="parentCoordinate2" select="xs:annotation/xs:appinfo/coordinate2"/>
																<xsl:with-param name="parentCoordinate3" select="xs:annotation/xs:appinfo/coordinate3"/>
																<xsl:with-param name="parentCoordinate4" select="xs:annotation/xs:appinfo/coordinate4"/>
																<xsl:with-param name="parentCoordinate5" select="xs:annotation/xs:appinfo/coordinate5"/>
																<xsl:with-param name="parentCoordinate6" select="xs:annotation/xs:appinfo/coordinate6"/>
																<xsl:with-param name="parentUnits" select="$parentUnitsForChild"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="@name"/>
																<xsl:with-param name="currPath_doc" select="concat(@name,'(i',$aosLevel,')')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel+1"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
																<xsl:with-param name="parentCoordinate1" select="xs:annotation/xs:appinfo/coordinate1"/>
																<xsl:with-param name="parentCoordinate2" select="xs:annotation/xs:appinfo/coordinate2"/>
																<xsl:with-param name="parentCoordinate3" select="xs:annotation/xs:appinfo/coordinate3"/>
																<xsl:with-param name="parentCoordinate4" select="xs:annotation/xs:appinfo/coordinate4"/>
																<xsl:with-param name="parentCoordinate5" select="xs:annotation/xs:appinfo/coordinate5"/>
																<xsl:with-param name="parentCoordinate6" select="xs:annotation/xs:appinfo/coordinate6"/>
																<xsl:with-param name="parentUnits" select="$parentUnitsForChild"/>
															</xsl:call-template>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="doImplementType">
														<xsl:with-param name="thisType" select="@type"/>
														<xsl:with-param name="currPath" select="@name"/>
														<xsl:with-param name="currPath_doc" select="@name"/>
														<xsl:with-param name="aosLevel" select="$aosLevel"/>
														<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
														<xsl:with-param name="parentCoordinate1" select="xs:annotation/xs:appinfo/coordinate1"/>
														<xsl:with-param name="parentCoordinate2" select="xs:annotation/xs:appinfo/coordinate2"/>
														<xsl:with-param name="parentCoordinate3" select="xs:annotation/xs:appinfo/coordinate3"/>
														<xsl:with-param name="parentCoordinate4" select="xs:annotation/xs:appinfo/coordinate4"/>
														<xsl:with-param name="parentCoordinate5" select="xs:annotation/xs:appinfo/coordinate5"/>
														<xsl:with-param name="parentCoordinate6" select="xs:annotation/xs:appinfo/coordinate6"/>
														<xsl:with-param name="parentUnits" select="$parentUnitsForChild"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
													<xsl:choose>
														<xsl:when test="xs:annotation/xs:appinfo/type='dynamic'">
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="concat($currPath,'/',@name)"/>
																<xsl:with-param name="currPath_doc" select="concat($currPath_doc,'/',@name,'(itime)')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
																<xsl:with-param name="parentCoordinate1" select="xs:annotation/xs:appinfo/coordinate1"/>
																<xsl:with-param name="parentCoordinate2" select="xs:annotation/xs:appinfo/coordinate2"/>
																<xsl:with-param name="parentCoordinate3" select="xs:annotation/xs:appinfo/coordinate3"/>
																<xsl:with-param name="parentCoordinate4" select="xs:annotation/xs:appinfo/coordinate4"/>
																<xsl:with-param name="parentCoordinate5" select="xs:annotation/xs:appinfo/coordinate5"/>
																<xsl:with-param name="parentCoordinate6" select="xs:annotation/xs:appinfo/coordinate6"/>
																<xsl:with-param name="parentUnits" select="$parentUnitsForChild"/>
															</xsl:call-template>
														</xsl:when>
														<xsl:otherwise>
															<xsl:call-template name="doImplementType">
																<xsl:with-param name="thisType" select="@type"/>
																<xsl:with-param name="currPath" select="concat($currPath,'/',@name)"/>
																<xsl:with-param name="currPath_doc" select="concat($currPath_doc,'/',@name,'(i',$aosLevel,')')"/>
																<xsl:with-param name="aosLevel" select="$aosLevel+1"/>
																<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
																<xsl:with-param name="parentCoordinate1" select="xs:annotation/xs:appinfo/coordinate1"/>
																<xsl:with-param name="parentCoordinate2" select="xs:annotation/xs:appinfo/coordinate2"/>
																<xsl:with-param name="parentCoordinate3" select="xs:annotation/xs:appinfo/coordinate3"/>
																<xsl:with-param name="parentCoordinate4" select="xs:annotation/xs:appinfo/coordinate4"/>
																<xsl:with-param name="parentCoordinate5" select="xs:annotation/xs:appinfo/coordinate5"/>
																<xsl:with-param name="parentCoordinate6" select="xs:annotation/xs:appinfo/coordinate6"/>
																<xsl:with-param name="parentUnits" select="$parentUnitsForChild"/>
															</xsl:call-template>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="doImplementType">
														<xsl:with-param name="thisType" select="@type"/>
														<xsl:with-param name="currPath" select="concat($currPath,'/',@name)"/>
														<xsl:with-param name="currPath_doc" select="concat($currPath_doc,'/',@name)"/>
														<xsl:with-param name="aosLevel" select="$aosLevel"/>
														<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
														<xsl:with-param name="parentCoordinate1" select="xs:annotation/xs:appinfo/coordinate1"/>
														<xsl:with-param name="parentCoordinate2" select="xs:annotation/xs:appinfo/coordinate2"/>
														<xsl:with-param name="parentCoordinate3" select="xs:annotation/xs:appinfo/coordinate3"/>
														<xsl:with-param name="parentCoordinate4" select="xs:annotation/xs:appinfo/coordinate4"/>
														<xsl:with-param name="parentCoordinate5" select="xs:annotation/xs:appinfo/coordinate5"/>
														<xsl:with-param name="parentCoordinate6" select="xs:annotation/xs:appinfo/coordinate6"/>
														<xsl:with-param name="parentUnits" select="$parentUnitsForChild"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</field>
							</xsl:when>
							<xsl:otherwise>
								<!-- It is a root element defined in dd_support.xsd (e.g. ids_properties) -->
								<field>
									<xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
									<xsl:attribute name="structure_reference"><xsl:value-of select="$structure_reference"/></xsl:attribute>
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:attribute name="path"><xsl:value-of select="@name"/></xsl:attribute>
											<xsl:attribute name="path_doc"><xsl:value-of select="@name"/></xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="path"><xsl:value-of select="concat($currPath,'/',@name)"/></xsl:attribute>
											<xsl:attribute name="path_doc"><xsl:value-of select="concat($currPath_doc,'/',@name)"/></xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="documentation"><xsl:value-of select="xs:annotation/xs:documentation"/></xsl:attribute>
									<xsl:choose>
										<!-- It is an array of structures -->
										<xsl:when test="@maxOccurs='unbounded' or @maxOccurs &gt; 1">
											<xsl:attribute name="data_type">struct_array</xsl:attribute>
											<xsl:attribute name="maxoccur"><xsl:value-of select="@maxOccurs"/></xsl:attribute>
											<xsl:if test="contains(xs:annotation/xs:appinfo/coordinate1,'time')">
												<xsl:attribute name="timebasepath">time</xsl:attribute>
											</xsl:if>
											<xsl:if test="xs:annotation/xs:appinfo/coordinate1">
												<xsl:attribute name="coordinate1"><xsl:value-of select="xs:annotation/xs:appinfo/coordinate1"/></xsl:attribute>
											</xsl:if>
										</xsl:when>
										<!-- It is a regular structure -->
										<xsl:otherwise>
											<xsl:attribute name="data_type">structure</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:choose>
										<xsl:when test="$currPath=''">
											<xsl:apply-templates select="*/*/xs:element" mode="IMPLEMENT">
												<xsl:with-param name="currPath" select="@name"/>
												<xsl:with-param name="currPath_doc" select="@name"/>
												<xsl:with-param name="aosLevel" select="$aosLevel"/>
												<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="*/*/xs:element" mode="IMPLEMENT">
												<xsl:with-param name="currPath" select="concat($currPath, '/',@name)"/>
												<xsl:with-param name="currPath_doc" select="concat($currPath_doc, '/',@name)"/>
												<xsl:with-param name="aosLevel" select="$aosLevel"/>
												<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
											</xsl:apply-templates>
										</xsl:otherwise>
									</xsl:choose>
								</field>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!--Scan references in DECLARE mode-->
	<xsl:template name="doRefDeclare">
		<xsl:param name="thisRef"/>
		<xsl:param name="maxOcc"/>
		<xsl:apply-templates select="/*/xs:include" mode="DECLARE">
			<xsl:with-param name="actRef" select="$thisRef"/>
			<xsl:with-param name="maxOcc" select="$maxOcc"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="document('schemas/utilities/dd_support.xsd')/*/xs:element[@name=$thisRef]" mode="DECLARE"/>
	</xsl:template>
	<xsl:template match="xs:include" mode="DECLARE">
		<xsl:param name="actRef"/>
		<xsl:param name="maxOcc"/>
		<xsl:apply-templates select="document(@schemaLocation)/*/xs:element[@name=$actRef]" mode="DECLARE">
			<xsl:with-param name="currPath" select="''"/>
			<xsl:with-param name="currPath_doc" select="''"/>
			<xsl:with-param name="maxOcc" select="$maxOcc"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template name="doRefImplement">
		<xsl:param name="thisRef"/>
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:choose>
			<xsl:when test="document('schemas/utilities/dd_support.xsd')/*/xs:complexType[@name=$thisRef]">
				when the reference to be included is a complexType defined in utilities : NEVER HAPPENS
				CHECK RESULT HERE IF THIS APPEARS
				<xsl:apply-templates select="document('utilities.xsd')/*/xs:complexType[@name=$thisRef]" mode="IMPLEMENT">
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="parentmachine" select="yes"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="document('schemas/utilities/dd_support.xsd')/*/xs:element[@name=$thisRef]">
				<!-- when the reference to be included is an element defined in utilities -->
				<xsl:apply-templates select="document('schemas/utilities/dd_support.xsd')/*/xs:element[@name=$thisRef]" mode="IMPLEMENT">
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="structure_reference" select="$thisRef"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<!-- when the reference to be included is a whole additional xsd file -->
				<xsl:apply-templates select="/*/xs:include" mode="IMPLEMENT">
					<xsl:with-param name="actRef" select="$thisRef"/>
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="structure_reference" select="$thisRef"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="doImplementType">
		<xsl:param name="thisType"/>
		<xsl:param name="currPath"/>
		<xsl:param name="currPath_doc"/>
		<xsl:param name="aosLevel"/>
		<xsl:param name="aos3Parent"/>
		<xsl:param name="parentCoordinate1"/>
		<xsl:param name="parentCoordinate2"/>
		<xsl:param name="parentCoordinate3"/>
		<xsl:param name="parentCoordinate4"/>
		<xsl:param name="parentCoordinate5"/>
		<xsl:param name="parentCoordinate6"/>
		<xsl:param name="parentUnits"/>
		<xsl:param name="structure_reference"/>
		<xsl:choose>
			<xsl:when test="document('schemas/utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]">
				<!-- if the complexType definition is in Utilities-->
				<xsl:apply-templates select="document('schemas/utilities/dd_support.xsd')/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
					<!--This fills the complexType from its definition in utilities (if it is there and not in the local schema)-->
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
					<xsl:with-param name="structure_reference" select="$structure_reference"/>
					<xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/>
					<xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/>
					<xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/>
					<xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/>
					<xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/>
					<xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/>
					<xsl:with-param name="parentUnits" select="$parentUnits"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="/*/xs:complexType[@name=$thisType]">
				<!-- the definition of the Type is directly in the local schema -->
				<xsl:apply-templates select="/*/xs:complexType[@name=$thisType]" mode="IMPLEMENT">
					<xsl:with-param name="currPath" select="$currPath"/>
					<xsl:with-param name="currPath_doc" select="$currPath_doc"/>
					<xsl:with-param name="aosLevel" select="$aosLevel"/>
					<xsl:with-param name="aos3Parent" select="$aos3Parent"/>
					<xsl:with-param name="parentunit" select="substring-before(substring-after(string(xs:annotation/xs:documentation),'['),']')"/>
					<xsl:with-param name="parentCoordinate1" select="$parentCoordinate1"/>
					<xsl:with-param name="parentCoordinate2" select="$parentCoordinate2"/>
					<xsl:with-param name="parentCoordinate3" select="$parentCoordinate3"/>
					<xsl:with-param name="parentCoordinate4" select="$parentCoordinate4"/>
					<xsl:with-param name="parentCoordinate5" select="$parentCoordinate5"/>
					<xsl:with-param name="parentCoordinate6" select="$parentCoordinate6"/>
					<xsl:with-param name="parentUnits" select="$parentUnits"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Template to write the aosIndex to the path_doc attribute-->
	<xsl:template name="aosIndex">
		<xsl:param name="aosLevel"/>
		<xsl:choose>
			<xsl:when test="xs:annotation/xs:appinfo/type='dynamic'">(itime)</xsl:when>
			<xsl:otherwise>(i<xsl:value-of select="$aosLevel"/>)</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Below is the template dedicated to building absolute Path from the relative path, for the coordinate attributes-->
	<xsl:template name="BuildAbsolutePath">
		<xsl:param name="coordinate"/>
		<xsl:param name="currPath"/>
		<xsl:param name="coordinatePath"/>
		<xsl:param name="parentCoordinate1"/>
		<xsl:param name="parentCoordinate2"/>
		<xsl:param name="parentCoordinate3"/>
		<xsl:param name="parentCoordinate4"/>
		<xsl:param name="parentCoordinate5"/>
		<xsl:param name="parentCoordinate6"/>
		<xsl:analyze-string select="$coordinatePath" regex=" OR ">
			<!-- Identifies the OR statement and cuts the full coordinate string into a sequence of individual coordinates (non-matching the OR statement), then each individual coordinate is processed independently -->
			<xsl:matching-substring>
				<xsl:value-of select="' OR '"/>
				<!-- Output the OR statements as is -->
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<!-- Processes each individual coordinate between OR statements (or the unique coordinate if there is no OR statement) -->
				<xsl:analyze-string select="." regex=";">
					<!-- Identifies the ; separator and cuts the full coordinate string into a sequence of individual coordinates (non-matching the ; separator), then each individual coordinate is processed independently -->
					<xsl:matching-substring>
						<xsl:value-of select="';'"/>
						<!-- Output the ; separator as is -->
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<!-- Processes each individual coordinate between ; separators (or the unique coordinate if there is no ; separator) -->
						<xsl:choose>
							<xsl:when test="matches(.,'as_parent')">
								<!-- The coordinate is as_parent, so write down the coordinate of the parent -->
								<xsl:choose>
									<xsl:when test="contains($coordinate,'1')">
										<xsl:call-template name="BuildAbsolutePath">
											<xsl:with-param name="coordinate" select="$coordinate"/>
											<xsl:with-param name="currPath" select="concat($currPath,'/..')"/>
											<xsl:with-param name="coordinatePath" select="$parentCoordinate1"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="contains($coordinate,'2')">
										<xsl:call-template name="BuildAbsolutePath">
											<xsl:with-param name="coordinate" select="$coordinate"/>
											<xsl:with-param name="currPath" select="concat($currPath,'/..')"/>
											<xsl:with-param name="coordinatePath" select="$parentCoordinate2"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="contains($coordinate,'3')">
										<xsl:call-template name="BuildAbsolutePath">
											<xsl:with-param name="coordinate" select="$coordinate"/>
											<xsl:with-param name="currPath" select="concat($currPath,'/..')"/>
											<xsl:with-param name="coordinatePath" select="$parentCoordinate3"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="contains($coordinate,'4')">
										<xsl:call-template name="BuildAbsolutePath">
											<xsl:with-param name="coordinate" select="$coordinate"/>
											<xsl:with-param name="currPath" select="concat($currPath,'/..')"/>
											<xsl:with-param name="coordinatePath" select="$parentCoordinate4"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="contains($coordinate,'5')">
										<xsl:call-template name="BuildAbsolutePath">
											<xsl:with-param name="coordinate" select="$coordinate"/>
											<xsl:with-param name="currPath" select="concat($currPath,'/..')"/>
											<xsl:with-param name="coordinatePath" select="$parentCoordinate5"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="contains($coordinate,'6')">
										<xsl:call-template name="BuildAbsolutePath">
											<xsl:with-param name="coordinate" select="$coordinate"/>
											<xsl:with-param name="currPath" select="concat($currPath,'/..')"/>
											<xsl:with-param name="coordinatePath" select="$parentCoordinate6"/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="starts-with(.,'/')">
								<!-- Case of a coordinate path expressed relative to the IDS root or nearest AoS parent (special case for the utilities section, e.g. /time). We then just get rid of the initial slash for the absolute coordinate attribute (to avoid users having to learn this initial / convention) -->
								<xsl:value-of select="substring(.,2)"/>
							</xsl:when>
							<xsl:when test="contains(.,'...')">
								<!-- Case of a main coordinate, e.g. 1...N just reproduce it in the tag although remove any '../' at the beginning that could happen in case of a DATA/TIME construct -->
								<xsl:value-of select="replace(.,'../','')"/>
							</xsl:when>
							<xsl:when test="contains(.,'IDS')">
								<!-- Case of a coordinate in another IDS. In this case, absolute path is given, just reproduce it in the tag -->
								<xsl:value-of select="."/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="contains(.,'../')">
										<xsl:value-of select="local:getAbsolutePath(concat($currPath,'/',.))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($currPath,'/',.)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	<!-- Template dedicated to building relative Path from the nearest static AoS parent, to calculate the time coordinate relative path for the new low level. It first calculates the absolute path of the coordinate, exactly as done in the BuildAbsolutePath template, then extracts the substring after the last AoS parent (detected thanks to aosLevel param) -->
	<!-- NB does handle the detection of (itime) in case of a dynamic AoS parent, but this attribute will anyway not be used in this case because there is no need to specify a time coordinate ! -->
	<xsl:template name="BuildRelativeAosParentPath">
		<xsl:param name="coordinate"/>
		<xsl:param name="currPath"/>
		<xsl:param name="coordinatePath"/>
		<xsl:param name="aosLevel"/>
		<xsl:param name="structure_reference"/>
		<xsl:param name="utilities_aoscontext"/>
		<xsl:choose>
			<xsl:when test="starts-with($coordinatePath,'/')">
				<!-- Case of a coordinate path expressed relative to the IDS root (special case needed for the utilities section but also directly understandable in the main IDS section by the Low Level, e.g. /time). We then keep the initial slash and display it as it is, the AL will know how to interpret it -->
				<xsl:value-of select="$coordinatePath"/>
			</xsl:when>
			<xsl:when test="contains($coordinatePath,'...')">
				<!-- Case of a main coordinate, e.g. 1...N just reproduce it in the tag although remove any '../' at the beginning that could happen in case of a DATA/TIME construct -->
				<xsl:value-of select="replace($coordinatePath,'../','')"/>
			</xsl:when>
			<xsl:when test="contains($coordinatePath,'IDS')">
				<!-- Case of a coordinate in another IDS. In this case, absolute path is given, just reproduce it in the tag -->
				<xsl:value-of select="$coordinatePath"/>
			</xsl:when>
			<xsl:when test="contains($currPath,'(i1)')">
				<!-- There is at least one static AoS ancestor, process the path to make it relative to the nearest one -->
				<xsl:choose>
					<xsl:when test="contains($coordinatePath,'../')">
						<xsl:value-of select="substring-after(local:getAbsolutePath(concat($currPath,'/',$coordinatePath)),concat('(i',$aosLevel,')/'))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$coordinatePath">
								<!--if coordinatePath is not empty-->
								<xsl:value-of select="substring-after(concat($currPath,'/',$coordinatePath),concat('(i',$aosLevel,')/'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-after($currPath,concat('(i',$aosLevel,')/'))"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Case with no static AoS ancestor, simply calculate the absolute path as in the BuilAbsolutePath template -->
				<xsl:choose>
					<xsl:when test="contains($structure_reference,'self')">
						<!-- Case of a coordinate path expressed relative to the root of the utilities complexType or element (special case for the utilities section). We then keep the initial anti-slash in the utilities section only and display it as it is, the AL will transform it properly -->
						<xsl:choose>
							<xsl:when test="$coordinatePath and $utilities_aoscontext">
								<!--if coordinatePath and utilities_aoscontext are not empty. Case of a relative path going above the top of the utilities complex Type, in such case we assume that the path is valid wrt the parent aos root and thus we don't add the \, even for utilities (the AL will handle it with the AoS context) -->
								<xsl:value-of select="local:getAbsolutePath($coordinatePath)"/>
							</xsl:when>
							<xsl:when test="$coordinatePath">
								<!--if coordinatePath is not empty-->
								<xsl:value-of select="concat('\',local:getAbsolutePath($coordinatePath))"/>
							</xsl:when>
							<xsl:otherwise>
								<!--Then it is a time array itself arriving with the information in $currPath in utilities (this may be a specific processing but should be the only case -->
								<xsl:value-of select="concat('\',$currPath)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="contains($coordinatePath,'../')">
						<xsl:value-of select="local:getAbsolutePath(concat($currPath,'/',$coordinatePath))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$coordinatePath">
								<!--if coordinatePath is not empty-->
								<xsl:value-of select="concat($currPath,'/',$coordinatePath)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$currPath"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Adding parenthesis at the end of path_doc as a function of the number of dimensions -->
	<xsl:template name="AddToPathDoc">
		<xsl:param name="data_type"/>
		<xsl:choose>
			<xsl:when test="contains($data_type,'1d') or contains($data_type,'1D')">(:)</xsl:when>
			<xsl:when test="contains($data_type,'2d') or contains($data_type,'2D')">(:,:)</xsl:when>
			<xsl:when test="contains($data_type,'3d') or contains($data_type,'3D')">(:,:,:)</xsl:when>
			<xsl:when test="contains($data_type,'4d') or contains($data_type,'4D')">(:,:,:,:)</xsl:when>
			<xsl:when test="contains($data_type,'5d') or contains($data_type,'5D')">(:,:,:,:,:)</xsl:when>
			<xsl:when test="contains($data_type,'6d') or contains($data_type,'6D')">(:,:,:,:,:,:)</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Convert simple types without errorbars to regular data types recognized by the Access Layer -->
	<xsl:template name="ConvertDataType">
		<xsl:param name="data_type"/>
        <xsl:value-of select="upper-case(substring-before($data_type,'_type'))"/>
        <xsl:if test="not(contains($data_type,'d_type'))">_0D</xsl:if>        
	</xsl:template>
</xsl:stylesheet>
