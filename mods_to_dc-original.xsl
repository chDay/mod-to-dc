<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods xs" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:template match="text()"/>
	<xsl:template match="/">
		<xsl:choose>
			<!-- WS: updated schema location -->
			<xsl:when test="//mods:modsCollection">
				<srw_dc:dcCollection xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/recordSchemas/dc-schema.xsd">
					<xsl:apply-templates/>
					<xsl:for-each select="mods:modsCollection/mods:mods">
						<srw_dc:dc xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/standards/sru/recordSchemas/dc-schema.xsd">
							<xsl:apply-templates/>
						</srw_dc:dc>
					</xsl:for-each>
				</srw_dc:dcCollection>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="mods:mods">
					<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
						<xsl:apply-templates/>
					</oai_dc:dc>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- adjusted to add title.alternative loop -->
	<xsl:template match="mods:titleInfo">
		<xsl:choose>
			<xsl:when test="@type='alternative'">
				<dc:title.alternative>
					<xsl:value-of select="mods:nonSort"/>
					<xsl:if test="mods:nonSort">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="mods:title"/>
					<xsl:if test="mods:subTitle">
						<xsl:text>: </xsl:text>
						<xsl:value-of select="mods:subTitle"/>
					</xsl:if>
					<xsl:if test="mods:partNumber">
						<xsl:text>. </xsl:text>
						<xsl:value-of select="mods:partNumber"/>
					</xsl:if>
					<xsl:if test="mods:partName">
						<xsl:text>. </xsl:text>
						<xsl:value-of select="mods:partName"/>
					</xsl:if>

				</dc:title.alternative>
			</xsl:when>
			<xsl:otherwise>
				<dc:title>
					<xsl:value-of select="mods:nonSort"/>
					<xsl:if test="mods:nonSort">
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="mods:title"/>
					<xsl:if test="mods:subTitle">
						<xsl:text>: </xsl:text>
						<xsl:value-of select="mods:subTitle"/>
					</xsl:if>
					<xsl:if test="mods:partNumber">
						<xsl:text>. </xsl:text>
						<xsl:value-of select="mods:partNumber"/>
					</xsl:if>
					<xsl:if test="mods:partName">
						<xsl:text>. </xsl:text>
						<xsl:value-of select="mods:partName"/>
					</xsl:if>
				</dc:title>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!-- Edited to change roleTerm selection from Creator to Author and add @type='personal' test -->

	<!-- tmee mods 3.5 -->
	<xsl:template match="mods:name">
		<xsl:choose>
			<xsl:when test="@type='personal'">
				<xsl:choose>
					<xsl:when test="mods:role/mods:roleTerm[@type='text' and @authority='marcrelator']='Author' or mods:role/mods:roleTerm[@type='code']='aut'">
						<dc:creator>
							<xsl:call-template name="name"/>
						</dc:creator>
					</xsl:when>
					<xsl:otherwise>
						<!-- ws  1.7 -->
						<dc:contributor>
							<xsl:call-template name="name"/>
						</dc:contributor>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- ws  1.7 -->
				<dc:contributor>
					<xsl:call-template name="name"/>
				</dc:contributor>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ws 1.7  -->
	<xsl:template match="mods:subject">
		<xsl:if test="mods:topic | mods:occupation | mods:name">
			<dc:subject>
				<xsl:for-each select="mods:topic | mods:occupation">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">--</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="mods:name">
					<xsl:call-template name="name"/>
				</xsl:for-each>
			</dc:subject>
		</xsl:if>
		<xsl:for-each select="mods:titleInfo">
			<dc:subject>
				<xsl:for-each select="child::*">
					<xsl:value-of select="."/>
					<xsl:if test="following-sibling::*"><xsl:text> </xsl:text></xsl:if>
				</xsl:for-each>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="mods:geographic">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>
		<xsl:for-each select="mods:hierarchicalGeographic">
			<dc:coverage>
				<xsl:for-each select="mods:continent|mods:country|mods:province|mods:region|mods:state|mods:territory|mods:county|mods:city|mods:island|mods:area">
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
		<xsl:if test="*[1][local-name()='topic'] and *[local-name()!='topic']">
			<dc:subject>
				<xsl:for-each select="*[local-name()!='cartographics' and local-name()!='geographicCode' and local-name()!='hierarchicalGeographic'] ">
					<xsl:value-of select="."/>
					<xsl:if test="position()!=last()">--</xsl:if>
				</xsl:for-each>
			</dc:subject>
		</xsl:if>
	</xsl:template>

<!-- changed dc:description to dc:description.abstract and just 'mods:abstract' -->
  <xsl:template match="mods:abstract">
		<dc:description.abstract>
			<xsl:value-of select="."/>
		</dc:description.abstract>
	</xsl:template>

