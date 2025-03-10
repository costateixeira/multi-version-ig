Profile: ImBodyStructure
Parent: http://hl7.eu/fhir/base/StructureDefinition/BodyStructure-eu
Id: im-body-structure
* insert SetFmmAndStatusRule( 1, draft )
* insert MandateLanguageAndSecurity
* morphology 1..1 MS
* active MS
{% if isR5 %}
* includedStructure MS
  * structure MS
  * laterality MS
* excludedStructure MS
{% endif %}

{{R4}}* location MS
{{R4}}* locationQualifier MS
