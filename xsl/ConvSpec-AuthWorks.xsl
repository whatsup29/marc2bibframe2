<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc">

  <!--
      Conversion specs for Name/Title authority records
  -->

  <xsl:template mode="authWork" match="marc:datafield[@tag='024'] |
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
    <xsl:template match="marc:datafield[@tag='040']" mode="authAdminmetadata">
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

  <xsl:template match="marc:datafield[@tag='042']" mode="authAdminmetadata">
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
  <xsl:template match="marc:datafield[@tag='043']" mode="authWork">
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
  <xsl:template match="marc:datafield[@tag='046']" mode="authWork">
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

  <xsl:template match="marc:datafield[@tag='050']" mode="authWork">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="authWork050a" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='050' or @tag='880']" mode="authWork050a">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:for-each select="marc:subfield[@code='a']">
          <bf:classification>
            <bf:ClassificationLcc>
              <xsl:if test="../@ind2 = '0'">
                <bf:source>
                  <bf:Source>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="concat($organizations,'dlc')"/></xsl:attribute>
                  </bf:Source>
                </bf:source>
              </xsl:if>
              <bf:classificationPortion>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </bf:classificationPortion>
              <xsl:if test="position() = 1">
                <xsl:for-each select="../marc:subfield[@code='b'][position()=1]">
                  <bf:itemPortion>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </bf:itemPortion>
                </xsl:for-each>
              </xsl:if>
			      <!-- auths only: -->
				  <xsl:for-each select="../marc:subfield[@code='d']">
				  <bflc:appliesTo><bflc:AppliesTo><rdfs:label><xsl:value-of select="."/></rdfs:label></bflc:AppliesTo></bflc:appliesTo>
				  </xsl:for-each>
				  <xsl:for-each select="../marc:subfield[@code='5']"><xsl:apply-templates select="." mode="subfield5auth"/></xsl:for-each>				  
           </bf:ClassificationLcc>
          </bf:classification>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='052']" mode="authWork"> <!-- use bib spec -->
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="work052" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

 

  <xsl:template match="marc:datafield[@tag='060']" mode="authWork">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:classification>
          <bf:ClassificationNlm>
            <xsl:for-each select="marc:subfield[@code='a']">
              <bf:classificationPortion><xsl:value-of select="."/></bf:classificationPortion>
            </xsl:for-each>
            <xsl:for-each select="marc:subfield[@code='b']">
              <bf:itemPortion><xsl:value-of select="."/></bf:itemPortion>
            </xsl:for-each>
            <xsl:if test="@ind2 = '0'">
              <bf:source>
                <bf:Source>
                  <rdfs:label>National Library of Medicine</rdfs:label>
                </bf:Source>
              </bf:source>
            </xsl:if>
			   <!-- auths only: -->
				<xsl:for-each select="../marc:subfield[@code='d']">
				 <bflc:appliesTo><bflc:AppliesTo><rdfs:label><xsl:value-of select="."/></rdfs:label></bflc:AppliesTo></bflc:appliesTo>
				</xsl:for-each>
				<xsl:for-each select="../marc:subfield[@code='5']">
					<xsl:apply-templates select="." mode="subfield5"/>
				</xsl:for-each>
          </bf:ClassificationNlm>
        </bf:classification>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
      Conversion specs for names from 1XX, 6XX, 7XX, and 8XX fields adapted from bib spec, uses bib spec where possible.
  -->
  <!-- <xsl:include href="../xsl/ConvSpec-1XX,6XX,7XX,8XX-names.xsl"/> -->


  <!-- bf:Work properties from name fields -->
  <xsl:template match="marc:datafield[@tag='100' or @tag='110' or @tag='111']" mode="authWork">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
   <xsl:variable name="agentiri">
      <xsl:apply-templates mode="generateUri" select=".">
        <xsl:with-param name="pDefaultUri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of select="@tag"/>-<xsl:value-of select="position()"/></xsl:with-param>
        <xsl:with-param name="pEntity">bf:Agent</xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates mode="authWorkName" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
	  <xsl:if test="marc:subfield[@code='t']">
      <xsl:apply-templates mode="authWorkUnifTitle" select=".">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- override the bib spec, so we can process 4xx differently 
    is  next nate , test 430-->
  
  
  <xsl:template  match="marc:datafield[ @tag='400' or @tag='410' or @tag='411'  or @tag='500' or @tag='510' or @tag='511']" mode="authWork">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of    select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="authWork4XX" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
	 <!-- <xsl:apply-templates mode="work">
            <xsl:with-param name="recordid" select="$recordid"/>
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates> -->
  </xsl:template>
  <xsl:template  match="marc:datafield[ @tag='430' ]" mode="authWork">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="agentiri"><xsl:value-of select="$recordid"/>#Agent<xsl:value-of    select="@tag"/>-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="authWork430" select=".">
      <xsl:with-param name="agentiri" select="$agentiri"/>
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>
 <xsl:template  match="marc:datafield[ @tag='530' ]" mode="authWork">  
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>    
    <xsl:variable name="workiri"><xsl:value-of select="$recordid"/>#Work<xsl:value-of select="@tag"   />-<xsl:value-of select="position()"/></xsl:variable>
    <xsl:apply-templates mode="authWork530" select=".">      
      <xsl:with-param name="workiri" select="$workiri"/>
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>
   <!-- from work8xx for 4xx  -->
   <xsl:template match="marc:datafield" mode="authWork4XX">
     <xsl:param name="pPrimaryNameLabel"/>
    <xsl:param name="agentiri"/>
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="." mode="xmllang"/>
    </xsl:variable>
	
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">

        <!--  if name matches 1xx  name, it's a variant title,
              if not,  its a related work
              If there is no title, it's a contributor to the main work. -->
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='t']">
            <xsl:variable name="vNameLabel">
              <xsl:apply-templates select="." mode="authTNameLabel"/>
            </xsl:variable>
 		  	<xsl:variable name="vTitleLabel">
              <xsl:apply-templates select="." mode="authTTitleLabel"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$pPrimaryNameLabel=$vNameLabel">
                <bf:title>			                      
                  <bf:Title>
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'VariantTitle')"/></xsl:attribute>
                    </rdf:type>
                    <bf:mainTitle>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang">
                          <xsl:value-of select="$vXmlLang"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$vTitleLabel"/>
                    </bf:mainTitle>
                  </bf:Title>
                </bf:title>
              </xsl:when>
              <!--end name=primaryname-->
              <xsl:otherwise>
                <!--names don't match, related work testing removal of the whole otherwise-->				  
			 <xsl:for-each select="marc:subfield[@code='i']"> <!-- from 787 bibs -->			 
              <bflc:relationship>
                <bflc:Relationship>
                  <bflc:relation>
                    <rdfs:Resource>
                      <rdfs:label>
                        <xsl:if test="$vXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="chopPunctuation">
                          <xsl:with-param name="chopString">
                            <xsl:value-of select="."/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </rdfs:label>
                    </rdfs:Resource>
                  </bflc:relation>
                  <bf:relatedTo>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$workiri"/></xsl:attribute>
                  </bf:relatedTo>
                </bflc:Relationship>
              </bflc:relationship>
            </xsl:for-each>
         	<xsl:variable name="vRelation"> <!-- copied from 530 -->
          	  <xsl:choose>
			  <xsl:when test="not(marc:subfield[@code='i'] ) and not(marc:subfield[@code='4']) ">bf:relatedTo</xsl:when>
              	 <xsl:when test="substring(marc:subfield[@code='w'],1,1)='f' ">bf:derivativeOf</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='i' ">bf:relatedTo</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='r' ">bf:relatedTo</xsl:when>
				  <xsl:otherwise>bf:relatedTo</xsl:otherwise>
			  </xsl:choose>
            </xsl:variable>
              <xsl:element name="{$vRelation}">
                   <bf:Work>   <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>				   
                 <xsl:apply-templates mode="authWorkUnifTitle" select=".">
              		<xsl:with-param name="serialization" select="$serialization"/>
            	</xsl:apply-templates>
						  
					 <xsl:apply-templates mode="authWorkName" select=".">
                      <xsl:with-param name="agentiri" select="$agentiri"/>
                      <xsl:with-param name="serialization" select="$serialization"/>
                    </xsl:apply-templates>					
                  </bf:Work> 
                </xsl:element>
              </xsl:otherwise>
              <!--name=primaryname-->
            </xsl:choose>
          </xsl:when> <!--t-->
          <xsl:otherwise> <!--no t-->
              <!--no $t, so it's a contributor to the main work-->
              <!-- related name -->      
                  <xsl:apply-templates mode="authWorkName" select=".">
                    <xsl:with-param name="agentiri" select="$agentiri"/>
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                  <xsl:if test="not(marc:subfield[@code='4' or @code='e'])">
                    <bf:role rdf:resource="http://id.loc.gov/relators/ctr"/>
                  </xsl:if>           
            </xsl:otherwise>
            <!--no $t, so it's a contributor to the main work-->
        </xsl:choose>
		</xsl:when>
        
        </xsl:choose>
       <!--serialization-->
  </xsl:template>

   <!-- fromwork4XX -->
  <xsl:template match="marc:datafield" mode="authWork430">
    <xsl:param name="agentiri"/>
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="." mode="xmllang"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <!--  if name matches 1xx  name, it's a variant title,
              if not,  its a related work
              If there is no title, it's a contributor to the main work. -->                     
 		  	<xsl:variable name="vTitleLabel">
            <xsl:apply-templates select="." mode="authTTitleLabel"/>
			<!-- testing!! nate -->
			<!-- <xsl:apply-templates select="." mode="authWorkUnifTitle">
              <xsl:with-param name="serialization" select="$serialization"/>
            </xsl:apply-templates> -->
            </xsl:variable>                         
                <bf:title>			                      
                  <bf:Title>
                    <rdf:type>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'VariantTitle')"/></xsl:attribute>
                    </rdf:type>
                    <bf:mainTitle>
                      <xsl:if test="$vXmlLang != ''">
                        <xsl:attribute name="xml:lang">
                          <xsl:value-of select="$vXmlLang"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$vTitleLabel"/>
                    </bf:mainTitle>
                  </bf:Title>
                </bf:title>
              </xsl:when>
          <!--serialization-->
        </xsl:choose>
     
  </xsl:template>
  <!-- from  work4XX -->
  <xsl:template match="marc:datafield" mode="authWork530">    
    <xsl:param name="workiri"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="." mode="xmllang"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">        
			<xsl:variable name="vRelation">
          	  <xsl:choose>
			  <xsl:when test="not(marc:subfield[@code='i'] ) and not(marc:subfield[@code='4']) ">bf:relatedTo</xsl:when>
              	 <xsl:when test="substring(marc:subfield[@code='w'],1,1)='f' ">bf:derivativeOf</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='i' ">bf:relatedTo</xsl:when>
				  <xsl:when test="substring(marc:subfield[@code='w'],1,1)='r' ">bf:relatedTo</xsl:when>
			  </xsl:choose>
            </xsl:variable>
              <xsl:element name="{$vRelation}">
                   <bf:Work>
				    <xsl:attribute name="rdf:about"><xsl:value-of select="$workiri"/></xsl:attribute>
                 <xsl:apply-templates mode="authWorkUnifTitle" select=".">
              		<xsl:with-param name="serialization" select="$serialization"/>
            	</xsl:apply-templates>
				  <!-- <xsl:for-each select="marc:subfield[@code='4']"><bflc:relation rdf:resource="{.}"/></xsl:for-each>
					<xsl:for-each select="marc:subfield[@code='i']"><bflc:relation><bflc:Relation><rdfs:label><xsl:value-of select="."/></rdfs:label></bflc:Relation></bflc:relation></xsl:for-each> -->
                  </bf:Work> 
                </xsl:element>              
        
        </xsl:when>
          <!--serialization-->
        </xsl:choose>
     
  </xsl:template>
  <xsl:template match="marc:datafield" mode="authWorkName">
    <xsl:param name="agentiri"/>
    <xsl:param name="recordid"/>
    <xsl:param name="serialization"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rolesFromSubfields">
      <xsl:choose>
        <xsl:when test="substring($tag,2,2)='11'">
          <xsl:apply-templates select="marc:subfield[@code='j']" mode="authContributionRole">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:when>		
        <xsl:otherwise>
          <xsl:apply-templates select="marc:subfield[@code='e']" mode="authContributionRole">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="marc:subfield[@code='4']" mode="authContributionRoleCode">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:contribution>
          <bf:Contribution>
            <xsl:if test="substring($tag,1,1) = '1'">
              <rdf:type>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bflc,'PrimaryContribution')"/></xsl:attribute>
              </rdf:type>
            </xsl:if>
            <bf:agent>
              <xsl:apply-templates mode="authAgent" select=".">
                <xsl:with-param name="agentiri" select="$agentiri"/>
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </bf:agent>
            <xsl:choose>
              <xsl:when test="substring($tag,1,1)='6'">
                <bf:role>
                  <bf:Role>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,'ctb')"/></xsl:attribute>
                  </bf:Role>
                </bf:role>
              </xsl:when>
			    <!-- 5xx roles -->
			    <xsl:when test="substring($tag,1,1)='5'">
                <bf:role>
                  <bf:Role>
				  <rdfs:label><xsl:value-of select="marc:subfield[@code='i']"/></rdfs:label>                    
                  </bf:Role>
                </bf:role>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="(substring($tag,3,1) = '0' and marc:subfield[@code='e']) or
                                  (substring($tag,3,1) = '1' and marc:subfield[@code='j']) or
                                  marc:subfield[@code='4']">
                    <xsl:copy-of select="$rolesFromSubfields"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <bf:role>
                      <bf:Role>
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,'ctb')"/></xsl:attribute>
                      </bf:Role>
                    </bf:role>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </bf:Contribution>
        </bf:contribution>
      </xsl:when>
    </xsl:choose>
	<!-- 410 dups issue  -->
    <!-- <xsl:if test="marc:subfield[@code='t']">
      <xsl:apply-templates mode="workUnifTitle" select=".">
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:if> -->
  </xsl:template>
  
  <!-- build bf:role properties from $4 -->
  <xsl:template match="marc:subfield[@code='4']" mode="authContributionRoleCode">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:role>
          <bf:Role>
            <xsl:attribute name="rdf:about">
              <xsl:value-of select="concat($relators,substring(.,1,3))"/>
            </xsl:attribute>
          </bf:Role>
        </bf:role>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- build bf:role properties from $e or $j -->
  <xsl:template match="marc:subfield" mode="authContributionRole">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pMode" select="'role'"/>
    <xsl:param name="pRelatedTo"/>
    <xsl:variable name="vXmlLang">
      <xsl:apply-templates select="parent::*" mode="xmllang"/>
    </xsl:variable>
    <xsl:call-template name="authSplitRole">
      <xsl:with-param name="serialization" select="$serialization"/>
      <xsl:with-param name="roleString" select="."/>
      <xsl:with-param name="pMode" select="$pMode"/>
      <xsl:with-param name="pRelatedTo" select="$pRelatedTo"/>
      <xsl:with-param name="pXmlLang" select="$vXmlLang"/>
    </xsl:call-template>
  </xsl:template>
