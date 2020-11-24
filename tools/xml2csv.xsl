<?xml version="1.0"?>
<!--
project: morgen - Model Order Reduction for Gas and Energy Networks
version: 0.9 (2020-11-24)
authors: C. Himpe (0000-0003-2194-6754)
license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
summary: Convert GasLib xml to MORGEN csv
-->

<!--
Add the line:

<?xml-stylesheet href="xml2csv.xsl" type="text/xsl" ?>

below the xml declaration, and convert the xml file with an XSLT processor.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:net="http://gaslib.zib.de/Gas"
                              xmlns:framework="http://gaslib.zib.de/Framework">
<!--
	The output is a CSV file
-->
	<xsl:output method="text" encoding="utf-8" omit-xml-declaration="yes" />
<!--
	Extract list of nodes
-->
	<xsl:variable name="nodes" select="/net:network/framework:nodes/child::*" />
<!--
	Extract list of boundary nodes
-->
	<xsl:variable name="boundaries" select="$nodes[name() = 'source' or name() = 'sink']"/>
<!--
	Extract list of supply nodes
-->
	<xsl:variable name="supplies" select="$nodes[name() = 'source']"/>
<!--
	Extract list of demand nodes
-->
	<xsl:variable name="demands" select="$nodes[name() = 'sink']"/>
<!--
	Count number of nodes, this is needed for the extra boundary node short-pipes
-->
	<xsl:variable name="numNodes" select="count($nodes)"/>
<!--
	Read network name and set as filename of transformation.
-->
	<!--xsl:variable name="name" select="/net:network/framework:information/framework:title" />
	<xsl:result-document href="{$name}.csv"-->
<!--
	Break default recursion
-->
	<xsl:template match="text()"/>
<!--
	Named template to convert prefixed length values
-->
	<xsl:template name="length2base">

		<xsl:param name="value"/>
		<xsl:param name="unit"/>

		<!--xsl:when test="matches($value, '^\-?[\d\.,]*[Ee][+\-]*\d*$')"> 

                	<xsl:value-of select="format-number(number($value), '#0.#############')"/>

		</xsl:when--> 

		<xsl:choose>
<!--
			Case: meter
-->
			<xsl:when test="$unit = 'm' or $unit = 'meter'">
				<xsl:value-of select="number($value) * 1.0"/>
			</xsl:when>
<!--
			Case: millimeter
-->
			<xsl:when test="$unit = 'mm'">
				<xsl:value-of select="number($value) * 0.001"/>
			</xsl:when>
<!--
			Case: kilometer
-->
			<xsl:when test="$unit = 'km'">
				<xsl:value-of select="number($value) * 1000.0"/>
			</xsl:when>
<!--
			Else: error
-->
			<xsl:otherwise>
				<xsl:message terminate="yes">
Unknown unit: <xsl:value-of select="$unit"/>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
<!--
	Match root element
-->
	<xsl:template match="net:network">

# type, identifier-in, identifier-out, pipe-length [m], pipe diameter [m], height difference [m], pipe roughness [m]<!--
-->		<xsl:for-each select="framework:connections/child::*">
			<xsl:variable name="from" select="@from"/>
			<xsl:variable name="to" select="@to"/>

			<xsl:variable name="from_height">
<xsl:call-template name="length2base">
	<xsl:with-param name="value" select="$nodes[@id=$from]/net:height/@value"/>
	<xsl:with-param name="unit" select="$nodes[@id=$from]/net:height/@unit"/>
</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="to_height">
<xsl:call-template name="length2base">
	<xsl:with-param name="value" select="$nodes[@id=$to]/net:height/@value"/>
	<xsl:with-param name="unit" select="$nodes[@id=$to]/net:height/@unit"/>
</xsl:call-template>
			</xsl:variable>

<!--
			Select edge type
-->
			<xsl:choose>
<!--
				Case: pipe
-->
				<xsl:when test="name() = 'pipe'">
