<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<?modxslt-stylesheet type="text/xsl" media="fuffa, screen and $GET[stylesheet]" href="./$GET[stylesheet]" alternate="no" title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
<?modxslt-stylesheet type="text/xsl" media="screen" alternate="no" title="Show raw source of the XML file" charset="ISO-8859-1" ?>
<!-- This stylesheet implements some validation tests on IDSDef.xml -->
<xsl:stylesheet xmlns:yaslt="http://www.mod-xslt2.com/ns/2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" extension-element-prefixes="yaslt" xmlns:fn="http://www.w3.org/2005/02/xpath-functions" xmlns:local="http://www.example.com/functions/local" exclude-result-prefixes="local xs">
<xsl:output method="text" encoding="UTF-8"/>
<xsl:template match="/*">
<!-- Tests for the utilities section -->
<xsl:choose>
<xsl:when test="not(./utilities//field[@timebasepath=''])">
The utilities section is valid
</xsl:when>
<xsl:otherwise>
The utilities section has errors:<xsl:apply-templates select="./utilities//field[@timebasepath='']">
<xsl:with-param name="error_description" select="'Problem in the timebasepath computation or in the specification of the time coordinate : this field has an empty timebasepath attribute'"/>
</xsl:apply-templates>
</xsl:otherwise>
</xsl:choose>

<!-- Tests are done for each IDS -->
<xsl:for-each select="IDS">
<!-- First execute all tests. If any fail, their output will be stored in $test_output -->
<xsl:variable name="test_output">
<!-- Test the presence of the "type" metadata (R5.2) -->
<xsl:apply-templates select=".//field[not(@type) and not(@data_type='structure') and not(@data_type='struct_array')]">
<xsl:with-param name="error_description" select="'This field must have a type attribute (constant/static/dynamic)'"/>
</xsl:apply-templates>
<!-- Test the presence of the "coordinate1" metadata for 1D+ data (R5.4) -->
<xsl:apply-templates select=".//field[not(@coordinate1) and (matches(@data_type, '^FLT_[1-6]D$') or matches(@data_type, '^INT_[1-4]D$') or matches(@data_type, '^CPX_[1-6]D$') or @data_type='STR_1D' or @data_type='struct_array' )]">
<xsl:with-param name="error_description" select="'This field must have a coordinate1 attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of the "coordinate2" metadata for 2D+ data (R5.4) -->
<xsl:apply-templates select=".//field[not(@coordinate2) and (matches(@data_type, '^FLT_[2-6]D$') or matches(@data_type, '^INT_[2-4]D$') or matches(@data_type, '^CPX_[2-6]D$'))]">
<xsl:with-param name="error_description" select="'This field must have a coordinate2 attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of the "coordinate3" metadata for 3D+ data (R5.4) -->
<xsl:apply-templates select=".//field[not(@coordinate3) and (matches(@data_type, '^FLT_[3-6]D$') or matches(@data_type, '^INT_[3-4]D$') or matches(@data_type, '^CPX_[3-6]D$'))]">
<xsl:with-param name="error_description" select="'This field must have a coordinate3 attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of the "coordinate4" metadata for 4D+ data (R5.4) -->
<xsl:apply-templates select=".//field[not(@coordinate4) and (matches(@data_type, '^FLT_[4-6]D$') or @data_type='INT_4D' or matches(@data_type, '^CPX_[4-6]D$'))]">
<xsl:with-param name="error_description" select="'This field must have a coordinate4 attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of the "coordinate5" metadata for 5D+ data (R5.4) -->
<xsl:apply-templates select=".//field[not(@coordinate5) and (matches(@data_type, '^FLT_[5-6]D$') or matches(@data_type, '^CPX_[5-6]D$'))]">
<xsl:with-param name="error_description" select="'This field must have a coordinate5 attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of the "coordinate6" metadata for 6D+ data (R5.4) -->
<xsl:apply-templates select=".//field[not(@coordinate6) and (@data_type='FLT_6D' or @data_type='CPX_6D' )]">
<xsl:with-param name="error_description" select="'This field must have a coordinate6 attribute'"/>
</xsl:apply-templates>
<!-- Test the absence of coordinate metadata of dimensions higher than the dimension of the data type -->
<xsl:apply-templates select=".//field[@coordinate1 and not(matches(@data_type, '[1-6][dD]|structure|struct_array'))]">
<xsl:with-param name="error_description" select="'This field must not have a coordinate1 attribute'"/>
</xsl:apply-templates>
<xsl:apply-templates select=".//field[@coordinate2 and not(matches(@data_type, '[2-6][dD]|structure'))]">
<xsl:with-param name="error_description" select="'This field must not have a coordinate2 attribute'"/>
</xsl:apply-templates>
<xsl:apply-templates select=".//field[@coordinate3 and not(matches(@data_type, '[3-6][dD]|structure'))]">
<xsl:with-param name="error_description" select="'This field must not have a coordinate3 attribute'"/>
</xsl:apply-templates>
<xsl:apply-templates select=".//field[@coordinate4 and not(matches(@data_type, '[4-6][dD]|structure'))]">
<xsl:with-param name="error_description" select="'This field must not have a coordinate4 attribute'"/>
</xsl:apply-templates>
<xsl:apply-templates select=".//field[@coordinate5 and not(matches(@data_type, '[5-6][dD]|structure'))]">
<xsl:with-param name="error_description" select="'This field must not have a coordinate5 attribute'"/>
</xsl:apply-templates>
<xsl:apply-templates select=".//field[@coordinate6 and not(matches(@data_type, '6[dD]|structure'))]">
<xsl:with-param name="error_description" select="'This field must not have a coordinate6 attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of the "units" metadata for FLT and CPX data (R5.3) -->
<xsl:apply-templates select=".//field[not(@units) and (@data_type='FLT_0D' or @data_type='FLT_1D' or @data_type='FLT_2D' or @data_type='FLT_3D' or @data_type='FLT_4D' or @data_type='FLT_5D' or @data_type='FLT_6D' or @data_type='CPX_0D' or @data_type='CPX_1D' or @data_type='CPX_2D' or @data_type='CPX_3D' or @data_type='CPX_4D' or @data_type='CPX_5D' or @data_type='CPX_6D')]">
<xsl:with-param name="error_description" select="'This field must have a units attribute'"/>
</xsl:apply-templates>
<!-- Test that units are in the correct format: can be either one of:
        - dimensionless ("1")
        - mixed ("mixed")
        - normalized composite units with optional powers: m, m^2, m^-3, kg.m.s^-2, etc.
    We make exceptions for:
        - grid_ggd/space/objects_per_dimension/object/measure: m^dimension
        - amns_data IDS: "units given by ..."
        - Some units are not normalized: (m.s^-1)^-3.m^-3 / (m.s^-1)^-3.m^-3.s^-1
