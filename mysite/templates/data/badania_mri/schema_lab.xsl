<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:extPL="http://www.csioz.gov.pl/xsd/extPL/r2" version="1.0">

	<xsl:output method="html" version="4.01" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01//EN" media-type="text/html" doctype-system="about:legacy-compat"/>
	
	<xsl:variable name="LOWERCASE_LETTERS">aąbcćdeęfghijklłmnńoópqrsśtuvwxyzżź</xsl:variable>
	<xsl:variable name="UPPERCASE_LETTERS">AĄBCĆDEĘFGHIJKLŁMNŃOÓPQRSŚTUVWXYZŻŹ</xsl:variable>
	<!-- dokumenty medyczne posiadają etykiety w języku polskim za wyjątkiem części lub całych dokumentów, dla których wskazano język angielski kodem en-US -->
	<xsl:variable name="secondLanguage">en-US</xsl:variable>
	
	<xsl:template match="/">
		<xsl:apply-templates select="hl7:ClinicalDocument"/>
	</xsl:template>
	
	<!-- dokument medyczny, szablon bazowy 2.16.840.1.113883.3.4424.13.10.1.1, szablon bazowy dla P1 2.16.840.1.113883.3.4424.13.10.1.2 -->
	<xsl:template match="hl7:ClinicalDocument">
		<html>
			<head>
				<xsl:call-template name="styles"/>
			</head>
			<body>
				<div class="document">
					<div class="doc_theader">
						<xsl:choose>
							<!-- dla binarnych dokumentów embedowanych w XML HL7 CDA nagłówek jest inicjalnie zwinięty, dostępny pod definiowanym tu przyciskiem -->
							<xsl:when test="hl7:component/hl7:structuredBody/hl7:component/hl7:section/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.3.55'">
								<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
								<xsl:variable name="show">
									<xsl:choose>
										<xsl:when test="$lang = $secondLanguage">
											<xsl:text>CDA Header</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Nagłówek CDA</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="hide">
									<xsl:choose>
										<xsl:when test="$lang = $secondLanguage">
											<xsl:text>Hide CDA Header</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Ukryj nagłówek CDA</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<input id="showCdaHeader" name="group" type="radio" class="show_cda_header"/>
								<label for="showCdaHeader" class="show_cda_header_label">
									<span><xsl:value-of select="$show"/></span>
								</label>
								<input id="hideCdaHeader" name="group" type="radio" class="hide_cda_header"/>
								<label for="hideCdaHeader" class="hide_cda_header_label">
									<span><xsl:value-of select="$hide"/></span>
								</label>
								
								<div class="doc_dheader">
									<xsl:call-template name="header"/>
								</div>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="header"/>
							</xsl:otherwise>
						</xsl:choose>
					</div>
					
					<div class="doc_body">	
						<xsl:call-template name="structuredBody"/>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
	
	<!-- nagłówek -->
	<xsl:template name="header">
		<xsl:call-template name="title"/>
		<xsl:call-template name="headerElements"/>
		<xsl:call-template name="relatedDocument"/>
		<xsl:call-template name="versionRelated"/>
		<div class="doc_header">
			<div class="doc_header_2">
				<div class="patient_related_header">					
					<xsl:call-template name="recordTarget"/>
					<xsl:call-template name="authorization"/>
					<xsl:call-template name="informant"/>
					<xsl:call-template name="reimbursementRelated"/>
					<xsl:call-template name="informationRecipient"/>
					<xsl:call-template name="componentOf"/>
					<xsl:call-template name="inFulfillmentOf"/>
				</div>
				<div class="document_related_header">
					<xsl:call-template name="legalAuthenticator"/>
					<xsl:call-template name="author"/>
					<xsl:call-template name="authenticator"/>
					<xsl:call-template name="dataEnterer"/>
					<xsl:call-template name="documentationOf"/>
					<xsl:call-template name="participant"/><!-- uwaga, participant płatnik wyświetlany jest niezależnie w ramach reimbursementRelated -->
					<xsl:call-template name="custodian"/>
				</div>
			</div>
		</div>
	</xsl:template>
	
	<!-- tytuł dokumentu -->
	<xsl:template name="title">
		<div class="doc_title">
			<!-- element title jest zawsze wymagany w PL IG -->
			<span class="title_label">
				<xsl:value-of select="hl7:title"/>
			</span>
			<xsl:choose>
				<xsl:when test="hl7:code/hl7:translation[@code='04.12']/hl7:qualifier/hl7:name[@code='RRREC']">
					<!-- Rodzaj realizacji recepty i opcjonalnie awaryjny tryb jej realizacji -->
					<xsl:variable name="suffix_class">
						<xsl:text>title_suffix</xsl:text>
						<xsl:if test="hl7:code/hl7:translation[@code='04.12']/hl7:qualifier/hl7:name[@code='RRREC']/../hl7:value/@code = 'W'">
							<xsl:text> highlighted</xsl:text>
						</xsl:if>
					</xsl:variable>
					
					<span class="{$suffix_class}">
						<xsl:text>(</xsl:text>
						<xsl:value-of select="hl7:code/hl7:translation[@code='04.12']/hl7:qualifier/hl7:name[@code='RRREC']/../hl7:value/@displayName"/>
						<!-- Rodzaj realizacji recepty jest obowiązkowy dla dokumentu realizacji recepty, stąd awaryjny tryb wydania leku jedynie dopisuję do rodzaju -->
						<xsl:if test="hl7:code/hl7:translation[@code='04.12']/hl7:qualifier/hl7:name[@code='TWLEK']/../hl7:value/@code = 'A'">
							<xsl:text>, </xsl:text>
							<span class="toned">
								<xsl:text>awaryjnie</xsl:text>
							</span>
						</xsl:if>
						<xsl:text>)</xsl:text>
					</span>
				</xsl:when>
				<xsl:when test="hl7:code/hl7:translation[@code='04.01']/hl7:qualifier/hl7:name[@code='RRECE']/../hl7:value[@code='PA']"> 
					<span class="title_suffix" style="font-style: italic">
						<xsl:text>pro auctore</xsl:text>
					</span>
				</xsl:when>
				<xsl:when test="hl7:code/hl7:translation[@code='04.01']/hl7:qualifier/hl7:name[@code='RRECE']/../hl7:value[@code='PF']"> 
					<span class="title_suffix" style="font-style: italic">
						<xsl:text>pro familiae</xsl:text>
					</span>
				</xsl:when>
				<xsl:when test="hl7:code/hl7:translation[@code='04.01']/hl7:qualifier/hl7:name[@code='RRECE']/../hl7:value[@code='TG']"> 
					<span class="title_suffix" style="font-style: italic">
						<xsl:text>transgraniczna</xsl:text>
					</span>
				</xsl:when>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- effectiveTime oraz id -->
	<xsl:template name="headerElements">
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="effectiveDateLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Effective date</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Data wystawienia</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<div class="doc_header_elements">
			<xsl:call-template name="dateTimeInDiv">
				<xsl:with-param name="date" select="hl7:effectiveTime"/>
				<xsl:with-param name="label" select="$effectiveDateLabel"/>
				<xsl:with-param name="divClass">effective_time_header_element doc_header_element header_element</xsl:with-param>
			</xsl:call-template>
			
			<div class="id_header_element doc_header_element header_element">
				<span class="header_label">
					<xsl:text>ID</xsl:text>
				</span>
				<div class="header_inline_value header_value id_header_value">
					<xsl:call-template name="identifierOID">
						<xsl:with-param name="id" select="hl7:id"/>
						<xsl:with-param name="knownOnly" select="false()"/>
					</xsl:call-template>
				</div>
			</div>
		</div>
	</xsl:template>
	
	<!-- setId oraz versionNumber -->
	<xsl:template name="versionRelated">
		<!-- polskie recepty i zlecenia nie są wersjonowane (tj. nie mogą być korygowane, posiadają wersję 1), pozostałe typy dokumentów tak -->
		<xsl:if test="not(hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.3' 
						or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.6' 
						or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.7' 
						or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.8' 
						or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.26' 
						or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.5')">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
			<xsl:variable name="versionLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Version</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Wersja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="setIdLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Set ID</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>ID zbioru wersji</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<div class="doc_header_elements">
				<div class="version_header_element doc_header_element header_element">
					<span class="header_label">
						<xsl:value-of select="$versionLabel"/>
					</span>
					<xsl:choose>
						<xsl:when test="hl7:versionNumber/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="hl7:versionNumber"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<div class="header_inline_value header_value">
								<xsl:value-of select="hl7:versionNumber/@value"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="value_set_header_element doc_header_element header_element">
					<span class="header_label">
						<xsl:value-of select="$setIdLabel"/>
					</span>
					<div class="header_inline_value header_value id_header_value">
						<xsl:call-template name="identifierOID">
							<xsl:with-param name="id" select="hl7:setId"/>
							<xsl:with-param name="knownOnly" select="false()"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- relatedDocument 2.16.840.1.113883.3.4424.13.10.2.7 -->
	<xsl:template name="relatedDocument">
		<!-- dla dokumentów przechowywanych poza P1 krotność maksymalna to 2 -->
		<xsl:if test="hl7:relatedDocument">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
			<div class="doc_header_elements">
				<div class="related_document_header_element doc_header_element header_element">
					<xsl:for-each select="hl7:relatedDocument">
						<span class="header_label">
							<xsl:call-template name="translateRelatedDocumentCode">
								<xsl:with-param name="typeCode" select="./@typeCode"/>
								<xsl:with-param name="lang" select="$lang"/>
							</xsl:call-template>
						</span>
						<div class="header_inline_value header_value">
							<xsl:call-template name="identifierOID">
								<xsl:with-param name="id" select="./hl7:parentDocument/hl7:id"/>
								<xsl:with-param name="knownOnly" select="false()"/>
							</xsl:call-template>
						</div>
						<xsl:if test="position()!=last()">
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
	</xsl:template>	
	
	<!-- Osoba autoryzująca dokument legalAuthenticator: templateId 2.16.840.1.113883.3.4424.13.10.2.6 oraz 2.16.840.1.113883.3.4424.13.10.2.63 -->
	<xsl:template name="legalAuthenticator">
		
		<xsl:variable name="legalAuthenticator" select="hl7:legalAuthenticator"/>
		<!-- jeżeli dane wystawcy dokumentu zawarte są w jednym z elementów author, to wskazanie który z autorów jest wystawcą realizuje się poprzez umieszczenie co najmniej identyfikatora tego autora w elemencie legalAuthenticator -->
		<xsl:variable name="legalAuthor" select="/hl7:ClinicalDocument/hl7:author[hl7:assignedAuthor/hl7:id[@root=$legalAuthenticator/hl7:assignedEntity/hl7:id/@root and @extension=$legalAuthenticator/hl7:assignedEntity/hl7:id/@extension]]"/>
		<!-- w PIK 1.3.1(.2) dodano obsługę danych asystenta medycznego 2.16.840.1.113883.3.4424.13.10.2.90, proponując, by jeżeli id jedno i to samo, wyświetlać dane dataEnterera w tym miejscu. Jednak w takiej sytuacji legalAuthenticator również powinien zawierać wszystkie informacje o wystawcy, pomijane w wyświetlaniu -->
		<xsl:variable name="legalEnterer" select="/hl7:ClinicalDocument/hl7:dataEnterer[hl7:assignedEntity/hl7:id[@root=$legalAuthenticator/hl7:assignedEntity/hl7:id/@root and @extension=$legalAuthenticator/hl7:assignedEntity/hl7:id/@extension]]"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:variable name="legalAuthenticatorLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Legal authenticator</xsl:text>
				</xsl:when>
				<xsl:when test="/hl7:ClinicalDocument/hl7:dataEnterer/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.90' and $legalEnterer">
					<xsl:text>Asystent medyczny</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Wystawca dokumentu</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="organizationLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Organization</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Miejsce wystawienia</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- dane umowy wyłącznie w danych autora. Dotyczy realizacji recept, wyświetlane wyłącznie gdy autor jest jednocześnie legalAuthenticatorem -->
		<xsl:variable name="reimbursementRelatedContract">
			<!-- numer umowy z NFZ templateId 2.16.840.1.113883.3.4424.13.10.2.44 -->
			<xsl:if test="$legalAuthor/hl7:assignedAuthor/extPL:boundedBy">
				<div class="reimbursement_related_contract_element header_element">
					<xsl:choose>
						<xsl:when test="$legalAuthor/hl7:assignedAuthor/extPL:boundedBy/extPL:reimbursementRelatedContract/extPL:id/@nullFlavor">
							<span class="header_label">
								<xsl:choose>
									<xsl:when test="$lang = $secondLanguage">
										<xsl:text>NFZ contract number</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Numer umowy z NFZ</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</span>
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$legalAuthor/hl7:assignedAuthor/extPL:boundedBy/extPL:reimbursementRelatedContract/extPL:id"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<span class="header_label">
								<xsl:call-template name="translateReimbursementRelatedContractId">
									<xsl:with-param name="oid" select="$legalAuthor/hl7:assignedAuthor/extPL:boundedBy/extPL:reimbursementRelatedContract/extPL:id/@root"/>
								</xsl:call-template>
							</span>
							<div class="header_inline_value header_value">
								<xsl:value-of select="$legalAuthor/hl7:assignedAuthor/extPL:boundedBy/extPL:reimbursementRelatedContract/extPL:id/@extension"/>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
		</xsl:variable>
		
		<xsl:choose>
			<!-- standardowy przypadek, dane legalAuthenticatora zapisane w danych jednego z autorów -->
			<xsl:when test="$legalAuthor">
				<xsl:call-template name="assignedEntity">
					<xsl:with-param name="entity" select="$legalAuthor/hl7:assignedAuthor"/>
					<xsl:with-param name="blockClass">header_block</xsl:with-param>
					<xsl:with-param name="blockLabel" select="$legalAuthenticatorLabel"/>
					<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
					<xsl:with-param name="knownIdentifiersOnly" select="true()"/>
					<xsl:with-param name="addToLevel1" select="$reimbursementRelatedContract"/>
					<xsl:with-param name="hideSecondOrgLevel" select="true()"/>
				</xsl:call-template>
			</xsl:when>
			<!-- przypadek asystenta medycznego, bez danych organizacji i bez boundedBy -->
			<xsl:when test="/hl7:ClinicalDocument/hl7:dataEnterer/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.90' and $legalEnterer">
				<xsl:call-template name="assignedEntity">
					<xsl:with-param name="entity" select="$legalEnterer/hl7:assignedEntity"/>
					<xsl:with-param name="blockClass">header_block</xsl:with-param>
					<xsl:with-param name="blockLabel" select="$legalAuthenticatorLabel"/>
					<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
					<xsl:with-param name="knownIdentifiersOnly" select="true()"/>
					<xsl:with-param name="addToLevel1" select="$reimbursementRelatedContract"/>
					<xsl:with-param name="hideSecondOrgLevel" select="true()"/>
				</xsl:call-template>
			</xsl:when>
			<!-- przypadek, w którym legalAuthenticator nie jest autorem (tylko np. asystentem med. zapisanym dodatkowo w dataEnterer), a wszystkie jego dane zapisane są w jego własnym elemencie -->
			<xsl:otherwise>
				<xsl:call-template name="assignedEntity">
					<xsl:with-param name="entity" select="$legalAuthenticator/hl7:assignedEntity"/>
					<xsl:with-param name="blockClass">header_block</xsl:with-param>
					<xsl:with-param name="blockLabel" select="$legalAuthenticatorLabel"/>
					<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
					<xsl:with-param name="knownIdentifiersOnly" select="true()"/>
					<xsl:with-param name="hideSecondOrgLevel" select="true()"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- recordTarget templateId 2.16.840.1.113883.3.4424.13.10.2.3 -->
	<xsl:template name="recordTarget">
		<xsl:variable name="patientRole" select="hl7:recordTarget/hl7:patientRole"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="patientLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Patient</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Pacjent</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dateOfBirthLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Date of birth</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Data urodzenia</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="multipleBirthOrderNumberLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Multiple birth order no</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Numer kolejny urodzenia</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="addressLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Address</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Adres</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="nameOfFatherLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Name of father</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Imię ojca</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="nameOfMotherLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Name of mother</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Imię matki</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="nameOfClosePersonLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Name of close person</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Imię osoby bliskiej</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<div class="header_block">
			<span class="record_target_block_label header_block_label">
				<xsl:value-of select="$patientLabel"/>
			</span>
			
			<xsl:choose>
				<xsl:when test="hl7:recordTarget/@nullFlavor">
					<xsl:call-template name="translateNullFlavor">
						<xsl:with-param name="nullableElement" select="hl7:recordTarget"/>
					</xsl:call-template>
					<xsl:call-template name="confidentialityCode">
						<xsl:with-param name="cCode" select="hl7:confidentialityCode"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$patientRole/@nullFlavor">
					<xsl:call-template name="translateNullFlavor">
						<xsl:with-param name="nullableElement" select="$patientRole"/>
					</xsl:call-template>
					<xsl:call-template name="confidentialityCode">
						<xsl:with-param name="cCode" select="hl7:confidentialityCode"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- poziom wrażliwości dokumentu (poza template), dane dokumentu są danymi wrażliwymi z perspektywy pacjenta -->
					<xsl:call-template name="confidentialityCode">
						<xsl:with-param name="cCode" select="hl7:confidentialityCode"/>
					</xsl:call-template>
					
					<!-- istnieją dane wyłącznie jednego pacjenta w każdym dokumencie zgodnym z PL IG -->
					<!-- imiona i nazwiska pacjenta -->
					<xsl:call-template name="person">
						<xsl:with-param name="person" select="$patientRole/hl7:patient"></xsl:with-param>
					</xsl:call-template>
					
					<!-- identyfikatory pacjenta elementu patientRole, identyfikatory elementu patient nie są stosowane -->
					<xsl:call-template name="identifiersInDiv">
						<xsl:with-param name="ids" select="$patientRole/hl7:id"/>
						<xsl:with-param name="knownOnly" select="true()"/>
					</xsl:call-template>
					
					<!-- data urodzenia -->
					<xsl:call-template name="dateTimeInDiv">
						<xsl:with-param name="date" select="$patientRole/hl7:patient/hl7:birthTime"/>
						<xsl:with-param name="label" select="$dateOfBirthLabel"/>
						<xsl:with-param name="divClass">header_element</xsl:with-param>
						<xsl:with-param name="calculateAge" select="true()"/>
					</xsl:call-template>
					
					<!-- wyróżnik w przypadku noworodka z ciąży mnogiej -->
					<xsl:if test="$patientRole/hl7:patient/extPL:multipleBirthInd/@value and $patientRole/hl7:patient/extPL:multipleBirthOrderNumber">
						<div class="header_element">
							<span class="header_label">
								<xsl:value-of select="$multipleBirthOrderNumberLabel"/>
							</span>
							<div class="header_inline_value header_value">
								<xsl:choose>
									<xsl:when test="$patientRole/hl7:patient/extPL:multipleBirthOrderNumber/@nullFlavor">
										<xsl:call-template name="translateNullFlavor">
											<xsl:with-param name="nullableElement" select="$patientRole/hl7:patient/extPL:multipleBirthOrderNumber"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$patientRole/hl7:patient/extPL:multipleBirthOrderNumber/@value"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</xsl:if>
					
					<xsl:call-template name="birthPlace">
						<xsl:with-param name="birthPlace" select="$patientRole/hl7:patient/hl7:birthplace"/>
					</xsl:call-template>
					
					<!-- elementy martialStatusCode, religiousAffiliationCode, raceCode, ethnicGroupCode, languageCommunication nie są wyświetlane -->
					
					<!-- płeć -->
					<xsl:call-template name="translateGenderCode">
						<xsl:with-param name="genderCode" select="$patientRole/hl7:patient/hl7:administrativeGenderCode"/>
					</xsl:call-template>
					
					<!-- dane osób bliskich, polskie rozszerzenie na potrzeby skierowania do szpitala psychiatrycznego -->
					<xsl:if test="$patientRole/hl7:patient/extPL:personalRelationship/extPL:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.9'">
						<xsl:for-each select="$patientRole/hl7:patient/extPL:personalRelationship">
							<div class="header_element">
								<span class="header_label">
									<xsl:choose>
										<xsl:when test="./extPL:code/@nullFlavor">
											<xsl:value-of select="$nameOfClosePersonLabel"/>
										</xsl:when>
										<xsl:when test="./extPL:code/@code = 'MTH'">
											<xsl:value-of select="$nameOfMotherLabel"/>
										</xsl:when>
										<xsl:when test="./extPL:code/@code = 'FTH'">
											<xsl:value-of select="$nameOfFatherLabel"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$nameOfClosePersonLabel"/>
										</xsl:otherwise>
									</xsl:choose>
								</span>
								<div class="header_inline_value header_value">
									<xsl:choose>
										<xsl:when test="./@nullFlavor">
											<xsl:call-template name="translateNullFlavor">
												<xsl:with-param name="nullableElement" select="."/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="./extPL:person/@nullFlavor">
											<xsl:call-template name="translateNullFlavor">
												<xsl:with-param name="nullableElement" select="./extPL:person"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="./extPL:person/extPL:name/@nullFlavor">
											<xsl:call-template name="translateNullFlavor">
												<xsl:with-param name="nullableElement" select="./extPL:person/extPL:name"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="./extPL:person/extPL:name/hl7:given/@nullFlavor">
											<xsl:call-template name="translateNullFlavor">
												<xsl:with-param name="nullableElement" select="./extPL:person/extPL:name/hl7:given"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="./extPL:person/extPL:name/hl7:given"/>
										</xsl:otherwise>
									</xsl:choose>
								</div>
							</div>
						</xsl:for-each>
					</xsl:if>
					
					<!-- część dokumentów wymaga podania adresu, przynajmniej z oznaczeniem nullFlavor (w recepcie poniższy if zawsze będzie true, w realizacji recepty nie zawsze).
						 Brak adresu stosowany jest przede wszystkim w realizacjach recept papierowych, węzeł ten jest w takim przypadku pomijany, poniższy if jest false -->
					<xsl:if test="count($patientRole/hl7:addr) &gt; 0">
						<xsl:choose>
							<!-- dane adresowe i kontaktowe pacjenta, przy czym nullFlavor w adresie pacjenta 
								 w receptach, realizacjach recept, skierowaniach i zleceniach wyświetlany jest wyjątkowo jako NMZ -->
							<xsl:when test="(  hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.3' 
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.4' 
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.5'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.6'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.7'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.8'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.9'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.10'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.11'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.12'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.13'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.26'
											or hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.1.27')
										and count($patientRole/hl7:addr[not(@nullFlavor)]) = 0">
								<div class="header_element">
									<span class="header_label">
										<xsl:value-of select="$addressLabel"/>
									</span>
									<!-- kod ustalony legislacyjnie, nie podlega tłumaczeniu -->
									<xsl:text> NMZ</xsl:text>
								</div>
								<xsl:call-template name="addressTelecomInDivs">
									<xsl:with-param name="telecom" select="$patientRole/hl7:telecom"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="addressTelecomInDivs">
									<xsl:with-param name="addr" select="$patientRole/hl7:addr"/>
									<xsl:with-param name="telecom" select="$patientRole/hl7:telecom"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					
					<!-- providerOrganization - nie są wyświetlane dane właściciela rekordu medycznego, z którego pochodzą dane pacjenta
					<xsl:if test="$patientRole/hl7:providerOrganization/hl7:id or $patientRole/hl7:providerOrganization/hl7:name">
						<xsl:call-template name="organization">
							<xsl:with-param name="organization" select="$patientRole/hl7:providerOrganization"/>
							<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
							<xsl:with-param name="level" select="1"/>
							<xsl:with-param name="level1BlockLabel">Właściciel rekordu medycznego</xsl:with-param>
							<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
						</xsl:call-template>
					</xsl:if> -->
				</xsl:otherwise>
			</xsl:choose>
		</div>
		
		<!-- opiekun -->
		<xsl:if test="$patientRole/hl7:patient/hl7:guardian">
			<xsl:call-template name="guardian">
				<xsl:with-param name="guardian" select="$patientRole/hl7:patient/hl7:guardian"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- guardian -->
	<xsl:template name="guardian">
		<xsl:param name="guardian"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="guardianLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Guardian</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Opiekun pacjenta</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="guardianOrganizationLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Guardian organization</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Instytucja opiekuna</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<div class="doc_guardian header_block">
			<span class="guardian_block_label header_block_label">
				<xsl:value-of select="$guardianLabel"/>
			</span>
			<xsl:choose>
				<xsl:when test="$guardian/@nullFlavor">
					<xsl:call-template name="translateNullFlavor">
						<xsl:with-param name="nullableElement" select="$guardian"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- istnieją dane maksymalnie jednego opiekuna: osoby lub instytucji -->
					<!-- imiona i nazwiska lub nazwa opiekuna -->
					<xsl:choose>
						<xsl:when test="$guardian/hl7:guardianPerson">
							<!-- nazwa osoby nie jest wymagana, dopuszczalne jest puste guardianPerson, w takiej sytuacji element nie wyświetla się -->
							<xsl:call-template name="person">
								<xsl:with-param name="person" select="$guardian/hl7:guardianPerson"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$guardian/hl7:guardianOrganization">
							<!-- nazwa instytucji nie jest wymagana, dopuszczale jest puste guardianOrganization, w takiej sytuacji element nie wyświetla się -->
							<xsl:if test="$guardian/hl7:guardianOrganization/hl7:name or $guardian/hl7:guardianOrganization/hl7:id[not(@displayable='false')]">
								<xsl:call-template name="organization">
									<xsl:with-param name="organization" select="$guardian/hl7:guardianOrganization"/>
									<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
									<xsl:with-param name="level" select="1"/>
									<xsl:with-param name="level1BlockLabel" select="$guardianOrganizationLabel"/>
									<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
					
					<!-- code relacji z pacjentem ze słownika 2.16.840.1.113883.5.111, nie zidentyfikowano potrzeby by wyświetlać
					<xsl:call-template name="codeInDiv">
						<xsl:with-param name="code" select="$guardian/hl7:code"/>
						<xsl:with-param name="label">Stopień pokrewieństwa</xsl:with-param>
					</xsl:call-template> -->
					
					<!-- wyświetlane są wyłącznie znane identyfikatory opiekuna -->
					<xsl:call-template name="identifiersInDiv">
						<xsl:with-param name="ids" select="$guardian/hl7:id"/>
						<xsl:with-param name="knownOnly" select="true()"/>
					</xsl:call-template>
					
					<!-- dane adresowe i kontaktowe opiekuna -->
					<xsl:call-template name="addressTelecomInDivs">
						<xsl:with-param name="addr" select="$guardian/hl7:addr"/>
						<xsl:with-param name="telecom" select="$guardian/hl7:telecom"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- participant underwriter templateId 2.16.840.1.113883.3.4424.13.10.2.19 -->
	<xsl:template name="reimbursementRelated">
		<xsl:variable name="underwriter" select="hl7:participant[hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.19']"/>
 		
		<!-- IG ogranicza ilość płatników do 1, jeśli w przyszłości dopuści się wielu płatników, każdy powinien otrzymać własny blok -->
		<xsl:if test="$underwriter"> <!-- or $entitlementDocs or $coveragePlans or $coverageEligibilityConfirmation"> --> 
			<div class="doc_underwriter header_block">
				<xsl:call-template name="underwriter">
					<xsl:with-param name="underwriter" select="$underwriter"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- płatnik templateId 2.16.840.1.113883.3.4424.13.10.2.19 -->
	<xsl:template name="underwriter">
		<xsl:param name="underwriter"/>
		
		<!-- IG wymusza jeden znany identyfikator o wartości root:
				- 2.16.840.1.113883.3.4424.3.1 - numer oddziału NFZ
				- 2.16.840.1.113883.3.4424.11.1.49 - kod kraju płatnika wg przepisów o koordynacji -->
		<xsl:if test="$underwriter and count($underwriter) = 1">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="underwriterLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Underwriter</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Płatnik</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- poniższy div nie jest blokiem ani elementem, pełni rolę header_block
				 dla coverageEligibilityConfirmation, coveragePlan, entitlementDoc, teoretycznie może też nie istnieć -->
			<div>
				<span class="underwriter_block_label header_block_label">
					<xsl:value-of select="$underwriterLabel"/>
				</span>
				<div class="underwriter_id_value header_inline_value header_value">
					<xsl:choose>
						<xsl:when test="$underwriter/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$underwriter"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$underwriter/hl7:associatedEntity/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$underwriter/hl7:associatedEntity"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$underwriter/hl7:associatedEntity/hl7:id/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$underwriter/hl7:associatedEntity/hl7:id"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="identifierOID">
								<xsl:with-param name="id" select="$underwriter/hl7:associatedEntity/hl7:id"/>
								<xsl:with-param name="knownOnly" select="true()"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	
	<!-- custodian templateId 2.16.840.1.113883.3.4424.13.10.2.5 oraz 2.16.840.1.113883.3.4424.13.10.2.20 -->
	<xsl:template name="custodian">
		<xsl:variable name="custodian" select="hl7:custodian/hl7:assignedCustodian/hl7:representedCustodianOrganization"/>
		
		<!-- wyświetlane są wyłącznie dane kustosza, dla którego możliwe jest wyświetlenie identyfikatora lub nazwy
			 brak obsługi nullFlavor w całym elemencie, 
			 informacja o kustoszu zawsze jest wymagana, znajduje się w dokumencie także gdy nie jest wyświetlana -->
		<xsl:if test="$custodian and (not($custodian/hl7:id/@displayable='false') or string-length($custodian/hl7:name) &gt;= 1)">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="custodianLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Custodian</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Kustosz</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="nameLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Name</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Nazwa</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="doc_custodian header_block">
				<span class="custodian_block_label header_block_label">
					<xsl:value-of select="$custodianLabel"/>
				</span>
				
				<xsl:call-template name="identifiersInDiv">
					<xsl:with-param name="ids" select="$custodian/hl7:id"/>
				</xsl:call-template>
				
				<xsl:if test="string-length($custodian/hl7:name) &gt;= 1">
					<div class="header_element">
						<span class="header_label">
							<xsl:value-of select="$nameLabel"/>
						</span>
						<div class="header_inline_value header_value">
							<xsl:value-of select="$custodian/hl7:name"/>
						</div>
					</div>
				</xsl:if>
				
				<!-- dane adresowe i kontaktowe kustosza -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$custodian/hl7:addr"/>
					<xsl:with-param name="telecom" select="$custodian/hl7:telecom"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- informantionRecipient templateId 2.16.840.1.113883.3.4424.13.10.2.61 liczność 0..* -->
	<xsl:template name="informationRecipient">
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:variable name="prcpLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Intended recipient</xsl:text>
				</xsl:when>
				<!-- wyjątek dla skierowań, gdyż adresat dokumentu jest sugerowanym pacjentowi realizatorem skierowania -->
				<xsl:when test="hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.4']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.9']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.10']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.11']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.12']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.13']">
					<xsl:text>Sugerowane miejsce realizacji</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Adresat dokumentu</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="trcLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Secondary recipient</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Dodatkowy adresat dokumentu</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="prcpOrganizationLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Intended recipient organization</xsl:text>
				</xsl:when>
				<!-- wyjątek dla skierowań podobnie jak w przypadku samego realizatora skierowania -->
				<xsl:when test="hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.4']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.9']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.10']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.11']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.12']
							or hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.1.13']">
					<xsl:text>Instytucja realizatora</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Instytucja adresata</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- każdy odbiorca wyświetlany niezależnie, w kolejności jak w dokumencie XML, 
			 bez zwijania treści (treść jest istotna dla czytelnika już na pierwszy rzut oka, jeżeli podano) -->
		<xsl:for-each select="hl7:informationRecipient">
			<xsl:choose>
				<xsl:when test="./@nullFlavor">
					<div class="header_block">
						<span class="header_block_label">
							<xsl:choose>
								<xsl:when test="./@typeCode = 'TRC'">
									<xsl:value-of select="$trcLabel"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$prcpLabel"/>
								</xsl:otherwise>
							</xsl:choose>
						</span>
						<xsl:call-template name="translateNullFlavor">
							<xsl:with-param name="nullableElement" select="."/>
						</xsl:call-template>
					</div>
				</xsl:when>
				<!-- typ adresata: dodatkowy TRC -->
				<xsl:when test="./@typeCode = 'TRC'">
					<xsl:call-template name="assignedEntity">
						<xsl:with-param name="entity" select="./hl7:intendedRecipient"/>
						<xsl:with-param name="context">intendedRecipient</xsl:with-param>
						<xsl:with-param name="blockClass">header_block</xsl:with-param>
						<xsl:with-param name="blockLabel" select="$trcLabel"/>
						<xsl:with-param name="organizationLevel1BlockLabel" select="$prcpOrganizationLabel"/>
						<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
					</xsl:call-template>
				</xsl:when>
				<!-- podobnie obsłużono typ główny PRCP, różnicą jest etykieta, istnieją tylko dwa typy: PRCP i TRC -->
				<xsl:otherwise>
					<xsl:call-template name="assignedEntity">
						<xsl:with-param name="entity" select="./hl7:intendedRecipient"/>
						<xsl:with-param name="context">intendedRecipient</xsl:with-param>
						<xsl:with-param name="blockClass">header_block</xsl:with-param>
						<xsl:with-param name="blockLabel" select="$prcpLabel"/>
						<xsl:with-param name="organizationLevel1BlockLabel" select="$prcpOrganizationLabel"/>
						<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<!-- componentOf, dane wizyty lub pobytu 2.16.840.1.113883.3.4424.13.10.2.52, 2.16.840.1.113883.3.4424.13.10.2.66, 2.16.840.1.113883.3.4424.13.10.2.69 -->
	<xsl:template name="componentOf">
		<xsl:variable name="encounter" select="hl7:componentOf/hl7:encompassingEncounter"/>
		
		<!-- maksymalnie jedno zdarzenie medyczne jest dopuszczalne w dokumencie medycznym -->
		<xsl:if test="$encounter">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="encounterLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Encounter</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Wizyta, pobyt, zdarzenie medyczne</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="dateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="encounterCodeLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Specialty</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Specjalność placówki</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="dischargeDispositionLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Discharge disposition code</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Tryb wypisu</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			
			<div class="doc_component_of header_block">
				<span class="component_of_block_label header_block_label">
					<xsl:value-of select="$encounterLabel"/>
				</span>
				<xsl:choose>
					<xsl:when test="hl7:componentOf/@nullFlavor">
						<xsl:call-template name="translateNullFlavor">
							<xsl:with-param name="nullableElement" select="hl7:componentOf"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$encounter/@nullFlavor">
						<xsl:call-template name="translateNullFlavor">
							<xsl:with-param name="nullableElement" select="$encounter"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="identifiersInDiv">
							<xsl:with-param name="ids" select="$encounter/hl7:id"/>
						</xsl:call-template>
						
						<!-- specjalność placówki, tj. VIII część kodu resortowego -->
						<xsl:call-template name="codeInDiv">
							<xsl:with-param name="code" select="$encounter/hl7:code"/>
							<xsl:with-param name="label" select="$encounterCodeLabel"/>
						</xsl:call-template>
						
						<xsl:call-template name="dateTimeInDiv">
							<xsl:with-param name="date" select="$encounter/hl7:effectiveTime"/>
							<xsl:with-param name="label" select="$dateLabel"/>
							<xsl:with-param name="divClass">header_element</xsl:with-param>
						</xsl:call-template>
						
						<xsl:call-template name="codeInDiv">
							<!-- wyłącznie value set 2.16.840.1.113883.3.4424.13.11.36 ze słownika 2.16.840.1.113883.3.4424.11.3.21 Tryb wypisu ze szpitala,
								 podane w value set nazwy wyświetlania powodują wymuszenie wartości displayName w kodzie w dokumencie -->
							<xsl:with-param name="code" select="$encounter/hl7:dischargeDispositionCode"/>
							<xsl:with-param name="label" select="$dischargeDispositionLabel"/>
						</xsl:call-template>
						
						<!-- location (healthcareFacility z place lub organization) 0:1 -->
						<xsl:call-template name="location">
							<xsl:with-param name="location" select="$encounter/hl7:location"/>
						</xsl:call-template>
						
						<!-- responsibleParty 0:1 -->
						<xsl:if test="$encounter/hl7:responsibleParty/hl7:assignedEntity">
							<xsl:variable name="responsiblePartyOrganizationLabel">
								<xsl:choose>
									<xsl:when test="$lang = $secondLanguage">
										<xsl:text>Organization</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Instytucja osoby odpowiedzialnej</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="responsiblePartyLabel">
								<xsl:choose>
									<xsl:when test="$lang = $secondLanguage">
										<xsl:text>Responsible party</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Osoba odpowiedzialna</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<div class="header_block0">
								<span class="header_block_label">
									<xsl:value-of select="$responsiblePartyLabel"/>
								</span>
								
								<xsl:call-template name="showDheaderEnabler">
									<xsl:with-param name="blockName">responsible_party</xsl:with-param>
								</xsl:call-template>
								
								<div class="header_dheader">
									<xsl:call-template name="assignedEntity">
										<xsl:with-param name="entity" select="$encounter/hl7:responsibleParty/hl7:assignedEntity"/>
										<xsl:with-param name="blockClass">header_block</xsl:with-param>
										<xsl:with-param name="blockLabel"/>
										<xsl:with-param name="organizationLevel1BlockLabel" select="$responsiblePartyOrganizationLabel"/>
										<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
									</xsl:call-template>
								</div>
							</div>						
						</xsl:if>
						
						<!-- encounterParticipant 0:* -->
						<xsl:if test="count($encounter/hl7:encounterParticipant) &gt; 0">
							<xsl:variable name="participantOrganizationLabel">
								<xsl:choose>
									<xsl:when test="$lang = $secondLanguage">
										<xsl:text>Organization</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Instytucja osoby uczestniczącej</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="participantLabel">
								<xsl:choose>
									<xsl:when test="count($encounter/hl7:encounterParticipant) = 1 and $lang = $secondLanguage">
										<xsl:text>Encounter participant</xsl:text>
									</xsl:when>
									<xsl:when test="count($encounter/hl7:encounterParticipant) &gt; 1 and $lang = $secondLanguage">
										<xsl:text>Encounter participants</xsl:text>
									</xsl:when>
									<xsl:when test="count($encounter/hl7:encounterParticipant) = 1">
										<xsl:text>Osoba uczestnicząca</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Osoby uczestniczące</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="participantDateLabel">
								<xsl:choose>
									<xsl:when test="$lang = $secondLanguage">
										<xsl:text>Date</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Data</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:variable name="participantRoleLabel">
								<xsl:choose>
									<xsl:when test="$lang = $secondLanguage">
										<xsl:text>Role</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>Rola</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>							
							
							<div class="header_block0">
								<span class="header_block_label">
									<xsl:value-of select="$participantLabel"/>
								</span>
								<xsl:call-template name="showDheaderEnabler">
									<xsl:with-param name="blockName">encounter_participant</xsl:with-param>
								</xsl:call-template>
								<div class="header_dheader">
									<xsl:for-each select="$encounter/hl7:encounterParticipant">
										<xsl:variable name="typeCodeAndTime">
											<div class="header_element">
												<span class="header_label">
													<xsl:value-of select="$participantRoleLabel"/>
												</span>
												<div class="header_inline_value header_value">
													<!-- wyłącznie value set 2.16.840.1.113883.1.11.19600 Uczestnik wizyty,
														 wartości tego słownika nie zostały przetłumaczone na język polski, próba w wywoływanej translacji -->
													<xsl:call-template name="translateEncounterParticipantTypeCode">
														<xsl:with-param name="typeCode" select="./@typeCode"/>
													</xsl:call-template>
												</div>
											</div>
											
											<xsl:call-template name="dateTimeInDiv">
												<xsl:with-param name="date" select="./hl7:time"/>
												<xsl:with-param name="label" select="$participantDateLabel"/>
												<xsl:with-param name="divClass">header_element</xsl:with-param>
											</xsl:call-template>
										</xsl:variable>
										
										<xsl:call-template name="assignedEntity">
											<xsl:with-param name="entity" select="./hl7:assignedEntity"/>
											<xsl:with-param name="blockClass">header_block</xsl:with-param>
											<xsl:with-param name="blockLabel"/>
											<xsl:with-param name="organizationLevel1BlockLabel" select="$participantOrganizationLabel"/>
											<xsl:with-param name="addToLevel1" select="$typeCodeAndTime"/>
											<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
										</xsl:call-template>
									</xsl:for-each>
								</div>
							</div>		
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- documentationOf templateId 2.16.840.1.113883.3.4424.13.10.2.51 -->
	<xsl:template name="documentationOf">
		<xsl:variable name="documentationOf" select="hl7:documentationOf"/>
		
		<xsl:if test="count($documentationOf) &gt; 0">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="serviceLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Documentation of service</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Dokumentacja wykonanej usługi</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="serviceCodeLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Procedure</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Procedura</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="serviceDateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data wykonania</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Organizacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="functionLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Function</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Funkcja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- element documentationOf (procedury, w wyniku których dokument powstał) -->
			<xsl:for-each select="$documentationOf">
				<div class="doc_documentation_of header_block">
					<span class="documentation_of_block_label header_block_label">
						<xsl:value-of select="$serviceLabel"/>
					</span>
					<xsl:choose>
						<xsl:when test="./@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="."/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="./hl7:serviceEvent/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="./hl7:serviceEvent"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="identifiersInDiv">
								<xsl:with-param name="ids" select="./hl7:serviceEvent/hl7:id"/>
							</xsl:call-template>
							
							<xsl:call-template name="dateTimeInDiv">
								<xsl:with-param name="date" select="./hl7:serviceEvent/hl7:effectiveTime"/>
								<xsl:with-param name="label" select="$serviceDateLabel"/>
								<xsl:with-param name="divClass">header_element</xsl:with-param>
							</xsl:call-template>
							
							<xsl:call-template name="codeInDiv">
								<xsl:with-param name="code" select="./hl7:serviceEvent/hl7:code"/>
								<xsl:with-param name="label" select="$serviceCodeLabel"/>
							</xsl:call-template>
							
							<xsl:variable name="performers" select="./hl7:serviceEvent/hl7:performer[@typeCode = 'PPRF']"/>
							<xsl:variable name="participants" select="./hl7:serviceEvent/hl7:performer[@typeCode != 'PPRF']"/>
							
							<xsl:if test="count($performers) &gt; 0">
								<xsl:variable name="performerLabel">
									<xsl:choose>
										<xsl:when test="count($performers) = 1 and $lang = $secondLanguage">
											<xsl:text>Performer</xsl:text>
										</xsl:when>
										<xsl:when test="count($performers) &gt; 1 and $lang = $secondLanguage">
											<xsl:text>Performers</xsl:text>
										</xsl:when>
										<xsl:when test="count($performers) = 1">
											<xsl:text>Osoba wykonująca</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Osoby wykonujące</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<xsl:call-template name="servicePerformer">
									<xsl:with-param name="performerList" select="$performers"/>
									<xsl:with-param name="performerLabel" select="$performerLabel"/>
									<xsl:with-param name="organizationLabel" select="$organizationLabel"/>
									<xsl:with-param name="functionLabel" select="$functionLabel"/>
									<xsl:with-param name="serviceDateLabel" select="$serviceDateLabel"/>
									<xsl:with-param name="enableLabel" select="$enableLabel"/>
									<xsl:with-param name="enablerBlockName">service_performer_pprf</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							
							<xsl:if test="count($participants) &gt; 0">
								<xsl:variable name="performerLabel">
									<xsl:choose>
										<xsl:when test="count($participants) = 1 and $lang = $secondLanguage">
											<xsl:text>Participant</xsl:text>
										</xsl:when>
										<xsl:when test="count($participants) &gt; 1 and $lang = $secondLanguage">
											<xsl:text>Participants</xsl:text>
										</xsl:when>
										<xsl:when test="count($participants) = 1">
											<xsl:text>Osoba uczestnicząca</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Osoby uczestniczące</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<xsl:call-template name="servicePerformer">
									<xsl:with-param name="performerList" select="$participants"/>
									<xsl:with-param name="performerLabel" select="$performerLabel"/>
									<xsl:with-param name="organizationLabel" select="$organizationLabel"/>
									<xsl:with-param name="functionLabel" select="$functionLabel"/>
									<xsl:with-param name="serviceDateLabel" select="$serviceDateLabel"/>
									<xsl:with-param name="enableLabel" select="$enableLabel"/>
									<xsl:with-param name="enablerBlockName">service_performer_prf</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
	<!-- dane osoby wykonującej usługę -->
	<xsl:template name="servicePerformer">
		<xsl:param name="performerList"/>
		<xsl:param name="performerLabel"/>
		<xsl:param name="organizationLabel"/>
		<xsl:param name="functionLabel"/>
		<xsl:param name="serviceDateLabel"/>
		<xsl:param name="enableLabel"/>
		<xsl:param name="enablerBlockName"/>
		
		<div class="header_block0">
			<span class="header_block_label">
				<xsl:value-of select="$performerLabel"/>
			</span>
			<xsl:call-template name="showDheaderEnabler">
				<xsl:with-param name="blockName" select="$enablerBlockName"/>
			</xsl:call-template>
			<div class="header_dheader">
				<xsl:for-each select="$performerList">
					<xsl:call-template name="assignedEntity">
						<xsl:with-param name="entity" select="./hl7:assignedEntity"/>
						<xsl:with-param name="blockClass">header_block</xsl:with-param>
						<xsl:with-param name="blockLabel"/>
						<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
						<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
					</xsl:call-template>
					
					<xsl:if test="./hl7:functionCode">
						<div class="header_element">
							<span class="header_label">
								<xsl:value-of select="$functionLabel"/>
							</span>
							<div class="header_inline_value header_value">
								<!-- wyłącznie value set 2.16.840.1.113883.1.11.10267 Funkcja osoby w ramach usługi (np. położna) -->
								<xsl:call-template name="translateServiceEventPerformerFunctionCode">
									<xsl:with-param name="functionCode" select="./hl7:functionCode/@code"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					
					<xsl:call-template name="dateTimeInDiv">
						<xsl:with-param name="date" select="./hl7:time"/>
						<xsl:with-param name="label" select="$serviceDateLabel"/>
						<xsl:with-param name="divClass">header_element</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>
	
	<!-- inFulfillmentOf templateId 2.16.840.1.113883.3.4424.13.10.2.53 -->
	<xsl:template name="inFulfillmentOf">
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="orderLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Order</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Wykonano na podstawie zamówienia</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Type</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Rodzaj</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="priorityLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Priority</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Priorytet</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="urgentLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>urgent</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>pilne</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- element inFulfillmentOf (zlecenie/skierowanie, na podstawie którego dokument powstał) -->
		<xsl:for-each select="hl7:inFulfillmentOf">
			<div class="doc_in_fulfillment_of header_block">
				<span class="in_fulfillment_of_block_label header_block_label">
					<xsl:value-of select="$orderLabel"/>
				</span>
				<xsl:choose>
					<xsl:when test="./@nullFlavor">
						<xsl:call-template name="translateNullFlavor">
							<xsl:with-param name="nullableElement" select="."/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="./hl7:order/@nullFlavor">
						<xsl:call-template name="translateNullFlavor">
							<xsl:with-param name="nullableElement" select="./hl7:order"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<!-- identyfikator dokumentu -->
						<xsl:call-template name="identifiersInDiv">
							<xsl:with-param name="ids" select="./hl7:order/hl7:id"/>
							<xsl:with-param name="knownOnly" select="false()"/>
						</xsl:call-template>
						
						<!-- opcjonalny code z kodem słownika 2.16.840.1.113883.5.4 (nie został przetłumaczony na język polski) wyświetlany jest z dokumentu -->
						<xsl:call-template name="codeInDiv">
							<xsl:with-param name="code" select="./hl7:order/hl7:code"/>
							<xsl:with-param name="label" select="codeLabel"/>
						</xsl:call-template>
						
						<!-- kod pilności wyświetlany jest jedynie dla wartości z valueSet 2.16.840.1.113883.3.4424.13.11.26: UR, tj. pilne, 
							 wartość R normalna nie jest wyświetlana, pozostałe dopuszczalne template wartości są pomijane -->
						<xsl:if test="./hl7:order/hl7:priorityCode/@code = 'UR' and not(./hl7:order/hl7:priorityCode/@nullFlavor)">
							<div class="header_element">
								<span class="header_label">
									<xsl:value-of select="$priorityLabel"/>
								</span>
								<div class="urgent_priority_code_value header_inline_value header_value">
									<xsl:value-of select="$urgentLabel"/>
								</div>
							</div>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:for-each>
	</xsl:template>
	
	<!-- dataEnterer, dane osoby wypełniającej dokument wyświetlane są w do rozwinięcia -->
	<xsl:template name="dataEnterer">
		<xsl:variable name="dataEnterer" select="hl7:dataEnterer"/>
		<xsl:variable name="legalAuthenticator" select="hl7:legalAuthenticator"/>
		
		<!-- maksymalnie jeden możliwy wprowadzający dane, a w przypadku asystenta medycznego 2.16.840.1.113883.3.4424.13.10.2.90 - z jednym możliwym identyfikatorem,
			 dodatkowo, jeżeli dataEnterer jest jednocześnie legalAuthenticatorem (podpisał dokument) a jego dane podano w ramach szablonu asystenta medycznego 2.90,
			 to legalAuthenticator jest wystawcą dokumentu, dane autora/autorów oznaczone są etykietą "w imieniu", a samego dataEnterer nie wyświetla się jeżeli podano po jednym, takim samym id -->
		<xsl:if test="$dataEnterer and not($dataEnterer/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.90' and 
										$dataEnterer/hl7:assignedEntity/hl7:id/@extension = $legalAuthenticator/hl7:assignedEntity/hl7:id/@extension and 
										$dataEnterer/hl7:assignedEntity/hl7:id/@root = $legalAuthenticator/hl7:assignedEntity/hl7:id/@root)">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Organizacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="transcriptionDateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Transcription date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data wprowadzenia</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="dataEntererLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Data enterer</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Wprowadzający dane</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="header_block">
				<span class="header_block_label">
					<xsl:value-of select="$dataEntererLabel"/>
				</span>
				<xsl:call-template name="showDheaderEnabler">
					<xsl:with-param name="blockName">data_enterer</xsl:with-param>
				</xsl:call-template>
				<div class="header_dheader">
					<xsl:call-template name="assignedEntity">
						<xsl:with-param name="entity" select="$dataEnterer/hl7:assignedEntity"/>
						<xsl:with-param name="blockClass"/>
						<xsl:with-param name="blockLabel"/>
						<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
						<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
					</xsl:call-template>
					
					<!-- data wprowadzenia -->
					<xsl:call-template name="dateTimeInDiv">
						<xsl:with-param name="date" select="$dataEnterer/hl7:time"/>
						<xsl:with-param name="label" select="$transcriptionDateLabel"/>
						<xsl:with-param name="divClass">header_element</xsl:with-param>
						<xsl:with-param name="calculateAge" select="false()"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!--  authenticator, osoby poświadczające -->
	<xsl:template name="authenticator">
		<xsl:variable name="authenticator" select="hl7:authenticator"/>
		
		<xsl:if test="count($authenticator) &gt; 0">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
			<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Organizacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="authenticatorDateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="authenticatorLabel">
				<xsl:choose>
					<xsl:when test="count($authenticator) = 1 and $lang = $secondLanguage">
						<xsl:text>Authenticator</xsl:text>
					</xsl:when>
					<xsl:when test="count($authenticator) &gt; 1 and $lang = $secondLanguage">
						<xsl:text>Authenticators</xsl:text>
					</xsl:when>
					<xsl:when test="count($authenticator) = 1">
						<xsl:text>Poświadczający</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Poświadczający</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="header_block">
				<span class="header_block_label">
					<xsl:value-of select="$authenticatorLabel"/>
				</span>
				<xsl:call-template name="showDheaderEnabler">
					<xsl:with-param name="blockName">authenticator</xsl:with-param>
				</xsl:call-template>
				<div class="header_dheader">
					<xsl:for-each select="$authenticator">
						<xsl:call-template name="assignedEntity">
							<xsl:with-param name="entity" select="./hl7:assignedEntity"/>
							<xsl:with-param name="blockClass">header_block</xsl:with-param>
							<xsl:with-param name="blockLabel"/>
							<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
							<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
						</xsl:call-template>
						
						<xsl:call-template name="dateTimeInDiv">
							<xsl:with-param name="date" select="./hl7:time"/>
							<xsl:with-param name="label" select="$authenticatorDateLabel"/>
							<xsl:with-param name="divClass">header_element</xsl:with-param>
							<xsl:with-param name="calculateAge" select="false()"/>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- author templateId 2.16.840.1.113883.3.4424.13.10.2.4 oraz autor recepty 2.16.840.1.113883.3.4424.13.10.2.82 (w tym pro auctore/familia bez organizacji, z wymuszonym 1 adresem/tel ), i inne szablony autorów -->
	<xsl:template name="author">
		<!-- lista autorów za wyjątkiem autora będącego jednocześnie wystawcą dokumentu. Zgodnie z HL7 CDA autor może być osobą lub urządzeniem (w polskim IG urządzenie nie jest tu dopuszczalne, jednak zaimplementowano tę część na wypadek konieczności wyświetlenia dokumentu zewnętrznego -->
		<!-- nazewnictwo w etykiecie:
			- jeżeli 1 autor jest też legalAuth, to drugi autor to "Współautor", drugi i kolejni to "Współautorzy"
			- jeżeli żaden autor nie jest legalAuth, ani nie ma asystenta med, to jeden autor to "Autor", więcej autorów to "Autorzy"
			- jeżeli asystent medyczny (data enterer) jest też legalAuth, dla autora lub autorów stosuje się etykietę "Wystawiono w imieniu" -->
		<xsl:variable name="author" select="/hl7:ClinicalDocument/hl7:author[not(hl7:assignedAuthor/hl7:id[@root=/hl7:ClinicalDocument/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@root and @extension=/hl7:ClinicalDocument/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@extension])]"/>
		<xsl:variable name="allAuthors" select="/hl7:ClinicalDocument/hl7:author"/>
		<xsl:variable name="assistant" select="/hl7:ClinicalDocument/hl7:dataEnterer/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.90' and 
										/hl7:ClinicalDocument/hl7:dataEnterer/hl7:assignedEntity/hl7:id/@extension = /hl7:ClinicalDocument/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@extension and 
										/hl7:ClinicalDocument/hl7:dataEnterer/hl7:assignedEntity/hl7:id/@root = /hl7:ClinicalDocument/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@root"/>
		
		<xsl:if test="count($author) &gt; 0">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
			<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Organizacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="authorDateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="authorLabel">
				<xsl:choose>
					<xsl:when test="count($author) = 1 and count($allAuthors) = 2 and $lang = $secondLanguage">
						<xsl:text>Co-author</xsl:text>
					</xsl:when>
					<xsl:when test="count($author) = 1 and count($allAuthors) = 1 and $lang = $secondLanguage">
						<xsl:text>Author</xsl:text>
					</xsl:when>
					<xsl:when test="count($author) &gt; 1 and count($allAuthors) = (count($author) + 1) and $lang = $secondLanguage">
						<xsl:text>Co-authors</xsl:text>
					</xsl:when>
					<xsl:when test="count($author) &gt; 1 and count($allAuthors) = count($author) and $lang = $secondLanguage">
						<xsl:text>Authors</xsl:text>
					</xsl:when>
					
					<xsl:when test="$assistant = 'true'">
						<xsl:text>Wystawiono w imieniu</xsl:text>
					</xsl:when>
					<xsl:when test="count($author) = 1 and count($allAuthors) = 2">
						<xsl:text>Współautor</xsl:text>
					</xsl:when>
					<xsl:when test="count($author) = 1 and count($allAuthors) = 1">
						<xsl:text>Autor</xsl:text>
					</xsl:when>
					<xsl:when test="count($author) &gt; 1 and count($allAuthors) = (count($author) + 1)">
						<xsl:text>Współautorzy</xsl:text>
					</xsl:when>
					<xsl:when test="count($author) &gt; 1 and count($allAuthors) = count($author)">
						<xsl:text>Autorzy</xsl:text>
					</xsl:when>
					
					<!-- brak takiego przypadku -->
					<xsl:otherwise>
						<xsl:text>Autor</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="header_block">
				<span class="header_block_label">
					<xsl:value-of select="$authorLabel"/>
				</span>
				
				<!-- blok dodatkowego autora/autorów jest ukrywany do rozwinięcia, o ile wystawcą nie jest asystent med. wystawiający dokument w imieniu autora -->
				<xsl:if test="not($assistant)">
					<xsl:call-template name="showDheaderEnabler">
						<xsl:with-param name="blockName">author</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				
				<xsl:element name="div">
					<xsl:if test="not($assistant)">
						<!-- tą klasą manipuluje mechanizm ukrywania bloków -->
						<xsl:attribute name="class">header_dheader</xsl:attribute>
					</xsl:if>
					<xsl:for-each select="$author">
						<xsl:call-template name="assignedEntity">
							<xsl:with-param name="entity" select="./hl7:assignedAuthor"/>
							<xsl:with-param name="blockClass">header_block</xsl:with-param>
							<xsl:with-param name="blockLabel"/>
							<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
							<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
						</xsl:call-template>
						<xsl:call-template name="dateTimeInDiv">
							<xsl:with-param name="date" select="./hl7:time"/>
							<xsl:with-param name="label" select="$authorDateLabel"/>
							<xsl:with-param name="divClass">header_element</xsl:with-param>
							<xsl:with-param name="calculateAge" select="false()"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:element>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- informant 0:*, dane osoby, której relację spisano w dokumencie, wstępnie na poziomie headera, brak generycznego kodu dla sekcji -->
	<xsl:template name="informant">
		<xsl:variable name="informant" select="hl7:informant"/>
		
		<xsl:if test="count($informant)&gt;0">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Organizacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="informationDateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Information date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data informacji</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="informantLabel">
				<xsl:choose>
					<xsl:when test="count($informant) = 1 and $lang = $secondLanguage">
						<xsl:text>Informant</xsl:text>
					</xsl:when>
					<xsl:when test="count($informant) &gt; 1 and $lang = $secondLanguage">
						<xsl:text>Informants</xsl:text>
					</xsl:when>
					<xsl:when test="count($informant) = 1">
						<xsl:text>Informator</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Informatorzy</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		
			<div class="header_block">
				<span class="header_block_label">
					<xsl:value-of select="$informantLabel"/>
				</span>
				<xsl:call-template name="showDheaderEnabler">
					<xsl:with-param name="blockName">informant</xsl:with-param>
				</xsl:call-template>
				<div class="header_dheader">
					<xsl:for-each select="$informant">
							<xsl:choose>
								<xsl:when test="./hl7:assignedEntity">
									<xsl:call-template name="assignedEntity">
										<xsl:with-param name="entity" select="./hl7:assignedEntity"/>
										<xsl:with-param name="blockClass">header_block</xsl:with-param>
										<xsl:with-param name="blockLabel"/>
										<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
										<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="assignedEntity">
										<xsl:with-param name="entity" select="./hl7:relatedEntity"/>
										<xsl:with-param name="context">relatedEntity</xsl:with-param>
										<xsl:with-param name="blockClass">header_block</xsl:with-param>
										<xsl:with-param name="blockLabel"/>
										<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
										<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
									</xsl:call-template>
									<xsl:call-template name="dateTimeInDiv">
										<xsl:with-param name="date" select="./hl7:relatedEntity/hl7:effectiveTime"/>
										<xsl:with-param name="label" select="$informationDateLabel"/>
										<xsl:with-param name="divClass">header_element</xsl:with-param>
										<xsl:with-param name="calculateAge" select="false()"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- authorization (consent, zgoda pacjenta) -->
	<xsl:template name="authorization">
		<xsl:variable name="authorization" select="hl7:authorization"/>
		
		<xsl:if test="count($authorization)&gt;0">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
			<xsl:variable name="authorizationLabel">
				<xsl:choose>
					<xsl:when test="count($authorization) = 1 and $lang = $secondLanguage">
						<xsl:text>The consent has been registered</xsl:text>
					</xsl:when>
					<xsl:when test="count($authorization) &gt; 1 and $lang = $secondLanguage">
						<xsl:text>The consents have been registered</xsl:text>
					</xsl:when>
					<xsl:when test="count($authorization) = 1">
						<xsl:text>Zarejestrowano zgodę</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Zarejestrowano zgody</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="consentCodeLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Consent type</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rodzaj zgody</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="header_block">
				<span class="header_block_label">
					<xsl:value-of select="$authorizationLabel"/>
				</span>
				<xsl:call-template name="showDheaderEnabler">
					<xsl:with-param name="blockName">authorization</xsl:with-param>
				</xsl:call-template>
				<div class="header_dheader">
					<xsl:for-each select="$authorization">
						<div class="header_block">
							<xsl:choose>
								<xsl:when test="./@nullFlavor">
									<xsl:call-template name="translateNullFlavor">
										<xsl:with-param name="nullableElement" select="."/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="./hl7:consent/@nullFlavor">
									<xsl:call-template name="translateNullFlavor">
										<xsl:with-param name="nullableElement" select="./hl7:consent"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<!-- identyfikator dokumentu zgody, przynajmniej jeden jest wymagany wg schematu, choć wg schemy tylko code jest wymagany -->
									<xsl:call-template name="identifiersInDiv">
										<xsl:with-param name="ids" select="./hl7:consent/hl7:id"/>
										<xsl:with-param name="knownOnly" select="false()"/>
									</xsl:call-template>
									
									<!-- opcjonalny code (wg schemy wymagany) z kodem nieokreślonego z góry słownika, dotyczy informacji na co wydano zgodę -->
									<xsl:call-template name="codeInDiv">
										<xsl:with-param name="code" select="./hl7:consent/hl7:code"/>
										<xsl:with-param name="label" select="$consentCodeLabel"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- participant (inny niż płatnik templateId 2.16.840.1.113883.3.4424.13.10.2.19) -->
	<xsl:template name="participant">
		<!-- element participant templateId 2.16.840.1.113883.3.4424.13.10.2.19 wyświetlany jest w ramach template reimbursementRelated -->
		<xsl:variable name="participant" select="hl7:participant[not(hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.19')]"/>
		
		<xsl:if test="count($participant)&gt;0">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
			<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Organizacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="participantDateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Participation date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data udziału</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="participantLabel">
				<xsl:choose>
					<xsl:when test="count($participant) = 1 and $lang = $secondLanguage">
						<xsl:text>Participant</xsl:text>
					</xsl:when>
					<xsl:when test="count($participant) &gt; 1 and $lang = $secondLanguage">
						<xsl:text>Participants</xsl:text>
					</xsl:when>
					<xsl:when test="count($participant) = 1">
						<xsl:text>Współudział</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Współudział</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="enableLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Show more</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rozwiń</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="header_block">
				<span class="header_block_label">
					<xsl:value-of select="$participantLabel"/>
				</span>
				<xsl:call-template name="showDheaderEnabler">
					<xsl:with-param name="blockName">participant</xsl:with-param>
				</xsl:call-template>
				<div class="header_dheader">
					<xsl:for-each select="$participant">
						<xsl:call-template name="assignedEntity">
							<xsl:with-param name="entity" select="./hl7:associatedEntity"/>
							<xsl:with-param name="blockClass">header_block</xsl:with-param>
							<xsl:with-param name="blockLabel"/>
							<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
							<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
						</xsl:call-template>
						<xsl:call-template name="dateTimeInDiv">
							<xsl:with-param name="date" select="./hl7:time"/>
							<xsl:with-param name="label" select="$participantDateLabel"/>
							<xsl:with-param name="divClass">header_element</xsl:with-param>
							<xsl:with-param name="calculateAge" select="false()"/>
						</xsl:call-template>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- ++++++++++++++++++++++++++++++++++++++ DRUGA LINIA +++++++++++++++++++++++++++++++++++++++++++-->
	
	<!-- osoba przypisana AssignedEntity templateId 2.16.840.1.113883.3.4424.13.10.2.49 
		 wykorzytywane też do wyświetlenia IntendedRecipient i RelatedEntity oraz w przypadku autora będącego urządzeniem, także AuthoringDevice -->
	<xsl:template name="assignedEntity">
		<xsl:param name="entity"/>
		<!-- kontekst domyślny, dodatkowo obsługa intendedRecipient i RelatedEntity -->
		<xsl:param name="context">assignedEntity</xsl:param>
		<xsl:param name="blockClass">header_block0</xsl:param>
		<xsl:param name="blockLabel">Blok danych</xsl:param>
		<xsl:param name="organizationLevel1BlockLabel" select="false()"/>
		<xsl:param name="knownIdentifiersOnly" select="true()"/>
		<!-- opcjonalna wartość RTF do dodania po identyfikatorach -->
		<xsl:param name="addToLevel1Label" select="false()"/>
		<xsl:param name="addToLevel1" select="false()"/>
		<xsl:param name="hideSecondOrgLevel" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<!-- id 1:*, code 0:1, addr 0:*, telecom 0:*, assignedPerson 0:1/1:1, representedOrganization 0:1 -->
		<!-- w RelatedEntity istnieje dodatkowo code relacji z pacjentem i czas złożenia informacji, brak za to id -->
		<xsl:if test="$entity">
			<!-- poziom stylu 0 oznacza w wizualizacji poziom Act, do którego przypisany jest byt entity -->
			<div class="{$blockClass}">
				<span class="header_block_label">
					<xsl:value-of select="$blockLabel"/>
				</span>
				<xsl:choose>
					<xsl:when test="$entity/@nullFlavor">
						<xsl:call-template name="translateNullFlavor">
							<xsl:with-param name="nullableElement" select="$entity"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="assignedEntityText">
							<xsl:if test="$addToLevel1Label">
								<xsl:copy-of select="$addToLevel1Label"/>
							</xsl:if>
							
							<!-- osoba przypisana, opcjonalnie również urządzenie w przypadku autora w kontekście assignedEntity -->
							<xsl:choose>
								<xsl:when test="$context = 'assignedEntity'">
									<xsl:choose>
										<xsl:when test="$entity/hl7:assignedPerson">
											<xsl:call-template name="person">
												<xsl:with-param name="person" select="$entity/hl7:assignedPerson"/>
											</xsl:call-template>
										</xsl:when>
										<!-- brak obsługi informacji o ostatnim przeglądzie urządzenia i serwisancie (MaintainedDevice) -->
										<xsl:when test="$entity/hl7:assignedAuthoringDevice">
											<xsl:call-template name="device">
												<xsl:with-param name="device" select="$entity/hl7:assignedAuthoringDevice"/>
											</xsl:call-template>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="$context = 'intendedRecipient'">
									<xsl:call-template name="person">
										<xsl:with-param name="person" select="$entity/hl7:informationRecipient"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="$context = 'relatedEntity'">
									<xsl:call-template name="person">
										<xsl:with-param name="person" select="$entity/hl7:relatedPerson"/>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>
							
							<!-- kod roli przypisanego bytu, wykorzystywane gdy jest to słownik zawodów medycznych i podana jest wartość displayName
								 użycie dla innych słowników wymaga zdefiniowania zastosowania tego kodu w IG dla tych słowników
								 dodatkowo zawód wyświetlany jest wyłącznie przy identyfikatorze, o ile podano przynajmniej jeden identyfikator
								 wprowadzając zgodność z IHE PRE zawartość z code została przeniesiona o poziom wyżej do functionCode, cofnięcie się o poziom wyżej jest bezpieczne -->
							<xsl:variable name="idPrefix">
								<xsl:choose>
									<xsl:when test="$entity/../hl7:functionCode/@codeSystem = '2.16.840.1.113883.3.4424.11.3.18' and string-length($entity/../hl7:functionCode/@displayName) &gt;= 1">
										<xsl:value-of select="$entity/../hl7:functionCode/@displayName"/>
									</xsl:when>
									<!-- obsługa starszej wersji, do usunięcia w przyszłości -->
									<xsl:when test="$entity/hl7:code/@codeSystem = '2.16.840.1.113883.3.4424.11.3.18' and string-length($entity/hl7:code/@displayName) &gt;= 1">
										<xsl:value-of select="$entity/hl7:code/@displayName"/>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							
							<!-- identyfikator zwykle osoby w roli, nie używa się dla relatedEntity -->
							<xsl:if test="not($context = 'relatedEntity')">
								<xsl:call-template name="identifiersInDiv">
									<xsl:with-param name="ids" select="$entity/hl7:id"/>
									<xsl:with-param name="knownOnly" select="$knownIdentifiersOnly"/>
									<xsl:with-param name="prefix" select="$idPrefix"/>
								</xsl:call-template>
							</xsl:if>
							
							<!-- Specjalność autora, obowiązuje od PIK 1.2.1 zgodnie z IHE PRE -->
							<xsl:if test="$context = 'assignedEntity' and $entity/hl7:code and starts-with($entity/hl7:code/@codeSystem, '2.16.840.1.113883.3.4424.11.3.3')">
								<xsl:call-template name="personQualifiedEntity">
									<xsl:with-param name="qualificationCode" select="$entity/hl7:code"/>
								</xsl:call-template>
							</xsl:if>
							
							<!-- relacja z pacjentem (wyłącznie informant) -->
							<xsl:if test="$context = 'relatedEntity' and string-length($entity/hl7:code/@code) &gt;= 1">
								<xsl:variable name="relationshipLabel">
									<xsl:choose>
										<xsl:when test="$lang = $secondLanguage">
											<xsl:text>Relationship</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Relacja</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<div class="header_element">
									<span class="header_label">
										<xsl:value-of select="$relationshipLabel"/>
									</span>
									<div class="header_inline_value header_value">
										<xsl:call-template name="translatePersonalRelationshipRoleCode">
											<xsl:with-param name="roleCode" select="$entity/hl7:code/@code"/>
										</xsl:call-template>
									</div>
								</div>
							</xsl:if>
							
							<!-- czas poinformowania przez relatedEntity -->
							<xsl:if test="$context = 'relatedEntity' and $entity/hl7:effectiveTime">
								<xsl:variable name="informationDateLabel">
									<xsl:choose>
										<xsl:when test="$lang = $secondLanguage">
											<xsl:text>Information date</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Data poinformowania</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<xsl:call-template name="dateTimeInDiv">
									<xsl:with-param name="date" select="$entity/hl7:effectiveTime"/>
									<xsl:with-param name="label" select="$informationDateLabel"/>
									<xsl:with-param name="divClass">effective_time_header_element doc_header_element header_element</xsl:with-param>
								</xsl:call-template>
							</xsl:if>
							
							<xsl:if test="$addToLevel1">
								<xsl:copy-of select="$addToLevel1"/>
							</xsl:if>
							
							<!-- dane adresowe i kontaktowe przypisanego bytu -->
							<xsl:call-template name="addressTelecomInDivs">
								<xsl:with-param name="addr" select="$entity/hl7:addr"/>
								<xsl:with-param name="telecom" select="$entity/hl7:telecom"/>
							</xsl:call-template>
						</xsl:variable>
						
						<!-- variable assignedEntityText utworzona jest by zweryfikować 
							 czy poziom assignedEntity i person zawiera treść, 
							 jeżeli nie, dane organizacji wyświetlane są na pierwszym poziomie -->
						<xsl:copy-of select="$assignedEntityText"/>
						
						<xsl:variable name="addNextLevel" select="string-length($assignedEntityText) &gt; 0"/>
						
						<!-- dane instytucji dla AssignedEntity lub IntendedRecipient, nie istnieją dla relatedEntity -->
						<xsl:choose>
							<xsl:when test="$context = 'assignedEntity'">
								<!-- jeżeli cokolwiek wyświetlono z danych osoby lub osoby przypisanej, dane organizacji wyświetlane są na level 1 -->
								<xsl:call-template name="organization">
									<xsl:with-param name="organization" select="$entity/hl7:representedOrganization"/>
									<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
									<xsl:with-param name="level" select="1"/>
									<xsl:with-param name="level1BlockLabel" select="$organizationLevel1BlockLabel"/>
									<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
									<xsl:with-param name="addNextLevel" select="$addNextLevel"/>
									<xsl:with-param name="hideNextLevel" select="$hideSecondOrgLevel"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="$context = 'intendedRecipient'">
								<xsl:call-template name="organization">
									<xsl:with-param name="organization" select="$entity/hl7:receivedOrganization"/>
									<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
									<xsl:with-param name="level" select="1"/>
									<xsl:with-param name="level1BlockLabel" select="$organizationLevel1BlockLabel"/>
									<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
									<xsl:with-param name="addNextLevel" select="$addNextLevel"/>
								</xsl:call-template>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- organization templateId 2.16.840.1.113883.3.4424.13.10.2.2
		 rekurencyjnie dla nieznanych instytucji i płasko dla podmiotów i aptek -->
	<xsl:template name="organization">
		<xsl:param name="organization"/>
		<xsl:param name="showAddressAndContactInfo" select="false()"/>
		<xsl:param name="level" select="false()"/>
		<xsl:param name="level1BlockLabel" select="false()"/>
		<xsl:param name="knownIdentifiersOnly" select="false()"/>
		<xsl:param name="addNextLevel" select="false()"/>
		<xsl:param name="hideNextLevel" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="firstLevelLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>As part of institution</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Jako część instytucji</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="secondLevelLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Within organization</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>W ramach organizacji</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="typeOfActivityLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Type</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Rodzaj działalności</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- kod nieoptymalny z powodu wyświetlania jak najmniejszej ilości danych w najpopularniejszych przypadkach -->
		<xsl:if test="$organization">
			<xsl:choose>
				<!-- rozpoznanie szablonów szczegółowych tylko dla pierwszego poziomu -->
				<xsl:when test="not($level) or $level = 0 or $level = 1">
					<xsl:choose>
						<xsl:when test="$addNextLevel">
							<div class="doc_legal_authenticator_organization_{$level} header_block{$level}">
								<xsl:if test="$level1BlockLabel">
									<span class="legal_authenticator_organization_block_label header_block_label">
										<xsl:value-of select="$level1BlockLabel"/>
									</span>
								</xsl:if>
								<xsl:call-template name="organizationContent">
									<xsl:with-param name="organization" select="$organization"/>
									<xsl:with-param name="typeOfActivityLabel" select="$typeOfActivityLabel"/>
									<xsl:with-param name="knownIdentifiersOnly" select="$knownIdentifiersOnly"/>
									<xsl:with-param name="hideNextLevel" select="$hideNextLevel"/>
								</xsl:call-template>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="organizationContent">
								<xsl:with-param name="organization" select="$organization"/>
								<xsl:with-param name="typeOfActivityLabel" select="$typeOfActivityLabel"/>
								<xsl:with-param name="knownIdentifiersOnly" select="$knownIdentifiersOnly"/>
								<xsl:with-param name="hideNextLevel" select="$hideNextLevel"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$hideNextLevel">
					<!-- nagłówek dla każdego poziomu poza pierwszym w ramach ogólnego szablonu organizacji. 
						 Wyświetlane są tu wyłącznie nieznane typy instytucji. -->
					<span class="legal_authenticator_organization_block_label header_block_label">
						<xsl:value-of select="$firstLevelLabel"/>
					</span>
					
					<xsl:call-template name="showDheaderEnabler">
						<xsl:with-param name="blockName">legal_authenticator</xsl:with-param>
					</xsl:call-template>
					
					<div class="header_dheader">
						<xsl:call-template name="organizationLevelContent">
							<xsl:with-param name="organization" select="$organization"/>
							<xsl:with-param name="typeOfActivityLabel" select="$typeOfActivityLabel"/>
						</xsl:call-template>
						<!-- rekurencja -->
						<xsl:if test="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization">
							<xsl:call-template name="organization">
								<xsl:with-param name="organization" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization"/>
								<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
								<xsl:with-param name="level" select="$level+1"/>
								<xsl:with-param name="knownIdentifiersOnly" select="$knownIdentifiersOnly"/>
							</xsl:call-template>
						</xsl:if>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<!-- nagłówek dla każdego poziomu poza pierwszym w ramach ogólnego szablonu organizacji. 
						 Wyświetlane są tu wyłącznie nieznane typy instytucji. -->
					<span class="legal_authenticator_organization_block_label header_block_label">
						<xsl:value-of select="$secondLevelLabel"/>
					</span>
					
					<xsl:call-template name="organizationLevelContent">
						<xsl:with-param name="organization" select="$organization"/>
						<xsl:with-param name="typeOfActivityLabel" select="$typeOfActivityLabel"/>
					</xsl:call-template>
					<!-- rekurencja -->
					<xsl:if test="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization">
						<xsl:call-template name="organization">
							<xsl:with-param name="organization" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization"/>
							<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
							<xsl:with-param name="level" select="$level+1"/>
							<xsl:with-param name="knownIdentifiersOnly" select="$knownIdentifiersOnly"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="organizationContent">
		<xsl:param name="organization"/>
		<xsl:param name="typeOfActivityLabel"/>
		<xsl:param name="knownIdentifiersOnly" select="false()"/>
		<xsl:param name="hideNextLevel" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="typeOfJednostkaLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Type</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Rodzaj jednostki</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="typeOfPrzedsiebiorstwoLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Type</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Rodzaj przedsiębiorstwa</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="typeOfPodmiotLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Type</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Rodzaj podmiotu leczniczego</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$organization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.15']">
				<!-- Praktyka zawodowa -->
				<!-- nazwy instytucji -->
				<div class="header_element">
					<xsl:if test="string-length($organization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:name"/>
						</div>
					</xsl:if>
					<xsl:if test="string-length($organization/hl7:name) = 0 or $organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name != $organization/hl7:name">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
						</div>
					</xsl:if>
				</div>
				
				<!-- identyfikatory zbierane ręcznie -->
				<div class="identifiers header_element">
					<!-- id miejsca udzielania świadczeń, tj. id praktyki i id rodzaju działalności rozdzielone myślnikiem -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:id"/>
					</xsl:call-template>
					<!-- wyłącznie REGON jeżeli podano, gdyż id praktyki zawarty jest w id miejsca -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:id[@root='2.16.840.1.113883.3.4424.2.2.1']"/>
					</xsl:call-template>
				</div>
				
				<!-- rodzaj działalności -->
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfActivityLabel"/>
				</xsl:call-template>

				<!-- adresy i dane kontaktowe miejsca udzielania świadczeń i praktyki zawodowej -->
				<xsl:variable name="addrM" select="$organization/hl7:addr"/>
				<xsl:variable name="addrP" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:addr"/>
				<xsl:variable name="telsM" select="$organization/hl7:telecom"/>
				<xsl:variable name="telP" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:telecom"/>
				
				<!-- weryfikacja czy kontakt praktyki istnieje wśród kontaktów miejsca udzielania świadczeń, porównywany jest sam kontakt, nie jego przeznaczenie -->
				<xsl:variable name="telPdoubled">
					<xsl:for-each select="$telsM">
						<xsl:if test="./@value = $telP/@value">
							<xsl:value-of select="true()"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				
				<!-- adres (1..1) miejsca udzielania świadczeń -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$addrM"/>
					<xsl:with-param name="telecom" select="$telsM"/>
				</xsl:call-template>
				
				<!-- adres praktyki zawodowej (1..1) pod warunkiem, że inny niż miejsca udzielania świadczeń, zakłada się, że poniższy zestaw porównywanych elementów jest wystarczający (strlen gdy jeden istnieje a drugiego brak) -->
				<xsl:if test="$addrM/hl7:streetName != $addrP/hl7:streetName or string-length($addrM/hl7:streetName) != string-length($addrP/hl7:streetName) 
							or $addrM/hl7:houseNumber != $addrP/hl7:houseNumber or string-length($addrM/hl7:houseNumber) != string-length($addrP/hl7:houseNumber) 
							or $addrM/hl7:unitID != $addrP/hl7:unitID or string-length($addrM/hl7:unitID) != string-length($addrP/hl7:unitID) 
							or $addrM/hl7:city != $addrP/hl7:city or string-length($addrM/hl7:city) != string-length($addrP/hl7:city)">
					<xsl:call-template name="addressTelecomInDivs">
						<xsl:with-param name="addr" select="$addrP"/>
					</xsl:call-template>
				</xsl:if>
				
				<!-- kontakt do praktyki zawodowej (1..1) pod warunkiem, że jest inny niż miejsca udzielania świadczeń -->
				<xsl:if test="$telPdoubled != 'true'">
					<xsl:call-template name="addressTelecomInDivs">
						<xsl:with-param name="telecom" select="$telP"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			
			<xsl:when test="$organization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.18'] and $organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.17']">
				<!-- Komórka organizacyjna w jednostce organizacyjnej -->
				<!-- UWAGA: jeżeli nazwa na dowolnym prócz pierwszego poziomie powtarza się lub nic nie wnosi, nie należy jej podawać w dokumencie -->
				<div class="header_element">
					<xsl:if test="string-length($organization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:name"/>
						</div>
					</xsl:if>
					<xsl:if test="string-length($organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
						</div>
					</xsl:if>
					<xsl:if test="string-length($organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
						</div>
					</xsl:if>
					<xsl:if test="string-length($organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
						</div>
					</xsl:if>
				</div>
				
				<!-- identyfikatory zbierane ręcznie -->
				<div class="identifiers header_element">
					<!-- id komórki -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:id"/>
					</xsl:call-template>
					<!-- id jednostki -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:id"/>
					</xsl:call-template>
					<!-- id przedsiębiorstwa, tj. REGON 14-znakowy -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:id"/>
					</xsl:call-template>
					<!-- id podmiotu leczniczego jest pomijany, zawiera się w id komórki -->
					<!-- <xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:id[@root='2.16.840.1.113883.3.4424.2.3.1']"/>
					</xsl:call-template> -->
				</div>
				
				<!-- rodzaj działalności -->
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfActivityLabel"/>
				</xsl:call-template>
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfJednostkaLabel"/>
				</xsl:call-template>
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfPrzedsiebiorstwoLabel"/>
				</xsl:call-template>
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfPodmiotLabel"/>
				</xsl:call-template>
				
				<!-- adresy i dane kontaktowe -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:telecom"/>
				</xsl:call-template>
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:telecom"/>
				</xsl:call-template>
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:telecom"/>
				</xsl:call-template>
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:telecom"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test="$organization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.17'] or ($organization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.18'] and $organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.16'])">
				<!-- Komórka organizacyjna bezpośrednio w przedsiębiorstwie lub jednostka organizacyjna w przedsiębiorstwie -->
				<div class="header_element">
					<xsl:if test="string-length($organization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:name"/>
						</div>
					</xsl:if>
					<xsl:if test="string-length($organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
						</div>
					</xsl:if>
					<xsl:if test="string-length($organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
						</div>
					</xsl:if>
				</div>
				
				<!-- identyfikatory zbierane ręcznie -->
				<div class="identifiers header_element">
					<!-- id komórki lub jednostki -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:id"/>
					</xsl:call-template>
					<!-- id przedsiębiorstwa, tj. REGON 14-znakowy -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:id"/>
					</xsl:call-template>
					<!-- id podmiotu leczniczego jest pomijany, zawiera się w id jednostki -->
					<!-- <xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:id[@root='2.16.840.1.113883.3.4424.2.3.1']"/>
					</xsl:call-template> -->
				</div>
				
				<!-- rodzaj działalności -->
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfActivityLabel"/>
				</xsl:call-template>
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfPrzedsiebiorstwoLabel"/>
				</xsl:call-template>
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfPodmiotLabel"/>
				</xsl:call-template>
				
				<!-- adresy i dane kontaktowe -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:telecom"/>
				</xsl:call-template>
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:telecom"/>
				</xsl:call-template>
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:telecom"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test="$organization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.16']">
				<!-- Przedsiębiorstwo podmiotu leczniczego -->
				<div class="header_element">
					<xsl:if test="$organization/hl7:name and string-length($organization/hl7:name) &gt;= 1">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:name"/>
						</div>
					</xsl:if>
					<xsl:if test="not($organization/hl7:name) or string-length($organization/hl7:name) = 0 or $organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name != $organization/hl7:name">
						<div class="header_value">
							<xsl:value-of select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:name"/>
						</div>
					</xsl:if>
				</div>
				
				<!-- identyfikatory zbierane ręcznie -->
				<div class="identifiers header_element">
					<!-- id podmiotu leczniczego, wyłącznie numer wpisu bez 9-znakowego numeru REGON -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:id[@root='2.16.840.1.113883.3.4424.2.3.1']"/>
					</xsl:call-template>
					<!-- id przedsiębiorstwa, tj. REGON 14-znakowy -->
					<xsl:call-template name="listIdentifiersOID">
						<xsl:with-param name="ids" select="$organization/hl7:id"/>
					</xsl:call-template>
				</div>
				
				<!-- rodzaj działalności -->
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfActivityLabel"/>
				</xsl:call-template>
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfPodmiotLabel"/>
				</xsl:call-template>
				
				<!-- adresy i dane kontaktowe -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:telecom"/>
				</xsl:call-template>
				
				<!-- adresy i dane kontaktowe -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization/hl7:telecom"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test="$organization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.14']">
				<!-- Podmiot leczniczy -->
				<xsl:call-template name="organizationLevelContent">
					<xsl:with-param name="organization" select="$organization"/>
					<xsl:with-param name="typeOfActivityLabel" select="$typeOfActivityLabel"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test="$organization/hl7:templateId[@root='2.16.840.1.113883.3.4424.13.10.2.31']">
				<!-- Apteka -->
				<xsl:call-template name="organizationLevelContent">
					<xsl:with-param name="organization" select="$organization"/>
					<xsl:with-param name="typeOfActivityLabel" select="$typeOfActivityLabel"/>
				</xsl:call-template>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:call-template name="organizationLevelContent">
					<xsl:with-param name="organization" select="$organization"/>
					<xsl:with-param name="typeOfActivityLabel" select="$typeOfActivityLabel"/>
				</xsl:call-template>
				<!-- rekurencja rozpoczynana z pierwszego poziomu dla szablonu ogólnego organizacji -->
				<xsl:if test="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization">
					<xsl:call-template name="organization">
						<xsl:with-param name="organization" select="$organization/hl7:asOrganizationPartOf/hl7:wholeOrganization"/>
						<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
						<xsl:with-param name="level" select="2"/>
						<xsl:with-param name="knownIdentifiersOnly" select="$knownIdentifiersOnly"/>
						<xsl:with-param name="hideNextLevel" select="$hideNextLevel"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="organizationLevelContent">
		<xsl:param name="organization"/>
		<xsl:param name="typeOfActivityLabel"/>
		
		<xsl:choose>
			<xsl:when test="$organization/@nullFlavor">
				<xsl:call-template name="translateNullFlavor">
					<xsl:with-param name="nullableElement" select="$organization"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- nazwy instytucji -->
				<xsl:call-template name="organizationName">
					<xsl:with-param name="name" select="$organization/hl7:name"/>
				</xsl:call-template>
				
				<!-- identyfikatory -->
				<xsl:call-template name="identifiersInDiv">
					<xsl:with-param name="ids" select="$organization/hl7:id"/>
					<xsl:with-param name="knownOnly" select="false()"/>
				</xsl:call-template>
				
				<!-- rodzaj działalności -->
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$organization/hl7:standardIndustryClassCode"/>
					<xsl:with-param name="label" select="$typeOfActivityLabel"/>
				</xsl:call-template>
				
				<!-- adresy i dane kontaktowe -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$organization/hl7:addr"/>
					<xsl:with-param name="telecom" select="$organization/hl7:telecom"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- nazwy organizacji z obsługą nullFlavor -->
	<xsl:template name="organizationName">
		<xsl:param name="name"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="nameLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Name</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Nazwa</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$name">
			<div class="header_element">
				<!-- może istnieć wiele nazw instytucji, przy czym wyświetlana jest wyłącznie treść elementu name -->
				<xsl:for-each select="$name">
					<xsl:choose>
						<xsl:when test="./@nullFlavor">
							<span>
								<xsl:value-of select="$nameLabel"/>
							</span>
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="."/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="string-length(.) &gt;= 1">
							<div class="header_value">
								<xsl:value-of select="."/>
							</div>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- placówka w ramach danych wizyty -->
	<xsl:template name="location">
		<xsl:param name="location"/>
		<!-- brak obsługi nullFlavor, element nie jest wymagany -->
		<xsl:if test="$location">
			<xsl:variable name="facility" select="$location/hl7:healthCareFacility"/>
			
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="locationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Location</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Miejsce</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="typeLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Type</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Rodzaj</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Instytucja realizująca</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- place wg templateId 2.16.840.1.113883.3.4424.13.10.2.75 z uwzględnieniem identyfikatora i rodzaju -->
			<xsl:if test="$facility/hl7:id or string-length($facility/hl7:location/hl7:name) &gt;= 1 or $facility/hl7:location/hl7:addr or $facility/hl7:code">
				<span class="header_label">
					<xsl:value-of select="$locationLabel"/>
				</span>
				
				<!-- nazwa miejsca -->
				<xsl:if test="string-length($facility/hl7:location/hl7:name) &gt;= 1">
					<div class="header_element">
						<div class="header_value">
							<xsl:value-of select="$facility/hl7:location/hl7:name"/>
						</div>
					</div>
				</xsl:if>
				
				<xsl:call-template name="identifiersInDiv">
					<xsl:with-param name="ids" select="$facility/hl7:id"/>
				</xsl:call-template>
				
				<!-- rodzaj lub specjalność miejsca "ServiceDeliveryLocationRoleType"
			 		 value set nie został przetłumaczony na język polski, warto zastosować inny słownik -->
				<xsl:call-template name="codeInDiv">
					<xsl:with-param name="code" select="$facility/hl7:code"/>
					<xsl:with-param name="label" select="$typeLabel"/>
				</xsl:call-template>
				
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$facility/hl7:location/hl7:addr"/>
				</xsl:call-template>
			</xsl:if>
			
			<!-- placówka realizująca -->
			<xsl:call-template name="organization">
				<xsl:with-param name="organization" select="$facility/hl7:serviceProviderOrganization"/>
				<xsl:with-param name="showAddressAndContactInfo" select="true()"/>
				<xsl:with-param name="level" select="1"/>
				<xsl:with-param name="level1BlockLabel" select="$organizationLabel"/>
				<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- miejsce urodzenia: dopuszczalna nazwa, city i country, stąd brak wywołania template'u place -->
	<xsl:template name="birthPlace">
		<xsl:param name="birthPlace"/>
		
		<xsl:variable name="birthPlaceName" select="$birthPlace/hl7:place/hl7:name"/>
		<xsl:variable name="birthPlaceCity" select="$birthPlace/hl7:place/hl7:addr/hl7:city"/>
		<xsl:variable name="birthPlaceCountry" select="$birthPlace/hl7:place/hl7:addr/hl7:country"/>
		
		<xsl:if test="string-length($birthPlaceName) &gt;= 1 or string-length($birthPlaceCity) &gt;= 1 or string-length($birthPlaceCountry) &gt;= 1">
			
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="birthPlaceLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Place of birth</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Miejsce urodzenia</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="noInformationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>(no information)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>(nie podano)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
		
			<div class="header_element">
				<span class="header_label">
					<xsl:value-of select="$birthPlaceLabel"/>
				</span>
				
				<div class="header_inline_value header_value">
					<xsl:choose>
						<!-- nullFlavor dla ewentualnych template'ów wymagających miejsca urodzenia podczas gdy informacja ta nie jest dostępna -->
						<xsl:when test="$birthPlace/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$birthPlace"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$birthPlace/hl7:place/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$birthPlace/hl7:place"/>
							</xsl:call-template>
						</xsl:when>
						
						<!-- podano nazwę miejsca -->
						<xsl:when test="string-length($birthPlaceName) &gt;= 1 and not($birthPlaceName/@nullFlavor)">
							<xsl:value-of select="$birthPlaceName"/>
							<xsl:if test="string-length($birthPlaceCity) &gt;= 1 and not($birthPlaceCity/@nullFlavor) and not($birthPlace/hl7:place/hl7:addr/@nullFlavor)">
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$birthPlaceCity"/>
							</xsl:if>
							<xsl:if test="string-length($birthPlaceCountry) &gt;= 1 and not($birthPlaceCountry/@nullFlavor) and not($birthPlace/hl7:place/hl7:addr/@nullFlavor) and not(translate($birthPlaceCountry, $LOWERCASE_LETTERS, $UPPERCASE_LETTERS) = 'POLSKA')">
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$birthPlaceCountry"/>
							</xsl:if>
						</xsl:when>
						
						<!-- nie podano nazwy miejsca, podano miejscowość urodzenia -->
						<xsl:when test="string-length($birthPlaceCity) &gt;= 1 and not($birthPlaceCity/@nullFlavor) and not($birthPlace/hl7:place/hl7:addr/@nullFlavor)">
							<xsl:value-of select="$birthPlaceCity"/>
							<xsl:if test="string-length($birthPlaceCountry) &gt;= 1 and not($birthPlaceCountry/@nullFlavor) and not(translate($birthPlaceCountry, $LOWERCASE_LETTERS, $UPPERCASE_LETTERS) = 'POLSKA')">
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$birthPlaceCountry"/>
							</xsl:if>
						</xsl:when>
						
						<!-- nie podano nazwy miejsca ani miejscowości, podano wyłącznie nazwę kraju - wyświetla się także "Polska" -->
						<xsl:when test="string-length($birthPlaceCountry) &gt;= 1 and not($birthPlaceCountry/@nullFlavor) and not($birthPlace/hl7:place/hl7:addr/@nullFlavor)">
							<xsl:value-of select="$birthPlaceCountry"/>
						</xsl:when>
						
						<!-- uproszczona obsługa nullFlavor -->
						<xsl:otherwise>
							<xsl:value-of select="$noInformationLabel"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- osoba templateId 2.16.840.1.113883.3.4424.13.10.2.1 bez specjalizacji -->
	<xsl:template name="person">
		<xsl:param name="person"/>
		
		<xsl:if test="$person">
			<xsl:choose>
				<xsl:when test="$person/@nullFlavor">
					<xsl:call-template name="translateNullFlavor">
						<xsl:with-param name="nullableElement" select="$person"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- imiona i nazwiska przypisanej osoby, brak innych istotnych danych w tym elemencie -->
					<xsl:if test="$person/hl7:name">
						<xsl:call-template name="personName">
							<xsl:with-param name="name" select="$person/hl7:name"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- nazwa urządzenia i oprogramowania oraz kod -->
	<xsl:template name="device">
		<xsl:param name="device"/>
		
		<xsl:if test="$device">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="deviceLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Authoring device</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Urządzenie</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="softwareLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Software</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Oprogramowanie</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- nazwę urządzenia wyświetlam także gdy nie podano, zajmując pierwszy wiersz nagłówkiem "Urządzenie" -->
			<div class="header_element">
				<span class="header_label">
					<xsl:value-of select="$deviceLabel"/>
				</span>
				<div class="header_inline_value header_value">
					<xsl:choose>
						<xsl:when test="$device/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$device"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$device/hl7:manufacturerModelName"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			
			<!-- nazwę oprogramowania wyświetlam wyłącznie gdy istnieje -->
			<xsl:if test="$device/hl7:softwareName and string-length($device/hl7:softwareName) &gt;= 1">
				<div class="header_element">
					<span class="header_label">
						<xsl:value-of select="$softwareLabel"/>
					</span>
					<div class="header_inline_value header_value">
						<xsl:value-of select="$device/hl7:softwareName"/>
					</div>
				</div>
			</xsl:if>
			
			<!-- opcjonalny code z kodem nieokreślonego z góry słownika, dotyczy informacji o urządzeniu -->
			<xsl:call-template name="codeInDiv">
				<xsl:with-param name="code" select="$device/hl7:code"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- specjalizacja osoby, od PIK 1.2.1 zgodnie z IHE PRE -->
	<xsl:template name="personQualifiedEntity">
		<xsl:param name="qualificationCode"/>
		
		<!-- specjalizacja osoby, do wyświetlenia wymaga się displayName mimo że jest to element wymagany wyłącznie dla specjalizacji mnogich -->
		<xsl:if test="$qualificationCode/@displayName and string-length($qualificationCode/@displayName) &gt;= 1 and starts-with($qualificationCode/@codeSystem, '2.16.840.1.113883.3.4424.11.3.3')">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="specialtyLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Specialty</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Specializacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="specialtiesLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Specialties</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Specjalizacje</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="legal_authenticator_qualification_element header_element">
				<span class="header_label">
					<xsl:choose>
						<!-- pojedyncza specjalizacja -->
						<xsl:when test="$qualificationCode/@codeSystem = '2.16.840.1.113883.3.4424.11.3.3'">
							<xsl:value-of select="$specialtyLabel"/>
						</xsl:when>
						<!-- zapis specjalizacji mnogiej z OID 2.16.840.1.113883.3.4424.11.3.3.1 -->
						<xsl:otherwise>
							<xsl:value-of select="$specialtiesLabel"/>
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<div class="header_inline_value header_value">
					<xsl:value-of select="$qualificationCode/@displayName"/>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- imiona i nazwiska osoby z prefiksem i suffiksem
		 templateId 2.16.840.1.113883.3.4424.13.10.7.2 -->
	<xsl:template name="personName">
		<xsl:param name="name"/>
		
		<xsl:if test="$name">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="unknownGivenNameLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>(unknown given name)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>(imienia nie podano)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="unknownFamilyNameLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>(unknown family name)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>(nazwiska nie podano)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<div class="header_element">
				<!-- może istnieć wiele "nazw" osób, przy czym jedno imię i jedno nazwisko w polskim IG jest wymagane -->
				<xsl:for-each select="$name">
					<xsl:choose>
						<!-- gdy całe name oznaczono nullFlavor -->
						<xsl:when test="./@nullFlavor">
							<span class="person_name_value header_value"><xsl:text>Imię i nazwisko</xsl:text></span>
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="."/>
							</xsl:call-template>
						</xsl:when>
						<!-- gdy istnieje zawartość zgodna z szablonem PIK HL7 CDA -->
						<xsl:when test="./hl7:family">
							<div class="person_name_value header_value">
								<xsl:if test="string-length(./hl7:prefix) &gt;= 1">
									<xsl:value-of select="./hl7:prefix"/>
									<xsl:text> </xsl:text>
								</xsl:if>
								<xsl:for-each select="./hl7:given">
									<xsl:if test="./@nullFlavor">
										<xsl:value-of select="$unknownGivenNameLabel"/>
										<xsl:text> </xsl:text>
									</xsl:if>
									<xsl:if test="not(./@nullFlavor)">
										<xsl:value-of select="."/>
										<xsl:text> </xsl:text>
									</xsl:if>
								</xsl:for-each>
								<xsl:for-each select="./hl7:family">
									<xsl:if test="./@nullFlavor">
										<xsl:text> </xsl:text>
										<xsl:value-of select="$unknownFamilyNameLabel"/>
									</xsl:if>
									<xsl:if test="not(./@nullFlavor)">
										<xsl:value-of select="."/>
										<xsl:if test="position()!=last()">
											<xsl:text> </xsl:text>
										</xsl:if>
									</xsl:if>
								</xsl:for-each>
								<xsl:if test="string-length(./hl7:suffix) &gt;= 1">
									<xsl:text> </xsl:text>
									<xsl:value-of select="./hl7:suffix"/>
								</xsl:if>
							</div>
						</xsl:when>
						<!-- na potrzeby wyświetlenia danych dokumentu zgodnego z ogólnym HL7 CDA, 
							 tj. gdy imię i nazwisko nie są rozdzielone na niezależne elementy.
							 Nie stosuje się jednak pełnych zasad formatowania HL7 CDA, np. "<name>John Smith<delimiter/>from North</name> -->
						<xsl:when test="string-length(.) &gt;= 1">
							<div class="person_name_value header_value">
								<xsl:value-of select="."/>
							</div>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- płeć -->
	<xsl:template name="translateGenderCode">
		<xsl:param name="genderCode"/>
		<xsl:if test="$genderCode">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:variable name="sexLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Gender</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Płeć</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="header_element">
				<span class="header_label">
					<xsl:value-of select="$sexLabel"/>
				</span>
				<div class="header_inline_value header_value">
					<xsl:choose>
						<xsl:when test="$genderCode/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$genderCode"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="$genderCode/@code = 'F' and $lang = $secondLanguage">
							<xsl:text>female</xsl:text>
						</xsl:when>
						<xsl:when test="$genderCode/@code = 'F'">
							<xsl:text>kobieta</xsl:text>
						</xsl:when>
						<xsl:when test="$genderCode/@code = 'M' and $lang = $secondLanguage">
							<xsl:text>male</xsl:text>
						</xsl:when>
						<xsl:when test="$genderCode/@code = 'M'">
							<xsl:text>mężczyzna</xsl:text>
						</xsl:when>
						<xsl:when test="$genderCode/@code = 'UN' and $lang = $secondLanguage">
							<xsl:text>undifferentiated</xsl:text>
						</xsl:when>
						<xsl:when test="$genderCode/@code = 'UN'">
							<xsl:text>nieokreślona</xsl:text>
						</xsl:when>
						<xsl:when test="$lang = $secondLanguage">
							<xsl:text>- code unknown: </xsl:text>
							<xsl:value-of select="$genderCode/@code"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- kod nieznany, wyświetlany bezpośrednio -->
							<xsl:text>- kod płci nieznany: </xsl:text>
							<xsl:value-of select="$genderCode/@code"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- pełna, sformatowana lista identyfikatorów typu II, przy czym przed pierwszym umieścić można prefiks -->
	<xsl:template name="identifiersInDiv">
		<xsl:param name="ids"/>
		<xsl:param name="knownOnly" select="false()"/>
		<xsl:param name="prefix" select="false()"/>
		
		<xsl:variable name="displayableIds" select="$ids[not(@displayable='false')]"/>
		<xsl:variable name="count" select="count($displayableIds)"/>
		
		<xsl:if test="$count &gt; 0">
			<div class="identifiers header_element">
				<xsl:call-template name="listIdentifiersOID">
					<xsl:with-param name="ids" select="$displayableIds"/>
					<xsl:with-param name="knownOnly" select="$knownOnly"/>
					<xsl:with-param name="prefix" select="$prefix"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!--  lista identyfikatorów OID -->
	<xsl:template name="listIdentifiersOID">
		<xsl:param name="ids"/>
		<xsl:param name="knownOnly" select="true()"/>
		<xsl:param name="prefix" select="false()"/>
		
		<xsl:for-each select="$ids">
			<div class="identifier header_value">
				<xsl:if test="$prefix and position() = 1">
					<span>
						<xsl:value-of select="$prefix"/>
						<xsl:text> </xsl:text>
					</span>
				</xsl:if>
				<xsl:call-template name="identifierOID">
					<xsl:with-param name="id" select="."/>
					<xsl:with-param name="knownOnly" select="$knownOnly"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
	</xsl:template>
	
	<!--  identyfikator OID -->
	<xsl:template name="identifierOID">
		<xsl:param name="id"/>
		<xsl:param name="knownOnly"/>

		<xsl:choose>
			<xsl:when test="not($id) or $id/@nullFlavor">
				<span class="null_flavor_id oid">
					<xsl:text>ID </xsl:text>
				</span>
				<xsl:call-template name="translateNullFlavor">
					<xsl:with-param name="nullableElement" select="$id"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="rootName">
					<xsl:call-template name="translateOID">
						<xsl:with-param name="oid" select="$id/@root"/>
						<xsl:with-param name="ext" select="$id/@extension"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$knownOnly">
						<!-- identyfikator nie jest wyświetlany gdy nie jest znany, a knownOnly = true -->
						<xsl:if test="string-length($rootName) &gt;= 1">
							<span class="oid">
								<xsl:value-of select="$rootName"/>
								<xsl:if test="string-length($id/@extension) &gt;= 1">
									<xsl:text> </xsl:text>
									<xsl:value-of select="$id/@extension"/>
								</xsl:if>
							</span>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<span class="oid">
							<xsl:choose>
								<xsl:when test="string-length($rootName) &gt;= 1">
									<xsl:value-of select="$rootName"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not_known_id_prefix">
										<xsl:text>ID </xsl:text>
									</span>
									<xsl:value-of select="$id/@root"/>
									<xsl:if test="string-length($id/@assigningAuthorityName) &gt;= 1">
										<xsl:text> (</xsl:text>
										<xsl:value-of select="$id/@assigningAuthorityName"/>
										<xsl:text>)</xsl:text>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="string-length($id/@extension) &gt;= 1">
								<xsl:text> </xsl:text>
								<xsl:value-of select="$id/@extension"/>
							</xsl:if>
						</span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- code typu CV i prostsze -->
	<!-- Jeśli zaistnieje potrzeba wyświetlania bardziej rozbudowanych typów kodów (CE, CD), należy rozwinąć ten template o translation i qualifier -->
	<xsl:template name="codeInDiv">
		<xsl:param name="code"/>
		<xsl:param name="label" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="codeLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>code </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>kod </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="codeSystemLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text> code system: </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> wg słownika </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="versionLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text> version </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> wersja </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$code">
			<div class="header_element">
				<xsl:if test="$label and string-length($label) &gt;= 1">
					<span class="header_label">
						<xsl:value-of select="$label"/>
					</span>
				</xsl:if>
				<div class="header_inline_value header_value">
					<xsl:choose>
						<!-- nullFlavor skutkuje pominięciem wszystkich danych elementu code, nie tylko samego kodu -->
						<xsl:when test="$code/@nullFlavor">
							<xsl:call-template name="translateNullFlavor">
								<xsl:with-param name="nullableElement" select="$code"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<!-- definicja displayName: "A name or title for the code, under which the sending system shows the code value to its users." -->
							<!-- Przykład wyświetlenia przy dostępnym displayName: Procedura RTG klatki piersiowej (87.440) słownik ICD-9-PL wersja 1.0 -->
							<!-- Przykład wyświetlenia przy nieznanym displayName: Procedura 87.440 słownik 2.16.840.1.113883.3.4424.11.2.6 -->
							<xsl:if test="string-length($code/@displayName) &gt;= 1">
								<xsl:value-of select="$code/@displayName"/>
								<!-- ponieważ displayName nie może być traktowane w systemie odbiorcy dokumentu jako stuprocentowo pewne,
						 			 zawsze wyświetlany jest także kod -->
								<xsl:if test="$code/@code">
									<xsl:text> (</xsl:text>
									<xsl:value-of select="$codeLabel"/>
								</xsl:if>
							</xsl:if>
							<xsl:if test="$code/@code">
								<xsl:value-of select="$code/@code"/>
							</xsl:if>
							<xsl:if test="string-length($code/@displayName) &gt;= 1 and $code/@code">
								<xsl:text>)</xsl:text>
							</xsl:if>
							<xsl:if test="string-length($code/@displayName) &gt;= 1 or $code/@code">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not($code/@nullFlavor) and ($code/@codeSystemName or $code/@codeSystem)">
						<xsl:value-of select="$codeSystemLabel"/>
						<xsl:choose>
							<xsl:when test="string-length($code/@codeSystemName) &gt;= 1">
								<xsl:value-of select="$code/@codeSystemName"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="translateCodeSystemOID">
									<xsl:with-param name="oid" select="$code/@codeSystem"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="string-length($code/@codeSystemVersion) &gt;= 1">
							<xsl:value-of select="$versionLabel"/>
							<xsl:value-of select="$code/@codeSystemVersion"/>
						</xsl:if>
					</xsl:if>
				</div>
				
				<!-- słowne, często ręczne doprecyzowanie kodu -->
				<xsl:if test="not($code/@nullFlavor) and string-length($code/hl7:originalText) &gt;= 1">
					<div class="header_value">
						<xsl:value-of select="$code/hl7:originalText"/>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- dane adresowe i kontaktowe -->
	<xsl:template name="addressTelecomInDivs">
		<xsl:param name="addr" select="false()"/>
		<xsl:param name="telecom" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="addressLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Contact</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Dane adresowe</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$addr">
	 		<xsl:variable name="countAddr" select="count($addr)"/>
			<xsl:if test="$countAddr &gt; 0">
				<div class="header_element">
					<xsl:choose>
						<xsl:when test="$countAddr &gt; 1">
							<span class="header_label">
								<xsl:value-of select="$addressLabel"/>
							</span>
							<div class="header_value">
								<xsl:call-template name="addresses">
									<xsl:with-param name="addresses" select="$addr"/>
								</xsl:call-template>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<span class="header_label">
								<xsl:call-template name="translateAddressUseCode">
									<xsl:with-param name="useCode" select="$addr/@use"/>
								</xsl:call-template>
							</span>
							
							<!-- adres w jednej linii wyłącznie gdy istnieją podstawowe elementy oraz jest to jeden adres -->
							<xsl:variable name="inline" select="not($addr/hl7:streetAddressLine or ($addr/hl7:postalCode/@postCity and $addr/hl7:postalCode/@postCity != $addr/hl7:city) or ($addr/hl7:country and translate($addr/hl7:country, $LOWERCASE_LETTERS, $UPPERCASE_LETTERS) != 'POLSKA'))"/>
							
							<xsl:element name="div">
								<xsl:choose>
									<xsl:when test="$inline">
										<xsl:attribute name="class">header_inline_value header_value</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">header_value</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:call-template name="address">
									<xsl:with-param name="addr" select="$addr"/>
									<xsl:with-param name="inline" select="$inline"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
		</xsl:if>
		
		<xsl:if test="$telecom">
			<xsl:variable name="countTelecom" select="count($telecom)"/>
			
			<xsl:variable name="contactsLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Contact details</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Dane kontaktowe</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="contactLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Contact details </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Kontakt </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:if test="$countTelecom &gt; 0">
				<div class="header_element">
					<xsl:choose>
						<xsl:when test="$countTelecom &gt; 1">
							<span class="header_label">
								<xsl:value-of select="$contactsLabel"/>
							</span>
							<div class="header_value">
								<xsl:call-template name="telecoms">
									<xsl:with-param name="telecoms" select="$telecom"/>
								</xsl:call-template>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<span class="header_label">
								<xsl:value-of select="$contactLabel"/>
							</span>
							<xsl:call-template name="telecom">
								<xsl:with-param name="tele" select="$telecom"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<!-- adresy -->
	<xsl:template name="addresses">
		<xsl:param name="addresses"/>
		
		<xsl:for-each select="$addresses">
			<div class="address_element">
				<span class="address_label">
					<xsl:call-template name="translateAddressUseCode">
						<xsl:with-param name="useCode" select="./@use"/>
					</xsl:call-template>
				</span>
				<div class="address_value header_value">
					<xsl:call-template name="address">
						<xsl:with-param name="addr" select="."/>
						<xsl:with-param name="inline" select="false()"/>
					</xsl:call-template>
				</div>
			</div>
		</xsl:for-each>
	</xsl:template>
	
	<!-- adres templateId 2.16.840.1.113883.3.4424.13.10.7.1 -->
	<xsl:template name="address">
		<xsl:param name="addr"/>
		<xsl:param name="inline" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="addressUnitLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text> / </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> lok. </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="postOfficeLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Post office</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Poczta</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<!-- wyświetlenie informacji o braku wyłącznie gdy podano nullFlavor na poziomie całego adresu -->
			<xsl:when test="$addr/@nullFlavor">
				<xsl:call-template name="translateNullFlavor">
					<xsl:with-param name="nullableElement" select="$addr"/>
				</xsl:call-template>
			</xsl:when>
			<!-- adres prosty, jednoliniowy, jeżeli zawiera wyłącznie ulicę, numery, kod pocztowy i miejscowość
				 wprowadzony by zaoszczędzić miejsce w dokumencie -->
			<xsl:when test="$inline">
				<!-- ulica, numer domu, numer mieszkania, kod pocztowy, miejscowość -->
				<xsl:value-of select="$addr/hl7:streetName"/>
				<xsl:if test="string-length($addr/hl7:houseNumber) &gt;= 1">
					<xsl:text> </xsl:text>
					<xsl:value-of select="$addr/hl7:houseNumber"/>
					<xsl:if test="string-length($addr/hl7:unitID) &gt;= 1">
						<xsl:value-of select="$addressUnitLabel"/>
						<xsl:value-of select="$addr/hl7:unitID"/>
					</xsl:if>
				</xsl:if>
				<xsl:if test="string-length($addr/hl7:postalCode) &gt;= 1">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$addr/hl7:postalCode"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$addr/hl7:city"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- standardowa obsługa adresu, który nie mieści się w jednej linii
					 obsługiwane są wyłącznie podstawowe pola zdefiniowane w PL IG (bez unitType, 
					 w którym za granicą wyróżnia się typ lokalu, np. appartment) 
					 oraz pole streetAddressLine wspierające zapis adresów zagranicznych,
					 nie są wyświetlanie adresy wprowadzane w postaci nieanalitycznej, tzw. plain-text -->
				<xsl:if test="$addr/hl7:streetAddressLine or $addr/hl7:streetName or $addr/hl7:city or $addr/hl7:country">
					
					<!-- linie dla adresu zagranicznego, przy czym dopuszczalne jest stosowanie także innych elementów -->
					<xsl:for-each select="$addr/hl7:streetAddressLine">
						<div class="address_line address_street_address_line">
							<xsl:value-of select="."/>
						</div>
					</xsl:for-each>
					
					<!-- układ adresu polskiego, stosowanego także dla adresów zagranicznych z podanym city -->
					<xsl:if test="string-length($addr/hl7:city) &gt;= 1">
						<xsl:choose>
							<xsl:when test="string-length($addr/hl7:streetName) &gt;= 1">
								<!-- ulica, numer domu, numer mieszkania -->
								<div class="address_line address_street_line">
									<xsl:value-of select="$addr/hl7:streetName"/>
									<xsl:if test="string-length($addr/hl7:houseNumber) &gt;= 1">
										<xsl:text> </xsl:text>
										<xsl:value-of select="$addr/hl7:houseNumber"/>
										<xsl:if test="string-length($addr/hl7:unitID) &gt;= 1">
											<xsl:value-of select="$addressUnitLabel"/>
											<xsl:value-of select="$addr/hl7:unitID"/>
										</xsl:if>
									</xsl:if>
								</div>
								<xsl:choose>
									<xsl:when test="not($addr/hl7:postalCode/@postCity) or $addr/hl7:postalCode/@postCity = $addr/hl7:city">
										<!-- adres z ulicą i miejscowością posiadającą pocztę
											ul. Stroma 120
											41-400 Równe -->
										<div class="address_line address_city_line">
											<xsl:if test="string-length($addr/hl7:postalCode) &gt;= 1">
												<xsl:value-of select="$addr/hl7:postalCode"/>
												<xsl:text> </xsl:text>
											</xsl:if>
											<xsl:value-of select="$addr/hl7:city"/>
										</div>
									</xsl:when>
									<xsl:otherwise>
										<!-- adres z ulicą, miejscowością i inną pocztą
											ul. Stroma 120
											Wygoniska
											Poczta: 41-400 Równe -->
										<div class="address_line address_city_line">
											<xsl:value-of select="$addr/hl7:city"/>
										</div>
										<div class="address_line address_postCity_line">
											<xsl:value-of select="$postOfficeLabel"/>
											<xsl:text>: </xsl:text>
											<xsl:if test="string-length($addr/hl7:postalCode) &gt;= 1">
												<xsl:value-of select="$addr/hl7:postalCode"/>
												<xsl:text> </xsl:text>
											</xsl:if>
											<xsl:value-of select="$addr/hl7:postalCode/@postCity"/>
										</div>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<!-- ulica nie istnieje w adresie -->
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="not($addr/hl7:postalCode/@postCity) or $addr/hl7:postalCode/@postCity = $addr/hl7:city">
										<!-- adres bez ulicy, z miejscowością posiadającą pocztę
											41-400 Równe 120 -->
										<div class="address_line address_city_line">
											<xsl:if test="string-length($addr/hl7:postalCode) &gt;= 1">
												<xsl:value-of select="$addr/hl7:postalCode"/>
												<xsl:text> </xsl:text>
											</xsl:if>
											<xsl:value-of select="$addr/hl7:city"/>
											<xsl:if test="string-length($addr/hl7:houseNumber) &gt;= 1">
												<xsl:text> </xsl:text>
												<xsl:value-of select="$addr/hl7:houseNumber"/>
												<xsl:if test="string-length($addr/hl7:unitID) &gt;= 1">
													<xsl:value-of select="$addressUnitLabel"/>
													<xsl:value-of select="$addr/hl7:unitID"/>
												</xsl:if>
											</xsl:if>
										</div>
									</xsl:when>
									<xsl:otherwise>
										<!-- adres bez ulicy, z miejscowością i inną pocztą
											Wygoniska 120
											41-400 Równe -->
										<div class="address_line address_city_line">
											<xsl:value-of select="$addr/hl7:city"/>
											<xsl:if test="string-length($addr/hl7:houseNumber) &gt;= 1">
												<xsl:text> </xsl:text>
												<xsl:value-of select="$addr/hl7:houseNumber"/>
												<xsl:if test="string-length($addr/hl7:unitID) &gt;= 1">
													<xsl:value-of select="$addressUnitLabel"/>
													<xsl:value-of select="$addr/hl7:unitID"/>
												</xsl:if>
											</xsl:if>
										</div>
										<div class="address_line address_postCity_line">
											<xsl:value-of select="$postOfficeLabel"/>
											<xsl:text>: </xsl:text>
											<xsl:if test="string-length($addr/hl7:postalCode) &gt;= 1">
												<xsl:value-of select="$addr/hl7:postalCode"/>
												<xsl:text> </xsl:text>
											</xsl:if>
											<xsl:value-of select="$addr/hl7:postalCode/@postCity"/>
										</div>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<!-- kod teryt hl7:censusTract nie jest wyświetlany, powinien być obsługiwany elektronicznie -->
					
					<!-- kraj gdy inny niż Polska, natomiast ewentualny region/stan nie jest wyświetlany -->
					<xsl:if test="string-length($addr/hl7:country) &gt;= 1 and translate($addr/hl7:country, $LOWERCASE_LETTERS, $UPPERCASE_LETTERS) != 'POLSKA'">
						<div class="address_line address_country_line">
							<xsl:value-of select="$addr/hl7:country"/>
						</div>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- dane kontaktowe -->
	<xsl:template name="telecoms">
		<xsl:param name="telecoms"/>
		
		<xsl:for-each select="$telecoms">
			<div class="telecom">
				<xsl:call-template name="telecom">
					<xsl:with-param name="tele" select="."/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
	</xsl:template>	

	<!-- linia danych kontaktowych -->
	<xsl:template name="telecom">
		<xsl:param name="tele"/>
		
		<xsl:choose>
			<!-- wyświetlenie informacji o braku wyłącznie gdy podano nullFlavor -->
			<xsl:when test="$tele/@nullFlavor">
				<xsl:call-template name="translateNullFlavor">
					<xsl:with-param name="nullableElement" select="$tele"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- format <telecom use="PUB" value="tel: 22 2345 123"/> -->
				<xsl:variable name="address" select="substring-after($tele/@value, ':')"/>
				<xsl:variable name="protocol" select="substring-before($tele/@value, ':')"/>
				
				<xsl:choose>
					<xsl:when test="$address and $protocol">
						<xsl:call-template name="translateTelecomProtocolCode">
							<xsl:with-param name="protocolCode" select="$protocol"/>
						</xsl:call-template>
						
						<xsl:value-of select="$address"/>
						
						<xsl:if test="$tele/@use">
							<xsl:text> (</xsl:text>
							<xsl:call-template name="translateTelecomUseCode">
								<xsl:with-param name="useCode" select="$tele/@use"/>
							</xsl:call-template>
							<xsl:text>)</xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-- dane w niepoprawnym formacie, są jednak wyświetlane -->
						<xsl:value-of select="$tele"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ++++++++++++++ obsługa dat ++++++++++++++++ -->
	
	<!-- ilość dni w miesiącu -->
	<xsl:template name="daysInMonth">
		<xsl:param name="month"/>
		<xsl:param name="year"/>
		
		<xsl:choose>
			<xsl:when test="$month = 1 or $month = 3 or $month = 5 or $month = 7 or $month = 8 or $month = 10 or $month = 12">
				<xsl:value-of select="number(31)"/>
			</xsl:when>
			<xsl:when test="$month = 4 or $month = 6 or $month = 9 or $month = 11">
				<xsl:value-of select="number(30)"/>
			</xsl:when>
			<xsl:when test="$month = 2 and $year mod 4 = 0 and ($year mod 100 != 0 or $year mod 400 = 0)">
				<xsl:value-of select="number(29)"/>
			</xsl:when>
			<xsl:when test="$month = 2">
				<xsl:value-of select="number(28)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number(0)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- data i czas jako @value lub hl7:high/@value i hl7:low/@value -->
	<!-- obsługa ograniczona do danych przeznaczonych do wizualizacji, brak wyświetlania szeregu atrybutów TS i IVL TS -->
	<xsl:template name="dateTimeInDiv">
		<xsl:param name="date"/>
		<xsl:param name="label"/>
		<xsl:param name="divClass"/>
		<xsl:param name="calculateAge" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="ageLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Age</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Wiek w dniu wystawienia</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="fromLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>from </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>od </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="toLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>to </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>do </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="noInformationLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>(no information)</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>(nie podano)</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$date">
			<div class="{$divClass}">
				<xsl:if test="$label">
					<span class="header_label">
						<xsl:value-of select="$label"/>
					</span>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$date/@nullFlavor">
						<xsl:call-template name="translateNullFlavor">
							<xsl:with-param name="nullableElement" select="$date"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$date/@value">
						<div class="header_inline_value header_value">
							<xsl:call-template name="formatDateTime">
								<xsl:with-param name="date" select="$date/@value"/>
							</xsl:call-template>
						</div>
						<xsl:if test="$calculateAge">
							<div class="age_element header_element">
								<span class="header_label">
									<xsl:value-of select="$ageLabel"/>
								</span>
								<div class="header_inline_value header_value">
									<xsl:call-template name="age">
										<xsl:with-param name="startDateValue" select="$date/@value"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
					</xsl:when>
					<xsl:when test="$date/hl7:low/@value or $date/hl7:high/@value">
						<xsl:if test="$date/hl7:low/@value">
							<div class="header_inline_value header_value">
								<xsl:value-of select="$fromLabel"/>
								<xsl:call-template name="formatDateTime">
									<xsl:with-param name="date" select="$date/hl7:low/@value"/>
								</xsl:call-template>
							</div>
						</xsl:if>
						<xsl:if test="$date/hl7:high/@value">
							<div class="header_inline_value header_value">
								<xsl:value-of select="$toLabel"/>
								<xsl:call-template name="formatDateTime">
									<xsl:with-param name="date" select="$date/hl7:high/@value"/>
								</xsl:call-template>
							</div>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$noInformationLabel"/>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="age">
		<xsl:param name="startDateValue"/>
		<xsl:variable name="docDateValue" select="hl7:effectiveTime/@value"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:if test="string-length($startDateValue) &gt;= 8 and string-length($docDateValue) &gt;= 8">
			<xsl:variable name="year" select="number(substring($startDateValue, 1, 4))"/>
			<xsl:variable name="month" select="number(substring($startDateValue, 5, 2))"/>
			<xsl:variable name="day" select="number(substring($startDateValue, 7, 2))"/>
			<xsl:variable name="currYear" select="number(substring($docDateValue, 1, 4))"/>
			<xsl:variable name="currMonth" select="number(substring($docDateValue, 5, 2))"/>
			<xsl:variable name="currDay" select="number(substring($docDateValue, 7, 2))"/>
			
			<!-- własny kod ze względu na ograniczenia XSLT 1.0 bez dodatkowych bibliotek -->
			<xsl:choose>
				<!-- powyżej 7 lat - w latach -->
				<xsl:when test="$currYear &gt; ($year+7) or ($currYear = ($year+7) and ($currMonth &gt; $month or ($currMonth = $month and $currDay &gt;= $day)))">
					<xsl:choose>
						<xsl:when test="$currMonth &gt; $month or ($currMonth = $month and $currDay &gt;= $day)">
							<xsl:call-template name="formatAge">
								<xsl:with-param name="years" select="$currYear - $year"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="formatAge">
								<xsl:with-param name="years" select="$currYear - $year - 1"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				
				<!-- powyżej 3 lat w latach i połowach -->
				<xsl:when test="$currYear &gt; ($year+3) or ($currYear = ($year+3) and ($currMonth &gt; $month or ($currMonth = $month and $currDay &gt;= $day)))">
					<xsl:choose>
						<xsl:when test="$currMonth &gt; $month or ($currMonth = $month and $currDay &gt;= $day)">
							<xsl:call-template name="formatAge">
								<xsl:with-param name="years" select="$currYear - $year"/>
								<!-- w styczniu sie urodz i przekroczylem o więcej niż 6 mies -->
								<xsl:with-param name="half" select="$currMonth &gt; ($month+6) or ($currMonth = ($month+6) and $currDay &gt;= $day)"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<!-- jest w tym roku, ale jeszcze nie skończył -->
							<xsl:call-template name="formatAge">
								<xsl:with-param name="years" select="$currYear - $year - 1"/>
								<!-- np. urodzony w grudniu i jest o mniej niz 6 miesięcy przed urodzinami -->
								<xsl:with-param name="half" select="($currMonth+6) &gt; $month or (($currMonth+6) = $month and $currDay &gt;= $day)"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				
				<!-- powyżej roku w latach i miesiącach -->
				<xsl:when test="$currYear &gt; ($year+1) or ($currYear = ($year+1) and ($currMonth &gt; $month or ($currMonth = $month and $currDay &gt;= $day)))">
					<xsl:choose>
						<xsl:when test="$currMonth &gt; $month or ($currMonth = $month and $currDay &gt;= $day)">
							<!-- różnica w miesiącach -->
							<xsl:choose>
								<xsl:when test="$currDay &gt;= $day">
									<xsl:call-template name="formatAge">
										<xsl:with-param name="years" select="$currYear - $year"/>
										<xsl:with-param name="months" select="$currMonth - $month"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="formatAge">
										<xsl:with-param name="years" select="$currYear - $year"/>
										<xsl:with-param name="months" select="$currMonth - $month - 1"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<!-- jest w tym roku, ale jeszcze nie skończył -->
							<!-- różnica w miesiącach od 12 -->
							<xsl:choose>
								<xsl:when test="$currDay &gt;= $day">
									<xsl:call-template name="formatAge">
										<xsl:with-param name="years" select="$currYear - $year - 1"/>
										<xsl:with-param name="months" select="12 + $currMonth - $month"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="formatAge">
										<xsl:with-param name="years" select="$currYear - $year - 1"/>
										<xsl:with-param name="months" select="12 + $currMonth - $month - 1"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				
				<!-- powyżej 3 miesięcy - w miesiącach -->
				<xsl:when test="$currYear = ($year+1) and ($currMonth &gt; ($month - 9) or ($currMonth = ($month - 9) and $currDay &gt;= $day))
					or $currYear = $year and ($currMonth &gt; ($month+3) or ($currMonth = ($month+3) and $currDay &gt;= $day))">
					<xsl:choose>
						<xsl:when test="$currYear = $year">
							<xsl:choose>
								<xsl:when test="$currDay &gt;= $day">
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="$currMonth - $month"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="$currMonth - $month - 1"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$currDay &gt;= $day">
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="12 + $currMonth - $month"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="12 + $currMonth - $month - 1"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				
				<!-- powyżej 1 miesiąca - w miesiącach i tygodniach-->
				<xsl:when test="$currYear = ($year+1) and ($currMonth &gt; ($month - 11)) or ($currMonth = ($month - 11) and $currDay &gt;= $day)
					or $currYear = $year and ($currMonth &gt; ($month+1) or ($currMonth = ($month+1) and $currDay &gt;= $day))">
					<xsl:choose>
						<xsl:when test="$currYear = $year">
							<xsl:choose>
								<xsl:when test="$currDay &gt;= $day">
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="$currMonth - $month"/>
										<!-- tygodnie powyżej wyznaczonej liczby miesięcy, czyli różnica między dniami/7 -->
										<xsl:with-param name="weeks" select="($currDay - $day) div 7"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="previousMonthLength">
										<xsl:call-template name="daysInMonth">
											<!-- bezpieczne $currMonth - 1 z uwagi na wcześniejsze warunki -->
											<xsl:with-param name="month" select="$currMonth - 1"/>
											<xsl:with-param name="year" select="$currYear"/>
										</xsl:call-template>
									</xsl:variable>
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="$currMonth - $month - 1"/>
										<!-- tygodnie powyżej wyznaczonej liczby miesięcy, uzupełniam o liczbę dni poprzedniego miesiąca -->
										<xsl:with-param name="weeks" select="($previousMonthLength + $currDay - $day) div 7"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$currDay &gt;= $day">
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="12 + $currMonth - $month"/>
										<!-- tygodnie powyżej wyznaczonej liczby miesięcy -->
										<xsl:with-param name="weeks" select="($currDay - $day) div 7"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="previousMonthLength">
										<xsl:choose>
											<xsl:when test="$currMonth = 1">
												<xsl:call-template name="daysInMonth">
													<xsl:with-param name="month" select="12"/>
													<xsl:with-param name="year" select="$currYear"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="daysInMonth">
													<xsl:with-param name="month" select="$currMonth - 1"/>
													<xsl:with-param name="year" select="$currYear"/>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:call-template name="formatAge">
										<xsl:with-param name="months" select="12 + $currMonth - $month - 1"/>
										<!-- tygodnie powyżej wyznaczonej liczby miesięcy -->
										<xsl:with-param name="weeks" select="($previousMonthLength + $currDay - $day) div 7"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				
				<!-- poniżej 1 miesiąca - w tygodniach i dniach -->
				<xsl:otherwise>
					<!-- liczba dni: rok nie jest istotny, miesiąc ten sam lub +1 lub grudzień/styczeń -->
					<xsl:choose>
						<xsl:when test="$currMonth = $month and $currDay = $day">
							<xsl:if test="$lang = $secondLanguage">
								<xsl:text>born in the day the document was issued</xsl:text>
							</xsl:if>
							<xsl:if test="$lang != $secondLanguage">
								<xsl:text>urodzony w dniu wystawienia dokumentu</xsl:text>
							</xsl:if>
						</xsl:when>
						<xsl:when test="$currMonth = $month">
							<xsl:call-template name="formatAge">
								<xsl:with-param name="weeks" select="($currDay - $day) div 7"/>
								<xsl:with-param name="days" select="($currDay - $day) mod 7"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="monthLength">
								<xsl:call-template name="daysInMonth">
									<xsl:with-param name="month" select="$month"/>
									<xsl:with-param name="year" select="$year"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:call-template name="formatAge">
								<xsl:with-param name="weeks" select="($monthLength + $currDay - $day) div 7"/>
								<xsl:with-param name="days" select="($monthLength + $currDay - $day) mod 7"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="formatAge">
		<xsl:param name="years" select="false()"/>
		<xsl:param name="half" select="false()"/>
		<xsl:param name="months" select="false()"/>
		<xsl:param name="weeks" select="false()"/>
		<xsl:param name="days" select="false()"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:if test="$years &gt; 0">
			<xsl:value-of select="$years"/>
			<xsl:variable name="year" select="format-number($years, '000')" />
			<xsl:variable name="tens" select="number(substring($year, 2, 1))"/>
			<xsl:variable name="decs" select="number(substring($year, 3, 1))"/>
			<xsl:choose>
				<xsl:when test="$years = 1 and $lang = $secondLanguage">
					<xsl:text> year</xsl:text>
				</xsl:when>
				<xsl:when test="$years = 1">
					<xsl:text> rok</xsl:text>
				</xsl:when>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text> years</xsl:text>
				</xsl:when>
				<xsl:when test="$years &lt; 5">
					<xsl:text> lata</xsl:text>
				</xsl:when>
				<xsl:when test="$years &lt; 22">
					<xsl:text> lat</xsl:text>
				</xsl:when>
				<xsl:when test="$decs &gt;= 2 and $decs &lt;= 4 and $tens != 1">
					<xsl:text> lata</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> lat</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$half and $lang = $secondLanguage">
			<xsl:text> and a half</xsl:text>
		</xsl:if>
		<xsl:if test="$half">
			<xsl:text> i pół</xsl:text>
		</xsl:if>
		<xsl:if test="$months &gt; 0">
			<xsl:if test="$years &gt; 0 and $lang = $secondLanguage">
				<xsl:text> and </xsl:text>
			</xsl:if>
			<xsl:if test="$years &gt; 0 and $lang != $secondLanguage">
				<xsl:text> i </xsl:text>
			</xsl:if>
			<xsl:value-of select="$months"/>
			<xsl:choose>
				<xsl:when test="$months = 1 and $lang = $secondLanguage">
					<xsl:text> month</xsl:text>
				</xsl:when>
				<xsl:when test="$months = 1">
					<xsl:text> miesiąc</xsl:text>
				</xsl:when>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text> months</xsl:text>
				</xsl:when>
				<xsl:when test="$months &lt; 5">
					<xsl:text> miesiące</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> miesięcy</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$weeks &gt;= 1">
			<!-- zaokrąglenie w dół w XSLT 1.0 -->
			<xsl:variable name="weeksRounded" select="format-number($weeks - 0.5, '##0')"/>
			<xsl:if test="$months &gt; 0 and $lang = $secondLanguage">
				<xsl:text> and </xsl:text>
			</xsl:if>
			<xsl:if test="$months &gt; 0 and $lang != $secondLanguage">
				<xsl:text> i </xsl:text>
			</xsl:if>
			<xsl:value-of select="$weeksRounded"/>
			<xsl:choose>
				<xsl:when test="$weeks = 1 and $lang = $secondLanguage">
					<xsl:text> week</xsl:text>
				</xsl:when>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text> weeks</xsl:text>
				</xsl:when>
				<xsl:when test="$weeksRounded &gt;= 5">
					<xsl:text> tygodni</xsl:text>
				</xsl:when>
				<xsl:when test="$weeksRounded &gt;= 2">
					<xsl:text> tygodnie</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> tydzień</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$days &gt; 0">
			<xsl:if test="$weeks &gt;= 1 and $lang = $secondLanguage">
				<xsl:text> i </xsl:text>
			</xsl:if>
			<xsl:if test="$weeks &gt;= 1 and $lang != $secondLanguage">
				<xsl:text> i </xsl:text>
			</xsl:if>
			<xsl:value-of select="$days"/>
			<xsl:choose>
				<xsl:when test="$days = 1 and $lang = $secondLanguage">
					<xsl:text> day</xsl:text>
				</xsl:when>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text> days</xsl:text>
				</xsl:when>
				<xsl:when test="$days = 1">
					<xsl:text> dzień</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> dni</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- formatowanie daty i czasu -->
	<xsl:template name="formatDateTime">
		<xsl:param name="date"/>
		
		<xsl:param name="year" select="number(substring($date, 1, 4))"/>
		<xsl:param name="monthIndex" select="number(substring($date, 5, 2))"/>
		<xsl:param name="day" select="number(substring($date, 7, 2))"/>
		<xsl:param name="hour" select="substring($date, 9, 2)"/>
		<xsl:param name="minute" select="substring($date, 11, 2)"/>
		<xsl:param name="second" select="substring($date, 13, 2)"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="ageLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Age</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Wiek w dniu wystawienia</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$day">
				<xsl:value-of select="$day"/>
				<xsl:text> </xsl:text>
				<xsl:call-template name="translateFullDateMonth">
					<xsl:with-param name="month" select="$monthIndex"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$year"/>
				
				<xsl:if test="$lang != $secondLanguage">
					<xsl:text> r.</xsl:text>
				</xsl:if>
				
				<xsl:if test="$hour">
					<xsl:variable name="displayHour">
						<xsl:choose>
							<xsl:when test="$hour = 00">
								<xsl:value-of select="$hour"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="number($hour)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable> 
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="$minute">
							<xsl:if test="$lang != $secondLanguage">
								<xsl:text> godz. </xsl:text>
							</xsl:if>
							<xsl:value-of select="$displayHour"/>
							<xsl:text>:</xsl:text>
							<xsl:value-of select="$minute"/>
							<xsl:if test="$second">
								<xsl:text>:</xsl:text>
								<xsl:value-of select="$second"/>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="$lang != $secondLanguage">
								<xsl:text> godz. ok. </xsl:text>
								<xsl:value-of select="$displayHour"/>
								<xsl:text>.</xsl:text>
							</xsl:if>
							<xsl:if test="$lang = $secondLanguage">
								<xsl:text> at about </xsl:text>
								<xsl:value-of select="$displayHour"/>
								<xsl:text> hour</xsl:text>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$monthIndex">
					<xsl:call-template name="translateMonth">
						<xsl:with-param name="month" select="$monthIndex"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$year"/>
				<xsl:if test="$lang != $secondLanguage">
					<xsl:text> r.</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++ KODY / ZBIORY WARTOŚCI +++++++++++++++++++++++++++++++++++++++++++++++++++++-->
	
	<!-- kod poufności -->
	<xsl:template name="confidentialityCode">
		<xsl:param name="cCode"/>
		<!-- kod poufności wyświetlany jest wyłącznie dla wyższych poziomów -->
		<xsl:if test="$cCode and $cCode/@code != 'N' and not($cCode/@nullFlavor)">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			<xsl:element name="span">
				<xsl:attribute name="class">confidentiality_code_value</xsl:attribute>
				<xsl:choose>
					<xsl:when test="$cCode/@code = 'N' and $lang = $secondLanguage">
						<xsl:text>Normal confidentiality</xsl:text>
					</xsl:when>
					<xsl:when test="$cCode/@code = 'N'">
						<xsl:text>Poufność normalna</xsl:text>
					</xsl:when>
					<xsl:when test="$cCode/@code = 'R' and $lang = $secondLanguage">
						<xsl:text>RESTRICTED</xsl:text>
					</xsl:when>
					<xsl:when test="$cCode/@code = 'R'">
						<xsl:text>POUFNE</xsl:text>
					</xsl:when>
					<xsl:when test="$cCode/@code = 'V' and $lang = $secondLanguage">
						<xsl:text>VERY RESTRICTED</xsl:text>
					</xsl:when>
					<xsl:when test="$cCode/@code = 'V'">
						<xsl:text>WYSOCE POUFNE</xsl:text>
					</xsl:when>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Confidentiality: </xsl:text>
						<xsl:value-of select="$cCode/@code"/>
					</xsl:when>
					<xsl:otherwise>
						<!--Kod nieznany, wyświetlany bezpośrednio-->
						<xsl:text>Poufność: </xsl:text>
						<xsl:value-of select="$cCode/@code"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<!-- źródło - HL7 V3 Data Types 2.19.2 Telecommunication Use Code -->
	<xsl:template name="translateTelecomUseCode">
		<xsl:param name="useCode"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:choose>
			<xsl:when test="($useCode='H' or $useCode='HP') and $lang = $secondLanguage">
				<xsl:text>home</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='H' or $useCode='HP'">
				<xsl:text>domowy</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='HV' and $lang = $secondLanguage">
				<xsl:text>vacation home</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='HV'">
				<xsl:text>podczas urlopu</xsl:text>
			</xsl:when>
			
			<xsl:when test="$useCode='WP' and $lang = $secondLanguage">
				<xsl:text>work place</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='WP'">
				<xsl:text>służbowy</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='DIR' and $lang = $secondLanguage">
				<xsl:text>direct</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='DIR'">
				<xsl:text>służbowy bezpośredni</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='PUB' and $lang = $secondLanguage">
				<xsl:text>public</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='PUB'">
				<xsl:text>rejestracja</xsl:text>
			</xsl:when>
			
			<xsl:when test="$useCode='TMP' and $lang = $secondLanguage">
				<xsl:text>temporary address</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='TMP'">
				<xsl:text>tymczasowy</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='EC' and $lang = $secondLanguage">
				<xsl:text>emergency</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='EC'">
				<xsl:text>w nagłych przypadkach</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='MC' and $lang = $secondLanguage">
				<xsl:text>mobile</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='MC'">
				<xsl:text>komórkowy</xsl:text>
			</xsl:when>
			
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>unrecognized: </xsl:text>
				<xsl:value-of select="$useCode"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>inny: </xsl:text>
				<xsl:value-of select="$useCode"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- źródło - HL7 V3 Data Types 2.18.1 Protocol Code -->
	<xsl:template name="translateTelecomProtocolCode">
		<xsl:param name="protocolCode"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:choose>
			<xsl:when test="$protocolCode='tel' and $lang = $secondLanguage">
				<xsl:text>phone: </xsl:text>
			</xsl:when>
			<xsl:when test="$protocolCode='tel'">
				<xsl:text>tel: </xsl:text>
			</xsl:when>
			<xsl:when test="$protocolCode='fax' and $lang = $secondLanguage">
				<xsl:text>fax: </xsl:text>
			</xsl:when>
			<xsl:when test="$protocolCode='fax'">
				<xsl:text>faks: </xsl:text>
			</xsl:when>
			<xsl:when test="$protocolCode='http'">
				<xsl:text>Internet: </xsl:text>
			</xsl:when>
			<xsl:when test="$protocolCode='mailto'">
				<xsl:text>e-mail: </xsl:text>
			</xsl:when>
			<!-- pozostałe przypadki są nieistotne, będą jednak wyświetlane -->
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>unrecognized: </xsl:text>
				<xsl:value-of select="$protocolCode"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>inny: </xsl:text>
				<xsl:value-of select="$protocolCode"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<!-- źródło - HL7 V3 Data Types 2.21.1 Postal Address Use Code -->
	<xsl:template name="translateAddressUseCode">
		<xsl:param name="useCode"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:choose>
			<!-- podstawowy adres instytucji, biura lub pracy -->
			<xsl:when test="(not($useCode) or $useCode='WP' or $useCode='DIR' or $useCode='PUB' or $useCode='PHYS') and $lang = $secondLanguage">
				<xsl:text>Address</xsl:text>
			</xsl:when>
			<xsl:when test="not($useCode) or $useCode='WP' or $useCode='DIR' or $useCode='PUB' or $useCode='PHYS'">
				<xsl:text>Adres</xsl:text>
			</xsl:when>
			
			<xsl:when test="($useCode='H' or $useCode='HP') and $lang = $secondLanguage">
				<xsl:text>Home address</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='H' or $useCode='HP'">
				<xsl:text>Adres zamieszkania</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='HV' and $lang = $secondLanguage">
				<xsl:text>Vacation home</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='HV'">
				<xsl:text>Adres w trakcie urlopu</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='TMP' and $lang = $secondLanguage">
				<xsl:text>Temporary address</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='TMP'">
				<xsl:text>Adres tymczasowy</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='PST' and $lang = $secondLanguage">
				<xsl:text>Postal address</xsl:text>
			</xsl:when>
			<xsl:when test="$useCode='PST'">
				<xsl:text>Adres korespondencyjny</xsl:text>
			</xsl:when>
			
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>Address (</xsl:text>
				<xsl:value-of select="$useCode"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Inny adres (</xsl:text>
				<xsl:value-of select="$useCode"/>
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- typy powiązań do dokumentu nadrzędnego -->
	<xsl:template name="translateRelatedDocumentCode">
		<xsl:param name="typeCode"/>
		<xsl:param name="lang"/>
		
		<xsl:choose>
			<xsl:when test="$typeCode='RPLC' and $lang = $secondLanguage">
				<xsl:text>Replacement of document with ID</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='RPLC'">
				<xsl:text>Korekta dokumentu o ID</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='APND' and $lang = $secondLanguage">
				<xsl:text>Addendum to document with ID</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='APND'">
				<xsl:text>Załącznik do dokumentu o ID</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='XFRM' and $lang = $secondLanguage">
				<xsl:text>Transformation of document with ID</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='XFRM'">
				<xsl:text>Wynik transformaty dokumentu o ID</xsl:text>
			</xsl:when>
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>Unknown relationship (</xsl:text>
				<xsl:value-of select="$typeCode"/>
				<xsl:text>) to document with ID</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Nieznane powiązanie (</xsl:text>
				<xsl:value-of select="$typeCode"/>
				<xsl:text>) z dokumentem o ID</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- rola uczestnika wizyty, value set 2.16.840.1.113883.1.11.19600 -->
	<xsl:template name="translateEncounterParticipantTypeCode">
		<xsl:param name="typeCode"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:choose>
			<xsl:when test="$typeCode='ADM' and $lang = $secondLanguage">
				<xsl:text>admitter</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='ADM'">
				<xsl:text>przyjmujący</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='ATND' and $lang = $secondLanguage">
				<xsl:text>attender</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='ATND'">
				<xsl:text>asystent</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='CON' and $lang = $secondLanguage">
				<xsl:text>consultant</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='CON'">
				<xsl:text>konsultant</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='DIS' and $lang = $secondLanguage">
				<xsl:text>discharger</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='DIS'">
				<xsl:text>wypisujący</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='REF' and $lang = $secondLanguage">
				<xsl:text>referrer</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='REF'">
				<xsl:text>kierujący</xsl:text>
			</xsl:when>
			
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>unrecognized role (</xsl:text>
				<xsl:value-of select="$typeCode"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>nieznana rola (</xsl:text>
				<xsl:value-of select="$typeCode"/>
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- rola realizatora usługi, value set 2.16.840.1.113883.1.11.19601 -->
	<xsl:template name="translateServiceEventPerformerTypeCode">
		<xsl:param name="typeCode"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:choose>
			<xsl:when test="$typeCode='PRF' and $lang = $secondLanguage">
				<xsl:text>performer</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='PRF'">
				<xsl:text>wykonawca</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='PPRF' and $lang = $secondLanguage">
				<xsl:text>primary performer</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='PPRF'">
				<xsl:text>główny wykonawca</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='SPRF' and $lang = $secondLanguage">
				<xsl:text>secondary performer</xsl:text>
			</xsl:when>
			<xsl:when test="$typeCode='SPRF'">
				<xsl:text>wykonawca</xsl:text>
			</xsl:when>
			
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>unrecognized role (</xsl:text>
				<xsl:value-of select="$typeCode"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>nieznana rola (</xsl:text>
				<xsl:value-of select="$typeCode"/>
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- funkcja realizatora usługi, value set 2.16.840.1.113883.1.11.10267 ze słownika 2.16.840.1.113883.5.88 -->
	<xsl:template name="translateServiceEventPerformerFunctionCode">
		<xsl:param name="functionCode"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:choose>
			<xsl:when test="$functionCode='ADMPHYS' and $lang = $secondLanguage">
				<xsl:text>admitting physician</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='ADMPHYS'">
				<xsl:text>lekarz kwalifikujący</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='ANEST' and $lang = $secondLanguage">
				<xsl:text>anesthesist</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='ANEST'">
				<xsl:text>anestezjolog</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='ANRS' and $lang = $secondLanguage">
				<xsl:text>anesthesia nurse</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='ANRS'">
				<xsl:text>pielęgniarka anestezjologiczna</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='ATTPHYS' and $lang = $secondLanguage">
				<xsl:text>attending physician</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='ATTPHYS'">
				<xsl:text>lekarz prowadzący</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='DISPHYS' and $lang = $secondLanguage">
				<xsl:text>discharging physician</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='DISPHYS'">
				<xsl:text>lekarz wypisujący</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='FASST' and $lang = $secondLanguage">
				<xsl:text>first assistant surgeon</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='FASST'">
				<xsl:text>pierwsza asysta chirurgiczna</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='MDWF' and $lang = $secondLanguage">
				<xsl:text>midwife</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='MDWF'">
				<xsl:text>położna</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='NASST' and $lang = $secondLanguage">
				<xsl:text>nurse assistant</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='NASST'">
				<!-- nurse assistant (non-sterile): pielęgniarka instrumentariuszka brudna -->
				<xsl:text>pielęgniarka asystująca</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='PCP' and $lang = $secondLanguage">
				<xsl:text>primary care physician</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='PCP'">
				<xsl:text>lekarz pierwszego kontaktu</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='PRISURG' and $lang = $secondLanguage">
				<xsl:text>primary surgeon</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='PRISURG'">
				<!-- primary surgeon: "chirurg prowadzący" zgodnie z Rozporządzeniem MZ § 33. 13) -->
				<xsl:text>chirurg prowadzący</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='RNDPHYS' and $lang = $secondLanguage">
				<xsl:text>rounding physician</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='RNDPHYS'">
				<xsl:text>lekarz wykonujący obchód</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='SASST' and $lang = $secondLanguage">
				<xsl:text>second assistant surgeon</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='SASST'">
				<!-- second assistant surgeon -->
				<xsl:text>druga asysta chirurgiczna</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='SNRS' and $lang = $secondLanguage">
				<xsl:text>scrub nurse</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='SNRS'">
				<!-- scrub nurse (sterile): pielęgniarka instrumentariuszka czysta -->
				<xsl:text>pielęgniarka operacyjna</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='TASST' and $lang = $secondLanguage">
				<xsl:text>third assistant</xsl:text>
			</xsl:when>
			<xsl:when test="$functionCode='TASST'">
				<!-- third assistant: występuje w rzadkich przypadkach, nie stosuje się słowa 'chirurgiczna' -->
				<xsl:text>trzecia asysta</xsl:text>
			</xsl:when>
			
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>unrecognized function (</xsl:text>
				<xsl:value-of select="$functionCode"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>inna funkcja (</xsl:text>
				<xsl:value-of select="$functionCode"/>
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- relacje międzyludzkie, podstawowe, value set PersonalRelationshipRoleType 2.16.840.1.113883.1.11.19563 
		 ze słownika 2.16.840.1.113883.5.111 http://wiki.hl7.de/index.php?title=2.16.840.1.113883.5.111
		 celowo rozszerzony w stosunku do bardzo krótkiego zbioru wypisanego w PIK HL7 CDA -->
	<xsl:template name="translatePersonalRelationshipRoleCode">
		<xsl:param name="roleCode"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:choose>
			<xsl:when test="$roleCode='MTH' and $lang = $secondLanguage"><xsl:text>Mother</xsl:text></xsl:when>
			<xsl:when test="$roleCode='MTH'"><xsl:text>Matka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='FTH' and $lang = $secondLanguage"><xsl:text>Father</xsl:text></xsl:when>
			<xsl:when test="$roleCode='FTH'"><xsl:text>Ojciec</xsl:text></xsl:when>
			<xsl:when test="$roleCode='CHILD' and $lang = $secondLanguage"><xsl:text>Child</xsl:text></xsl:when>
			<xsl:when test="$roleCode='CHILD'"><xsl:text>Dziecko</xsl:text></xsl:when>
			<xsl:when test="$roleCode='DAU' and $lang = $secondLanguage"><xsl:text>Daughter</xsl:text></xsl:when>
			<xsl:when test="$roleCode='DAU'"><xsl:text>Córka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='DAUC' and $lang = $secondLanguage"><xsl:text>Daughter</xsl:text></xsl:when>
			<xsl:when test="$roleCode='DAUC'"><xsl:text>Córka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SON' and $lang = $secondLanguage"><xsl:text>Son</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SON'"><xsl:text>Syn</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SONC' and $lang = $secondLanguage"><xsl:text>Son</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SONC'"><xsl:text>Syn</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NSON' and $lang = $secondLanguage"><xsl:text>Son</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NSON'"><xsl:text>Syn</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NDAU' and $lang = $secondLanguage"><xsl:text>Daughter</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NDAU'"><xsl:text>Córka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='COUSN' and $lang = $secondLanguage"><xsl:text>Cousin</xsl:text></xsl:when>
			<xsl:when test="$roleCode='COUSN'"><xsl:text>Kuzyn</xsl:text></xsl:when>
			<xsl:when test="$roleCode='CHLDINLAW' and $lang = $secondLanguage"><xsl:text>Child in-law</xsl:text></xsl:when>
			<xsl:when test="$roleCode='CHLDINLAW'"><xsl:text>Dziecko przybrane</xsl:text></xsl:when>
			<xsl:when test="$roleCode='CHLDADOPT' and $lang = $secondLanguage"><xsl:text>Adopted child</xsl:text></xsl:when>
			<xsl:when test="$roleCode='CHLDADOPT'"><xsl:text>Dziecko adoptowane</xsl:text></xsl:when>
			<xsl:when test="$roleCode='GRPRN' and $lang = $secondLanguage"><xsl:text>Grandparent</xsl:text></xsl:when>
			<xsl:when test="$roleCode='GRPRN'"><xsl:text>Dziadek/babcia</xsl:text></xsl:when>
			<xsl:when test="$roleCode='GRARNT' and $lang = $secondLanguage"><xsl:text>Grandparent</xsl:text></xsl:when>
			<xsl:when test="$roleCode='GRARNT'"><xsl:text>Dziadek/babcia</xsl:text></xsl:when>
			<xsl:when test="$roleCode='GRNDCHILD' and $lang = $secondLanguage"><xsl:text>Grandchild</xsl:text></xsl:when>
			<xsl:when test="$roleCode='GRNDCHILD'"><xsl:text>Wnuk/wnuczka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='FAMMEMB' and $lang = $secondLanguage"><xsl:text>Family member</xsl:text></xsl:when>
			<xsl:when test="$roleCode='FAMMEMB'"><xsl:text>Członek rodziny</xsl:text></xsl:when>
			<xsl:when test="$roleCode='AUNT' and $lang = $secondLanguage"><xsl:text>Aunt</xsl:text></xsl:when>
			<xsl:when test="$roleCode='AUNT'"><xsl:text>Ciotka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='UNCLE' and $lang = $secondLanguage"><xsl:text>Uncle</xsl:text></xsl:when>
			<xsl:when test="$roleCode='UNCLE'"><xsl:text>Wuj</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NPRN' and $lang = $secondLanguage"><xsl:text>Parent</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NPRN'"><xsl:text>Rodzic</xsl:text></xsl:when>
			<xsl:when test="$roleCode='PRN' and $lang = $secondLanguage"><xsl:text>Parent</xsl:text></xsl:when>
			<xsl:when test="$roleCode='PRN'"><xsl:text>Rodzic</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SIB' and $lang = $secondLanguage"><xsl:text>Sibling</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SIB'"><xsl:text>Rodzeństwo</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SPS' and $lang = $secondLanguage"><xsl:text>Spouse</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SPS'"><xsl:text>Małżonek/małżonka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='HUSB' and $lang = $secondLanguage"><xsl:text>Husband</xsl:text></xsl:when>
			<xsl:when test="$roleCode='HUSB'"><xsl:text>Mąż</xsl:text></xsl:when>
			<xsl:when test="$roleCode='WIFE' and $lang = $secondLanguage"><xsl:text>Wife</xsl:text></xsl:when>
			<xsl:when test="$roleCode='WIFE'"><xsl:text>Żona</xsl:text></xsl:when>
			<xsl:when test="$roleCode='PRNINLAW' and $lang = $secondLanguage"><xsl:text>Parent in-law</xsl:text></xsl:when>
			<xsl:when test="$roleCode='PRNINLAW'"><xsl:text>Rodzic przybrany</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NBOR' and $lang = $secondLanguage"><xsl:text>Neighbor</xsl:text></xsl:when>
			<xsl:when test="$roleCode='NBOR'"><xsl:text>Sąsiad</xsl:text></xsl:when>
			<xsl:when test="$roleCode='FRND' and $lang = $secondLanguage"><xsl:text>Unrelated friend</xsl:text></xsl:when>
			<xsl:when test="$roleCode='FRND'"><xsl:text>Przyjaciel</xsl:text></xsl:when>
			<xsl:when test="$roleCode='DOMPART' and $lang = $secondLanguage"><xsl:text>Domestic partner</xsl:text></xsl:when>
			<xsl:when test="$roleCode='DOMPART'"><xsl:text>Partner/partnerka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='EXT' and $lang = $secondLanguage"><xsl:text>Extended family member</xsl:text></xsl:when>
			<xsl:when test="$roleCode='EXT'"><xsl:text>Daleki członek rodziny</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SIGOTHR' and $lang = $secondLanguage"><xsl:text>Significant other</xsl:text></xsl:when>
			<xsl:when test="$roleCode='SIGOTHR'"><xsl:text>Partner/partnerka</xsl:text></xsl:when>
			<xsl:when test="$roleCode='ROOM' and $lang = $secondLanguage"><xsl:text>Roommate</xsl:text></xsl:when>
			<xsl:when test="$roleCode='ROOM'"><xsl:text>Współlokator</xsl:text></xsl:when>
			<xsl:when test="$roleCode='ONESELF' and $lang = $secondLanguage"><xsl:text>Self</xsl:text></xsl:when>
			<xsl:when test="$roleCode='ONESELF'"><xsl:text>Ta sama osoba</xsl:text></xsl:when>
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>unrecognized relationship (</xsl:text>
				<xsl:value-of select="$roleCode"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>inna relacja (</xsl:text>
				<xsl:value-of select="$roleCode"/>
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="translateReimbursementRelatedContractId">
		<xsl:param name="oid"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:choose>
			<!-- angielskojęzyczna wersja uproszczona, bez numeru oddziału -->
			<xsl:when test="$lang = $secondLanguage">
				<xsl:text>NFZ contract number</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.1'">
				<xsl:text>Umowa z 01 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.2'">
				<xsl:text>Umowa z 02 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.3'">
				<xsl:text>Umowa z 03 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.4'">
				<xsl:text>Umowa z 04 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.5'">
				<xsl:text>Umowa z 05 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.6'">
				<xsl:text>Umowa z 06 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.7'">
				<xsl:text>Umowa z 07 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.8'">
				<xsl:text>Umowa z 08 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.9'">
				<xsl:text>Umowa z 09 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.10'">
				<xsl:text>Umowa z 10 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.11'">
				<xsl:text>Umowa z 11 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.12'">
				<xsl:text>Umowa z 12 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.13'">
				<xsl:text>Umowa z 13 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.14'">
				<xsl:text>Umowa z 14 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.15'">
				<xsl:text>Umowa z 15 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.6.1.16'">
				<xsl:text>Umowa z 16 Oddziałem NFZ</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Umowa (nieznany Oddział NFZ)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- znane węzły OID -->
	<xsl:template name="translateOID">
		<xsl:param name="oid"/>
		<xsl:param name="ext"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:choose>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.1.1.616'">
				<xsl:text>PESEL</xsl:text>
			</xsl:when>
			<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.6.')">
				<xsl:text>NPWZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.2.1'">
				<xsl:text>REGON</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.2.2'">
				<xsl:text>REGON</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.1'">
				<xsl:text>NIP</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.3.1'">
				<xsl:text>cz. I sys. kod. res.</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.3.2'">
				<xsl:text>cz. I-V sys. kod. res.</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.3.3'">
				<xsl:text>cz. I-VII sys. kod. res.</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.6' and $lang = $secondLanguage">
				<xsl:text>Register of pharmacies</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.6'">
				<xsl:text>Wpis w Rejestrze Aptek</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.3.1'">
				<xsl:choose>
					<xsl:when test="$ext='01'">
						<xsl:text>Dolnośląski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='02'">
						<xsl:text>Kujawsko-Pomorski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='03'">
						<xsl:text>Lubelski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='04'">
						<xsl:text>Lubuski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='05'">
						<xsl:text>Łódzki Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='06'">
						<xsl:text>Małopolski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='07'">
						<xsl:text>Mazowiecki Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='08'">
						<xsl:text>Opolski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='09'">
						<xsl:text>Podkarpacki Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='10'">
						<xsl:text>Podlaski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='11'">
						<xsl:text>Pomorski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='12'">
						<xsl:text>Śląski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='13'">
						<xsl:text>Świętokrzyski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='14'">
						<xsl:text>Warmińsko-Mazurski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='15'">
						<xsl:text>Wielkopolski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='16'">
						<xsl:text>Zachodniopomorski Oddział NFZ</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='95'">
						<xsl:text>Minister Pracy i Polityki Społecznej</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='96'">
						<xsl:text>Minister Edukacji Narodowej</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='97'">
						<xsl:text>Minister Obrony Narodowej</xsl:text>
					</xsl:when>
					<xsl:when test="$ext='98'">
						<xsl:text>Minister Zdrowia</xsl:text>
					</xsl:when>
					<!-- nie tłumaczymy nazw Oddziałów, wyświetlane są polskie nazwy, poniższe wyłacznie gdy kod nie jest rozpoznany -->
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>other</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>inny</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.11.1.49' and $lang = $secondLanguage">
				<xsl:call-template name="translateISO3166alfa2orISO3166">
					<xsl:with-param name="codeValue" select="$ext"/>
				</xsl:call-template>
				<xsl:text> - country code </xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.11.1.49'">
				<xsl:call-template name="translateISO3166alfa2orISO3166">
					<xsl:with-param name="codeValue" select="$ext"/>
				</xsl:call-template>
				<xsl:text> - kod kraju </xsl:text>
			</xsl:when>
			<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.')">
				<xsl:choose>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.50')"><xsl:text>Wpis OIL w Białymstoku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.51')"><xsl:text>Wpis OIL w Bielsku-Białej</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.52')"><xsl:text>Wpis OIL w Bydgoszczy</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.53')"><xsl:text>Wpis OIL w Gdańsku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.54')"><xsl:text>Wpis OIL w Gorzowie Wielkopolskim</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.55')"><xsl:text>Wpis OIL w Katowicach</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.56')"><xsl:text>Wpis OIL w Kielcach</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.57')"><xsl:text>Wpis OIL w Krakowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.58')"><xsl:text>Wpis OIL w Lublinie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.59')"><xsl:text>Wpis OIL w Łodzi</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.60')"><xsl:text>Wpis OIL w Olsztynie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.61')"><xsl:text>Wpis OIL w Opolu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.62')"><xsl:text>Wpis OIL w Płocku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.63')"><xsl:text>Wpis OIL w Poznaniu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.64')"><xsl:text>Wpis OIL w Rzeszowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.65')"><xsl:text>Wpis OIL w Szczecinie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.66')"><xsl:text>Wpis OIL w Tarnowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.67')"><xsl:text>Wpis OIL w Toruniu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.68')"><xsl:text>Wpis OIL w Warszawie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.69')"><xsl:text>Wpis OIL we Wrocławiu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.70')"><xsl:text>Wpis OIL w Zielonej Górze</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.72')"><xsl:text>Wpis Wojskowej Izby Lekarskiej</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.74')"><xsl:text>Wpis OIL w Koszalinie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.4.75')"><xsl:text>Wpis OIL w Częstochowie</xsl:text></xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.')">
				<xsl:choose>
					<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.5.1' or $oid='2.16.840.1.113883.3.4424.2.5.1.1'"><xsl:text>Wpis OIPiP w Białej Podlaskiej</xsl:text></xsl:when>
					<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.5.2' or $oid='2.16.840.1.113883.3.4424.2.5.2.1'"><xsl:text>Wpis OIPiP w Białymstoku</xsl:text></xsl:when>
					<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.5.3' or $oid='2.16.840.1.113883.3.4424.2.5.3.1'"><xsl:text>Wpis OIPiP w Bielsku-Białej</xsl:text></xsl:when>
					<xsl:when test="$oid='2.16.840.1.113883.3.4424.2.5.4' or $oid='2.16.840.1.113883.3.4424.2.5.4.1'"><xsl:text>Wpis OIPiP w Bydgoszczy</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.5')"><xsl:text>Wpis OIPiP w Chełmnie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.6')"><xsl:text>Wpis OIPiP w Ciechanowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.7')"><xsl:text>Wpis OIPiP w Częstochowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.8')"><xsl:text>Wpis OIPiP w Elblągu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.9')"><xsl:text>Wpis OIPiP w Gdańsku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.10')"><xsl:text>Wpis OIPiP w Gorzowie Wielkopolskim</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.11')"><xsl:text>Wpis OIPiP w Jeleniej Górze</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.12')"><xsl:text>Wpis OIPiP w Kaliszu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.13')"><xsl:text>Wpis OIPiP w Katowicach</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.14')"><xsl:text>Wpis OIPiP w Kielcach</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.15')"><xsl:text>Wpis OIPiP w Koninie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.16')"><xsl:text>Wpis OIPiP w Koszalinie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.17')"><xsl:text>Wpis OIPiP w Krakowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.18')"><xsl:text>Wpis OIPiP w Krośnie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.19')"><xsl:text>Wpis OIPiP w Lesznie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.20')"><xsl:text>Wpis OIPiP w Lublinie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.21')"><xsl:text>Wpis OIPiP w Łomży</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.22')"><xsl:text>Wpis OIPiP w Łodzi</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.23')"><xsl:text>Wpis OIPiP w Olsztynie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.24')"><xsl:text>Wpis OIPiP w Opolu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.25')"><xsl:text>Wpis OIPiP w Ostrołęce</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.26')"><xsl:text>Wpis OIPiP w Pile</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.27')"><xsl:text>Wpis OIPiP w Płocku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.28')"><xsl:text>Wpis OIPiP w Poznaniu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.29')"><xsl:text>Wpis OIPiP w Przeworsku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.30')"><xsl:text>Wpis OIPiP w Radomiu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.31')"><xsl:text>Wpis OIPiP w Rzeszowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.32')"><xsl:text>Wpis OIPiP w Siedlcach</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.33')"><xsl:text>Wpis OIPiP w Sieradzu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.34')"><xsl:text>Wpis OIPiP w Słupsku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.35')"><xsl:text>Wpis OIPiP w Suwałkach</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.36')"><xsl:text>Wpis OIPiP w Szczecinie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.37')"><xsl:text>Wpis OIPiP w Nowym Sączu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.38')"><xsl:text>Wpis OIPiP w Tarnowie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.39')"><xsl:text>Wpis OIPiP w Toruniu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.40')"><xsl:text>Wpis OIPiP w Wałbrzychu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.41')"><xsl:text>Wpis OIPiP w Warszawie</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.42')"><xsl:text>Wpis OIPiP we Włocławku</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.43')"><xsl:text>Wpis OIPiP we Wrocławiu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.44')"><xsl:text>Wpis OIPiP w Zamościu</xsl:text></xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.2.5.45')"><xsl:text>Wpis OIPiP w Zielonej Górze</xsl:text></xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.2' and $lang = $secondLanguage">
				<xsl:text>NFZ Certificate</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.2'">
				<xsl:text>Poświadczenie NFZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.3' and $lang = $secondLanguage">
				<xsl:text>EKUZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.3'">
				<xsl:text>Karta EKUZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.4' and $lang = $secondLanguage">
				<xsl:text>eWUŚ Certificate</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.4'">
				<xsl:text>Potwierdzenie eWUŚ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.5' and $lang = $secondLanguage">
				<xsl:text>EKUZ Substitution</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.8.5'">
				<xsl:text>Certyfikat zastępujący EKUZ</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='1.3.160'">
				<xsl:text>GS1/EAN</xsl:text>
			</xsl:when>
			<!-- identyfikatory osób z pominięciem PESEL i NPWZ, które znajdują się wyżej ze względu na częstotliwość występowania -->
			<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.')">
				<xsl:call-template name="translateISO3166alfa2orISO3166">
					<xsl:with-param name="codeValue" select="substring($oid, 30, 3)"/>
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.1.') and $lang = $secondLanguage">
						<xsl:text> - national ID</xsl:text>
					</xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.1.')">
						<xsl:text> - krajowy identyfikator osoby</xsl:text>
					</xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.2.') and $lang = $secondLanguage">
						<xsl:text> - identity card number</xsl:text>
					</xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.2.')">
						<xsl:text> - numer dowodu osobistego</xsl:text>
					</xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.3.') and $lang = $secondLanguage">
						<xsl:text> - driver's license number</xsl:text>
					</xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.3.')">
						<xsl:text> - numer prawa jazdy</xsl:text>
					</xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.5.') and $lang = $secondLanguage">
						<xsl:text> - sailor ID</xsl:text>
					</xsl:when>
					<xsl:when test="starts-with($oid, '2.16.840.1.113883.3.4424.1.5.')">
						<xsl:text> - numer książeczki żeglarskiej</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="starts-with($oid, '2.16.840.1.113883.4.330')">
				<xsl:call-template name="translateISO3166alfa2orISO3166">
					<xsl:with-param name="codeValue" select="substring($oid, 25, 3)"/>
				</xsl:call-template>
				<xsl:if test="$lang = $secondLanguage">
					<xsl:text> - passport number</xsl:text>
				</xsl:if>
				<xsl:if test="$lang != $secondLanguage">
					<xsl:text> - numer paszportu</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.2.4.6.3' and $lang = $secondLanguage">
				<xsl:text>Netherlands - national ID</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.2.4.6.3'">
				<xsl:text>Holandia - krajowy identyfikator osoby</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.578.1.12.4.1.4.1' and $lang = $secondLanguage">
				<xsl:text>Norway - national ID</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.578.1.12.4.1.4.1'">
				<xsl:text>Norwegia - krajowy identyfikator osoby</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="translateCodeSystemOID">
		<xsl:param name="oid"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:choose>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.11.2.4' and $lang = $secondLanguage">
				<xsl:text>Specialty</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.11.2.4'">
				<xsl:text>Specjalność (cz. VIII sys. kod. res.)</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.11.2.6'">
				<xsl:text>ICD-9-PL</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.6.260'">
				<xsl:text>ICD-10 Dual Coding</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.6.1'">
				<xsl:text>LOINC</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.6.96'">
				<xsl:text>SNOMED CT</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.6.97'">
				<xsl:text>ICNP</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.11.3.21' and $lang = $secondLanguage">
				<xsl:text>Discharge disposition code</xsl:text>
			</xsl:when>
			<xsl:when test="$oid='2.16.840.1.113883.3.4424.11.3.21'">
				<xsl:text>Tryb wypisu ze szpitala</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$oid"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- nullFlavor-->
	<xsl:template name="translateNullFlavor">
		<xsl:param name="nullableElement"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<!-- HL7 CDA dopuszcza podanie nullFlavor dla każdego kwantu danych i każdego elementu
			 obsłużono wyłącznie najważniejsze przypadki i najpopularniejsze kody, pozostałe kody tłumaczone są na 'nie podano':
			 NI = No Information. This is the most general and default null flavor.
			 NA = Not Applicable. Known to have no proper value (e.g., last menstrual period for a male).
			 UNK = Unknown. A proper value is applicable, but is not known.
			 ASKU = asked, but not known. Information was sought, but not found (e.g., the patient was asked but did not know).
			 NAV = temporarily unavailable. The information is not available, but is expected to be available later.
			 NASK = Not Asked. The patient was not asked. -->
		<xsl:if test="not($nullableElement) or $nullableElement/@nullFlavor">
			<span class="null_flavor">
				<xsl:choose>
					<xsl:when test="not($nullableElement) and $lang = $secondLanguage">
						<xsl:text>(no information)</xsl:text>
					</xsl:when>
					<xsl:when test="not($nullableElement)">
						<xsl:text>(nie podano)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NI' and $lang = $secondLanguage">
						<xsl:text>(no information)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NI'">
						<xsl:text>(brak informacji)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NA' and $lang = $secondLanguage">
						<xsl:text>(not applicable)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NA'">
						<xsl:text>(nie dotyczy)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='UNK' and $lang = $secondLanguage">
						<xsl:text>(unknown)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='UNK'">
						<xsl:text>(nieznane)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='ASKU' and $lang = $secondLanguage">
						<xsl:text>(asked but unknown)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='ASKU'">
						<xsl:text>(nie uzyskano informacji)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NAV' and $lang = $secondLanguage">
						<xsl:text>(temporarily unavailable)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NAV'">
						<xsl:text>(czasowo niedostępne)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NASK' and $lang = $secondLanguage">
						<xsl:text>(not asked)</xsl:text>
					</xsl:when>
					<xsl:when test="$nullableElement/@nullFlavor='NASK'">
						<xsl:text>(nie pytano)</xsl:text>
					</xsl:when>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>(no information)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>(nie podano)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</span>
		</xsl:if>
	</xsl:template>
	
	<!-- nazwa miesiąca w pełnej dacie -->
	<xsl:template name="translateFullDateMonth">
		<xsl:param name="month"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:choose>
			<xsl:when test="$month='01' and $lang = $secondLanguage"><xsl:text>January</xsl:text></xsl:when>
			<xsl:when test="$month='01'"><xsl:text>stycznia</xsl:text></xsl:when>
			<xsl:when test="$month='02' and $lang = $secondLanguage"><xsl:text>February</xsl:text></xsl:when>
			<xsl:when test="$month='02'"><xsl:text>lutego</xsl:text></xsl:when>
			<xsl:when test="$month='03' and $lang = $secondLanguage"><xsl:text>March</xsl:text></xsl:when>
			<xsl:when test="$month='03'"><xsl:text>marca</xsl:text></xsl:when>
			<xsl:when test="$month='04' and $lang = $secondLanguage"><xsl:text>April</xsl:text></xsl:when>
			<xsl:when test="$month='04'"><xsl:text>kwietnia</xsl:text></xsl:when>
			<xsl:when test="$month='05' and $lang = $secondLanguage"><xsl:text>May</xsl:text></xsl:when>
			<xsl:when test="$month='05'"><xsl:text>maja</xsl:text></xsl:when>
			<xsl:when test="$month='06' and $lang = $secondLanguage"><xsl:text>June</xsl:text></xsl:when>
			<xsl:when test="$month='06'"><xsl:text>czerwca</xsl:text></xsl:when>
			<xsl:when test="$month='07' and $lang = $secondLanguage"><xsl:text>July</xsl:text></xsl:when>
			<xsl:when test="$month='07'"><xsl:text>lipca</xsl:text></xsl:when>
			<xsl:when test="$month='08' and $lang = $secondLanguage"><xsl:text>August</xsl:text></xsl:when>
			<xsl:when test="$month='08'"><xsl:text>sierpnia</xsl:text></xsl:when>
			<xsl:when test="$month='09' and $lang = $secondLanguage"><xsl:text>September</xsl:text></xsl:when>
			<xsl:when test="$month='09'"><xsl:text>września</xsl:text></xsl:when>
			<xsl:when test="$month='10' and $lang = $secondLanguage"><xsl:text>October</xsl:text></xsl:when>
			<xsl:when test="$month='10'"><xsl:text>października</xsl:text></xsl:when>
			<xsl:when test="$month='11' and $lang = $secondLanguage"><xsl:text>November</xsl:text></xsl:when>
			<xsl:when test="$month='11'"><xsl:text>listopada</xsl:text></xsl:when>
			<xsl:when test="$month='12' and $lang = $secondLanguage"><xsl:text>December</xsl:text></xsl:when>
			<xsl:when test="$month='12'"><xsl:text>grudnia</xsl:text></xsl:when>
			<xsl:otherwise><xsl:value-of select="$month"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- nazwa miesiąca -->
	<xsl:template name="translateMonth">
		<xsl:param name="month"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:choose>
			<xsl:when test="$month='01' and $lang = $secondLanguage"><xsl:text>January</xsl:text></xsl:when>
			<xsl:when test="$month='01'"><xsl:text>styczeń</xsl:text></xsl:when>
			<xsl:when test="$month='02' and $lang = $secondLanguage"><xsl:text>February</xsl:text></xsl:when>
			<xsl:when test="$month='02'"><xsl:text>luty</xsl:text></xsl:when>
			<xsl:when test="$month='03' and $lang = $secondLanguage"><xsl:text>March</xsl:text></xsl:when>
			<xsl:when test="$month='03'"><xsl:text>marzec</xsl:text></xsl:when>
			<xsl:when test="$month='04' and $lang = $secondLanguage"><xsl:text>April</xsl:text></xsl:when>
			<xsl:when test="$month='04'"><xsl:text>kwiecień</xsl:text></xsl:when>
			<xsl:when test="$month='05' and $lang = $secondLanguage"><xsl:text>May</xsl:text></xsl:when>
			<xsl:when test="$month='05'"><xsl:text>maj</xsl:text></xsl:when>
			<xsl:when test="$month='06' and $lang = $secondLanguage"><xsl:text>June</xsl:text></xsl:when>
			<xsl:when test="$month='06'"><xsl:text>czerwiec</xsl:text></xsl:when>
			<xsl:when test="$month='07' and $lang = $secondLanguage"><xsl:text>July</xsl:text></xsl:when>
			<xsl:when test="$month='07'"><xsl:text>lipiec</xsl:text></xsl:when>
			<xsl:when test="$month='08' and $lang = $secondLanguage"><xsl:text>August</xsl:text></xsl:when>
			<xsl:when test="$month='08'"><xsl:text>sierpień</xsl:text></xsl:when>
			<xsl:when test="$month='09' and $lang = $secondLanguage"><xsl:text>September</xsl:text></xsl:when>
			<xsl:when test="$month='09'"><xsl:text>wrzesień</xsl:text></xsl:when>
			<xsl:when test="$month='10' and $lang = $secondLanguage"><xsl:text>October</xsl:text></xsl:when>
			<xsl:when test="$month='10'"><xsl:text>październik</xsl:text></xsl:when>
			<xsl:when test="$month='11' and $lang = $secondLanguage"><xsl:text>November</xsl:text></xsl:when>
			<xsl:when test="$month='11'"><xsl:text>listopad</xsl:text></xsl:when>
			<xsl:when test="$month='12' and $lang = $secondLanguage"><xsl:text>December</xsl:text></xsl:when>
			<xsl:when test="$month='12'"><xsl:text>grudzień</xsl:text></xsl:when>
			<xsl:otherwise><xsl:value-of select="$month"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="translateISO3166alfa2orISO3166">
		<xsl:param name="codeValue"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:variable name="code">
			<xsl:call-template name="fillUpToThreeChars">
				<xsl:with-param name="code" select="$codeValue"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="($code='0AF' or $code='004') and $lang = $secondLanguage"><xsl:text>Afghanistan</xsl:text></xsl:when>
			<xsl:when test="($code='0AF' or $code='004') and $lang != $secondLanguage"><xsl:text>Afganistan</xsl:text></xsl:when>
			<xsl:when test="($code='0AL' or $code='008')"><xsl:text>Albania</xsl:text></xsl:when>
			<xsl:when test="($code='0DZ' or $code='012') and $lang = $secondLanguage"><xsl:text>Algeria</xsl:text></xsl:when>
			<xsl:when test="($code='0DZ' or $code='012') and $lang != $secondLanguage"><xsl:text>Algieria</xsl:text></xsl:when>
			<xsl:when test="($code='0AD' or $code='020') and $lang = $secondLanguage"><xsl:text>Andorra</xsl:text></xsl:when>
			<xsl:when test="($code='0AD' or $code='020') and $lang != $secondLanguage"><xsl:text>Andora</xsl:text></xsl:when>
			<xsl:when test="($code='0AO' or $code='024')"><xsl:text>Angola</xsl:text></xsl:when>
			<xsl:when test="($code='0AI' or $code='660')"><xsl:text>Anguilla</xsl:text></xsl:when>
			<xsl:when test="($code='0AQ' or $code='010') and $lang = $secondLanguage"><xsl:text>Antarctica</xsl:text></xsl:when>
			<xsl:when test="($code='0AQ' or $code='010') and $lang != $secondLanguage"><xsl:text>Antarktyka</xsl:text></xsl:when>
			<xsl:when test="($code='0AG' or $code='028') and $lang = $secondLanguage"><xsl:text>Antigua and Barbuda</xsl:text></xsl:when>
			<xsl:when test="($code='0AG' or $code='028') and $lang != $secondLanguage"><xsl:text>Antigua i Barbuda</xsl:text></xsl:when>
			<xsl:when test="($code='0SA' or $code='682') and $lang = $secondLanguage"><xsl:text>Saudi Arabia</xsl:text></xsl:when>
			<xsl:when test="($code='0SA' or $code='682') and $lang != $secondLanguage"><xsl:text>Arabia Saudyjska</xsl:text></xsl:when>
			<xsl:when test="($code='0AR' or $code='032') and $lang = $secondLanguage"><xsl:text>Argentina</xsl:text></xsl:when>
			<xsl:when test="($code='0AR' or $code='032') and $lang != $secondLanguage"><xsl:text>Argentyna</xsl:text></xsl:when>
			<xsl:when test="($code='0AM' or $code='051')"><xsl:text>Armenia</xsl:text></xsl:when>
			<xsl:when test="($code='0AW' or $code='533')"><xsl:text>Aruba</xsl:text></xsl:when>
			<xsl:when test="($code='0AU' or $code='036')"><xsl:text>Australia</xsl:text></xsl:when>
			<xsl:when test="($code='0AT' or $code='040')"><xsl:text>Austria</xsl:text></xsl:when>
			<xsl:when test="($code='0AZ' or $code='031') and $lang = $secondLanguage"><xsl:text>Azerbaijan</xsl:text></xsl:when>
			<xsl:when test="($code='0AZ' or $code='031') and $lang != $secondLanguage"><xsl:text>Azerbejdżan</xsl:text></xsl:when>
			<xsl:when test="($code='0BS' or $code='044') and $lang = $secondLanguage"><xsl:text>Bahamas</xsl:text></xsl:when>
			<xsl:when test="($code='0BS' or $code='044') and $lang != $secondLanguage"><xsl:text>Bahamy</xsl:text></xsl:when>
			<xsl:when test="($code='0BH' or $code='048') and $lang = $secondLanguage"><xsl:text>Bahrain</xsl:text></xsl:when>
			<xsl:when test="($code='0BH' or $code='048') and $lang != $secondLanguage"><xsl:text>Bahrajn</xsl:text></xsl:when>
			<xsl:when test="($code='0BD' or $code='050') and $lang = $secondLanguage"><xsl:text>Bangladesh</xsl:text></xsl:when>
			<xsl:when test="($code='0BD' or $code='050') and $lang != $secondLanguage"><xsl:text>Bangladesz</xsl:text></xsl:when>
			<xsl:when test="($code='0BB' or $code='052')"><xsl:text>Barbados</xsl:text></xsl:when>
			<xsl:when test="($code='0BE' or $code='056') and $lang = $secondLanguage"><xsl:text>Belgium</xsl:text></xsl:when>
			<xsl:when test="($code='0BE' or $code='056') and $lang != $secondLanguage"><xsl:text>Belgia</xsl:text></xsl:when>
			<xsl:when test="($code='0BZ' or $code='084')"><xsl:text>Belize</xsl:text></xsl:when>
			<xsl:when test="($code='0BJ' or $code='204')"><xsl:text>Benin</xsl:text></xsl:when>
			<xsl:when test="($code='0BM' or $code='060') and $lang = $secondLanguage"><xsl:text>Bermuda</xsl:text></xsl:when>
			<xsl:when test="($code='0BM' or $code='060') and $lang != $secondLanguage"><xsl:text>Bermudy</xsl:text></xsl:when>
			<xsl:when test="($code='0BT' or $code='064')"><xsl:text>Bhutan</xsl:text></xsl:when>
			<xsl:when test="($code='0BY' or $code='112') and $lang = $secondLanguage"><xsl:text>Belarus</xsl:text></xsl:when>
			<xsl:when test="($code='0BY' or $code='112') and $lang != $secondLanguage"><xsl:text>Białoruś</xsl:text></xsl:when>
			<xsl:when test="($code='0BO' or $code='068') and $lang = $secondLanguage"><xsl:text>Bolivia</xsl:text></xsl:when>
			<xsl:when test="($code='0BO' or $code='068') and $lang != $secondLanguage"><xsl:text>Boliwia</xsl:text></xsl:when>
			<xsl:when test="($code='0BQ' or $code='535') and $lang = $secondLanguage"><xsl:text>Bonaire, Sint Eustatius and Saba</xsl:text></xsl:when>
			<xsl:when test="($code='0BQ' or $code='535') and $lang != $secondLanguage"><xsl:text>Bonaire, Sint Eustatius i Saba</xsl:text></xsl:when>
			<xsl:when test="($code='0BA' or $code='070') and $lang = $secondLanguage"><xsl:text>Bosnia and Herzegovina</xsl:text></xsl:when>
			<xsl:when test="($code='0BA' or $code='070') and $lang != $secondLanguage"><xsl:text>Bośnia i Hercegowina</xsl:text></xsl:when>
			<xsl:when test="($code='0BW' or $code='072')"><xsl:text>Botswana</xsl:text></xsl:when>
			<xsl:when test="($code='0BR' or $code='076') and $lang = $secondLanguage"><xsl:text>Brazil</xsl:text></xsl:when>
			<xsl:when test="($code='0BR' or $code='076') and $lang != $secondLanguage"><xsl:text>Brazylia</xsl:text></xsl:when>
			<xsl:when test="($code='0BN' or $code='096')"><xsl:text>Brunei</xsl:text></xsl:when>
			<xsl:when test="($code='0IO' or $code='086') and $lang = $secondLanguage"><xsl:text>British Indian Ocean Territory</xsl:text></xsl:when>
			<xsl:when test="($code='0IO' or $code='086') and $lang != $secondLanguage"><xsl:text>Brytyjskie Terytorium Oceanu Indyjskiego</xsl:text></xsl:when>
			<xsl:when test="($code='0VG' or $code='092') and $lang = $secondLanguage"><xsl:text>Virgin Islands, British</xsl:text></xsl:when>
			<xsl:when test="($code='0VG' or $code='092') and $lang != $secondLanguage"><xsl:text>Brytyjskie Wyspy Dziewicze</xsl:text></xsl:when>
			<xsl:when test="($code='0BG' or $code='100') and $lang = $secondLanguage"><xsl:text>Bulgaria</xsl:text></xsl:when>
			<xsl:when test="($code='0BG' or $code='100') and $lang != $secondLanguage"><xsl:text>Bułgaria</xsl:text></xsl:when>
			<xsl:when test="($code='0BF' or $code='854')"><xsl:text>Burkina Faso</xsl:text></xsl:when>
			<xsl:when test="($code='0BI' or $code='108')"><xsl:text>Burundi</xsl:text></xsl:when>
			<xsl:when test="($code='0CL' or $code='152')"><xsl:text>Chile</xsl:text></xsl:when>
			<xsl:when test="($code='0CN' or $code='156') and $lang = $secondLanguage"><xsl:text>China</xsl:text></xsl:when>
			<xsl:when test="($code='0CN' or $code='156') and $lang != $secondLanguage"><xsl:text>Chiny</xsl:text></xsl:when>
			<xsl:when test="($code='0HR' or $code='191') and $lang = $secondLanguage"><xsl:text>Croatia</xsl:text></xsl:when>
			<xsl:when test="($code='0HR' or $code='191') and $lang != $secondLanguage"><xsl:text>Chorwacja</xsl:text></xsl:when>
			<xsl:when test="($code='0CW' or $code='531')"><xsl:text>Curaçao</xsl:text></xsl:when>
			<xsl:when test="($code='0CY' or $code='196') and $lang = $secondLanguage"><xsl:text>Cyprus</xsl:text></xsl:when>
			<xsl:when test="($code='0CY' or $code='196') and $lang != $secondLanguage"><xsl:text>Cypr</xsl:text></xsl:when>
			<xsl:when test="($code='0TD' or $code='148') and $lang = $secondLanguage"><xsl:text>Chad</xsl:text></xsl:when>
			<xsl:when test="($code='0TD' or $code='148') and $lang != $secondLanguage"><xsl:text>Czad</xsl:text></xsl:when>
			<xsl:when test="($code='0ME' or $code='499') and $lang = $secondLanguage"><xsl:text>Montenegro</xsl:text></xsl:when>
			<xsl:when test="($code='0ME' or $code='499') and $lang != $secondLanguage"><xsl:text>Czarnogóra</xsl:text></xsl:when>
			<xsl:when test="($code='0CZ' or $code='203') and $lang = $secondLanguage"><xsl:text>Czechia</xsl:text></xsl:when>
			<xsl:when test="($code='0CZ' or $code='203')"><xsl:text>Czechy</xsl:text></xsl:when>
			<xsl:when test="($code='0UM' or $code='581') and $lang = $secondLanguage"><xsl:text>United States Minor Outlying Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0UM' or $code='581') and $lang != $secondLanguage"><xsl:text>Dalekie Wyspy Mniejsze Stanów Zjednoczonych</xsl:text></xsl:when>
			<xsl:when test="($code='0DK' or $code='208') and $lang = $secondLanguage"><xsl:text>Denmark</xsl:text></xsl:when>
			<xsl:when test="($code='0DK' or $code='208') and $lang != $secondLanguage"><xsl:text>Dania</xsl:text></xsl:when>
			<xsl:when test="($code='0CD' or $code='180') and $lang = $secondLanguage"><xsl:text>the Democratic Republic of the Congo</xsl:text></xsl:when>
			<xsl:when test="($code='0CD' or $code='180') and $lang != $secondLanguage"><xsl:text>Demokratyczna Republika Konga</xsl:text></xsl:when>
			<xsl:when test="($code='0DM' or $code='212') and $lang = $secondLanguage"><xsl:text>Dominica</xsl:text></xsl:when>
			<xsl:when test="($code='0DM' or $code='212') and $lang != $secondLanguage"><xsl:text>Dominika</xsl:text></xsl:when>
			<xsl:when test="($code='0DO' or $code='214') and $lang = $secondLanguage"><xsl:text>Dominican Republic</xsl:text></xsl:when>
			<xsl:when test="($code='0DO' or $code='214') and $lang != $secondLanguage"><xsl:text>Dominikana</xsl:text></xsl:when>
			<xsl:when test="($code='0DJ' or $code='262') and $lang = $secondLanguage"><xsl:text>Djibouti</xsl:text></xsl:when>
			<xsl:when test="($code='0DJ' or $code='262') and $lang != $secondLanguage"><xsl:text>Dżibuti</xsl:text></xsl:when>
			<xsl:when test="($code='0EG' or $code='818') and $lang = $secondLanguage"><xsl:text>Egypt</xsl:text></xsl:when>
			<xsl:when test="($code='0EG' or $code='818') and $lang != $secondLanguage"><xsl:text>Egipt</xsl:text></xsl:when>
			<xsl:when test="($code='0EC' or $code='218') and $lang = $secondLanguage"><xsl:text>Ecuador</xsl:text></xsl:when>
			<xsl:when test="($code='0EC' or $code='218') and $lang != $secondLanguage"><xsl:text>Ekwador</xsl:text></xsl:when>
			<xsl:when test="($code='0ER' or $code='232') and $lang = $secondLanguage"><xsl:text>Eritrea</xsl:text></xsl:when>
			<xsl:when test="($code='0ER' or $code='232') and $lang != $secondLanguage"><xsl:text>Erytrea</xsl:text></xsl:when>
			<xsl:when test="($code='0EE' or $code='233')"><xsl:text>Estonia</xsl:text></xsl:when>
			<xsl:when test="($code='0ET' or $code='231') and $lang = $secondLanguage"><xsl:text>Ethiopia</xsl:text></xsl:when>
			<xsl:when test="($code='0ET' or $code='231') and $lang != $secondLanguage"><xsl:text>Etiopia</xsl:text></xsl:when>
			<xsl:when test="($code='0FK' or $code='238') and $lang = $secondLanguage"><xsl:text>Falkland Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0FK' or $code='238') and $lang != $secondLanguage"><xsl:text>Falklandy</xsl:text></xsl:when>
			<xsl:when test="($code='0FJ' or $code='242') and $lang = $secondLanguage"><xsl:text>Fiji</xsl:text></xsl:when>
			<xsl:when test="($code='0FJ' or $code='242') and $lang != $secondLanguage"><xsl:text>Fidżi</xsl:text></xsl:when>
			<xsl:when test="($code='0PH' or $code='608') and $lang = $secondLanguage"><xsl:text>Philippines</xsl:text></xsl:when>
			<xsl:when test="($code='0PH' or $code='608') and $lang != $secondLanguage"><xsl:text>Filipiny</xsl:text></xsl:when>
			<xsl:when test="($code='0FI' or $code='246') and $lang = $secondLanguage"><xsl:text>Finland</xsl:text></xsl:when>
			<xsl:when test="($code='0FI' or $code='246') and $lang != $secondLanguage"><xsl:text>Finlandia</xsl:text></xsl:when>
			<xsl:when test="($code='0FR' or $code='250') and $lang = $secondLanguage"><xsl:text>France</xsl:text></xsl:when>
			<xsl:when test="($code='0FR' or $code='250') and $lang != $secondLanguage"><xsl:text>Francja</xsl:text></xsl:when>
			<xsl:when test="($code='0TF' or $code='260') and $lang = $secondLanguage"><xsl:text>French Southern Territories</xsl:text></xsl:when>
			<xsl:when test="($code='0TF' or $code='260') and $lang != $secondLanguage"><xsl:text>Francuskie Terytoria Południowe i Antarktyczne</xsl:text></xsl:when>
			<xsl:when test="($code='0GA' or $code='266')"><xsl:text>Gabon</xsl:text></xsl:when>
			<xsl:when test="($code='0GM' or $code='270')"><xsl:text>Gambia</xsl:text></xsl:when>
			<xsl:when test="($code='0GS' or $code='239') and $lang = $secondLanguage"><xsl:text>South Georgia and the South Sandwich Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0GS' or $code='239') and $lang != $secondLanguage"><xsl:text>Georgia Południowa i Sandwich Południowy</xsl:text></xsl:when>
			<xsl:when test="($code='0GH' or $code='288')"><xsl:text>Ghana</xsl:text></xsl:when>
			<xsl:when test="($code='0GI' or $code='292')"><xsl:text>Gibraltar</xsl:text></xsl:when>
			<xsl:when test="($code='0GR' or $code='300') and $lang = $secondLanguage"><xsl:text>Greece</xsl:text></xsl:when>
			<xsl:when test="($code='0GR' or $code='300') and $lang != $secondLanguage"><xsl:text>Grecja</xsl:text></xsl:when>
			<xsl:when test="($code='0GD' or $code='308') and $lang = $secondLanguage"><xsl:text>Saint Vincent and the Grenadines</xsl:text></xsl:when>
			<xsl:when test="($code='0GD' or $code='308') and $lang != $secondLanguage"><xsl:text>Grenada</xsl:text></xsl:when>
			<xsl:when test="($code='0GL' or $code='304') and $lang = $secondLanguage"><xsl:text>Greenland</xsl:text></xsl:when>
			<xsl:when test="($code='0GL' or $code='304') and $lang != $secondLanguage"><xsl:text>Grenlandia</xsl:text></xsl:when>
			<xsl:when test="($code='0GE' or $code='268') and $lang = $secondLanguage"><xsl:text>Georgia</xsl:text></xsl:when>
			<xsl:when test="($code='0GE' or $code='268') and $lang != $secondLanguage"><xsl:text>Gruzja</xsl:text></xsl:when>
			<xsl:when test="($code='0GU' or $code='316')"><xsl:text>Guam</xsl:text></xsl:when>
			<xsl:when test="($code='0GG' or $code='831')"><xsl:text>Guernsey</xsl:text></xsl:when>
			<xsl:when test="($code='0GF' or $code='254') and $lang = $secondLanguage"><xsl:text>French Guiana</xsl:text></xsl:when>
			<xsl:when test="($code='0GF' or $code='254') and $lang != $secondLanguage"><xsl:text>Gujana Francuska</xsl:text></xsl:when>
			<xsl:when test="($code='0GY' or $code='328') and $lang = $secondLanguage"><xsl:text>Guyana</xsl:text></xsl:when>
			<xsl:when test="($code='0GY' or $code='328') and $lang != $secondLanguage"><xsl:text>Gujana</xsl:text></xsl:when>
			<xsl:when test="($code='0GP' or $code='312') and $lang = $secondLanguage"><xsl:text>Guadeloupe</xsl:text></xsl:when>
			<xsl:when test="($code='0GP' or $code='312') and $lang != $secondLanguage"><xsl:text>Gwadelupa</xsl:text></xsl:when>
			<xsl:when test="($code='0GT' or $code='320') and $lang = $secondLanguage"><xsl:text>Guatemala</xsl:text></xsl:when>
			<xsl:when test="($code='0GT' or $code='320') and $lang != $secondLanguage"><xsl:text>Gwatemala</xsl:text></xsl:when>
			<xsl:when test="($code='0GW' or $code='624') and $lang = $secondLanguage"><xsl:text>Guinea Bissau</xsl:text></xsl:when>
			<xsl:when test="($code='0GW' or $code='624') and $lang != $secondLanguage"><xsl:text>Gwinea Bissau</xsl:text></xsl:when>
			<xsl:when test="($code='0GQ' or $code='226') and $lang = $secondLanguage"><xsl:text>Equatorial Guinea</xsl:text></xsl:when>
			<xsl:when test="($code='0GQ' or $code='226') and $lang != $secondLanguage"><xsl:text>Gwinea Równikowa</xsl:text></xsl:when>
			<xsl:when test="($code='0GN' or $code='324') and $lang = $secondLanguage"><xsl:text>Guinea</xsl:text></xsl:when>
			<xsl:when test="($code='0GN' or $code='324') and $lang != $secondLanguage"><xsl:text>Gwinea</xsl:text></xsl:when>
			<xsl:when test="($code='0HT' or $code='332')"><xsl:text>Haiti</xsl:text></xsl:when>
			<xsl:when test="($code='0ES' or $code='724') and $lang = $secondLanguage"><xsl:text>Spain</xsl:text></xsl:when>
			<xsl:when test="($code='0ES' or $code='724') and $lang != $secondLanguage"><xsl:text>Hiszpania</xsl:text></xsl:when>
			<xsl:when test="($code='0NL' or $code='528') and $lang = $secondLanguage"><xsl:text>Netherlands</xsl:text></xsl:when>
			<xsl:when test="($code='0NL' or $code='528') and $lang != $secondLanguage"><xsl:text>Holandia</xsl:text></xsl:when>
			<xsl:when test="($code='0HN' or $code='340')"><xsl:text>Honduras</xsl:text></xsl:when>
			<xsl:when test="($code='0HK' or $code='344') and $lang = $secondLanguage"><xsl:text>Hong Kong</xsl:text></xsl:when>
			<xsl:when test="($code='0HK' or $code='344') and $lang != $secondLanguage"><xsl:text>Hongkong</xsl:text></xsl:when>
			<xsl:when test="($code='0IN' or $code='356') and $lang = $secondLanguage"><xsl:text>India</xsl:text></xsl:when>
			<xsl:when test="($code='0IN' or $code='356') and $lang != $secondLanguage"><xsl:text>Indie</xsl:text></xsl:when>
			<xsl:when test="($code='0ID' or $code='360') and $lang = $secondLanguage"><xsl:text>Indonesia</xsl:text></xsl:when>
			<xsl:when test="($code='0ID' or $code='360') and $lang != $secondLanguage"><xsl:text>Indonezja</xsl:text></xsl:when>
			<xsl:when test="($code='0IQ' or $code='368') and $lang = $secondLanguage"><xsl:text>Iraq</xsl:text></xsl:when>
			<xsl:when test="($code='0IQ' or $code='368') and $lang != $secondLanguage"><xsl:text>Irak</xsl:text></xsl:when>
			<xsl:when test="($code='0IR' or $code='364')"><xsl:text>Iran</xsl:text></xsl:when>
			<xsl:when test="($code='0IE' or $code='372') and $lang = $secondLanguage"><xsl:text>Ireland</xsl:text></xsl:when>
			<xsl:when test="($code='0IE' or $code='372') and $lang != $secondLanguage"><xsl:text>Irlandia</xsl:text></xsl:when>
			<xsl:when test="($code='0IS' or $code='352') and $lang = $secondLanguage"><xsl:text>Iceland</xsl:text></xsl:when>
			<xsl:when test="($code='0IS' or $code='352') and $lang != $secondLanguage"><xsl:text>Islandia</xsl:text></xsl:when>
			<xsl:when test="($code='0IL' or $code='376') and $lang = $secondLanguage"><xsl:text>Israel</xsl:text></xsl:when>
			<xsl:when test="($code='0IL' or $code='376') and $lang != $secondLanguage"><xsl:text>Izrael</xsl:text></xsl:when>
			<xsl:when test="($code='0JM' or $code='388') and $lang = $secondLanguage"><xsl:text>Jamaica</xsl:text></xsl:when>
			<xsl:when test="($code='0JM' or $code='388') and $lang != $secondLanguage"><xsl:text>Jamajka</xsl:text></xsl:when>
			<xsl:when test="($code='0JP' or $code='392') and $lang = $secondLanguage"><xsl:text>Japan</xsl:text></xsl:when>
			<xsl:when test="($code='0JP' or $code='392') and $lang != $secondLanguage"><xsl:text>Japonia</xsl:text></xsl:when>
			<xsl:when test="($code='0YE' or $code='887') and $lang = $secondLanguage"><xsl:text>Yemen</xsl:text></xsl:when>
			<xsl:when test="($code='0YE' or $code='887') and $lang != $secondLanguage"><xsl:text>Jemen</xsl:text></xsl:when>
			<xsl:when test="($code='0JE' or $code='832')"><xsl:text>Jersey</xsl:text></xsl:when>
			<xsl:when test="($code='0JO' or $code='400') and $lang = $secondLanguage"><xsl:text>Jordan</xsl:text></xsl:when>
			<xsl:when test="($code='0JO' or $code='400') and $lang != $secondLanguage"><xsl:text>Jordania</xsl:text></xsl:when>
			<xsl:when test="($code='0KY' or $code='136') and $lang = $secondLanguage"><xsl:text>Cayman Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0KY' or $code='136') and $lang != $secondLanguage"><xsl:text>Kajmany</xsl:text></xsl:when>
			<xsl:when test="($code='0KH' or $code='116') and $lang = $secondLanguage"><xsl:text>Cambodia</xsl:text></xsl:when>
			<xsl:when test="($code='0KH' or $code='116') and $lang != $secondLanguage"><xsl:text>Kambodża</xsl:text></xsl:when>
			<xsl:when test="($code='0CM' or $code='120') and $lang = $secondLanguage"><xsl:text>Cameroon</xsl:text></xsl:when>
			<xsl:when test="($code='0CM' or $code='120') and $lang != $secondLanguage"><xsl:text>Kamerun</xsl:text></xsl:when>
			<xsl:when test="($code='0CA' or $code='124') and $lang = $secondLanguage"><xsl:text>Canada</xsl:text></xsl:when>
			<xsl:when test="($code='0CA' or $code='124') and $lang != $secondLanguage"><xsl:text>Kanada</xsl:text></xsl:when>
			<xsl:when test="($code='0QA' or $code='634') and $lang = $secondLanguage"><xsl:text>Qatar</xsl:text></xsl:when>
			<xsl:when test="($code='0QA' or $code='634') and $lang != $secondLanguage"><xsl:text>Katar</xsl:text></xsl:when>
			<xsl:when test="($code='0KZ' or $code='398') and $lang = $secondLanguage"><xsl:text>Kazakhstan</xsl:text></xsl:when>
			<xsl:when test="($code='0KZ' or $code='398') and $lang != $secondLanguage"><xsl:text>Kazachstan</xsl:text></xsl:when>
			<xsl:when test="($code='0KE' or $code='404') and $lang = $secondLanguage"><xsl:text>Kenya</xsl:text></xsl:when>
			<xsl:when test="($code='0KE' or $code='404') and $lang != $secondLanguage"><xsl:text>Kenia</xsl:text></xsl:when>
			<xsl:when test="($code='0KG' or $code='417') and $lang = $secondLanguage"><xsl:text>Kyrgyzstan</xsl:text></xsl:when>
			<xsl:when test="($code='0KG' or $code='417') and $lang != $secondLanguage"><xsl:text>Kirgistan</xsl:text></xsl:when>
			<xsl:when test="($code='0KI' or $code='296')"><xsl:text>Kiribati</xsl:text></xsl:when>
			<xsl:when test="($code='0CO' or $code='170') and $lang = $secondLanguage"><xsl:text>Colombia</xsl:text></xsl:when>
			<xsl:when test="($code='0CO' or $code='170') and $lang != $secondLanguage"><xsl:text>Kolumbia</xsl:text></xsl:when>
			<xsl:when test="($code='0KM' or $code='174') and $lang = $secondLanguage"><xsl:text>Comoros</xsl:text></xsl:when>
			<xsl:when test="($code='0KM' or $code='174') and $lang != $secondLanguage"><xsl:text>Komory</xsl:text></xsl:when>
			<xsl:when test="($code='0CG' or $code='178') and $lang = $secondLanguage"><xsl:text>Congo</xsl:text></xsl:when>
			<xsl:when test="($code='0CG' or $code='178') and $lang != $secondLanguage"><xsl:text>Kongo</xsl:text></xsl:when>
			<xsl:when test="($code='0KR' or $code='410') and $lang = $secondLanguage"><xsl:text>South Korea</xsl:text></xsl:when>
			<xsl:when test="($code='0KR' or $code='410') and $lang != $secondLanguage"><xsl:text>Korea Południowa</xsl:text></xsl:when>
			<xsl:when test="($code='0KP' or $code='408') and $lang = $secondLanguage"><xsl:text>North Korea</xsl:text></xsl:when>
			<xsl:when test="($code='0KP' or $code='408') and $lang != $secondLanguage"><xsl:text>Korea Północna</xsl:text></xsl:when>
			<xsl:when test="($code='0CR' or $code='188') and $lang = $secondLanguage"><xsl:text>Costa Rica</xsl:text></xsl:when>
			<xsl:when test="($code='0CR' or $code='188') and $lang != $secondLanguage"><xsl:text>Kostaryka</xsl:text></xsl:when>
			<xsl:when test="($code='0CU' or $code='192') and $lang = $secondLanguage"><xsl:text>Cuba</xsl:text></xsl:when>
			<xsl:when test="($code='0CU' or $code='192') and $lang != $secondLanguage"><xsl:text>Kuba</xsl:text></xsl:when>
			<xsl:when test="($code='0KW' or $code='414') and $lang = $secondLanguage"><xsl:text>Kuwait</xsl:text></xsl:when>
			<xsl:when test="($code='0KW' or $code='414') and $lang != $secondLanguage"><xsl:text>Kuwejt</xsl:text></xsl:when>
			<xsl:when test="($code='0LA' or $code='418')"><xsl:text>Laos</xsl:text></xsl:when>
			<xsl:when test="($code='0LS' or $code='426')"><xsl:text>Lesotho</xsl:text></xsl:when>
			<xsl:when test="($code='0LB' or $code='422') and $lang = $secondLanguage"><xsl:text>Lebanon</xsl:text></xsl:when>
			<xsl:when test="($code='0LB' or $code='422') and $lang != $secondLanguage"><xsl:text>Liban</xsl:text></xsl:when>
			<xsl:when test="($code='0LR' or $code='430')"><xsl:text>Liberia</xsl:text></xsl:when>
			<xsl:when test="($code='0LY' or $code='434') and $lang = $secondLanguage"><xsl:text>Lybia</xsl:text></xsl:when>
			<xsl:when test="($code='0LY' or $code='434') and $lang != $secondLanguage"><xsl:text>Libia</xsl:text></xsl:when>
			<xsl:when test="($code='0LI' or $code='438')"><xsl:text>Liechtenstein</xsl:text></xsl:when>
			<xsl:when test="($code='0LT' or $code='440') and $lang = $secondLanguage"><xsl:text>Lithuania</xsl:text></xsl:when>
			<xsl:when test="($code='0LT' or $code='440') and $lang != $secondLanguage"><xsl:text>Litwa</xsl:text></xsl:when>
			<xsl:when test="($code='0LU' or $code='442') and $lang = $secondLanguage"><xsl:text>Luxembourg</xsl:text></xsl:when>
			<xsl:when test="($code='0LU' or $code='442') and $lang != $secondLanguage"><xsl:text>Luksemburg</xsl:text></xsl:when>
			<xsl:when test="($code='0LV' or $code='428') and $lang = $secondLanguage"><xsl:text>Latvia</xsl:text></xsl:when>
			<xsl:when test="($code='0LV' or $code='428') and $lang != $secondLanguage"><xsl:text>Łotwa</xsl:text></xsl:when>
			<xsl:when test="($code='0MK' or $code='807')"><xsl:text>Macedonia</xsl:text></xsl:when>
			<xsl:when test="($code='0MG' or $code='450') and $lang = $secondLanguage"><xsl:text>Madagascar</xsl:text></xsl:when>
			<xsl:when test="($code='0MG' or $code='450') and $lang != $secondLanguage"><xsl:text>Madagaskar</xsl:text></xsl:when>
			<xsl:when test="($code='0YT' or $code='175') and $lang = $secondLanguage"><xsl:text>Mayotte</xsl:text></xsl:when>
			<xsl:when test="($code='0YT' or $code='175') and $lang != $secondLanguage"><xsl:text>Majotta</xsl:text></xsl:when>
			<xsl:when test="($code='0MO' or $code='446') and $lang = $secondLanguage"><xsl:text>Macao</xsl:text></xsl:when>
			<xsl:when test="($code='0MO' or $code='446') and $lang != $secondLanguage"><xsl:text>Makau</xsl:text></xsl:when>
			<xsl:when test="($code='0MW' or $code='454')"><xsl:text>Malawi</xsl:text></xsl:when>
			<xsl:when test="($code='0MV' or $code='462') and $lang = $secondLanguage"><xsl:text>Maldives</xsl:text></xsl:when>
			<xsl:when test="($code='0MV' or $code='462') and $lang != $secondLanguage"><xsl:text>Malediwy</xsl:text></xsl:when>
			<xsl:when test="($code='0MY' or $code='458') and $lang = $secondLanguage"><xsl:text>Malaysia</xsl:text></xsl:when>
			<xsl:when test="($code='0MY' or $code='458') and $lang != $secondLanguage"><xsl:text>Malezja</xsl:text></xsl:when>
			<xsl:when test="($code='0ML' or $code='466')"><xsl:text>Mali</xsl:text></xsl:when>
			<xsl:when test="($code='0MT' or $code='470')"><xsl:text>Malta</xsl:text></xsl:when>
			<xsl:when test="($code='0MP' or $code='580') and $lang = $secondLanguage"><xsl:text>Northern Mariana Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0MP' or $code='580') and $lang != $secondLanguage"><xsl:text>Mariany Północne</xsl:text></xsl:when>
			<xsl:when test="($code='0MA' or $code='504') and $lang = $secondLanguage"><xsl:text>Morocco</xsl:text></xsl:when>
			<xsl:when test="($code='0MA' or $code='504') and $lang != $secondLanguage"><xsl:text>Maroko</xsl:text></xsl:when>
			<xsl:when test="($code='0MQ' or $code='474') and $lang = $secondLanguage"><xsl:text>Martinique</xsl:text></xsl:when>
			<xsl:when test="($code='0MQ' or $code='474') and $lang != $secondLanguage"><xsl:text>Martynika</xsl:text></xsl:when>
			<xsl:when test="($code='0MR' or $code='478') and $lang = $secondLanguage"><xsl:text>Mauritania</xsl:text></xsl:when>
			<xsl:when test="($code='0MR' or $code='478') and $lang != $secondLanguage"><xsl:text>Mauretania</xsl:text></xsl:when>
			<xsl:when test="($code='0MU' or $code='480')"><xsl:text>Mauritius</xsl:text></xsl:when>
			<xsl:when test="($code='0MX' or $code='484') and $lang = $secondLanguage"><xsl:text>Mexico</xsl:text></xsl:when>
			<xsl:when test="($code='0MX' or $code='484') and $lang != $secondLanguage"><xsl:text>Meksyk</xsl:text></xsl:when>
			<xsl:when test="($code='0FM' or $code='583') and $lang = $secondLanguage"><xsl:text>Fedarated States of Micronesia</xsl:text></xsl:when>
			<xsl:when test="($code='0FM' or $code='583') and $lang != $secondLanguage"><xsl:text>Mikronezja</xsl:text></xsl:when>
			<xsl:when test="($code='0MM' or $code='104') and $lang = $secondLanguage"><xsl:text>Myanmar</xsl:text></xsl:when>
			<xsl:when test="($code='0MM' or $code='104') and $lang != $secondLanguage"><xsl:text>Mjanma</xsl:text></xsl:when>
			<xsl:when test="($code='0MD' or $code='498') and $lang = $secondLanguage"><xsl:text>Moldova</xsl:text></xsl:when>
			<xsl:when test="($code='0MD' or $code='498') and $lang != $secondLanguage"><xsl:text>Mołdawia</xsl:text></xsl:when>
			<xsl:when test="($code='0MC' or $code='492') and $lang = $secondLanguage"><xsl:text>Monaco</xsl:text></xsl:when>
			<xsl:when test="($code='0MC' or $code='492') and $lang != $secondLanguage"><xsl:text>Monako</xsl:text></xsl:when>
			<xsl:when test="($code='0MN' or $code='496')"><xsl:text>Mongolia</xsl:text></xsl:when>
			<xsl:when test="($code='0MS' or $code='500')"><xsl:text>Montserrat</xsl:text></xsl:when>
			<xsl:when test="($code='0MZ' or $code='508') and $lang = $secondLanguage"><xsl:text>Mozambique</xsl:text></xsl:when>
			<xsl:when test="($code='0MZ' or $code='508') and $lang != $secondLanguage"><xsl:text>Mozambik</xsl:text></xsl:when>
			<xsl:when test="($code='0NA' or $code='516')"><xsl:text>Namibia</xsl:text></xsl:when>
			<xsl:when test="($code='0NR' or $code='520')"><xsl:text>Nauru</xsl:text></xsl:when>
			<xsl:when test="($code='0NP' or $code='524')"><xsl:text>Nepal</xsl:text></xsl:when>
			<xsl:when test="($code='0DE' or $code='276') and $lang = $secondLanguage"><xsl:text>Germany</xsl:text></xsl:when>
			<xsl:when test="($code='0DE' or $code='276') and $lang != $secondLanguage"><xsl:text>Niemcy</xsl:text></xsl:when>
			<xsl:when test="($code='0NE' or $code='562')"><xsl:text>Niger</xsl:text></xsl:when>
			<xsl:when test="($code='0NG' or $code='566')"><xsl:text>Nigeria</xsl:text></xsl:when>
			<xsl:when test="($code='0NI' or $code='558') and $lang = $secondLanguage"><xsl:text>Nicaragua</xsl:text></xsl:when>
			<xsl:when test="($code='0NI' or $code='558') and $lang != $secondLanguage"><xsl:text>Nikaragua</xsl:text></xsl:when>
			<xsl:when test="($code='0NU' or $code='570')"><xsl:text>Niue</xsl:text></xsl:when>
			<xsl:when test="($code='0NF' or $code='574') and $lang = $secondLanguage"><xsl:text>Norfolk Island</xsl:text></xsl:when>
			<xsl:when test="($code='0NF' or $code='574') and $lang != $secondLanguage"><xsl:text>Norfolk</xsl:text></xsl:when>
			<xsl:when test="($code='0NO' or $code='578') and $lang = $secondLanguage"><xsl:text>Norway</xsl:text></xsl:when>
			<xsl:when test="($code='0NO' or $code='578') and $lang != $secondLanguage"><xsl:text>Norwegia</xsl:text></xsl:when>
			<xsl:when test="($code='0NC' or $code='540') and $lang = $secondLanguage"><xsl:text>New Caledonia</xsl:text></xsl:when>
			<xsl:when test="($code='0NC' or $code='540') and $lang != $secondLanguage"><xsl:text>Nowa Kaledonia</xsl:text></xsl:when>
			<xsl:when test="($code='0NZ' or $code='554') and $lang = $secondLanguage"><xsl:text>New Zealand</xsl:text></xsl:when>
			<xsl:when test="($code='0NZ' or $code='554') and $lang != $secondLanguage"><xsl:text>Nowa Zelandia</xsl:text></xsl:when>
			<xsl:when test="($code='0OM' or $code='512')"><xsl:text>Oman</xsl:text></xsl:when>
			<xsl:when test="($code='0PK' or $code='586')"><xsl:text>Pakistan</xsl:text></xsl:when>
			<xsl:when test="($code='0PW' or $code='585')"><xsl:text>Palau</xsl:text></xsl:when>
			<xsl:when test="($code='0PS' or $code='275') and $lang = $secondLanguage"><xsl:text>Palestine</xsl:text></xsl:when>
			<xsl:when test="($code='0PS' or $code='275') and $lang != $secondLanguage"><xsl:text>Palestyna</xsl:text></xsl:when>
			<xsl:when test="($code='0PA' or $code='591')"><xsl:text>Panama</xsl:text></xsl:when>
			<xsl:when test="($code='0PG' or $code='598') and $lang = $secondLanguage"><xsl:text>Papua New Guinea</xsl:text></xsl:when>
			<xsl:when test="($code='0PG' or $code='598') and $lang != $secondLanguage"><xsl:text>Papua-Nowa Gwinea</xsl:text></xsl:when>
			<xsl:when test="($code='0PY' or $code='600') and $lang = $secondLanguage"><xsl:text>Paraguay</xsl:text></xsl:when>
			<xsl:when test="($code='0PY' or $code='600') and $lang != $secondLanguage"><xsl:text>Paragwaj</xsl:text></xsl:when>
			<xsl:when test="($code='0PE' or $code='604')"><xsl:text>Peru</xsl:text></xsl:when>
			<xsl:when test="($code='0PN' or $code='612')"><xsl:text>Pitcairn</xsl:text></xsl:when>
			<xsl:when test="($code='0PF' or $code='258') and $lang = $secondLanguage"><xsl:text>French Polynesia</xsl:text></xsl:when>
			<xsl:when test="($code='0PF' or $code='258') and $lang != $secondLanguage"><xsl:text>Polinezja Francuska</xsl:text></xsl:when>
			<xsl:when test="($code='0PL' or $code='616') and $lang = $secondLanguage"><xsl:text>Poland</xsl:text></xsl:when>
			<xsl:when test="($code='0PL' or $code='616') and $lang != $secondLanguage"><xsl:text>Polska</xsl:text></xsl:when>
			<xsl:when test="($code='0PR' or $code='630') and $lang = $secondLanguage"><xsl:text>Puerto Rico</xsl:text></xsl:when>
			<xsl:when test="($code='0PR' or $code='630')"><xsl:text>Portoryko</xsl:text></xsl:when>
			<xsl:when test="($code='0PT' or $code='620') and $lang = $secondLanguage"><xsl:text>Portugal</xsl:text></xsl:when>
			<xsl:when test="($code='0PT' or $code='620') and $lang != $secondLanguage"><xsl:text>Portugalia</xsl:text></xsl:when>
			<xsl:when test="($code='0ZA' or $code='710') and $lang = $secondLanguage"><xsl:text>South Africa</xsl:text></xsl:when>
			<xsl:when test="($code='0ZA' or $code='710') and $lang != $secondLanguage"><xsl:text>Republika Południowej Afryki</xsl:text></xsl:when>
			<xsl:when test="($code='0CF' or $code='140') and $lang = $secondLanguage"><xsl:text>Central African Republic</xsl:text></xsl:when>
			<xsl:when test="($code='0CF' or $code='140') and $lang != $secondLanguage"><xsl:text>Republika Środkowoafrykańska</xsl:text></xsl:when>
			<xsl:when test="($code='0CV' or $code='132') and $lang = $secondLanguage"><xsl:text>Cape Verde</xsl:text></xsl:when>
			<xsl:when test="($code='0CV' or $code='132') and $lang != $secondLanguage"><xsl:text>Republika Zielonego Przylądka</xsl:text></xsl:when>
			<xsl:when test="($code='0RE' or $code='638')"><xsl:text>Réunion</xsl:text></xsl:when>
			<xsl:when test="($code='0RU' or $code='643') and $lang = $secondLanguage"><xsl:text>Russian Federation</xsl:text></xsl:when>
			<xsl:when test="($code='0RU' or $code='643') and $lang != $secondLanguage"><xsl:text>Rosja</xsl:text></xsl:when>
			<xsl:when test="($code='0RO' or $code='642') and $lang = $secondLanguage"><xsl:text>Romania</xsl:text></xsl:when>
			<xsl:when test="($code='0RO' or $code='642') and $lang != $secondLanguage"><xsl:text>Rumunia</xsl:text></xsl:when>
			<xsl:when test="($code='0RW' or $code='646')"><xsl:text>Rwanda</xsl:text></xsl:when>
			<xsl:when test="($code='0EH' or $code='732') and $lang = $secondLanguage"><xsl:text>Western Sahara</xsl:text></xsl:when>
			<xsl:when test="($code='0EH' or $code='732') and $lang != $secondLanguage"><xsl:text>Sahara Zachodnia</xsl:text></xsl:when>
			<xsl:when test="($code='0KN' or $code='659')"><xsl:text>Saint Kitts i Nevis</xsl:text></xsl:when>
			<xsl:when test="($code='0LC' or $code='662')"><xsl:text>Saint Lucia</xsl:text></xsl:when>
			<xsl:when test="($code='0VC' or $code='670')"><xsl:text>Saint Vincent i Grenadyny</xsl:text></xsl:when>
			<xsl:when test="($code='0BL' or $code='652')"><xsl:text>Saint-Barthélemy</xsl:text></xsl:when>
			<xsl:when test="($code='0MF' or $code='663')"><xsl:text>Saint-Martin</xsl:text></xsl:when>
			<xsl:when test="($code='0PM' or $code='666') and $lang = $secondLanguage"><xsl:text>Saint Pierre and Miquelon</xsl:text></xsl:when>
			<xsl:when test="($code='0PM' or $code='666') and $lang != $secondLanguage"><xsl:text>Saint-Pierre Miquelon</xsl:text></xsl:when>
			<xsl:when test="($code='0SV' or $code='222') and $lang = $secondLanguage"><xsl:text>El Salvador</xsl:text></xsl:when>
			<xsl:when test="($code='0SV' or $code='222') and $lang != $secondLanguage"><xsl:text>Salwador</xsl:text></xsl:when>
			<xsl:when test="($code='0AS' or $code='016') and $lang = $secondLanguage"><xsl:text>Amerikan Samoa</xsl:text></xsl:when>
			<xsl:when test="($code='0AS' or $code='016') and $lang != $secondLanguage"><xsl:text>Samoa Amerykańskie</xsl:text></xsl:when>
			<xsl:when test="($code='0WS' or $code='882')"><xsl:text>Samoa</xsl:text></xsl:when>
			<xsl:when test="($code='0SM' or $code='674')"><xsl:text>San Marino</xsl:text></xsl:when>
			<xsl:when test="($code='0SN' or $code='686')"><xsl:text>Senegal</xsl:text></xsl:when>
			<xsl:when test="($code='0RS' or $code='688')"><xsl:text>Serbia</xsl:text></xsl:when>
			<xsl:when test="($code='0SC' or $code='690') and $lang = $secondLanguage"><xsl:text>Seychelles</xsl:text></xsl:when>
			<xsl:when test="($code='0SC' or $code='690') and $lang != $secondLanguage"><xsl:text>Seszele</xsl:text></xsl:when>
			<xsl:when test="($code='0SL' or $code='694')"><xsl:text>Sierra Leone</xsl:text></xsl:when>
			<xsl:when test="($code='0SG' or $code='702') and $lang = $secondLanguage"><xsl:text>Singapore</xsl:text></xsl:when>
			<xsl:when test="($code='0SG' or $code='702') and $lang != $secondLanguage"><xsl:text>Singapur</xsl:text></xsl:when>
			<xsl:when test="($code='0SX' or $code='534')"><xsl:text>Sint Maarten</xsl:text></xsl:when>
			<xsl:when test="($code='0SK' or $code='703') and $lang = $secondLanguage"><xsl:text>Slovakia</xsl:text></xsl:when>
			<xsl:when test="($code='0SK' or $code='703') and $lang != $secondLanguage"><xsl:text>Słowacja</xsl:text></xsl:when>
			<xsl:when test="($code='0SI' or $code='705') and $lang = $secondLanguage"><xsl:text>Slovenia</xsl:text></xsl:when>
			<xsl:when test="($code='0SI' or $code='705') and $lang != $secondLanguage"><xsl:text>Słowenia</xsl:text></xsl:when>
			<xsl:when test="($code='0SO' or $code='706')"><xsl:text>Somalia</xsl:text></xsl:when>
			<xsl:when test="($code='0LK' or $code='144')"><xsl:text>Sri Lanka</xsl:text></xsl:when>
			<xsl:when test="($code='0US' or $code='840') and $lang = $secondLanguage"><xsl:text>United States of America</xsl:text></xsl:when>
			<xsl:when test="($code='0US' or $code='840') and $lang != $secondLanguage"><xsl:text>Stany Zjednoczone</xsl:text></xsl:when>
			<xsl:when test="($code='0SZ' or $code='748') and $lang = $secondLanguage"><xsl:text>Eswatini</xsl:text></xsl:when>
			<xsl:when test="($code='0SZ' or $code='748') and $lang != $secondLanguage"><xsl:text>Suazi</xsl:text></xsl:when>
			<xsl:when test="($code='0SD' or $code='729')"><xsl:text>Sudan</xsl:text></xsl:when>
			<xsl:when test="($code='0SS' or $code='728') and $lang = $secondLanguage"><xsl:text>South Sudan</xsl:text></xsl:when>
			<xsl:when test="($code='0SS' or $code='728') and $lang != $secondLanguage"><xsl:text>Sudan Południowy</xsl:text></xsl:when>
			<xsl:when test="($code='0SR' or $code='740') and $lang = $secondLanguage"><xsl:text>Suriname</xsl:text></xsl:when>
			<xsl:when test="($code='0SR' or $code='740') and $lang != $secondLanguage"><xsl:text>Surinam</xsl:text></xsl:when>
			<xsl:when test="($code='0SJ' or $code='744') and $lang = $secondLanguage"><xsl:text>Svalbard and Jan Mayen</xsl:text></xsl:when>
			<xsl:when test="($code='0SJ' or $code='744') and $lang != $secondLanguage"><xsl:text>Svalbard i Jan Mayen</xsl:text></xsl:when>
			<xsl:when test="($code='0SY' or $code='760')"><xsl:text>Syria</xsl:text></xsl:when>
			<xsl:when test="($code='0CH' or $code='756') and $lang = $secondLanguage"><xsl:text>Switzerland</xsl:text></xsl:when>
			<xsl:when test="($code='0CH' or $code='756') and $lang != $secondLanguage"><xsl:text>Szwajcaria</xsl:text></xsl:when>
			<xsl:when test="($code='0SE' or $code='752') and $lang = $secondLanguage"><xsl:text>Sweden</xsl:text></xsl:when>
			<xsl:when test="($code='0SE' or $code='752') and $lang != $secondLanguage"><xsl:text>Szwecja</xsl:text></xsl:when>
			<xsl:when test="($code='0TJ' or $code='762') and $lang = $secondLanguage"><xsl:text>Tajikistan</xsl:text></xsl:when>
			<xsl:when test="($code='0TJ' or $code='762') and $lang != $secondLanguage"><xsl:text>Tadżykistan</xsl:text></xsl:when>
			<xsl:when test="($code='0TH' or $code='764') and $lang = $secondLanguage"><xsl:text>Thailand</xsl:text></xsl:when>
			<xsl:when test="($code='0TH' or $code='764') and $lang != $secondLanguage"><xsl:text>Tajlandia</xsl:text></xsl:when>
			<xsl:when test="($code='0TW' or $code='158') and $lang = $secondLanguage"><xsl:text>Taiwan</xsl:text></xsl:when>
			<xsl:when test="($code='0TW' or $code='158') and $lang != $secondLanguage"><xsl:text>Tajwan</xsl:text></xsl:when>
			<xsl:when test="($code='0TZ' or $code='834')"><xsl:text>Tanzania</xsl:text></xsl:when>
			<xsl:when test="($code='0TZ' or $code='626') and $lang = $secondLanguage"><xsl:text>Timor-Leste</xsl:text></xsl:when>
			<xsl:when test="($code='0TL' or $code='626') and $lang != $secondLanguage"><xsl:text>Timor Wschodni</xsl:text></xsl:when>
			<xsl:when test="($code='0TG' or $code='768')"><xsl:text>Togo</xsl:text></xsl:when>
			<xsl:when test="($code='0TK' or $code='772')"><xsl:text>Tokelau</xsl:text></xsl:when>
			<xsl:when test="($code='0TO' or $code='776')"><xsl:text>Tonga</xsl:text></xsl:when>
			<xsl:when test="($code='0TT' or $code='780') and $lang = $secondLanguage"><xsl:text>Trinidad and Tobago</xsl:text></xsl:when>
			<xsl:when test="($code='0TT' or $code='780') and $lang != $secondLanguage"><xsl:text>Trynidad i Tobago</xsl:text></xsl:when>
			<xsl:when test="($code='0TN' or $code='788') and $lang = $secondLanguage"><xsl:text>Tunisia</xsl:text></xsl:when>
			<xsl:when test="($code='0TN' or $code='788') and $lang != $secondLanguage"><xsl:text>Tunezja</xsl:text></xsl:when>
			<xsl:when test="($code='0TR' or $code='792') and $lang = $secondLanguage"><xsl:text>Turkey</xsl:text></xsl:when>
			<xsl:when test="($code='0TR' or $code='792') and $lang != $secondLanguage"><xsl:text>Turcja</xsl:text></xsl:when>
			<xsl:when test="($code='0TM' or $code='795')"><xsl:text>Turkmenistan</xsl:text></xsl:when>
			<xsl:when test="($code='0TC' or $code='796') and $lang = $secondLanguage"><xsl:text>Turks and Caicos Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0TC' or $code='796') and $lang != $secondLanguage"><xsl:text>Turks i Caicos</xsl:text></xsl:when>
			<xsl:when test="($code='0TV' or $code='798')"><xsl:text>Tuvalu</xsl:text></xsl:when>
			<xsl:when test="($code='0UG' or $code='800')"><xsl:text>Uganda</xsl:text></xsl:when>
			<xsl:when test="($code='0UA' or $code='804') and $lang = $secondLanguage"><xsl:text>Ukraine</xsl:text></xsl:when>
			<xsl:when test="($code='0UA' or $code='804') and $lang != $secondLanguage"><xsl:text>Ukraina</xsl:text></xsl:when>
			<xsl:when test="($code='0UY' or $code='858') and $lang = $secondLanguage"><xsl:text>Uruguay</xsl:text></xsl:when>
			<xsl:when test="($code='0UY' or $code='858') and $lang != $secondLanguage"><xsl:text>Urugwaj</xsl:text></xsl:when>
			<xsl:when test="($code='0UZ' or $code='860')"><xsl:text>Uzbekistan</xsl:text></xsl:when>
			<xsl:when test="($code='0VU' or $code='548')"><xsl:text>Vanuatu</xsl:text></xsl:when>
			<xsl:when test="($code='0WF' or $code='876') and $lang = $secondLanguage"><xsl:text>Wallis and Futuna</xsl:text></xsl:when>
			<xsl:when test="($code='0WF' or $code='876') and $lang != $secondLanguage"><xsl:text>Wallis i Futuna</xsl:text></xsl:when>
			<xsl:when test="($code='0VA' or $code='336') and $lang = $secondLanguage"><xsl:text>Holy See</xsl:text></xsl:when>
			<xsl:when test="($code='0VA' or $code='336') and $lang != $secondLanguage"><xsl:text>Watykan</xsl:text></xsl:when>
			<xsl:when test="($code='0VE' or $code='862') and $lang = $secondLanguage"><xsl:text>Venezuela</xsl:text></xsl:when>
			<xsl:when test="($code='0VE' or $code='862') and $lang != $secondLanguage"><xsl:text>Wenezuela</xsl:text></xsl:when>
			<xsl:when test="($code='0HU' or $code='348') and $lang = $secondLanguage"><xsl:text>Hungary</xsl:text></xsl:when>
			<xsl:when test="($code='0HU' or $code='348') and $lang != $secondLanguage"><xsl:text>Węgry</xsl:text></xsl:when>
			<xsl:when test="($code='0GB' or $code='826') and $lang = $secondLanguage"><xsl:text>United Kingdom</xsl:text></xsl:when>
			<xsl:when test="($code='0GB' or $code='826') and $lang != $secondLanguage"><xsl:text>Wielka Brytania</xsl:text></xsl:when>
			<xsl:when test="($code='0VN' or $code='704') and $lang = $secondLanguage"><xsl:text>Viet Nam</xsl:text></xsl:when>
			<xsl:when test="($code='0VN' or $code='704') and $lang != $secondLanguage"><xsl:text>Wietnam</xsl:text></xsl:when>
			<xsl:when test="($code='0IT' or $code='380') and $lang = $secondLanguage"><xsl:text>Italy</xsl:text></xsl:when>
			<xsl:when test="($code='0IT' or $code='380') and $lang != $secondLanguage"><xsl:text>Włochy</xsl:text></xsl:when>
			<xsl:when test="($code='0CI' or $code='384') and $lang = $secondLanguage"><xsl:text>Côte d'Ivoire</xsl:text></xsl:when>
			<xsl:when test="($code='0CI' or $code='384') and $lang != $secondLanguage"><xsl:text>Wybrzeże Kości Słoniowej</xsl:text></xsl:when>
			<xsl:when test="($code='0BV' or $code='074') and $lang = $secondLanguage"><xsl:text>Bouvet Island</xsl:text></xsl:when>
			<xsl:when test="($code='0BV' or $code='074')"><xsl:text>Wyspa Bouveta</xsl:text></xsl:when>
			<xsl:when test="($code='0CX' or $code='162') and $lang = $secondLanguage"><xsl:text>Christmas Island</xsl:text></xsl:when>
			<xsl:when test="($code='0CX' or $code='162') and $lang != $secondLanguage"><xsl:text>Wyspa Bożego Narodzenia</xsl:text></xsl:when>
			<xsl:when test="($code='0IM' or $code='833') and $lang = $secondLanguage"><xsl:text>Isle of Man</xsl:text></xsl:when>
			<xsl:when test="($code='0IM' or $code='833') and $lang != $secondLanguage"><xsl:text>Wyspa Man</xsl:text></xsl:when>
			<xsl:when test="($code='0SH' or $code='654') and $lang = $secondLanguage"><xsl:text>Saint Helena, Ascension and Tristan da Cunha</xsl:text></xsl:when>
			<xsl:when test="($code='0SH' or $code='654') and $lang != $secondLanguage"><xsl:text>Wyspa Świętej Heleny, Wyspa Wniebowstąpienia i Tristan da Cunha</xsl:text></xsl:when>
			<xsl:when test="($code='0AX' or $code='248')"><xsl:text>Wyspy Alandzkie</xsl:text></xsl:when>
			<xsl:when test="($code='0CK' or $code='184') and $lang = $secondLanguage"><xsl:text>Cook Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0CK' or $code='184') and $lang != $secondLanguage"><xsl:text>Wyspy Cooka</xsl:text></xsl:when>
			<xsl:when test="($code='0VI' or $code='850') and $lang = $secondLanguage"><xsl:text>Virgin Islands, U.S.</xsl:text></xsl:when>
			<xsl:when test="($code='0VI' or $code='850') and $lang != $secondLanguage"><xsl:text>Wyspy Dziewicze Stanów Zjednoczonych</xsl:text></xsl:when>
			<xsl:when test="($code='0HN' or $code='334') and $lang = $secondLanguage"><xsl:text>Heard Island and McDonald Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0HN' or $code='334') and $lang != $secondLanguage"><xsl:text>Wyspy Heard i McDonalda</xsl:text></xsl:when>
			<xsl:when test="($code='0CC' or $code='166') and $lang = $secondLanguage"><xsl:text>Cocos Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0CC' or $code='166') and $lang != $secondLanguage"><xsl:text>Wyspy Kokosowe</xsl:text></xsl:when>
			<xsl:when test="($code='0MH' or $code='584') and $lang = $secondLanguage"><xsl:text>Marshall Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0MH' or $code='584') and $lang != $secondLanguage"><xsl:text>Wyspy Marshalla</xsl:text></xsl:when>
			<xsl:when test="($code='0FO' or $code='234') and $lang = $secondLanguage"><xsl:text>Faroe Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0FO' or $code='234') and $lang != $secondLanguage"><xsl:text>Wyspy Owcze</xsl:text></xsl:when>
			<xsl:when test="($code='0SB' or $code='090') and $lang = $secondLanguage"><xsl:text>Solomon Islands</xsl:text></xsl:when>
			<xsl:when test="($code='0SB' or $code='090') and $lang != $secondLanguage"><xsl:text>Wyspy Salomona</xsl:text></xsl:when>
			<xsl:when test="($code='0ST' or $code='678') and $lang = $secondLanguage"><xsl:text>Sao Tome and Principe</xsl:text></xsl:when>
			<xsl:when test="($code='0ST' or $code='678') and $lang != $secondLanguage"><xsl:text>Wyspy Świętego Tomasza i Książęca</xsl:text></xsl:when>
			<xsl:when test="($code='0ZM' or $code='894')"><xsl:text>Zambia</xsl:text></xsl:when>
			<xsl:when test="($code='0ZW' or $code='716')"><xsl:text>Zimbabwe</xsl:text></xsl:when>
			<xsl:when test="($code='0AE' or $code='784') and $lang = $secondLanguage"><xsl:text>United Arab Emirates</xsl:text></xsl:when>
			<xsl:when test="($code='0AE' or $code='784') and $lang != $secondLanguage"><xsl:text>Zjednoczone Emiraty Arabskie</xsl:text></xsl:when>
			<xsl:when test="$lang = $secondLanguage"><xsl:text>Unrecognized country code: </xsl:text><xsl:value-of select="$code"/></xsl:when>
			<xsl:otherwise><xsl:text>Kod kraju nieznany: </xsl:text><xsl:value-of select="$code"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="fillUpToThreeChars">
		<xsl:param name="code"/>
		<xsl:choose>
			<xsl:when test="string-length($code) = 3">
				<xsl:value-of select="$code"/>
			</xsl:when>
			<xsl:when test="string-length($code) = 2">
				<xsl:text>0</xsl:text>
				<xsl:value-of select="$code"/>
			</xsl:when>
			<xsl:when test="string-length($code) = 1">
				<xsl:text>00</xsl:text>
				<xsl:value-of select="$code"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- kod kraju nieznany -->
				<xsl:value-of select="$code"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- przykład translacji wartości słownika, zaniechano implementacji
		słownik jest zmienny w czasie, należy umieszczać displayName w dokumencie
		<xsl:template name="translateZawodMedycznyValueSet">
		<xsl:param name="code"/>
		
		<xsl:choose>
			<xsl:when test="$code='LEK'">
				<xsl:text>Lekarz</xsl:text>
			</xsl:when>
			<xsl:when test="$code='FEL'">
				<xsl:text>Felczer</xsl:text>
			</xsl:when>
			<xsl:when test="$code='LEKD'">
				<xsl:text>Lekarz dentysta</xsl:text>
			</xsl:when>
			<xsl:when test="$code='PIEL'">
				<xsl:text>Pielęgniarka</xsl:text>
			</xsl:when>
			<xsl:when test="$code='POL'">
				<xsl:text>Położna</xsl:text>
			</xsl:when>
			<xsl:when test="$code='FARM'">
				<xsl:text>Farmaceuta</xsl:text>
			</xsl:when>
			<xsl:when test="$code='DLAB'">
				<xsl:text>Diagnosta laboratoryjny</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template> -->
	
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++ POMOCNICZE +++++++++++++++++++++++++++++++++++++++++++++++++++++-->
	<!-- pierwiastek kwadratowy na potrzeby SVG (Sean B. Durkin) -->
	<xsl:template name="squareOfPositive">
		<xsl:param name="x"/>
		<xsl:choose>
			<xsl:when test="$x > 1">
				<xsl:call-template name="iterate-root">
					<xsl:with-param name="x" select="$x" />
					<xsl:with-param name="H" select="$x" />
					<xsl:with-param name="L" select="0" />
				</xsl:call-template>  
			</xsl:when>  
			<xsl:when test="($x = 1) or ($x &lt;= 0)">
				<xsl:value-of select="$x" />
			</xsl:when>  
			<xsl:otherwise>
				<xsl:variable name="inv-root">
					<xsl:call-template name="iterate-root">
						<xsl:with-param name="x" select="1 div $x" />
						<xsl:with-param name="H" select="1 div $x" />
						<xsl:with-param name="L" select="0" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="1 div $inv-root" />
			</xsl:otherwise>  
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="iterate-root">
		<xsl:param name="x"/>
		<xsl:param name="H"/>
		<xsl:param name="L"/>
		<xsl:variable name="M" select="($H + $L) div 2" />
		<xsl:variable name="g" select="($M * $M - $x) div $x" />
		<xsl:variable name="verysmall" select="0.001"/>
		<xsl:choose>
			<xsl:when test="(($g &lt; $verysmall) and ((- $g) &lt; $verysmall)) or (($H - $L) &lt; $verysmall)">
				<xsl:value-of select="$M"/>
			</xsl:when>
			<xsl:when test="$g > 0">
				<xsl:call-template name="iterate-root">
					<xsl:with-param name="x" select="$x" />
					<xsl:with-param name="H" select="$M" />
					<xsl:with-param name="L" select="$L" />
				</xsl:call-template>  
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="iterate-root">
					<xsl:with-param name="x" select="$x" />
					<xsl:with-param name="H" select="$H" />
					<xsl:with-param name="L" select="$M" />
				</xsl:call-template>  
			</xsl:otherwise>
		</xsl:choose>  
	</xsl:template>

	<!-- w trybie screen ukrywa część danych pozwalając na żądanie je odkryć -->
	<xsl:template name="showDheaderEnabler">
		<xsl:param name="blockName"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:variable name="show">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Show</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Rozwiń</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="hide">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Hide</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Ukryj</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<input id="show_{$blockName}_id" name="{$blockName}" type="radio" class="show_{$blockName}"/>
		<label for="show_{$blockName}_id" class="show_{$blockName}_label">
			<span><xsl:value-of select="$show"/></span>
		</label>
		<input id="hide_{$blockName}_id" name="{$blockName}" type="radio" class="hide_{$blockName}"/>
		<label for="hide_{$blockName}_id" class="hide_{$blockName}_label">
			<span><xsl:value-of select="$hide"/></span>
		</label>
	</xsl:template>
	
	<xsl:template name="showDheaderEnablerStyle">
		<xsl:param name="blockName"/>
		
		<xsl:text>
	#show_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_id {
		display:none;
	}
	.show_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_label {
		float: right;
		padding: 1px 6px 0 3px;
		font-size: 0.9em;
		cursor: pointer;
		color: blue;
		text-decoration: underline;
		background: white;
	}
	#hide_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_id {
	    display:none;
	}
	.hide_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_label {
		float: right;
		padding: 1px 6px 0 3px;
		font-size: 0.9em;
		cursor: pointer;
		color: blue;
		text-decoration: underline;
		background: white;
		display:none;
	}
	input#show_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_id:checked ~ .header_dheader {
		display:block;
	}
	input#hide_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_id:checked ~ .header_dheader {
	    display:none;
	}
	input#show_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_id:checked ~ .show_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_label {
		display:none;
	}
	input#show_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_id:checked ~ .hide_</xsl:text><xsl:value-of select="$blockName"/><xsl:text>_label {
	 	display:block;
	}
		</xsl:text>
	</xsl:template>

	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++ STYLE +++++++++++++++++++++++++++++++++++++++++++++++++++++-->
	
	<xsl:template name="styles">
		<!-- w trybie mobilnym wstrzymano się z włączeniem trybu pełnoekranowego
		<meta name="viewport" content="width=device-widht"/> -->
		
		<style type="text/css">
		