P,<!--

	Inflow node

--><xsl:value-of select="count($nodes[@id=$from]/preceding-sibling::*) + 1"/>,<!--

	Outflow node
	
--><xsl:value-of select="count($nodes[@id=$to]/preceding-sibling::*) + 1"/>,<!--

	Pipe length

--><xsl:call-template name="length2base">
	<xsl:with-param name="value" select="net:length/@value"/>
	<xsl:with-param name="unit" select="net:length/@unit"/>
</xsl:call-template>,<!--

	Pipe diameter

--><xsl:call-template name="length2base">
	<xsl:with-param name="value" select="net:diameter/@value"/>
	<xsl:with-param name="unit" select="net:diameter/@unit"/>
</xsl:call-template>,<!--

	Pipe height difference

--><xsl:value-of select="number($to_height) - number($from_height)"/>,<!--

	Pipe roughness

--><xsl:call-template name="length2base">
	<xsl:with-param name="value" select="net:roughness/@value"/>
	<xsl:with-param name="unit" select="net:roughness/@unit"/>
</xsl:call-template>
				</xsl:when>
<!--
				Case: short-pipe
-->
				<xsl:when test="name() = 'shortPipe'">
S,<!--

	Inflow node

--><xsl:value-of select="count($nodes[@id=$from]/preceding-sibling::*) + 1"/>,<!--

	Outflow node

--><xsl:value-of select="count($nodes[@id=$to]/preceding-sibling::*) + 1"/>
				</xsl:when>

<!--
				Case: resistor
-->
				<xsl:when test="name() = 'resistor'">
S,<!--

	Inflow node

--><xsl:value-of select="count($nodes[@id=$from]/preceding-sibling::*) + 1"/>,<!--

	Outflow node

--><xsl:value-of select="count($nodes[@id=$to]/preceding-sibling::*) + 1"/>
				</xsl:when>

<!--
				Case: compressor
-->
				<xsl:when test="name() = 'compressorStation'">
C,<!--

	Inflow node

--><xsl:value-of select="count($nodes[@id=$from]/preceding-sibling::*) + 1"/>,<!--

	Outflow node

--><xsl:value-of select="count($nodes[@id=$to]/preceding-sibling::*) + 1"/>
				</xsl:when>
<!--
				Case: valve (or control-valve)
-->
				<xsl:when test="name() = 'valve' or name() = 'controlValve'">
V,<!--

	Inflow node

--><xsl:value-of select="count($nodes[@id=$from]/preceding-sibling::*) + 1"/>,<!--

	Outflow node

--><xsl:value-of select="count($nodes[@id=$to]/preceding-sibling::*) + 1"/>
				</xsl:when>
<!--
				Else: error
-->
				<xsl:otherwise>

					<xsl:message terminate="yes">

Unknown network edge type: <xsl:value-of select="name()"/>

					</xsl:message>
				</xsl:otherwise>

			</xsl:choose>

		</xsl:for-each>
<!--
		Add short-pipes before supply nodes to ensure correct directionality
-->
		<xsl:for-each select="$supplies">

			<xsl:variable name="id" select="@id"/>
S,<!--

	New inflow node

--><xsl:value-of select="$numNodes + count($boundaries[@id=$id]/preceding-sibling::*) + 1"/>,<!--

	Old outflow node

--><xsl:value-of select="count($nodes[@id=$id]/preceding-sibling::*) + 1"/>
		</xsl:for-each>

		<xsl:for-each select="$demands">
<!--
		Add short-pipes after demand nodes to ensure correct directionality
-->
			<xsl:variable name="id" select="@id"/>
S,<!--

	Old inflow node

--><xsl:value-of select="count($nodes[@id=$id]/preceding-sibling::*) + 1"/>,<!--

	New outflow node

--><xsl:value-of select="$numNodes + count($boundaries[@id=$id]/preceding-sibling::*) + 1"/>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
