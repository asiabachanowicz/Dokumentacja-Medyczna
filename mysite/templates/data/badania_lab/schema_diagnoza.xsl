<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:extPL="http://www.csioz.gov.pl/xsd/extPL/r2" version="1.0">

	<xsl:output method="html" version="4.01" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01//EN" media-type="text/html" doctype-system="about:legacy-compat"/>
	
	<xsl:variable name="LOWERCASE_LETTERS">aąbcćdeęfghijklłmnńoópqrsśtuvwxyzżź</xsl:variable>
	<xsl:variable name="UPPERCASE_LETTERS">AĄBCĆDEĘFGHIJKLŁMNŃOÓPQRSŚTUVWXYZŻŹ</xsl:variable>
	<!-- dokumenty medyczne posiadają etykiety w języku polskim za wyjątkiem części lub całych dokumentów, dla których wskazano język angielski kodem en-US -->
	<xsl:variable name="secondLanguage">en-US</xsl:variable>
	
	<xsl:template match="/">
		<xsl:apply-templates select="hl7:Document"/>
	</xsl:template>
	
	<!-- dokument medyczny-->
	<xsl:template match="hl7:Document">
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
				<div class="imageDiv">
					<p>Diagnoza</p>
					<p id="description">Tutaj opis diagnozy</p>
				</div>
				
			</body>
		</html>
	</xsl:template>
	
	<!-- nagłówek -->
	<xsl:template name="header">
		<xsl:call-template name="title"/>
		<xsl:call-template name="headerElements"/>
		<div class="doc_header">
			<div class="doc_header_2">
				<div class="patient_related_header">					
					<xsl:call-template name="recordTarget"/>
					<xsl:call-template name="componentOf"/>
				</div>
				<div class="document_related_header">
					<xsl:call-template name="legalAuthenticator"/>
					<xsl:call-template name="author"/>
					<xsl:call-template name="authenticator"/>
					<xsl:call-template name="dataEnterer"/>
					
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
	
	<!-- Osoba autoryzująca dokument legalAuthenticator: templateId 2.16.840.1.113883.3.4424.13.10.2.6 oraz 2.16.840.1.113883.3.4424.13.10.2.63 -->
	<xsl:template name="legalAuthenticator">
		
		<xsl:variable name="legalAuthenticator" select="hl7:legalAuthenticator"/>
		<!-- jeżeli dane wystawcy dokumentu zawarte są w jednym z elementów author, to wskazanie który z autorów jest wystawcą realizuje się poprzez umieszczenie co najmniej identyfikatora tego autora w elemencie legalAuthenticator -->
		<xsl:variable name="legalAuthor" select="/hl7:Document/hl7:author[hl7:assignedAuthor/hl7:id[@root=$legalAuthenticator/hl7:assignedEntity/hl7:id/@root and @extension=$legalAuthenticator/hl7:assignedEntity/hl7:id/@extension]]"/>
		<!-- w PIK 1.3.1(.2) dodano obsługę danych asystenta medycznego 2.16.840.1.113883.3.4424.13.10.2.90, proponując, by jeżeli id jedno i to samo, wyświetlać dane dataEnterera w tym miejscu. Jednak w takiej sytuacji legalAuthenticator również powinien zawierać wszystkie informacje o wystawcy, pomijane w wyświetlaniu -->
		<xsl:variable name="legalEnterer" select="/hl7:Document/hl7:dataEnterer[hl7:assignedEntity/hl7:id[@root=$legalAuthenticator/hl7:assignedEntity/hl7:id/@root and @extension=$legalAuthenticator/hl7:assignedEntity/hl7:id/@extension]]"/>
		<xsl:variable name="lang" select="(ancestor-or-self::*/hl7:languageCode/@code)[position()=last()]"/>
		
		<xsl:variable name="legalAuthenticatorLabel">
			<xsl:choose>
				<xsl:when test="$lang = $secondLanguage">
					<xsl:text>Legal authenticator</xsl:text>
				</xsl:when>
				<xsl:when test="/hl7:Document/hl7:dataEnterer/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.90' and $legalEnterer">
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
			<xsl:when test="/hl7:Document/hl7:dataEnterer/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.90' and $legalEnterer">
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
					
					
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- płatnik templateId 2.16.840.1.113883.3.4424.13.10.2.19 -->
	
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
		<xsl:variable name="author" select="/hl7:Document/hl7:author[not(hl7:assignedAuthor/hl7:id[@root=/hl7:Document/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@root and @extension=/hl7:Document/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@extension])]"/>
		<xsl:variable name="allAuthors" select="/hl7:Document/hl7:author"/>
		<xsl:variable name="assistant" select="/hl7:Document/hl7:dataEnterer/hl7:templateId/@root = '2.16.840.1.113883.3.4424.13.10.2.90' and 
										/hl7:Document/hl7:dataEnterer/hl7:assignedEntity/hl7:id/@extension = /hl7:Document/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@extension and 
										/hl7:Document/hl7:dataEnterer/hl7:assignedEntity/hl7:id/@root = /hl7:Document/hl7:legalAuthenticator/hl7:assignedEntity/hl7:id/@root"/>
		
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

	
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++ POMOCNICZE +++++++++++++++++++++++++++++++++++++++++++++++++++++-->
	<!-- pierwiastek kwadratowy na potrzeby SVG (Sean B. Durkin) -->
	
	
	
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

#imageOfExamination{
	display: block;
	margin-left: auto;
	margin-right: auto;
	width: 50%;
}

.imageDiv{
	font-size: 1.1em;
    font-weight: bold;
	font-family: "Noto sans", sans-serif;


}

#description{
	font-family: "Noto sans", sans-serif;
    font-size: 10pt;
	font-weight: normal;
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
		
		<xsl:apply-templates/>
		</xsl:element>
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
	
</xsl:stylesheet>