@media screen {
	body {
		margin: 0px;
		display: block;
		background-color: #f1f1f1;
	}

	.document {
		margin: 15px auto;
		width: 756px;
		overflow: hidden;
		font-family: "Noto sans", sans-serif;
		font-size: 10pt;
		-webkit-box-shadow: 0px 0px 2px 2px #dcdcdc;
		box-shadow: 0px 0px 2px 2px #dcdcdc;
		background-color: white;
	}
	
				<xsl:call-template name="showDheaderEnablerStyle">
				<xsl:with-param name="blockName">responsible_party</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">encounter_participant</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">service_performer_pprf</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">service_performer_prf</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">data_enterer</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">authenticator</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">author</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">informant</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">authorization</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">participant</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="showDheaderEnablerStyle">
					<xsl:with-param name="blockName">legal_authenticator</xsl:with-param>
				</xsl:call-template>
				
				<xsl:text>
	
	.header_dheader {
		display: none;
	}
	
	#showCdaHeader {
	    display:none;
	}
	.show_cda_header_label {
		position: absolute;
		right: 12px;
		padding: 4px 5px 0px 5px;
		font-size: 0.9em;
		cursor: pointer;
		color: blue;
		text-decoration: underline;
		background: white;
	}
	#hideCdaHeader {
	    display:none;
	}
	.hide_cda_header_label {
		position: absolute;
		right: 12px;
		padding: 4px 5px 0px 5px;
		font-size: 0.9em;
		cursor: pointer;
		color: blue;
		text-decoration: underline;
		background: white;
		display:none;
	}
	
	.doc_dheader {
	    display:none;
	}
	input#showCdaHeader:checked ~ .doc_dheader {
		display:block;
	}
	input#hideCdaHeader:checked ~ .doc_dheader {
	    display:none;
	}
	input#showCdaHeader:checked ~ .show_cda_header_label {
		display:none;
	}
	input#showCdaHeader:checked ~ .hide_cda_header_label {
	 	display:block;
	}
}

