Profile: DiagnosticReportTEST
Parent: DiagnosticReport
Id: diagnosticreportTEST

* status = #final

{% if isR4 %}
* imagingStudy 1..1 MS
{% endif %}

{{R5}}* study 1..1 MS