<!-- auth change -->
  <xsl:template match="marc:datafield" mode="authTNameLabel">
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
     
      <!-- auth change  for 4xx? nate suppressed $w-->
      <xsl:when test="$tag='400' or $tag='410'">
        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[not(@code='e' or @code=4 or @code='h' or @code='w')]"
        />
      </xsl:when>
	      <!-- auth change  for 4xx nate suppressed $w-->
      <xsl:when test="$tag='411'">
        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[not(@code='e' or @code=4 or @code='h' or @code='j' or @code='w' )]"
        />
      </xsl:when><!-- auth change  for 5xx nate suppressed $i,w-->
	  <xsl:when test="$tag='500' or $tag='510'">
        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[not(@code='e' or @code=4 or @code='h' or @code='w' or @code='i')]"
        />
      </xsl:when>
	      <!-- auth change  for 5xx nate suppressed $w-->
      <xsl:when test="$tag='511'">
        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[not(@code='e' or @code=4 or @code='h' or @code='j' or @code='w'  or @code='i')]"
        />
      </xsl:when>
      <xsl:otherwise>

        <xsl:apply-templates mode="concat-nodes-space"
          select="marc:subfield[@code='a' or
                                         @code='c' or
                                         @code='d' or
                                         @code='e' or
                                         @code='n' or
                                         @code='g' or
                                         @code='q']"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- recursive template to split bf:role properties out of a $e or $j -->
  <xsl:template name="authSplitRole">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="roleString"/>
    <xsl:param name="pMode" select="'role'"/>
    <xsl:param name="pRelatedTo"/>
    <xsl:param name="pXmlLang"/>
    <xsl:choose>
      <xsl:when test="contains($roleString,',')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,','))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,','))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="$vRole"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="string-length(normalize-space(substring-after($roleString,','))) &gt; 0">
          <xsl:call-template name="authSplitRole">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="roleString" select="substring-after($roleString,',')"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:when test="contains($roleString,' and')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,' and'))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,' and'))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(substring-before($roleString,' and'))"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="authSplitRole">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="roleString" select="substring-after($roleString,' and')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="contains($roleString,'&amp;')">
        <xsl:if test="string-length(normalize-space(substring-before($roleString,'&amp;'))) &gt; 0">
          <xsl:variable name="vRole"><xsl:value-of select="normalize-space(substring-before($roleString,'&amp;'))"/></xsl:variable>
          <xsl:choose>
            <xsl:when test="$serialization='rdfxml'">
              <xsl:choose>
                <xsl:when test="$pMode='role'">
                  <bf:role>
                    <bf:Role>
                      <rdfs:label>
                        <xsl:if test="$pXmlLang != ''">
                          <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="normalize-space(substring-before($roleString,'&amp;'))"/>
                      </rdfs:label>
                    </bf:Role>
                  </bf:role>
                </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$vRole"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:call-template name="authSplitRole">
          <xsl:with-param name="serialization" select="$serialization"/>
          <xsl:with-param name="roleString" select="substring-after($roleString,'&amp;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$serialization='rdfxml'">
            <xsl:choose>
              <xsl:when test="$pMode='role'">
                <bf:role>
                  <bf:Role>
                    <rdfs:label>
                      <xsl:if test="$pXmlLang != ''">
                        <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="normalize-space($roleString)"/>
                    </rdfs:label>
                  </bf:Role>
                </bf:role>
              </xsl:when>
                <xsl:when test="$pMode='relationship'">
                  <bflc:relationship>
                    <bflc:Relationship>
                      <bflc:relation>
                        <rdfs:Resource>
                          <rdfs:label>
                            <xsl:if test="$pXmlLang != ''">
                              <xsl:attribute name="xml:lang"><xsl:value-of select="$pXmlLang"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="normalize-space($roleString)"/>
                          </rdfs:label>
                        </rdfs:Resource>
                      </bflc:relation>
                      <xsl:if test="$pRelatedTo != ''">
                        <bf:relatedTo>
                          <xsl:attribute name="rdf:resource"><xsl:value-of select="$pRelatedTo"/></xsl:attribute>
                        </bf:relatedTo>
                      </xsl:if>
                    </bflc:Relationship>
                  </bflc:relationship>
                </xsl:when>
              </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- build a bf:Agent entity -->
  <xsl:template match="marc:datafield" mode="authAgent">
  <!-- note: in a 4xx or 5xx that is a related work, do we want primarycontributor? will i it help? 
   -->
    <xsl:param name="agentiri"/>
    <xsl:param name="pMADSClass"/>
    <xsl:param name="pSource"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="authTNameLabel"/>
    </xsl:variable>
   
    <xsl:variable name="marckey">
      <xsl:apply-templates mode="marcKey"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bf:Agent>
          <xsl:attribute name="rdf:about"><xsl:value-of select="$agentiri"/></xsl:attribute>
          <rdf:type>
            <xsl:choose>                
              <xsl:when test="substring($tag,2,2)='00'">
                <xsl:choose>
                  <xsl:when test="@ind1='3'">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Family</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="$bf"/>Person</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='10'">
                <xsl:choose>
                  <xsl:when test="@ind1='1'">
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Jurisdiction')"/></xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Organization')"/></xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="substring($tag,2,2)='11'">
                <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'Meeting')"/></xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </rdf:type>
         
            <xsl:if test="$pSource != ''">
              <xsl:copy-of select="$pSource"/>
            </xsl:if>
            <xsl:if test="not(marc:subfield[@code='t'])">
              <xsl:choose>
                <xsl:when test="substring($tag,2,2)='11'">
                  <xsl:apply-templates select="marc:subfield[@code='j']" mode="authContributionRole">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pMode">relationship</xsl:with-param>
                    <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                  </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="marc:subfield[@code='e']" mode="authContributionRole">
                    <xsl:with-param name="serialization" select="$serialization"/>
                    <xsl:with-param name="pMode">relationship</xsl:with-param>
                    <xsl:with-param name="pRelatedTo"><xsl:value-of select="$recordid"/>#Work</xsl:with-param>
                  </xsl:apply-templates>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:for-each select="marc:subfield[@code='4']">
                <bflc:relationship>
                  <bflc:Relationship>
                    <bflc:relation>
                      <rdfs:Resource>
                        <xsl:attribute name="rdf:about"><xsl:value-of select="concat($relators,substring(.,1,3))"/></xsl:attribute>
                      </rdfs:Resource>
                    </bflc:relation>
                    <bf:relatedTo>
                      <xsl:attribute name="rdf:resource"><xsl:value-of select="$recordid"/>#Work</xsl:attribute>
                    </bf:relatedTo>
                  </bflc:Relationship>
                </bflc:relationship>
              </xsl:for-each>
            </xsl:if>
          
          <xsl:choose>
            <xsl:when test="substring($tag,2,2)='00'">
              <xsl:if test="$label != ''">
                <bflc:name00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name00MatchKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName00MatchKey>
                </xsl:if>
              </xsl:if>
              <bflc:name00MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name00MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='10'">
              <xsl:if test="$label != ''">
                <bflc:name10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name10MatchKey>
              </xsl:if>
              <bflc:name10MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name10MarcKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName10MatchKey>
                </xsl:if>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='11'">
              <xsl:if test="$label != ''">
                <bflc:name11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:name11MatchKey>
              </xsl:if>
              <bflc:name11MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:name11MarcKey>
                <xsl:if test="substring($tag,1,1) = '1'">
                  <bflc:primaryContributorName11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:primaryContributorName11MatchKey>
                </xsl:if>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$label != ''">
            <rdfs:label>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space($label)"/>
            </rdfs:label>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='t']">
              <xsl:for-each select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='0' or @code='w'][starts-with(text(),'(uri)') or starts-with(text(),'http')]">
                <xsl:if test="position() != 1">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
              
			  <xsl:for-each select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='0' or @code='w'][string-length(text() ) >  1 ]">
                <xsl:if test="substring(text(),1,5) != '(uri)' and substring(text(),1,4) != 'http'">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='0' or @code='w'][starts-with(text(),'(uri)') or starts-with(text(),'http')][string-length(text())  > 1 ]">
                <xsl:if test="position() != 1">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
              <xsl:for-each select="marc:subfield[@code='0' or @code='w']">
                <xsl:if test="substring(text(),1,5) != '(uri)' and substring(text(),1,4) != 'http'">
                  <xsl:apply-templates mode="subfield0orw" select=".">
                    <xsl:with-param name="serialization" select="$serialization"/>
                  </xsl:apply-templates>
                </xsl:if>
              </xsl:for-each>
              <xsl:apply-templates mode="subfield3" select="marc:subfield[@code='3']">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
              <xsl:apply-templates mode="subfield5" select="marc:subfield[@code='5']">
                <xsl:with-param name="serialization" select="$serialization"/>
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </bf:Agent>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