@media print {
	body {
		margin: 0px;
		display: block;
		background-color: white;
	}

	.document {
		width: 200mm;
		overflow: hidden;
		font-family: "Noto sans", sans-serif;
		font-size: 10pt;
		background-color: white;
		background-repeat: no-repeat;
		background-image: none;
	}
	
	.doc_header_enabler {
		display:none;
	}

	input {
		display:none;
	}
	label {
		display:none;
	}
}

.doc_title {
	font-size: 1.4em;
	text-align: center;
	font-weight: bold;
	border-bottom: 3px black solid;
	padding: 4px 0 2px 0;
}

.title_suffix {
	font-size: 0.7em;
	font-weight: bold;
	position: absolute;
	margin: 5px;
}

.highlighted {
	color: red;
}
.toned {
	color: grey;
}

.doc_header_elements {
	clear: both;
	font-size: 1.0em;
}
.doc_header_elements > .doc_header_element {
	margin-top: 3px;
	margin-left: 15px;
}
.doc_header_elements>.doc_header_element > .header_label {
	font-size: 1.0em;
}

.header_elements_block_label {
	display: none;
}

.related_document_header_element {
	float: right;
	margin-right: 15px;
}
.related_document_block_label {
	display: none;
}

.doc_header_element {
	display: inline-block;
}
.id_header_element {
	float: right;
	margin-right: 15px;
}

