<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                xmlns:local="local:"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc local">

  <!--
      Conversion specs for 010-048
	  adapted for auths eg lccn belongs in Work.
	  these help translate; should be in utils.xsl
  -->

  
  

  <xsl:template mode="work" match="marc:datafield[@tag='024'] |
                                   marc:datafield[@tag='035']">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="@tag='024'">
        <xsl:variable name="vIdentifier">bf:Identifier</xsl:variable>          
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier"><xsl:value-of select="$vIdentifier"/></xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>    
      <xsl:when test="@tag='035'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Local</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@tag='036'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:StudyNumber</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>

    </xsl:choose>
  </xsl:template>
    <xsl:template match="marc:datafield[@tag='040']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='c']">
          <bf:source>
            <bf:Source>
			<bf:agent><bf:Agent>
			<xsl:choose>
		  		<xsl:when test="starts-with(.,'DLC')">
					<xsl:attribute  name="rdf:about"><xsl:value-of select="concat($organizations,translate(.,concat($vUpper,'- ' ),$vLower))"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
            	<rdfs:label><xsl:value-of select="."/></rdfs:label>
				</xsl:otherwise>
			</xsl:choose>                          
			</bf:Agent></bf:agent>
            </bf:Source>
          </bf:source>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='b']">
          <bf:descriptionLanguage>
            <bf:Language>
              <xsl:choose>
                <xsl:when test="string-length(.) = 3">
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($languages,.)"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <bf:code><xsl:value-of select="."/></bf:code>
                </xsl:otherwise>
              </xsl:choose>
            </bf:Language>
          </bf:descriptionLanguage>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='d']">
          <bf:descriptionModifier>
            <bf:Agent>
              <rdfs:label><xsl:value-of select="."/></rdfs:label>
            </bf:Agent>
          </bf:descriptionModifier>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='e']">
          <bf:descriptionConventions>
            <bf:DescriptionConventions>
              <xsl:choose>
                <xsl:when test=
                  "string-length(normalize-space(.))
                  -
                  string-length(translate(normalize-space(.),' ','')) +1
                  = 1">
                <xsl:attribute name="rdf:about"><xsl:value-of select="concat($descriptionConventions,.)"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <rdfs:label><xsl:value-of select="."/></rdfs:label>
                </xsl:otherwise>
              </xsl:choose>
            </bf:DescriptionConventions>
          </bf:descriptionConventions>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='042']" mode="adminmetadata">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:descriptionAuthentication>
            <bf:DescriptionAuthentication>
              <xsl:attribute name="rdf:about"><xsl:value-of select="concat($marcauthen,.)"/></xsl:attribute>
            </bf:DescriptionAuthentication>
          </bf:descriptionAuthentication>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="marc:datafield[@tag='043']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='c']">
          <bf:geographicCoverage>
            <bf:GeographicCoverage>
              <xsl:choose>
                <xsl:when test="@code='a'">
                  <xsl:variable name="vCode">
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString" select="."/>
                      <xsl:with-param name="punctuation"><xsl:text>- </xsl:text></xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:attribute name="rdf:about"><xsl:value-of select="concat($geographicAreas,$vCode)"/></xsl:attribute>
                </xsl:when>                              
              </xsl:choose>
            </bf:GeographicCoverage>
          </bf:geographicCoverage>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- new for auths only Special coded dates -->
  <xsl:template match="marc:datafield[@tag='046']" mode="work">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='k']">
			<xsl:variable name="year-only">
				<xsl:choose> <!-- valid xs:dates; so far just no end date and only 4 digits -->
					<xsl:when test="not(../marc:subfield[@code='l' ]) and string-length(.)= 4 and string-length(translate(.,$vDigits,'')) = 0 ">true	</xsl:when>
				</xsl:choose>
			</xsl:variable>
           <bf:originDate> 
		  	<xsl:if test="$year-only='true'">
		  		<xsl:attribute name="rdf:datatype"><xsl:value-of select="$xs"/>date</xsl:attribute></xsl:if>
	        	  <xsl:value-of select="."/><xsl:if  test="../marc:subfield[@code='l']">/<xsl:value-of select="../marc:subfield[@code='l' ]"/></xsl:if>
			 </bf:originDate>              
         <!--     <xsl:apply-templates select="../marc:subfield[@code='2']" mode="subfield2">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
       -->
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
<!-- 
<xsl:template mode="instance" match="marc:datafield[@tag='020'] |                                                                              
                                       marc:datafield[@tag='022'] |
                                       marc:datafield[@tag='024'] |									   
                                       marc:datafield[@tag='035'] 
                                       ">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="@tag='020'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Isbn</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
 	<xsl:when test="@tag='022'">
        <xsl:apply-templates select="." mode="instanceId">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="pIdentifier">bf:Issn</xsl:with-param>
          <xsl:with-param name="pInvalidLabel">invalid</xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
	  </xsl:choose>
	  </xsl:template>
  -->

  </xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2005. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios/><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext></MapperMetaTag>
</metaInformation>
-->