-->
<xsl:apply-templates select="
    .//field[
        @units and not(matches(@units, '^(1|mixed|[a-zA-Z]+(\^-?[1-9][0-9]*)?([.][a-zA-Z]+(\^-?[1-9][0-9]*)?)*)$'))
        and not(@name='measure' and @units='m^dimension')
        and not(ancestor::IDS[@name='amns_data'] and matches(@units, '^units given by'))
        and not(@units='(m.s^-1)^-3.m^-3') and not(@units='(m.s^-1)^-3.m^-3.s^-1')
    ]">
<xsl:with-param name="error_description" select="'This field has an incorrect units definition: '"/>
<xsl:with-param name="attr" select="'units'"/>
</xsl:apply-templates>
<!-- Test that INT and STR data have no "units" metadata (R5.3), although some exceptions are possible for specific cases (UTC, Elementary charge or atomic mass units) -->
<xsl:apply-templates select=".//field[@units and not(@units='UTC' or @units='u' or @units='e') and (contains(@data_type,'STR_') or contains(@data_type,'INT_') or contains(@data_type,'str_') or contains(@data_type,'int_'))]">
<xsl:with-param name="error_description" select="'This field should NOT have a units attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of nested AoS 3 (illegal) -->
<xsl:apply-templates select=".//field[@maxoccur='unbounded' and @type='dynamic' and ancestor::field[@maxoccur='unbounded' and @type='dynamic']]">
<xsl:with-param name="error_description" select="'Illegal construct: this field is an AoS type 3 nested under another AoS type 3'"/>
</xsl:apply-templates>
<!-- Test the presence of AoS 2 that is not nested below an AoS 3 (not implemented yet in the AL) -->
<xsl:apply-templates select=".//field[@maxoccur='unbounded' and not(@type='dynamic') and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]">
<xsl:with-param name="error_description" select="'Illegal construct: this field is an AoS type 2 and should be nested under an AoS type 3 (AoS 2 without nesting benow an AoS 3 are not implemented in the AL yet). If this construct is needed, set the field as an AoS type 1 by setting a finite maxOccurs attribute'"/>
</xsl:apply-templates>
<!-- Test the presence of "dynamic" scalars that are not nested below an AoS 3 (scalars cannot be dynamic unless under an AoS3) -->
<xsl:apply-templates select=".//field[(@data_type='FLT_0D' or @data_type='INT_0D' or @data_type='CPX_0D' or @data_type='STR_0D') and @type='dynamic' and not(ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]">
<xsl:with-param name="error_description" select="'Illegal metadata: this scalar field is marked as &quot;dynamic&quot;. Scalars cannot be dynamic unless placed under an AoS type 3'"/>
</xsl:apply-templates>
<!-- Test the presence of structures marked with a type attribute (no meaning and breaks the Java API) -->
<xsl:apply-templates select=".//field[@data_type='structure' and @type]">
<xsl:with-param name="error_description" select="'Illegal metadata: this structure field should NOT have a &quot;type&quot; attribute (constant/static/dynamic)'"/>
</xsl:apply-templates>
<!-- Test the presence of non-dynamic leaves under an AoS 3 (all leaves of an AoS3 must be dynamic) -->
<xsl:apply-templates select=".//field[(not(@data_type='structure') and not(@data_type='struct_array')) and not(@type='dynamic') and (ancestor::field[@maxoccur='unbounded' and @type='dynamic'])]">
<xsl:with-param name="error_description" select="'Illegal metadata: all leaves below an AoS3 must be dynamic'"/>
</xsl:apply-templates>
<!-- Test that all timebasepath attributes are non-empty -->
<xsl:apply-templates select=".//field[@timebasepath='']">
<xsl:with-param name="error_description" select="'Problem in the timebasepath computation or in the specification of the time coordinate : this field has an empty timebasepath attribute'"/>
</xsl:apply-templates>
<!-- Check usage of reserved names -->
<xsl:variable name="reserved_names" select="replace(unparsed-text('./reserved_names.txt'), '[\n\r]', '|')" />
<xsl:apply-templates select=".//field[contains($reserved_names, concat('|', @name, '|'))]">
<xsl:with-param name="error_description" select="'Illegal name: name is found in the list of reserved names (see `reserved_names.txt`)'"/>
</xsl:apply-templates>
<!-- Test that all identifier docs adhere to the pattern "*/*_identifier.xml" -->
<xsl:apply-templates select=".//field[@doc_identifier and not(matches(@doc_identifier, '^[^/]+/[^/]+_identifier\.xml$'))]">
<xsl:with-param name="error_description" select="'Illegal metadata: identifier documentation should be stored in a file ending in `_identifier.xml`.'"/>
</xsl:apply-templates>
<!-- Coordinate checks -->
<xsl:apply-templates select="." mode="coordinate_validation"/>
<!-- End of validation rules -->
</xsl:variable>
<xsl:choose>
    <xsl:when test="not(string($test_output))">
        <xsl:value-of select="concat('IDS ', @name, ' is valid.&#xA;')"/>
    </xsl:when>
    <xsl:otherwise>
        <xsl:value-of select="concat('IDS ', @name, ' has errors:&#xA;')"/>
        <xsl:value-of select="$test_output"/>
    </xsl:otherwise>