.id_header_value {
	font-size: 0.8em;
}

.confidentiality_code_label {
	display: none;
}
.confidentiality_code_value {
	float: right;
	color: red;
}

.version_header_element {
	margin-left: 15px;
}
.value_set_header_element {
	float: right;
	margin-right: 15px;
}


.doc_header {
	clear: left;
	float: left;
	width: 100%;
	overflow:hidden;
	border-top: 3px black solid;
	border-bottom: 3px black solid;
}

.doc_header_2 {
	float: left;
	width: 100%;
	position: relative;
	right: 50%;
	border-right: 2px solid #4d4d4d;
}

.patient_related_header {
	float: left;
	width: 46%;
	position: relative;
	left: 52%;
	overflow: hidden;
}

.document_related_header {
	float: left;
	width: 46%;
	position: relative;
	left: 56%;
	overflow: hidden;
}

.doc_theader {
	position:relative;
}


/*
.doc_dheader {
	display:none;
}

.doc_header_enabler {
	position: absolute;
	right: 30px;
	padding: 4px 5px 0px 5px;
	font-size: 0.9em;
	cursor: pointer;
	color: blue;
	text-decoration: underline;
	background: white;
}

.doc_header_enabler:focus + .doc_dheader {
	display: block;
}

.doc_header_enabler:focus {
	cursor: default;
}*/