<!-- Added mods:placeTerm section; added xsl:if test to concatenate mods:publsher and mods:placeTerm fields-->
	<xsl:template match="mods:originInfo">
		<xsl:apply-templates select="*[@point='start']"/>
		<xsl:apply-templates select="*[not(@point)]"/>

		<dc:publisher>
			<xsl:for-each select="mods:publisher">
				<xsl:value-of select="."/>
				<xsl:if test="position()!=last()">
					<xsl:text>; </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</dc:publisher>

		<dc:publisher>
			<xsl:for-each select="mods:place">
				<xsl:for-each select="mods:placeTerm">
					<xsl:if test="@type='text'">
						<xsl:value-of select="."/>
						<xsl:if test="position()!=last()">
							<xsl:text>; </xsl:text>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</dc:publisher>
	</xsl:template>

<!-- Edited to just use dateIssued or copyrightDate and only @keyDate value-->

	<xsl:template match="mods:dateIssued | mods:copyrightDate">
		<xsl:choose>
			<xsl:when test="@keyDate !=''">
				<dc:date>
					<xsl:value-of select="."/>
				</dc:date>
			</xsl:when>
		</xsl:choose>
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

<!-- Edited to change capitalization on Still Image -->
	<xsl:template match="mods:typeOfResource">
		<xsl:if test="@collection='yes'">
			<dc:type>Collection</dc:type>
		</xsl:if>
		<xsl:if test=". ='software' and ../mods:genre='database'">
			<dc:type>Dataset</dc:type>
		</xsl:if>
		<xsl:if test=".='software' and ../mods:genre='online system or service'">
			<dc:type>Service</dc:type>
		</xsl:if>
		<xsl:if test=".='software'">
			<dc:type>Software</dc:type>
		</xsl:if>
		<xsl:if test=".='cartographic material'">
			<dc:type>Image</dc:type>
		</xsl:if>
		<xsl:if test=".='multimedia'">
			<dc:type>InteractiveResource</dc:type>
		</xsl:if>
		<xsl:if test=".='moving image'">
			<dc:type>MovingImage</dc:type>
		</xsl:if>
		<xsl:if test=".='three dimensional object'">
			<dc:type>PhysicalObject</dc:type>
		</xsl:if>
		<xsl:if test="starts-with(.,'sound recording')">
			<dc:type>Sound</dc:type>
		</xsl:if>
		<xsl:if test=".='Still Image'">
			<dc:type>StillImage</dc:type>
		</xsl:if>
		<xsl:if test=". ='text'">
			<dc:type>Text</dc:type>
		</xsl:if>
		<xsl:if test=".='notated music'">
			<dc:type>Text</dc:type>
		</xsl:if>
	</xsl:template>

<!-- Edited to limit to mods:extent-->
	<xsl:template match="mods:physicalDescription">
		<xsl:for-each select="mods:extent">
			<dc:format>
				<!-- tmee mods 3.5 -->
				<xsl:variable name="unit" select="translate(@unit,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
				<!-- ws 1.7 -->
				<xsl:if test="@unit">
					<xsl:value-of select="$unit"/>:
				</xsl:if>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each>
	</xsl:template>

<!--replaced mods:identifier transform to only select @type='accession' -->
  <xsl:template match="mods:identifier">
    <xsl:choose>
      <xsl:when test="@type='accession'">
        <dc:identifier>
          <xsl:value-of select="."/>
        </dc:identifier>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:location">
		<xsl:for-each select="mods:url">
			<dc:identifier>
				<xsl:value-of select="."/>
			</dc:identifier>
		</xsl:for-each>
	</xsl:template>

<!-- adjusted to just select @type='code' -->
	<xsl:template match="mods:language">
		<xsl:for-each select="mods:languageTerm">
			<xsl:if test="@type='code'">
			<dc:language>
				<xsl:value-of select="."/>
			</dc:language>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mods:relatedItem[mods:titleInfo | mods:name | mods:identifier | mods:location]">
		<xsl:choose>
			<xsl:when test="@type='original'">
				<dc:source>
					<xsl:for-each select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">--</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:source>
			</xsl:when>
			<xsl:when test="@type='series'">
				<dc:relation>
					<xsl:for-each select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
						</xsl:if>
					</xsl:for-each>
				</dc:relation>
			</xsl:when>
			<xsl:otherwise>
				<dc:relation>
					<xsl:for-each select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:url">
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
				<xsl:value-of select="."/>
				<xsl:text> </xsl:text>
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

	<!-- suppress all else:-->
	<xsl:template match="*"/>


</xsl:stylesheet>