<!--
      create a bflc:applicableInstitution property from a subfield $5, overrides bib controlsubfields for dlc link
  -->
  <xsl:template match="marc:subfield" mode="subfield5auth">
    <xsl:param name="serialization" select="'rdfxml'"/>
	
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
        <bflc:applicableInstitution>
          <bf:Agent>
		  <xsl:choose>
		  		<xsl:when test="starts-with(.,'DLC')">
					<xsl:attribute  name="rdf:about"><xsl:value-of select="concat($organizations,translate(.,concat($vUpper,'- ' ),$vLower))"/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
            		<bf:code><xsl:value-of select="."/></bf:code>
				</xsl:otherwise>
			</xsl:choose>
          </bf:Agent>
        </bflc:applicableInstitution>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
      Conversion specs for Uniform Titles
	  added 430 to bibs stylesheet
  -->

  <!-- bf:Work properties from Uniform Title fields -->
  <xsl:template match="marc:datafield[@tag='130' or @tag='240']" mode="work">
    <xsl:param name="recordid"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates mode="authWorkUnifTitle" select=".">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="marc:datafield" mode="authWorkUnifTitle">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="label">
      <xsl:apply-templates select="." mode="authTTitleLabel"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if test="$label != ''">
          <rdfs:label>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="normalize-space($label)"/>
          </rdfs:label>
        </xsl:if>
        <bf:title>
          <xsl:apply-templates mode="authTitleUnifTitle" select=".">
            <xsl:with-param name="serialization" select="$serialization"/>
            <xsl:with-param name="label" select="$label"/>
          </xsl:apply-templates>
        </bf:title>
        <xsl:choose>
          <xsl:when test="substring($tag,2,2='10')">
            <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='d']">
              <bf:legalDate>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopParens">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </bf:legalDate>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="substring($tag,2,2)='30' or substring($tag,2,2)='40'">
            <xsl:for-each select="marc:subfield[@code='d']">
              <bf:legalDate>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopParens">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </bf:legalDate>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='f']">
          <bf:originDate>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:originDate>
        </xsl:for-each>
        <xsl:choose>
          <xsl:when test="substring($tag,2,2)='30' or substring($tag,2,2)='40'">
            <xsl:for-each select="marc:subfield[@code='g']">
              <bf:genreForm>
                <bf:GenreForm>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='g']">
              <bf:genreForm>
                <bf:GenreForm>
                  <rdfs:label>
                    <xsl:if test="$vXmlLang != ''">
                      <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </rdfs:label>
                </bf:GenreForm>
              </bf:genreForm>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="marc:subfield[@code='h']">
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:call-template name="chopBrackets">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="."/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='k']">
          <bf:natureOfContent>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:natureOfContent>
          <bf:genreForm>
            <bf:GenreForm>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:GenreForm>
          </bf:genreForm>
        </xsl:for-each>        
        <xsl:for-each select="marc:subfield[@code='l']">
          <bf:language>
            <bf:Language>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <rdfs:label>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:Language>
          </bf:language>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='m']">
          <bf:musicMedium>
            <bf:MusicMedium>
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </rdfs:label>
            </bf:MusicMedium>
          </bf:musicMedium>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='o' or @code='s']">
          <bf:version>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:version>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code='r']">
          <bf:musicKey>
            <xsl:if test="$vXmlLang != ''">
              <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
            </xsl:if>
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
          </bf:musicKey>
        </xsl:for-each>
        <xsl:if test="substring($tag,1,1)='7' or substring($tag,1,1)='8'">
         <xsl:for-each select="marc:subfield[@code='x']">
           <bf:identifiedBy>
             <bf:Issn>
               <rdf:value><xsl:value-of select="."/></rdf:value>
             </bf:Issn>
           </bf:identifiedBy>
         </xsl:for-each>
        </xsl:if>
        <xsl:if test="substring($tag,2,2)='30' or $tag='240' or marc:subfield[@code='t']">
          <xsl:apply-templates mode="subfield0orw" select="marc:subfield[@code='0']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
          <xsl:apply-templates mode="subfield3" select="marc:subfield[@code='3']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
          <xsl:apply-templates mode="subfield5auth" select="marc:subfield[@code='5']">
            <xsl:with-param name="serialization" select="$serialization"/>
          </xsl:apply-templates>
        </xsl:if>
      <!--   <xsl:apply-templates mode="subfield0orw" select="marc:subfield[@code='w']">
          <xsl:with-param name="serialization" select="$serialization"/>
        </xsl:apply-templates>
        -->
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- build a bf:Title entity -->
  <xsl:template match="marc:datafield" mode="authTitleUnifTitle">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="label"/>
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
    <xsl:variable name="nfi">
      <xsl:choose>      
        <xsl:when test="$tag='430' ">
          <xsl:value-of select="@ind2"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="marckey">
      <xsl:apply-templates mode="marcKey"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <bf:Title>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2)='00'">
              <xsl:if test="$label != ''">
                <bflc:title00MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title00MatchKey>
              </xsl:if>
              <bflc:title00MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title00MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='10'">
              <xsl:if test="$label != ''">
                <bflc:title10MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title10MatchKey>
              </xsl:if>
              <bflc:title10MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title10MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='11'">
              <xsl:if test="$label != ''">
                <bflc:title11MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title11MatchKey>
              </xsl:if>
              <bflc:title11MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title11MarcKey>
            </xsl:when>
			<xsl:when test="$tag='130'">			 	
              <xsl:if test="$label != ''">
                <bflc:title30MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title30MatchKey>
              </xsl:if>
              <bflc:title30MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title30MarcKey>
            </xsl:when>
			<!-- 430 and 530  are variants-->
            <xsl:when test="substring($tag,2,2)='30'">
			 	<rdf:type><xsl:attribute name="rdf:resource"><xsl:value-of select="concat($bf,'VariantTitle')"/></xsl:attribute>              </rdf:type>
              <xsl:if test="$label != ''">
                <bflc:title30MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title30MatchKey>
              </xsl:if>
              <bflc:title30MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title30MarcKey>
            </xsl:when>
            <xsl:when test="substring($tag,2,2)='40' and $tag != '740'">
              <xsl:if test="$label != ''">
                <bflc:title40MatchKey><xsl:value-of select="normalize-space($label)"/></bflc:title40MatchKey>
              </xsl:if>
              <bflc:title40MarcKey><xsl:value-of select="concat(@tag,@ind1,@ind2,normalize-space($marckey))"/></bflc:title40MarcKey>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="$label != ''">
            <rdfs:label><xsl:value-of select="normalize-space($label)"/></rdfs:label>
            <bflc:titleSortKey><xsl:value-of select="normalize-space(substring($label,$nfi+1))"/></bflc:titleSortKey>
          </xsl:if>
          <xsl:choose>
             <xsl:when test="substring($tag,2,2)='30' or substring($tag,2,2)='40'">
            <xsl:for-each select="marc:subfield[@code='a']">
                <bf:mainTitle>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:mainTitle>
              </xsl:for-each>
            </xsl:when> 
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='t']">
                <bf:mainTitle>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:mainTitle>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="substring($tag,2,2) = '11'">
              <xsl:for-each select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='n']">
                <bf:partNumber>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:partNumber>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="marc:subfield[@code='n']">
                <bf:partNumber>
                  <xsl:if test="$vXmlLang != ''">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                  </xsl:if>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </bf:partNumber>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:for-each select="marc:subfield[@code='p']">
            <bf:partName>
              <xsl:if test="$vXmlLang != ''">
                <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:value-of select="."/>
                </xsl:with-param>
              </xsl:call-template>
            </bf:partName>
          </xsl:for-each>
        </bf:Title>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- can be applied by templates above or by name/subject templates -->
  <xsl:template match="marc:datafield" mode="authTTitleLabel">
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@tag=880">
          <xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@tag"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose> 
      <xsl:when test="substring($tag,2,2)='00'">
        <xsl:apply-templates mode="concat-nodes-space"
                             select="marc:subfield[@code='t'] |
                                     marc:subfield[@code='t']/following-sibling::marc:subfield[@code='f' or
                                     @code='g' or 
                                     @code='k' or
                                     @code='l' or
                                     @code='m' or
                                     @code='n' or
                                     @code='o' or
                                     @code='p' or									  
                                     @code='r' or 
									 @code='s'  
                                     ]"/> 
      </xsl:when>
      <xsl:when test="substring($tag,2,2)='10'">
        <xsl:apply-templates mode="concat-nodes-space"
                             select="marc:subfield[@code='t'] |
                                     marc:subfield[@code='t']/following-sibling::marc:subfield[@code='d' or
                                     @code='f' or
                                     @code='g' or
                                     @code='k' or
                                     @code='l' or
                                     @code='m' or
                                     @code='n' or
                                     @code='o' or
                                    @code='p' or									  
                                     @code='r' or 
									 @code='s'  
                                     ]"/> 
      </xsl:when>
      <xsl:when test="substring($tag,2,2)='11'">
        <xsl:apply-templates mode="concat-nodes-space"
                             select="marc:subfield[@code='t'] |
                                     marc:subfield[@code='t']/following-sibling::marc:subfield[@code='f' or
                                     @code='g' or
                                     @code='k' or
                                     @code='l' or
                                     @code='n' or
                                     @code='p'	 or
									 @code='s']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="concat-nodes-space"
                             select="marc:subfield[@code='a' or
                                     @code='d' or
                                     @code='f' or
                                     @code='g' or 
                                     @code='k' or
                                     @code='l' or
                                     @code='m' or
                                     @code='n' or
                                     @code='o' or
                                     @code='p' or
                                     @code='r' or
									  @code='s']"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

	<xsl:template match="marc:datafield[@tag='370']" mode="authWork">
		<xsl:param name="serialization" select="'rdfxml'"/>
		<xsl:apply-templates select="." mode="authWork370">
			<xsl:with-param name="serialization" select="$serialization"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag='370' or @tag='880']" mode="authWork370">
		<xsl:param name="serialization" select="'rdfxml'"/>

		<xsl:choose>
			<xsl:when test="$serialization = 'rdfxml'">
				<xsl:for-each select="marc:subfield[@code='c' or @code='g']">
					<xsl:variable name="vXmlLang">
						<xsl:apply-templates select="parent::*" mode="xmllang"/>
					</xsl:variable>
					<bf:originPlace>
						<bf:Place>
							<rdfs:label>
								<xsl:if test="$vXmlLang != ''">
									<xsl:attribute name="xml:lang">
										<xsl:value-of select="$vXmlLang"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="."/>
							</rdfs:label>					
							 <xsl:if test="../marc:subfield[@code='2']" >
					          <bf:source>
					            <bf:Source>
					      	        <xsl:attribute name="rdf:about"><xsl:value-of select="concat($subjectSchemes,normalize-space(../marc:subfield[@code='2']))"/></xsl:attribute>
					            </bf:Source>
					          </bf:source>
					        </xsl:if>
							</bf:Place>
					</bf:originPlace>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag='377']" mode="authWork">
		<xsl:param name="serialization" select="'rdfxml'"/>
		<xsl:apply-templates select="." mode="authWork377">
			<xsl:with-param name="serialization" select="$serialization"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag='377' or @tag='880']" mode="authWork377">
		<xsl:param name="serialization" select="'rdfxml'"/>
		<xsl:choose>
			<xsl:when test="$serialization = 'rdfxml'">
				<xsl:if test="(@ind2!='7' and marc:subfield[@code='a']) or marc:subfield[@code='l' ]">
					<xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
					<bf:language>
						<bf:Language>
							<xsl:choose>
								<xsl:when test="marc:subfield[@code='a' ]">
									<xsl:attribute name="rdf:about">
										<xsl:value-of select="concat($languages, marc:subfield[@code='a'])"/>
									</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<bf:code>
										<xsl:value-of select="."/>
									</bf:code>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:for-each select="marc:subfield[@code='l' ]">							
								<rdfs:label>
									<xsl:if test="$vXmlLang != ''">
										<xsl:attribute name="xml:lang">
											<xsl:value-of select="$vXmlLang"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="."/>
								</rdfs:label>
							</xsl:for-each>
						</bf:Language>
					</bf:language>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
 	
  <xsl:template match="marc:datafield[@tag='381']" mode="authWork">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:apply-templates select="." mode="authWork381">
      <xsl:with-param name="serialization" select="$serialization"/>
    </xsl:apply-templates>
  </xsl:template>