.header_bottom {
	clear: both;
}

.doc_body {
	width: 100%;
	float: left;
	font-size: 1.1em;
}

.header_block {
	margin: 0 0 3px 0;
	padding: 3px 0;
	/**border-top: 2px solid #4d4d4d;**/
}

.header_block:not(:first-child) {
	border-top: 2px solid black;
}

.header_block_label {
	font-size: 1.1em;
	font-weight: bold;
}
.header_element {
	margin-top: 4px;
	margin-bottom: 2px;
	margin-left: 7px;
}
.header_label {
	font-weight: bold;
	font-size: 1.0em;
}
.header_value {
	margin-left: 5px;
	margin-top: 3px;
	overflow-wrap: break-word;
	word-wrap: break-word;
	-ms-word-break: break-all;
	word-break: break-word;
	hyphens: auto;
}
.header_inline_value {
	display: inline;
}

.header_block0:not(:first-child) {
	border-top: 1px solid #909090;
	padding-top: 3px;
}
.header_block1 {
	border-top: 1px solid #909090;
	padding-top: 3px;
}
.header_block1 .header_block_label {
	font-size: 1em;
}

.header_block2 {
	border-top: 1px solid #909090;
	padding-top: 3px;
}
.header_block3 {
	border-top: 1px solid #909090;
	padding-top: 3px;
}
.header_block4 {
	border-top: 1px solid #909090;
	padding-top: 3px;
}