</xsl:choose>
</xsl:for-each>

<!-- Tests for identifier XMLs: -->
<xsl:for-each select="distinct-values(//IDS//field[@doc_identifier]/@doc_identifier)">
<xsl:variable name="identifier_xml" select="doc(concat('schemas/', .))" />
<xsl:variable name="identifier_values" select="$identifier_xml//int/text()" as="xs:int*"/>
<!-- Identifier index values should be unique: -->
<xsl:if test="count(distinct-values($identifier_values)) != count($identifier_values)">
    Error in identifier <xsl:value-of select="." />: values of identifiers are not unique.
</xsl:if>
<!-- Names and aliases should be unique. First find out all names and aliases: -->
<xsl:variable name="identifier_name_and_aliases" as="xs:string*">
<xsl:for-each select="$identifier_xml//int">
<xsl:sequence select="@name" />
<xsl:for-each select="tokenize(@alias, ',')"><xsl:sequence select="."/></xsl:for-each>
</xsl:for-each>
</xsl:variable>
<!-- Uniqueness test: -->
<xsl:if test="count(distinct-values($identifier_name_and_aliases)) != count($identifier_name_and_aliases)">
    Error in identifier <xsl:value-of select="." />: name and/or alias is not unique.
</xsl:if>
</xsl:for-each>
</xsl:template>