<!-- 381 auth new -->
  <xsl:template match="marc:datafield[@tag='381' or @tag='880']" mode="authWork381">
    <xsl:param name="serialization" select="'rdfxml'"/>    
    <xsl:choose>
      <xsl:when test="$serialization='rdfxml'">
      <xsl:if test="marc:subfield[@code='a' or @code='v' or @code='u' ]">
	  <xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
          <bf:note>
            <bf:Note>             
              <rdfs:label>
                <xsl:if test="$vXmlLang != ''">
                  <xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
                </xsl:if>
				<xsl:if test="marc:subfield[@code='a']"><xsl:value-of select="marc:subfield[@code='a']"/></xsl:if>
				<xsl:if test="marc:subfield[@code='v' or @code='u'] ">  -  </xsl:if>
				<xsl:if test="marc:subfield[@code='v']"><xsl:value-of select="marc:subfield[@code='v']"/></xsl:if>
				<xsl:if test="marc:subfield[@code='u'] "><xsl:value-of select="marc:subfield[@code='u']"/></xsl:if>
              </rdfs:label>          			      				
				<xsl:apply-templates select="marc:subfield[@code='2']" mode="subfield2">
              		<xsl:with-param name="serialization" select="$serialization"/>
            	</xsl:apply-templates>
            </bf:Note>
          </bf:note>
    </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
      Conversion specs for 640 to 675 (641 is glommed onto 642)
  -->

  <xsl:template match="marc:datafield[@tag='640' or @tag='641' or  @tag='642'  or @tag='643'  or @tag='644'   or @tag='645'   or @tag='646']" mode="authWork">    
    <xsl:param name="serialization" select="'rdfxml'"/>
	<xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>
	  
    <xsl:variable name="seriesClass">
      <xsl:choose>
        <xsl:when test="@tag='640'">bflc:SeriesSequentialDesignation</xsl:when>        
		<xsl:when test="@tag='641'">bflc:SeriesNumberingPeculiarities</xsl:when>        
        <xsl:when test="@tag='642'">bflc:SeriesNumbering</xsl:when>
		<xsl:when test="@tag='643'">bflc:SeriesProvider</xsl:when>
		<xsl:when test="@tag='644'">bflc:SeriesAnalysis</xsl:when>
		<xsl:when test="@tag='645'">bflc:SeriesTracing</xsl:when>
        <xsl:when test="@tag='646'">bflc:SeriesClassification</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="seriesLabel">
      <xsl:choose>
        <xsl:when test="@tag='640'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='z']"> (<xsl:value-of select="marc:subfield[@code='z']"/>)</xsl:if></xsl:when>		
        <xsl:when test="@tag='641'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='z']"> (<xsl:value-of select="marc:subfield[@code='z']"/>)</xsl:if>	</xsl:when>		
		<xsl:when test="@tag='642'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>)</xsl:if>					</xsl:when>		
		<xsl:when test="@tag='643'"><xsl:value-of select="marc:subfield[@code='a']"/> <xsl:if test="marc:subfield[@code='b']">; <xsl:value-of select="marc:subfield[@code='b']"/> </xsl:if>  <xsl:if test="marc:subfield[@code='d']">; <xsl:value-of select="marc:subfield[@code='d']"/> </xsl:if></xsl:when>
		<xsl:when test="@tag='644'">
			<xsl:choose> 
				<xsl:when test="marc:subfield[@code='a']='f'">Full </xsl:when>
				<xsl:when test="marc:subfield[@code='a']='p'">Part </xsl:when>
				<xsl:when test="marc:subfield[@code='a']='n'">Not </xsl:when>		
			</xsl:choose>
			<xsl:if test="marc:subfield[@code='b']">; Exceptions:  <xsl:value-of select="marc:subfield[@code='b']"/> </xsl:if> 
			 <xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>) </xsl:if>
		</xsl:when>
		<xsl:when test="@tag='645'">
			<xsl:choose> 
				<xsl:when test="marc:subfield[@code='a']='t' ">Traced </xsl:when>				
				<xsl:when test="marc:subfield[@code='a']='n'">Not </xsl:when>		
			</xsl:choose>
		 	<xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>) </xsl:if>
		 </xsl:when>
		<xsl:when test="@tag='646'">
		<xsl:choose> 
				<xsl:when test="marc:subfield[@code='a']='c' ">Collection </xsl:when>				
				<xsl:when test="marc:subfield[@code='a']='m'">With main </xsl:when>		
				<xsl:when test="marc:subfield[@code='a']='s'">Separately </xsl:when>		
			</xsl:choose>
			 <xsl:if test="marc:subfield[@code='d']"> (<xsl:value-of select="marc:subfield[@code='d']"/>) </xsl:if></xsl:when>        
      </xsl:choose>
    </xsl:variable>
	<bflc:seriesTreatment>
		<xsl:element name="{$seriesClass}">
			<rdfs:label>
				<xsl:if test="$vXmlLang != ''">
                	<xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              	</xsl:if>
			  <xsl:value-of select="$seriesLabel"/></rdfs:label>
				<xsl:apply-templates mode="subfield5auth" select="marc:subfield[@code='5']">
            	  <xsl:with-param name="serialization" select="$serialization"/>
            	</xsl:apply-templates>
		</xsl:element>
	</bflc:seriesTreatment>
 </xsl:template>
  <xsl:template match="marc:datafield[@tag='667']" mode="authWork">    
    <xsl:param name="serialization" select="'rdfxml'"/>
	<xsl:variable name="vXmlLang"><xsl:apply-templates select="." mode="xmllang"/></xsl:variable>	  
		<bf:note><bf:Note>		
			<rdfs:label>
				<xsl:if test="$vXmlLang != ''">
                	<xsl:attribute name="xml:lang"><xsl:value-of select="$vXmlLang"/></xsl:attribute>
              	</xsl:if>
			  <xsl:value-of select="marc:subfield[@code='a']"/></rdfs:label>
				<bf:status>nonpublic</bf:status>
			</bf:Note>
		</bf:note>
	
 	</xsl:template>
    <xsl:template match="marc:datafield[@tag='670' or @tag='675']" mode="authAdminmetadata">
	<!-- issues: $u couild be a uri, not a string. could all be in one big note?? -->
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:if  test="marc:subfield[@code='a' or @code='b'  or @code='u' or @code='w' ]">		
          <bf:note>
            <bf:Note> 
  				 <xsl:choose>
					<xsl:when test="@tag='670' ">   	<bf:noteType>Data source</bf:noteType></xsl:when>
					<xsl:when test="@tag='675' ">   	<bf:noteType>Data not found</bf:noteType></xsl:when>
				</xsl:choose>				 
              	<rdfs:label>   <xsl:apply-templates mode="concat-nodes-space"  select="marc:subfield"  /></rdfs:label>
            	</bf:Note>
			</bf:note>
        </xsl:if>
		</xsl:when>
	</xsl:choose>
 	</xsl:template>

      </xsl:stylesheet>