.person_name_label {
	display: none;
}
.person_name_value {
	font-size: 1.3em;
}
.organization_name_label {
	display: none;
}
.age_element {
	margin-left: 0px;
}
.id_label {
	display: none;
}
.null_flavor {
	margin-left: 4px;
}
.not_known_id_prefix {
	font-weight: bold;
}
.id_header_element > .header_value > span > .not_known_id_prefix {
	display: none;
}
.id_header_element > .header_value > .null_flavor_id {
	display: none;
}
.value_set_header_element > .header_value > span > .not_known_id_prefix {
	display: none;
}
.value_set_header_element > .header_value > .null_flavor_id {
	display: none;
}
.related_document_header_element > .header_value > span > .not_known_id_prefix {
	display: none;
}
.related_document_header_element > .header_value > .null_flavor_id {
	display: none;
}

.legal_authenticator_id_value > div {
	display: inline;
}
.legal_authenticator_qualification_element {
	font-size: 0.9em;
}
.assigned_entity_code_header_element {
	font-size: 0.9em;
	float: left;
	margin: 5px 7px 1px 12px;
}

@media screen {
	.signature_code_value {
		float: right;
		font-size: 0.8em;
		margin-top: 3px;
	}
	.signature_code_value_print {
		display: none;
	}
}
@media print {
	.signature_code_value {
		display: none;
	}
	.signature_code_value_print {
		float: right;
		font-size: 8pt;
		margin-top: 1mm;
	}
}

