<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods srw_dc"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:srw_dc="info:srw/schema/1/dc-schema"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- 
This stylesheet transforms MODS version 3.2 records and collections of records to simple Dublin Core (DC) records, 
based on the Library of Congress' MODS to simple DC mapping <http://www.loc.gov/standards/mods/mods-dcsimple.html> 
		
The stylesheet will transform a collection of MODS 3.2 records into simple Dublin Core (DC)
as expressed by the SRU DC schema <http://www.loc.gov/standards/sru/dc-schema.xsd>

The stylesheet will transform a single MODS 3.2 record into simple Dublin Core (DC)
as expressed by the OAI DC schema <http://www.openarchives.org/OAI/2.0/oai_dc.xsd>
		
Because MODS is more granular than DC, transforming a given MODS element or subelement to a DC element frequently results in less precise tagging, 
and local customizations of the stylesheet may be necessary to achieve desired results. 

This stylesheet makes the following decisions in its interpretation of the MODS to simple DC mapping: 
	
When the roleTerm value associated with a name is creator, then name maps to dc:creator
When there is no roleTerm value associated with name, or the roleTerm value associated with name is a value other than creator, then name maps to dc:contributor
Start and end dates are presented as span dates in dc:date and in dc:coverage
When the first subelement in a subject wrapper is topic, subject subelements are strung together in dc:subject with hyphens separating them
Some subject subelements, i.e., geographic, temporal, hierarchicalGeographic, and cartographics, are also parsed into dc:coverage
The subject subelement geographicCode is dropped in the transform

Revision 2012-06-15 <robin@coalliance.org>
		Took out local: identifier prefix for type="local"
		
Revision 2012-06-12 <robin@coalliance.org>
		Changed title to only transform MODS title without any type attribute
		Added all namespaces to exclude-result-prefixes but DC namespace is still being inserted

Revision 1.1	2007-05-18 <tmee@loc.gov>
		Added modsCollection conversion to DC SRU
		Updated introductory documentation
	
Version 1.0	2007-05-04 Tracy Meehleib <tmee@loc.gov>