<!-- A generic template for printing the out_come of an error detection (adds a line to the output text report with the description of the error) -->
<xsl:template name ="print_error" match="field">
<xsl:param name ="error_description"/><xsl:param name="attr"/>    Error in <xsl:value-of select="@path_doc"/>: <xsl:value-of select="$error_description"/><xsl:value-of select="if ($attr = '') then '' else @*[name() = $attr]"/><xsl:text>&#10;</xsl:text>
</xsl:template>

<!-- ====================== Coordinate validation checks ======================================= -->
<xsl:template match="IDS" mode="coordinate_validation">
<xsl:for-each select=".//field">
    <!-- Skip checks for 0D types and structs -->
    <xsl:if test="not(matches(@data_type, '^((INT|STR|FLT|CPX)_0D|structure|int_type|flt_type|str_type)$'))">
        <!-- Magic to loop over all (max 6) defined coordinate attributes -->
        <xsl:for-each select="attribute::*[matches(name(), '^coordinate[1-6]$')]">
            <xsl:variable name="coordinate" select="string(.)"/>
            <xsl:variable name="name_same_as" select="concat(name(), '_same_as')"/>
            <xsl:variable name="coordinate_same_as" select="string(../attribute::*[name() = $name_same_as])"/>
            <!-- Validate coordinate_same_as -->
            <xsl:if test="not(not($coordinate_same_as))">
                <!-- <xsl:if test="$coordinate != '1...N'">
                    <xsl:apply-templates select="..">
                    <xsl:with-param name="error_description" select="concat($name_same_as, ' is provided, but ', name(), ' is not 1...N')"/>
                    </xsl:apply-templates>
                </xsl:if> -->
                <xsl:apply-templates select=".." mode="validate_coordinate">
                    <xsl:with-param name="path" select="$coordinate_same_as"/>
                    <xsl:with-param name="attr" select="$name_same_as"/>
                </xsl:apply-templates>
            </xsl:if>
            <!-- Validate coordinate -->
            <xsl:apply-templates select=".." mode="validate_coordinate">
                <xsl:with-param name="path" select="$coordinate"/>
                <xsl:with-param name="attr" select="name()"/>
            </xsl:apply-templates>
        </xsl:for-each>
        <xsl:if test="@alternative_coordinate1">
            <xsl:variable name="field" select="."/>
            <!-- alternative coordinates are separated by a ';' -->
            <xsl:if test="matches(@alternative_coordinate1, '^;|;;|;$|^$')">
                <xsl:apply-templates select=".">
                <xsl:with-param name="error_description" select="concat('Invalid alternative_coordinate1: `', @alternative_coordinate1, '` has an empty alternative coordinate.')"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:analyze-string select="@alternative_coordinate1" regex=";">
                <xsl:non-matching-substring>
                    <!-- validate the alternative coordinate -->
                    <xsl:apply-templates select="$field" mode="validate_path">
                        <xsl:with-param name="path" select="."/>
                        <xsl:with-param name="fullpath" select="."/>
                        <xsl:with-param name="attr" select="'alternative_coordinate1'"/>
                        <xsl:with-param name="ids_or_current_field" select="$field/ancestor::IDS"/>
                    </xsl:apply-templates>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:if>