.reimbursement_related_contract_element {
}
.reimbursement_related_contract_element > .header_label {
	font-size: 0.9em;
}
.reimbursement_related_contract_element > .header_value {
	font-size: 0.9em;
}

.header_block2, .header_block2 > .header_element > .header_block_label {
	font-size: 0.9em !important;
}
.header_block3, .header_block3 > .header_element > .header_block_label {
	font-size: 0.9em !important;
}
.header_block4, .header_block4 > .header_element > .header_block_label {
	font-size: 0.9em !important;
}

.doc_underwriter {
}
.underwriter_label {
}
.underwriter_id_label {
}
.underwriter_id_value {
	font-size: 1.1em;
}

.doc_custodian {
}
.custodian_block_label {
}

.identifier {
	font-size: 0.9em;
}

.address_element {
}

.address_value {
	margin-left: 15px;
	margin-bottom: 7px;
}

.doc_body {
	overflow-wrap: break-word;
	word-wrap: break-word;
	-ms-word-break: break-all;
	word-break: break-word;
	hyphens: auto;
}

.section_element_1 {
	padding: 7px;
	border-top: 1px black solid;
}
.doc_body > .section_element_1:first-child {
  border-top: none;
}
.doc_body > .section_element_1:last-child {
  padding-bottom: 10px;
}