-->

	<xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>
	<!-- remove mods elements without text nodes in itself or descendants -->
	<xsl:template match="*[normalize-space(.)='']"/>
	<xsl:template match="/">
		<xsl:choose>
		<xsl:when test="//mods:modsCollection">			
			<srw_dc:dcCollection xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/dc-schema.xsd">
				<xsl:apply-templates/>
			<xsl:for-each select="mods:modsCollection/mods:mods">			
				<srw_dc:dc xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/dc-schema.xsd">
				<xsl:apply-templates/>
			</srw_dc:dc>
			</xsl:for-each>
			</srw_dc:dcCollection>
		</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="mods:mods">
			<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd" xmlns:dc="http://purl.org/dc/elements/1.1/">
				<xsl:apply-templates/>
			</oai_dc:dc>
			</xsl:for-each>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="mods:titleInfo">
		<xsl:choose>
			<xsl:when test="not(@type)">
			<dc:title>
				<xsl:value-of select="mods:title"/>
				</dc:title>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="mods:name">
		
		<xsl:choose>
			<xsl:when test="mods:role/mods:roleTerm[@type='text']='creator' or mods:role/mods:roleTerm[@type='code']='cre' ">
				<dc:creator>
					<xsl:call-template name="name"/>
				</dc:creator>
			</xsl:when>

			<xsl:otherwise>
				<dc:contributor>
					<xsl:call-template name="name"/>
				</dc:contributor>
			</xsl:otherwise>
		</xsl:choose>
			
	</xsl:template>

	<xsl:template match="mods:classification">
		<dc:subject>
			<xsl:value-of select="."/>
		</dc:subject>
	</xsl:template>

	<xsl:template match="mods:subject[mods:topic | mods:name | mods:genre | mods:occupation | mods:geographic | mods:hierarchicalGeographic | mods:cartographics | mods:temporal] ">
		
			<xsl:for-each select="mods:topic">
					<xsl:if test="text() [normalize-space(.) ]">
						<dc:subject>
					<xsl:value-of select="."/>
						</dc:subject>
						</xsl:if>
			</xsl:for-each>
	
	<xsl:for-each select="mods:occupation">
					<xsl:if test="text() [normalize-space(.) ]">
						<dc:subject>
					<xsl:value-of select="."/>
						</dc:subject>
						</xsl:if>
	</xsl:for-each>
			<xsl:for-each select="mods:genre">
					<xsl:if test="text() [normalize-space(.) ]">
						<dc:subject>
					<xsl:value-of select="."/>
						</dc:subject>
						</xsl:if>
			</xsl:for-each>
		
		
			<xsl:for-each select="mods:name">
					<xsl:if test="text() [normalize-space(.) ]">
						<dc:subject>
					<xsl:call-template name="name"/>
						</dc:subject>
						</xsl:if>
			</xsl:for-each>
		

		<xsl:for-each select="mods:titleInfo/mods:title">
			<dc:subject>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dc:subject>
		</xsl:for-each>

		<xsl:for-each select="mods:geographic">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:hierarchicalGeographic">
			<dc:coverage>
				<xsl:for-each
					select="mods:continent|mods:country|mods:provence|mods:region|mods:state|mods:territory|mods:county|mods:city|mods:island|mods:area">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">--</xsl:if>
				</xsl:for-each>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics/*">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:if test="mods:temporal">
			<dc:coverage>
				<xsl:for-each select="mods:temporal">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">-</xsl:if>
				</xsl:for-each>
			</dc:coverage>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="mods:abstract | mods:tableOfContents | mods:note">
		<dc:description>
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>

	<xsl:template match="mods:originInfo">
		<dc:date>
			<xsl:for-each select="*">
				<xsl:if test="@keyDate='yes'">
					<xsl:value-of select="." />
				</xsl:if>
			</xsl:for-each>
		</dc:date>

		<xsl:for-each select="mods:publisher | mods:place/mods:placeTerm">
			<dc:publisher>
				<xsl:value-of select="."/>
			</dc:publisher>
		</xsl:for-each>
	</xsl:template>

<xsl:template match="mods:genre">
		<xsl:choose>
			<xsl:when test="@authority='dct'">
				<dc:type>
					<xsl:value-of select="."/>
				</dc:type>
				<xsl:for-each select="mods:typeOfResource">
					<dc:type>
						<xsl:value-of select="."/>
					</dc:type>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<dc:type>
					<xsl:value-of select="."/>
				</dc:type>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:typeOfResource">
	<!--transform to DCMI type covabulary http://dublincore.org/documents/2003/11/19/dcmi-type-vocabulary/ RD 2014-04018 --> 
		<xsl:if test="@collection='yes'">
			<dc:type>Collection</dc:type>
		</xsl:if>
		<!--
		<xsl:if test=". ='software' and ../mods:genre='database'">
			<dc:type>DataSet</dc:type>
		</xsl:if>
		<xsl:if test=".='software' and ../mods:genre='online system or service'">
			<dc:type>Service</dc:type>
		</xsl:if>
		-->
		<xsl:if test=". ='text'">
			<dc:type>Text</dc:type>
		</xsl:if>
		<xsl:if test=".='cartographic'">
			<dc:type>Image</dc:type>
		</xsl:if>
		<xsl:if test=".='notated music'">
			<dc:type>Text</dc:type>
		</xsl:if>
		<xsl:if test="starts-with(.,'sound recording')">
			<dc:type>Sound</dc:type>
		</xsl:if>
		<xsl:if test=".='still image'">
			<dc:type>Image</dc:type>
		</xsl:if>
		<xsl:if test=".='moving image'">
			<dc:type>Moving Image</dc:type>
		</xsl:if>
		<xsl:if test=".='software, multimedia'">
			<dc:type>Software</dc:type>
		</xsl:if>
		<xsl:if test=".='three-dimensional object'">
			<dc:type>Physical Object</dc:type>
		</xsl:if>
		
		
		
	</xsl:template>
	
	<xsl:template match="mods:physicalDescription">
		<xsl:for-each select="child::*">
			<dc:format>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each>
	</xsl:template>
<!--
	<xsl:template match="mods:physicalDescription">
		<xsl:for-each select="../*">
		<xsl:if test="mods:extent">
			<dc:format>
				<xsl:value-of select="mods:extent"/>
			</dc:format>
		</xsl:if>
		<xsl:if test="mods:form">
			<dc:format>
				<xsl:value-of select="mods:form"/>
			</dc:format>
		</xsl:if>
		<xsl:if test="mods:internetMediaType">
			<dc:format>
				<xsl:value-of select="mods:internetMediaType"/>
			</dc:format>
		</xsl:if>
		<xsl:if test="mods:digitalOrigin">
			<dc:format>
				<xsl:value-of select="mods:digitalOrigin"/>
			</dc:format>
	</xsl:if>
		<xsl:if test="mods:note">
			<xsl:for-each select="mods:note">
			<dc:description>
				<xsl:value-of select="."/>
			</dc:description>
			</xsl:for-each>
		</xsl:if>
		</xsl:for-each>
	</xsl:template>
-->
	<xsl:template match="mods:mimeType">
		<dc:format>
			<xsl:value-of select="."/>
		</dc:format>
	</xsl:template>

	<xsl:template match="mods:identifier">
		<xsl:variable name="type" select="translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
		<xsl:choose>
			<xsl:when test="contains ('isbn issn uri doi lccn uri', $type)">
				<dc:identifier>
					<xsl:if test="text() [normalize-space(.) ]">
					<xsl:value-of select="$type"/>: <xsl:value-of select="."/>
				</xsl:if>
				</dc:identifier>
				
			</xsl:when>
			<xsl:when test="contains ('local', $type)">
				<dc:identifier>
					<xsl:if test="text() [normalize-space(.) ]">
					<xsl:value-of select="."/>
						</xsl:if>
				</dc:identifier>
			</xsl:when>
			<xsl:otherwise>
				<dc:identifier>
					<xsl:value-of select="."/>
				</dc:identifier>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:location">
		<dc:identifier>
			<xsl:for-each select="mods:url">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</dc:identifier>
	</xsl:template>

	<xsl:template match="mods:language">
		<dc:language>
			<xsl:value-of select="normalize-space(.)"/>
		</dc:language>
	</xsl:template>

	<xsl:template match="mods:relatedItem[mods:titleInfo | mods:name | mods:identifier | mods:location]">
		<xsl:choose>
			<xsl:when test="@type='original'">
				<dc:source>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:source>
			</xsl:when>
			<xsl:when test="@type='series'"/>
			<xsl:otherwise>
				<dc:relation>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:relation>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="mods:accessCondition">
		<dc:rights>
			<xsl:value-of select="."/>
		</dc:rights>
	</xsl:template>

	<xsl:template name="name">
		<xsl:variable name="name">
			<xsl:for-each select="mods:namePart[not(@type)]">
				<xsl:if test="text() [normalize-space(.) ]">
				<xsl:value-of select="normalize-space(.)"/>
                    </xsl:if>
			</xsl:for-each>
			<xsl:value-of select="mods:namePart[@type='family']"/>
			<xsl:if test="mods:namePart[@type='given']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='given']"/>
			</xsl:if>
			<xsl:if test="mods:namePart[@type='date']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='date']"/>
				<xsl:text/>
			</xsl:if>
			<xsl:if test="mods:displayForm">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="mods:displayForm"/>
				<xsl:text>) </xsl:text>
			</xsl:if>
			</xsl:variable>
		<xsl:value-of select="normalize-space($name)"/>
	</xsl:template>

	<xsl:template match="mods:dateIssued[@point='start'] | mods:dateCreated[@point='start'] | mods:dateCaptured[@point='start'] | mods:dateOther[@point='start'] ">
		<xsl:variable name="dateName" select="local-name()"/>
			<dc:date>
				<xsl:value-of select="."/>-<xsl:value-of select="../*[local-name()=$dateName][@point='end']"/>
			</dc:date>
	</xsl:template>
	
	<xsl:template match="mods:temporal[@point='start']  ">
		<xsl:value-of select="."/>-<xsl:value-of select="../mods:temporal[@point='end']"/>
	</xsl:template>
	
	<xsl:template match="mods:temporal[@point!='start' and @point!='end']  ">
		<xsl:value-of select="."/>
	</xsl:template>
	
	<!--Remove empty elements 
	<xsl:template match="node()|@*">
  		<xsl:copy>
  			<xsl:apply-templates select="node()|@*"/>
  		</xsl:copy>
 	</xsl:template>
 	<xsl:template match="*[not(node())] | *[not(node()[2]) and node()/self::text() and
 	not(normalize-space())]"/>
	-->
	<!-- suppress all else:-->
	<xsl:template match="*"/>
		

	
</xsl:stylesheet>