</xsl:for-each>
</xsl:template>
<!-- Validate the value of a coordinate field -->
<xsl:template match="field" mode="validate_coordinate">
    <xsl:param name="path"/>
    <xsl:param name="fullpath" select="$path"/>
    <xsl:param name="attr"/>
    <xsl:choose>
        <!-- Allow multiple paths/fixed sizes separated by ' OR ' -->
        <xsl:when test="contains($path, ' OR ')">
            <!-- Recurse into self after splitting each part of the path -->
            <xsl:variable name="field" select="."/>
            <xsl:for-each select="tokenize($path, ' OR ')">
                <xsl:apply-templates select="$field" mode="validate_coordinate">
                    <xsl:with-param name="path" select="."/>
                    <xsl:with-param name="fullpath" select="$fullpath"/>
                    <xsl:with-param name="attr" select="$attr"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:when>
        <!-- Fixed size checks: '1...N' and '1...i' with i = 1, 2, ... -->
        <xsl:when test="starts-with($path, '1...')">
            <xsl:variable name="num" select="substring-after($path, '1...')"/>
            <xsl:if test="$num != 'N' and not(matches($num, '^[1-9][0-9]*$'))">
                <xsl:apply-templates select=".">
                <xsl:with-param name="error_description" select="concat('Invalid ', $attr, ': `', $fullpath, '`')"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:when>
        <!-- Cross IDS links: 'IDS:{IDS name}/{path in IDS} -->
        <xsl:when test="starts-with($path, 'IDS:')">
            <!-- Verify the IDS name is valid, then continue checking the path in the other IDS -->
            <xsl:variable name="ids_name" select="substring-before(substring-after($path, 'IDS:'), '/')"/>
            <xsl:variable name="ids" select="//IDS[@name=$ids_name]"/>
            <xsl:choose>
                <xsl:when test="count($ids) = 0">
                    <xsl:apply-templates select=".">
                    <xsl:with-param name="error_description"
                        select="concat('Invalid ', $attr, ': `', $fullpath, '`. Unknown IDS `', $ids_name, '`')"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Parse and validate path -->
                    <xsl:apply-templates select="." mode="validate_path">
                        <xsl:with-param name="path" select="substring-after($path, '/')"/>
                        <xsl:with-param name="fullpath" select="$fullpath"/>
                        <xsl:with-param name="attr" select="$attr"/>
                        <xsl:with-param name="ids_or_current_field" select="$ids"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <!-- References to other elements in the same IDS -->
        <xsl:otherwise>
            <xsl:apply-templates select="." mode="validate_path">
                <xsl:with-param name="path" select="$path"/>
                <xsl:with-param name="fullpath" select="$fullpath"/>
                <xsl:with-param name="attr" select="$attr"/>
                <xsl:with-param name="ids_or_current_field" select="ancestor::IDS"/>
            </xsl:apply-templates>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<!--
    Validate a coordinate path reference: path must exist and have the correct type

    This template is called recursively for descending into the IDS tree. For example with path:
        coherent_wave(i1)/profiles_2d(itime)/time
    
    The first call provides the top-level IDS with path: coherent_wave(i1)/profiles_2d(itime)/time
        This finds the field "coherent_wave" and verifies the index (i1) is valid
    The second call provides the coherent_wave field as ids_or_current_field with path: profiles_2d(itime)/time
        This finds the field "profiles_2d" and verifies the index (itime) is valid
    The third call provides the profiles_2d field as ids_or_current_field with path: time
        This finds the field "time" (there is no index to validate)
        The path is then fully resolved and we check that the "time" field has the correct type