.popup_container {
	position: relative;
	float: right;
}

.section_dheader_enabler {
	float: right;
	padding: 0 6px 0 3px;
	font-size: 0.9em;
	cursor: pointer;
	color: blue;
	text-decoration: underline;
	background: white;
}

.section_popup {
	font-size: 0.9em;
	white-space: nowrap;
}

.section_dheader {
	display: none;
}

.section_dheader_enabler:focus + .section_dheader {
	position: absolute;
	right: 0;
	margin-top: 20px;
	padding: 3px 7px 0 7px;
	z-index: 100;
	background: white;
	box-shadow: 0px 0px 2px 2px #dcdcdc;
	display: block;
}

.section_dheader_enabler:focus {
	cursor: default;
}

.section_title_1 {
	font-size: 1.1em;
	font-weight: bold;
}
.section_text_1 {
	padding: 7px 7px 0px 7px;
}

.section_element_2 {
	padding: 7px;
}
.section_title_2 {
	font-size: 1.1em;
	font-weight: bold;
}
.section_text_2 {
	padding: 7px 7px 0px 7px;
}

.header_inline_value > .oid {
	display: inline;
}

.caption {
	font-weight: bold;
}
.paragraph {
	margin-bottom: 7px;
}
.paragraph_caption {
	padding-right: 3px;
}
.paragraph:last-child {
	margin-bottom: 0px !important;
}
.paragraph > span:last-child {
	margin-bottom: 0px !important;
}

.footnote_div {
	border-top: 1px solid #dcdcdc;
	padding: 7px;
}
.footnote_text_inline {
}
.footnote_label {
	font-size: 1.0em;
	font-weight: bold;
}
.footnote_values {
	font-size: 0.9em;
	/**font-family: Georgia, serif;**/
}
.footnote_value {
	margin: 2px 0 0 15px;
}

img {
    height: 100%;
	width: 100%;
	max-width: 718px;
}
svg {
    height: 100%;
	width: 100%;
	max-width: 718px;
}

.multimedia_under_region_of_interest {
	position: relative;
	height: 100%;
	width: 100%;
    max-width: 718px;
}
.region_of_interest {
	position: absolute;
	top: 0;
	left: 0;
	height: 100%;
	width: 100%;
    max-width: 718px;
}

.multimedia_pdf {
	width: 100%;
	height: 1012px;
	padding-top: 5px;
}

.box {
	position: relative;
}

ol, ul {
	margin: 0;
}

.table_caption {
	font-weight: bold;
}
table {
	border-collapse: collapse;
}
th, td {
	padding: 5px;
}
			</xsl:text>
			
			<!-- jeśli nie użyto żadnych stylów typu Rrule Lrule Toprule Botrule, 
				 dodawany jest styl delikatnej szarej linii -->
			<xsl:if test="//hl7:table and not(//*[contains(@styleCode, 'Botrule')] or //*[contains(@styleCode, 'Lrule')] or //*[contains(@styleCode, 'Rrule')] or //*[contains(@styleCode, 'Toprule')])">
				<xsl:text>
table, th, td {
	border: 1px solid #dcdcdc;
}
				</xsl:text>
			</xsl:if>
		</style>
	</xsl:template>
	
	
	<!-- ++++++++++++++++++++++++++++++++++++++ STRUCTURED BODY +++++++++++++++++++++++++++++++++++++++++++-->
	
	<!-- structuredBody  -->
	<xsl:template name="structuredBody">
		<xsl:for-each select="hl7:component/hl7:structuredBody/hl7:component/hl7:section">
			<xsl:call-template name="section"/>
		</xsl:for-each>
	</xsl:template>
	
	<!-- główne sekcje dokumentu -->
	<xsl:template name="section">
		<div class="section_element_1">
			<xsl:call-template name="sectionParticipants"/>
			<xsl:if test="hl7:title">
				<xsl:call-template name="mainSectionTitle">
					<xsl:with-param name="title" select="hl7:title"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="mainSectionText"/>
			<xsl:for-each select="hl7:component/hl7:section">
				<xsl:call-template name="subSection">
					<xsl:with-param name="level" select="2"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:call-template name="footnotesOnTheBottom"/>
		</div>
	</xsl:template>
	
	<!-- tytuł głównej sekcji -->
	<xsl:template name="mainSectionTitle">
		<xsl:param name="title"/>
		<span class="section_title_1">
			<xsl:value-of select="$title"/>
		</span>
	</xsl:template>
	
	<!-- treść głównej sekcji -->
	<xsl:template name="mainSectionText">
		<div class="section_text_1">
			<xsl:call-template name="sectionText">
				<xsl:with-param name="text" select="hl7:text"/>
			</xsl:call-template>
		</div>
	</xsl:template>
	
	<!-- sekcje zagnieżdżone, wywołanie rekurencyjne -->
	<xsl:template name="subSection">
		<xsl:param name="level"/>
		<div class="section_element_{$level}">
			<xsl:call-template name="sectionParticipants"/>
			<span class="section_title_{$level}">
				<xsl:value-of select="hl7:title"/>
			</span>
			<div class="section_text_{$level}">
				<xsl:call-template name="sectionText">
					<xsl:with-param name="text" select="hl7:text"/>
				</xsl:call-template>
			</div>
		</div>
		<xsl:for-each select="hl7:component/hl7:section">
			<xsl:call-template name="subSection">
				<xsl:with-param name="level" select="$level+1"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="sectionText">
		<xsl:param name="text"/>
		<xsl:apply-templates select="$text"/>
	</xsl:template>
	
	<!-- Inny podmiot sekcji, dane autorów sekcji, dane informatorów sekcji -  wyświetlane w popupach -->
	<xsl:template name="sectionParticipants">
		<xsl:if test="hl7:subject or count(hl7:informant)&gt;0 or count(hl7:author)&gt;0">
		
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
	    	<xsl:variable name="organizationLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Organization</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Organizacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="popup_container">
				<xsl:if test="count(hl7:author)&gt;0">
				
					<xsl:variable name="authorDateLabel">
						<xsl:choose>
							<xsl:when test="$lang = $secondLanguage">
								<xsl:text>Date</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Data</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<span class="section_dheader_enabler" tabindex='0'>
						<xsl:choose>
							<xsl:when test="count(hl7:author) = 1 and $lang = $secondLanguage">
								<xsl:text>Section author</xsl:text>
							</xsl:when>
							<xsl:when test="count(hl7:author) &gt; 1 and $lang = $secondLanguage">
								<xsl:text>Section authors</xsl:text>
							</xsl:when>
							<xsl:when test="count(hl7:author) = 1">
								<xsl:text>Autor</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Autorzy</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<div class="section_dheader">
						<xsl:for-each select="hl7:author">
							<xsl:call-template name="assignedEntity">
								<xsl:with-param name="entity" select="./hl7:assignedAuthor"/>
								<xsl:with-param name="blockClass">header_block section_popup</xsl:with-param>
								<xsl:with-param name="blockLabel"/>
								<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
								<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
							</xsl:call-template>
							<xsl:call-template name="dateTimeInDiv">
								<xsl:with-param name="date" select="./hl7:time"/>
								<xsl:with-param name="label" select="$authorDateLabel"/>
								<xsl:with-param name="divClass">header_element</xsl:with-param>
								<xsl:with-param name="calculateAge" select="false()"/>
							</xsl:call-template>
						</xsl:for-each>
					</div>
				</xsl:if>
				
				<xsl:if test="count(hl7:informant)&gt;0">
					<span class="section_dheader_enabler" tabindex='0'>
						<xsl:choose>
							<xsl:when test="count(hl7:informant) = 1 and $lang = $secondLanguage">
								<xsl:text>Informant</xsl:text>
							</xsl:when>
							<xsl:when test="count(hl7:informant) &gt; 1 and $lang = $secondLanguage">
								<xsl:text>Informants</xsl:text>
							</xsl:when>
							<xsl:when test="count(hl7:informant) = 1">
								<xsl:text>Informator</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Informatorzy</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<div class="section_dheader">
						<xsl:for-each select="hl7:informant">
							<xsl:choose>
								<xsl:when test="./hl7:assignedEntity">
									<xsl:call-template name="assignedEntity">
										<xsl:with-param name="entity" select="./hl7:assignedEntity"/>
										<xsl:with-param name="blockClass">header_block section_popup</xsl:with-param>
										<xsl:with-param name="blockLabel"/>
										<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
										<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
									</xsl:call-template>
								</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="assignedEntity">
									<xsl:with-param name="entity" select="./hl7:relatedEntity"/>
									<xsl:with-param name="context">relatedEntity</xsl:with-param>
									<xsl:with-param name="blockClass">header_block section_popup</xsl:with-param>
									<xsl:with-param name="blockLabel"/>
									<xsl:with-param name="organizationLevel1BlockLabel" select="$organizationLabel"/>
									<xsl:with-param name="knownIdentifiersOnly" select="false()"/>
								</xsl:call-template>
							</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</xsl:if>
				
				<xsl:if test="hl7:subject">
					<span class="section_dheader_enabler" tabindex='0'>
						<xsl:choose>
							<xsl:when test="$lang = $secondLanguage">
								<xsl:text>Different subject</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>Dotyczy osoby</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<div class="section_dheader">
						<xsl:call-template name="sectionSubject"/>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- Dane podmiotu (zawsze wyłącznie osoba) związanego z sekcją, templateId 2.16.840.1.113883.3.4424.13.10.4.15 -->
	<xsl:template name="sectionSubject">
		<xsl:variable name="subject" select="hl7:subject/hl7:relatedSubject"/>
		
		<xsl:if test="$subject">
			<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
			
	    	<xsl:variable name="relationshipLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Relationship</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Relacja</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="birthDateLabel">
				<xsl:choose>
					<xsl:when test="$lang = $secondLanguage">
						<xsl:text>Birth date</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Data urodzenia</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<div class="header_block section_popup">
				<xsl:if test="$subject/hl7:subject/hl7:name">
					<xsl:call-template name="personName">
						<xsl:with-param name="name" select="$subject/hl7:subject/hl7:name"/>
					</xsl:call-template>
				</xsl:if>
				
				<!-- kod relacji z pacjentem -->
				<div class="header_element">
					<span class="header_label">
						<xsl:value-of select="$relationshipLabel"/>
					</span>
					<div class="header_inline_value header_value">
						<xsl:call-template name="translatePersonalRelationshipRoleCode">
							<xsl:with-param name="roleCode" select="$subject/hl7:code/@code"/>
						</xsl:call-template>
					</div>
				</div>
				
				<!-- data urodzenia podmiotu sekcji, nie wyświetlamy wieku -->
				<xsl:call-template name="dateTimeInDiv">
					<xsl:with-param name="date" select="$subject/hl7:subject/hl7:birthTime"/>
					<xsl:with-param name="label" select="$birthDateLabel"/>
					<xsl:with-param name="divClass">header_element</xsl:with-param>
					<xsl:with-param name="calculateAge" select="false()"/>
				</xsl:call-template>
				
				<!-- płeć -->
				<xsl:call-template name="translateGenderCode">
					<xsl:with-param name="genderCode" select="$subject/hl7:subject/hl7:administrativeGenderCode"/>
				</xsl:call-template>
				
				<!-- dane adresowe i kontaktowe podmiotu -->
				<xsl:call-template name="addressTelecomInDivs">
					<xsl:with-param name="addr" select="$subject/hl7:addr"/>
					<xsl:with-param name="telecom" select="$subject/hl7:telecom"/>
				</xsl:call-template>
			</div>
		</xsl:if>
    </xsl:template>
	

<!-- Transformata przekodowuje tagi MIME type "text/x-hl7-text+xml" na html:
	<content> - odpowiednik <span> w HTML, posiada opcjonalny identyfikator wykorzystywany do wskazywania tego tekstu w bloku entry. 
					Tag ten służy też do wyróżniania zmian w tekście pomiędzy wersjami dokumentu przy wykorzytaniu atrybutu @revised.
	<sub> oraz <sup> - identyczne jak w HTML
	<br> - identyczne jak w HTML
	<footnote> oraz <footnoteRef> - bez odpowiedników w HTML, należy oprogramować 
	<caption> - nagłówek elementów paragraph, list, list item, table, table cell, renderMultimedia. Może zawierać linki, przypisy, sub, sup.
	<paragraph> - odpowiednik <p> w HTML
	<linkHtml> - odpowiednik <a> w HTML, nie identyczny
	<renderMultiMedia> - odpowiednik <img> w HTML
	<list> z atrybutem @listType oraz elementem <item> - odpowiednik list <ol> i <ul> z elementem <li> w HTML
	<table> z elementami <thead>, <tbody>, <tfoot>, <th>, <td>, <tr>, <colgroup>, <col>, <caption> - identyczne jak w HTML
	atrybut styleCode:
	 - z listą wartości prymitywnych: bold, underline, emphasis, italics 
	 - od IG 1.3.1 z polskimi rozszerzeniami umożliwiającymi:
	 	- użycie podstawowych kolorów CSS dla czcionek: xPLred, xPLblue, xPLgreen, xPLlime, xPLgray, xPLviolet, xPLpurple, xPLorange, xPLolive, xPLnavy, xPLsilver,
	 	- powiększonego oraz pomniejszonego rozmiaru czcionki: xPLbig, xPLsmall, xPLxsmall,
	 	- dodanie margin'u między oddzielnymi wierszami jednego paragraph'u: xPLtextLine.
	-->

	<!-- content -->
	<xsl:template match="hl7:content">
		<xsl:choose>
			<xsl:when test="@revised='delete'">
				<!-- content wyróżniający fragmenty tekstu jako usunięte z poprzedniej wersji dokumentu -->
				<!-- tekst nie jest wyświetlany, pomijana jest cała usunięta zawartość, 
					 można rozważyć czy dodać specjalną obsługę revised (insert/delete), aktualnie uznano, że są to informacje nadmiarowe -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="span">
					<xsl:apply-templates select="@styleCode"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- sup -->
	<xsl:template match="hl7:sup">
		<xsl:element name="sup">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- sub -->
	<xsl:template match="hl7:sub">
		<xsl:element name="sub">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- br -->
	<xsl:template match="hl7:br">
		<xsl:element name='br'>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- przypis w sekcji -->
	<xsl:template match="hl7:footnote">
		<xsl:variable name="referenceId" select="@ID"/>
		<sup>
			<xsl:text>[</xsl:text>
			<xsl:choose>
				<xsl:when test="$referenceId">
					<a href="#przypis-{$referenceId}">
						<xsl:value-of select="$referenceId"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<!-- pojedyncze wystąpienie bez ID, brak odnośnika -->
					<span class="footnote_text_inline">
						<xsl:apply-templates/>
					</span>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>]</xsl:text>
		</sup>
	</xsl:template>
	
	<!-- odnośnik do przypisu -->
	<xsl:template match="hl7:footnoteRef">
		<xsl:variable name="referencedId" select="@IDREF"/>
		<sup>
			<xsl:text>[</xsl:text>
			<a href="#przypis-{$referencedId}">
				<xsl:value-of select="$referencedId"/>
			</a>
			<xsl:text>]</xsl:text>
		</sup>
	</xsl:template>
	
	<!-- przypis - wyświetlenie -->
	<xsl:template name="footnotesOnTheBottom">
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:variable name="footnoteLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Footnotes</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Przypisy</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="footnotes" select=".//hl7:footnote[@ID]"/>
		
		<xsl:if test="$footnotes">
			<div class="footnote_div">
				<span class="footnote_label">
					<xsl:value-of select="$footnoteLabel"/>
				</span>
				<div class="footnote_values">
					<xsl:for-each select="$footnotes">
						<xsl:if test="./@ID">			
							<div class="footnote_value">
								<a id="przypis-{./@ID}">
									<xsl:value-of select="./@ID"/>
									<xsl:text>. </xsl:text>	
									<xsl:apply-templates/>
								</a>	
							</div>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- nagłówek akapitu
		parametr intentionally wyokrzystywany jest do wyjęcia <caption> z elementu <paragraph> 
		w sytuacji gdy caption nie jest pierwszym węzłem paragraph,
		umieszczenie tekstu w <paragraph> przed elementem <caption> jest zgodne z XSD 
		o ile tekst nie zawiera innych elementów, nie jest jednak zalecane -->
	<xsl:template match="hl7:paragraph/hl7:caption">
		<xsl:param name="intentionally" select="false()"/>
		<xsl:if test="$intentionally">
			<xsl:element name="span">
				<xsl:attribute name="class">paragraph_caption caption</xsl:attribute>
				<xsl:apply-templates select="@styleCode"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<!-- paragraph -->
	<xsl:template match="hl7:paragraph">
		<xsl:element name="div">
			<xsl:attribute name="class">paragraph</xsl:attribute>
			<xsl:apply-templates select="@styleCode"/>
			<xsl:apply-templates select="hl7:caption">
				<xsl:with-param name="intentionally" select="true()"/>
			</xsl:apply-templates>
			<!-- spowoduje wywołanie template'ów dla wszystkich węzłów i dla caption, 
				jednak template caption nie wykona się bez parametru "intentionally" -->
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- list -->
	<xsl:template match="hl7:list">
		
		<xsl:apply-templates select="hl7:caption">
			<xsl:with-param name="intentionally" select="true()"/>
		</xsl:apply-templates>
		
		<xsl:choose>
			<xsl:when test="@listType='ordered'">
				<xsl:element name="ol">
					<xsl:choose>
						<!-- HTML5 nie wspiera tych typów -->
						<xsl:when test="contains(@styleCode, 'Arabic')">
							 <xsl:attribute name="type">1</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(@styleCode, 'BigAlpha')">
							 <xsl:attribute name="type">A</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(@styleCode, 'BigRoman')">
							 <xsl:attribute name="type">I</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(@styleCode, 'LittleAlpha')">
							 <xsl:attribute name="type">a</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(@styleCode, 'LittleRoman')">
							 <xsl:attribute name="type">i</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:apply-templates select="@styleCode"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="ul">
					<xsl:choose>
						<!-- HTML5 nie wspiera tych typów -->
						<xsl:when test="contains(@styleCode, 'Circle')">
							 <xsl:attribute name="type">circle</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(@styleCode, 'Disc')">
							 <xsl:attribute name="type">disc</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(@styleCode, 'Square')">
							 <xsl:attribute name="type">square</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:apply-templates select="@styleCode"/>
					<xsl:apply-templates/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- nagłówek listy przed głównym elementem listy
		 kolejny zabieg z intentionally pozwala uniknąć operatora exerpt z XPATH 2.0 -->
	<xsl:template match="hl7:list/hl7:caption">
		<xsl:param name="intentionally" select="false()"/>
		
		<xsl:if test="$intentionally">
			<xsl:element name="span">
				<xsl:attribute name="class">list_caption caption</xsl:attribute>
				<xsl:apply-templates select="@styleCode"/>
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="hl7:list/hl7:item">
		<xsl:element name="li">
			<xsl:apply-templates select="@styleCode"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- nagłówek elementu listy -->
	<xsl:template match="hl7:list/hl7:item/hl7:caption">
		<xsl:element name="span">
			<xsl:attribute name="class">list_caption caption</xsl:attribute>
			<xsl:apply-templates select="@styleCode"/>
			<xsl:apply-templates/>
		</xsl:element>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<!-- zmiana nazwy bez przepisywania ze względów bezpieczeństwa, wyłącznie dla znanych wartości, 
		w tym poza stylami HL7 CDA dodano dopuszczalne przez ten standard polskie rozszerzenia dot. kolorów czcionek
		(zastosowano style, gdyż jest silniejsze niż przypisany class) -->
	<xsl:template match="@styleCode">
		<xsl:if test="string-length(.) &gt;= 1">
			<xsl:attribute name="style">
				<xsl:if test="contains(., 'Italics')"> font-style: italic;</xsl:if>
				<xsl:if test="contains(., 'Bold')"> font-weight: bold;</xsl:if>
				<xsl:if test="contains(., 'Underline')"> text-decoration: underline;</xsl:if>
				<xsl:if test="contains(., 'Emphasis')"> font-style: bold;</xsl:if>
				<xsl:if test="contains(., 'xPLred')"> color: red;</xsl:if>
				<xsl:if test="contains(., 'xPLgreen')"> color: green;</xsl:if>
				<xsl:if test="contains(., 'xPLblue')"> color: blue;</xsl:if>
				<xsl:if test="contains(., 'xPLlime')"> color: lime;</xsl:if>
				<xsl:if test="contains(., 'xPLolive')"> color: olive;</xsl:if>
				<xsl:if test="contains(., 'xPLorange')"> color: orange;</xsl:if>
				<xsl:if test="contains(., 'xPLnavy')"> color: navy;</xsl:if>
				<xsl:if test="contains(., 'xPLviolet')"> color: violet;</xsl:if>
				<xsl:if test="contains(., 'xPLpurple')"> color: purple;</xsl:if>
				<xsl:if test="contains(., 'xPLsilver')"> color: silver;</xsl:if>
				<xsl:if test="contains(., 'xPLgray')"> color: gray;</xsl:if>
				<xsl:if test="contains(., 'xPLbig')"> font-size: 1.2em;</xsl:if>
				<xsl:if test="contains(., 'xPLsmall')"> font-size: 0.8em;</xsl:if>
				<xsl:if test="contains(., 'xPLxsmall')"> font-size: 0.6em;</xsl:if>
				<xsl:if test="contains(., 'xPLtextLine')"> display: block; margin-bottom: 7px;</xsl:if>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>
	
	<!--  Tabele  -->
	
	<!-- tabele są identyczne jak w HTML (poza atrybutem styleCode), są więc kopiowane bez zmian
		 XSD dopuszcza wiele atrybutów nieobsługiwanych w HTML5, ale dopuszczalnych tutaj. -->
	<xsl:template match="hl7:table | hl7:col | hl7:colgroup | hl7:tbody | hl7:td | hl7:tfoot | hl7:th | hl7:thead | hl7:tr">
		<xsl:element name="{local-name()}">
		
		<xsl:call-template name="copyTableAttributes">
			<xsl:with-param name="tagName" select="local-name()"/>
			<xsl:with-param name="attributes" select="./@*"/>
		</xsl:call-template>
		<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<!-- pełna kontrola nad tym co jest kopiowane -->
	<xsl:template name="copyTableAttributes">
		<xsl:param name="tagName"/>
		<xsl:param name="attributes"/>
		
		<xsl:variable name="tagNameUppercase" select="translate($tagName, $LOWERCASE_LETTERS, $UPPERCASE_LETTERS)"/>
		
		<xsl:for-each select="$attributes">
			<!-- Znaki dopuszczalne w atrybutach tabel, obsługa w XPATH 1.0, tj. bez wyrażeń regularnych -->
			<xsl:if test="string-length(translate(., 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ,.-_!', '')) = 0">
				<xsl:choose>
					<xsl:when test="local-name(.) = 'styleCode'">
						<xsl:if test="string-length(.) &gt;= 1">
							<xsl:attribute name="style">
								<xsl:if test="contains(., 'Italics')"> font-style: italic;</xsl:if>
								<xsl:if test="contains(., 'Bold')"> font-weight: bold;</xsl:if>
								<xsl:if test="contains(., 'Underline')"> text-decoration: underline;</xsl:if>
								<xsl:if test="contains(., 'Emphasis')"> font-style: bold;</xsl:if>
								<xsl:if test="contains(., 'Botrule')"> border-bottom: 1pt solid #dcdcdc;</xsl:if>
								<xsl:if test="contains(., 'Lrule')"> border-left: 1pt solid #dcdcdc;</xsl:if>
								<xsl:if test="contains(., 'Rrule')"> border-right: 1pt solid #dcdcdc;</xsl:if>
								<xsl:if test="contains(., 'Toprule')"> border-top: 1pt solid #dcdcdc;</xsl:if>
							</xsl:attribute>
						</xsl:if>
					</xsl:when>
					<!-- atrybuty pochodzące z HTML dopuszczalne w XSD Narrative Block dla elementów tabeli
		 				 wszystkie wartości tych atrybutów będą przepisywane bez zmian niniejszą transformatą z postaci "text/x-hl7-text+xml" do "text/html"
		 				 zapis celowo nieco nieoptymalny -->
					<xsl:when test="$tagNameUppercase = 'COL' and contains(';ID;language;span;width;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'COLGROUP' and contains(';ID;language;span;width;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'TABLE' and contains(';ID;language;summary;width;border;frame;rules;cellspacing;cellpadding;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'TBODY' and contains(';ID;language;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'TD' and contains(';ID;language;abbr;axis;headers;scope;rowspan;colspan;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'TFOOT' and contains(';ID;language;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'TH' and contains(';ID;language;abbr;axis;headers;scope;rowspan;colspan;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'THEAD' and contains(';ID;language;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
					<xsl:when test="$tagNameUppercase = 'TR' and contains(';ID;language;align;char;charoff;valign;', concat(';',local-name(.),';'))">
						<xsl:copy-of select="."/>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- nagłówek tabeli to standardowo i wyjątkowo element html caption -->
	<xsl:template match="hl7:table/hl7:caption">
		<xsl:element name="caption">
			<xsl:attribute name="class">table_caption caption</xsl:attribute>
			<xsl:apply-templates select="@styleCode"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- odnośnik -->
	<xsl:template match="hl7:linkHtml">
		<xsl:element name="a">
			<xsl:attribute name="href"><xsl:value-of select="./@href"/></xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- nagłówek multimediów -->
	<xsl:template match="hl7:renderMultiMedia/hl7:caption">
		<xsl:element name="span">
			<xsl:attribute name="class">list_caption caption</xsl:attribute>
			<xsl:apply-templates select="@styleCode"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- ten template może zostać rozszerzony do obsługi wszystkich typów zapisywanych w ED -->
	<xsl:template name="renderED">
		<xsl:param name="valueEDType"/>
		
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		<xsl:variable name="mediaType" select="$valueEDType/@mediaType"/>
		
		<xsl:variable name="alt">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Cannot display media content of type </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Twoje oprogramowanie nie potrafi wyświetlić multimediów typu </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$mediaType"/>
			<xsl:text>.</xsl:text>
		</xsl:variable>
		<xsl:variable name="altPDF">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Cannot display PDF media content.</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Twoje oprogramowanie nie potrafi wyświetlić multimediów typu PDF.</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="altOther">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Media content of type </xsl:text>
					<xsl:value-of select="$mediaType"/>
					<xsl:text> is not supported.</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Multimedialny format </xsl:text>
					<xsl:value-of select="$mediaType"/>
					<xsl:text> nie jest obsługiwany.</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="src">
			<xsl:choose>
				<xsl:when test="$valueEDType/hl7:reference/@value">
					<xsl:value-of select="$valueEDType/hl7:reference/@value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('data:', $mediaType, ';base64,', $valueEDType/text())"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$mediaType='image/gif' or $mediaType='image/jpeg' or $mediaType='image/jpg' or $mediaType='image/png' or $mediaType='image/tif' or $mediaType='image/tiff'">
				<xsl:element name="img">
					<xsl:attribute name="alt"><xsl:value-of select="$alt"/></xsl:attribute>
					<xsl:attribute name="src"><xsl:value-of select="$src"/></xsl:attribute>
				</xsl:element>
			</xsl:when>
			<xsl:when test="$mediaType='text/plain' or $mediaType='text/x-hl7-ft' or $mediaType='text/html'">
				<!-- nie spodziewamy się wartości tekstowych, umieszczane są w standardowy sposób bez ewentualnych tagów -->
				<xsl:value-of select="$src"/>
			</xsl:when>
			<xsl:when test="$mediaType='application/pdf'">
				<object class="multimedia_pdf" data="{$src}" type="application/pdf">
					<xsl:value-of select="$altPDF"/>
				</object>
			</xsl:when>
			<xsl:when test="$mediaType='audio/basic' or $mediaType='audio/mpeg' or $mediaType='application/ogg' or $mediaType='video/mpeg'">
				<div>
					<object width="300" data="{$src}" type="{$mediaType}">
						<embed src="{$src}" type="{$mediaType}" />
						<xsl:value-of select="$alt"/>
					</object>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$altOther"/>
			</xsl:otherwise>
		</xsl:choose>
		<!-- <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA
			AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO
			9TXL0Y4OHwAAAABJRU5ErkJggg==" alt="Red dot"/> - przykład
		</xsl:if> -->
	</xsl:template>
</xsl:stylesheet>