-->
<xsl:template match="field" mode="validate_path">
    <!-- Path to check, e.g. 'coherent_wave(i1)/profiles_2d(itime)/time' -->
    <xsl:param name="path"/>
    <!-- Full coordinate path (incl. e.g. ' OR '), only used for generating the error messages -->
    <xsl:param name="fullpath"/>
    <!-- Attribute name that is checked, e.g. coordinate1, coordinate4_same_as -->
    <xsl:param name="attr"/>
    <!-- IDS or parent field of the next part of the path -->
    <xsl:param name="ids_or_current_field"/>
    <!-- Is this path used as an index in another path -->
    <xsl:param name="is_index" select="false()"/>
    
    <!-- 
        Do some computation. E.g. for path = coherent_wave(i1)/profiles_2d(itime)/time this sets:
            next_path := profiles_2d(itime)/time
            current_chunk := coherent_wave(i1)
            current_field := coherent_wave
            index_with_parentheses := (i1)
    -->
    <xsl:variable name="next_path"
        select="replace($path, '^[0-9a-z_]+(\(([^()]*|\([^()]*\))*\))?/?', '')"/>
    <xsl:variable name="current_chunk" select="replace(substring($path, 1, string-length($path) - string-length($next_path)), '/$', '')"/>
    <xsl:variable name="current_field" select="substring-before(concat($current_chunk, '('), '(')"/>
    <xsl:variable name="index_with_parentheses" select="substring-after($current_chunk, $current_field)"/>

    <!-- Check that the referred element exists-->
    <xsl:variable name="current_field_node" select="$ids_or_current_field/field[@name=$current_field]"/>
    <xsl:choose>
        <xsl:when test="count($current_field_node) != 1">
            <xsl:apply-templates select=".">
            <xsl:with-param name="error_description" select="concat('Invalid ', $attr, ': `', $fullpath, '`. Unknown element `', $current_field, '`')"/>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
            <!-- Validate index -->
            <xsl:choose>
                <!-- Validate (i1), (i2), ... -->
                <xsl:when test="matches($index_with_parentheses, '^\(i[1-9]\)$')">
                    <!-- This can only be resolved when the struct_array is a parent node of the referent. -->
                    <xsl:if test="not(starts-with(@path, $current_field_node/@path))">
                        <xsl:apply-templates select=".">
                        <xsl:with-param name="error_description" select="concat('Invalid ', $attr, ': `', $fullpath, '`. Array of structures `', $current_field, '` is not an ancestor node.')"/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:when>
                <!-- No validation for (itime), see IMAS-4675 -->
                <xsl:when test="matches($index_with_parentheses, '^\(itime\)$')"/>
                <!-- Explicit index >= 1 is also fine, e.g. in coordinate_system(process(i1)/coordinate_index)/coordinate(1) -->
                <xsl:when test="matches($index_with_parentheses, '^\([1-9][0-9]*\)$')"/>
                <!-- The index refers to another node, e.g. coordinate_system(process(i1)/coordinate_index). Validate that path: -->
                <xsl:when test="$index_with_parentheses">
                    <xsl:apply-templates select="." mode="validate_path">
                        <xsl:with-param name="path" select="substring($index_with_parentheses, 2, string-length($index_with_parentheses)-2)"/>
                        <xsl:with-param name="fullpath" select="$fullpath"/>
                        <xsl:with-param name="attr" select="$attr"/>
                        <xsl:with-param name="ids_or_current_field" select="ancestor::IDS"/>
                        <xsl:with-param name="is_index" select="true()"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- No index provided otherwise, which is a problem when the current element is an AoS and the coordinate refers to an item in the AoS: -->
                <xsl:when test="$current_field_node/@data_type = 'struct_array' and $next_path">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="error_description" select="concat('Invalid ', $attr, ': `', $fullpath, '`. No index provided for array of structures `', $current_field, '`.')"/>
                    </xsl:apply-templates>
                </xsl:when>
            </xsl:choose>

            <xsl:choose>
                <!-- Recurse into self when the path is not yet fully resolved: -->
                <xsl:when test="$next_path">
                    <xsl:apply-templates select="." mode="validate_path">
                        <xsl:with-param name="path" select="$next_path"/>
                        <xsl:with-param name="fullpath" select="$fullpath"/>
                        <xsl:with-param name="attr" select="$attr"/>
                        <xsl:with-param name="ids_or_current_field" select="$current_field_node"/>
                        <xsl:with-param name="is_index" select="$is_index"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- We are fully resolved, check that this node has the correct data type -->
                <xsl:when test="$is_index">
                    <!-- Index nodes must be a int_0D or (legacy) int_type -->
                    <xsl:if test="not(matches($current_field_node/@data_type, '(INT_0D|int_type)'))">
                        <xsl:apply-templates select=".">
                        <xsl:with-param name="error_description" select="concat('Invalid ', $attr, ': `', $fullpath, '`. Referred index element `', $current_field_node/@path, '` has incorrect data type `', $current_field_node/@data_type, '`')"/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <!--
                        - same_as coordinates must have the correct number of dimensions (>= the dimension we are)
                        - struct_array coordinate must be 0D when the coordinate is inside self, otherwise 1D
                        - otherwise the coordinate must be a 1D data type or struct_array without index
                    -->
                    <xsl:variable name="coor_dim" select="substring($attr, 11, 1)"/>
                    <xsl:if test="
                    not(
                        contains($attr, 'same_as') and (
                            $coor_dim='1' and $current_field_node/@data_type = 'struct_array'
                            or matches($current_field_node/@data_type, concat('_[', $coor_dim, '-6]D'))
                        )
                        or @data_type = 'struct_array' and (
                            starts-with($current_field_node/@path, @path) and matches($current_field_node/@data_type, '(_0D|int_type|flt_type|str_type)')
                            or not(starts-with($current_field_node/@path, @path)) and matches($current_field_node/@data_type, '(_1D|_1d_type|struct_array)')
                        )
                        or @data_type != 'struct_array' and (
                            matches($current_field_node/@data_type, '(_1D|_1d_type)')
                            or ($current_field_node/@data_type = 'struct_array' and not($index_with_parentheses))
                        )
                    )">
                        <xsl:apply-templates select=".">
                        <xsl:with-param name="error_description" select="concat('Invalid ', $attr, ': `', $fullpath, '`. Referred element has incorrect data type `', $current_field_node/@data_type, '`')"/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
