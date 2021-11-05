# POSTCSTORE



versionado

| versión    | autor           | comentario                                                   |
| ---------- | --------------- | ------------------------------------------------------------ |
| 2021-11-02 | Jacques Fauquex | versión inicial                                              |
| 2021-11-02 | Jacques Fauquex | aetLocal en la ruta del servicio. <br />compuesto de los parámetros del pacs de destino |
| 2021-11-03 | Jacques Fauquex | header application/dicom+xml en caso 1                       |
| 2021-11-03 | Jacques Fauquex | aet autorizado                                               |
| 2021-11-04 | Jacques Fauquex | dirPath, scu/scp in path                                     |
|            |                 |                                                              |



## Servicio REST POSTCSTORE

demonio que escucha un puerto http para recibir Archivos DICOM  por protocolo HTTP POST DICOM STORE y los manda a un pacs DIMSE por protocolo C-STORE mediante la libraría dcmtk.

Los parametros de ejecución son:

- httpPort
- dirPath (for files received)
- destHost
- destPort
- aet autorizado
- ...





### HTTP POST

```
POST scu/scp/studies
```

(no implementamos POST service/studies/{studyIUID} en esta ocasión)

scu y scp son los aets usados para mandar los archivos al pacs por c-store.

### Content-Type

- multipart/related;type=application/dicom;boundary=myBoundary
- multipart/related;type=application/dicom+xml;boundary=myBoundary
- application/dicom+json
- application/dicom+json+dckv
- application/dicom+json+edckv



### (Content-Length: uint | Content-Encoding: encoding)

puede estar presente uno u otro de estos headers, pero no los dos en un mismo request.

Content-Length sirve par un body que no sea multipart.

Content-Encoding (por ejemplo: Content-Encoding: gzip) puede aplicarse a body multipart o no.



### Accept

Reservamos el uso de accept para definir en próximas etapas opciones de body de respuestas.



## query parameters

ninguno



## payload

el o los recursos enviados en el  body del POST



## Response

En la primera iteración devolverá exclusivamente un status

| code                      | descripción                                                  |
| ------------------------- | ------------------------------------------------------------ |
| 200(OK)                   | The origin server successfully stored all Instances.         |
| 202(Accepted)             | The origin server stored some of the Instances but warnings or failures exist for others. Additional information regarding this error may be found in the response message body. |
| 204(NoContent)            | There were no adequate resources in the body                 |
| 206(PartialContent)       | Some of the resources have been sent but not all             |
| 400(BadRequest)           | The origin server was unable to store any instances due to bad syntax. |
| 409(Conflict)             | The request was formed correctly but the origin server was unable to store any instances due to a conflict in the request (e.g., unsupported SOP Class or Study Instance UID mismatch). This may also be used to indicate that the origin server was unable to store any instances for a mixture of reasons. |
| 415(UnsupportedMediaType) | The origin server does not support the media type specified in the Content-Type header field of the request |



# Casos de uso

Inicialmente implementamos los casos "dicom" multiples archivos  y "dicom+xml" dicom metadata y xml encapsulado de un  solo archivo.

En otras iteraciones, implementaremos application/dicom+json, y los media-types propietarios application/dicom+dckv y application/dicom+edckv

## caso 1: multiples dicom 

archivos dicom binario

header

```
Content-Type: multipart/related;type=application/dicom; boundary=myBoundary
```

body (repetible)

```xml
\r\n--myBoundary--\r\n
Content-Type: application/dicom\r\n\r\n
<DICM>
```

tail

```
\r\n--myBoundary--\r\n
```



## caso 2: one dicom+xml and encapsulated xml

metadata DICOM en xml <NativeDicomModel>

que contiene

<DicomAttribute keyword="EncapsulatedDocument" tag="00420011" vr="OB"><BulkData uri="bulk"/></DicomAttribute>

Observar el uri "bulk" que se refiere al Content-Location que sigue en el POST



header

```
Content-Type: multipart/related; type=application/dicom+xml; boundary=myBoundary
```

body (repetible)

```xml
\r\n--myBoundary--\r\n
Content-Type: application/dicom+xml\r\n\r\n
transfer-syntax=1.2.840.10008.1.2.1\r\n\r\n
<NativeDicomModel>
\r\n\r\n--myboundary
\r\nContent-Type: text/XML
\r\nContent-Location: bulk
\r\n\r\n
<xml>
```

tail

```
\r\n--myBoundary--\r\n
```

# Ejemplo python de cliente dicom+xml

Este ejemplo se encuentra en html5cda. Crea la metadata dicom en formato dicom+xml <NativeDicomModel> para el documento encapsulado <ClinicalDocument>. Finalmente junta ambos en un request POST DICOM /studies

```python
    seriesuid = '2.25.{}'.format(int(str(uuid.uuid4()).replace('-', ''), 16))
    xml_dcm = '<?xml version="1.0" encoding="UTF-8"?>'
    xml_dcm += '<NativeDicomModel xml-space="preserved">'
    xml_dcm += '<DicomAttribute keyword="FileMetaInformationVersion" tag="00020001" vr="OB"><InlineBinary>AAE=</InlineBinary></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="MediaStorageSOPClassUID" tag="00020002" vr="UI"><Value number="1">1.2.840.10008.5.1.4.1.1.104.2</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="MediaStorageSOPInstanceUID" tag="00020003" vr="UI"><Value number="1">{}</Value></DicomAttribute>'.format(
        informeuid)
    xml_dcm += '<DicomAttribute keyword="TransferSyntaxUID" tag="00020010" vr="UI"><Value number="1">1.2.840.10008.1.2</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="ImplementationClassUID" tag="00020012" vr="UI"><Value number="1">2.16.858.0.2.9.62.0.1.0.217215590012</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="ImplementationVersionName" tag="00020013" vr="SH"><Value number="1">JESROS OPENDICOM</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="SpecificCharacterSet" tag="00080005" vr="CS"><Value number="1">ISO_IR 100</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="SOPClassUID" tag="00080016" vr="UI"><Value number="1">1.2.840.10008.5.1.4.1.1.104.2</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="SOPInstanceUID" tag="00080018" vr="UI"><Value number="1">{}</Value></DicomAttribute>'.format(
        informeuid)
    xml_dcm += '<DicomAttribute keyword="TimezoneOffsetFromUTC" tag="00080201" vr="SH"><Value number="1">-0300</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="PatientName" tag="00100010" vr="PN"><PersonName number="1"><Alphabetic><FamilyName>{}</FamilyName></Alphabetic></PersonName></DicomAttribute>'.format(
        values_submit['PatientName'][0])
    xml_dcm += '<DicomAttribute keyword="PatientID" tag="00100020" vr="LO"><Value number="1">{}</Value></DicomAttribute>'.format(
        values_submit['PatientID'][0])
    xml_dcm += '<DicomAttribute keyword="IssuerOfPatientID" tag="00100021" vr="LO"><Value number="1">{}</Value></DicomAttribute>'.format(
        values_submit['PatientIDIssuer'][0])
    xml_dcm += '<DicomAttribute keyword="PatientBirthDate" tag="00100030" vr="DA"><Value number="1">{}</Value></DicomAttribute>'.format(
        values_submit['PatientBirthDate'][0])
    xml_dcm += '<DicomAttribute keyword="PatientSex" tag="00100040" vr="CS"><Value number="1">{}</Value></DicomAttribute>'.format(
        values_submit['PatientSex'][0])
    xml_dcm += '<DicomAttribute keyword="StudyInstanceUID" tag="0020000D" vr="UI"><Value number="1">{}</Value></DicomAttribute>'.format(
        values_submit['StudyIUID'][0])
    xml_dcm += '<DicomAttribute keyword="Modality" tag="00080060" vr="CS"><Value number="1">DOC</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="SeriesInstanceUID" tag="0020000E" vr="UI"><Value number="1">{}</Value></DicomAttribute>'.format(
        seriesuid)
    xml_dcm += '<DicomAttribute keyword="SeriesNumber" tag="00200011" vr="IS"><Value number="1">-16</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="SeriesDescription" tag="0008103E" vr="LO"><Value number="1">ClinicalDocument</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="SeriesDate" tag="00080021" vr="DA"><Value number="1">{}</Value></DicomAttribute>'.format(
        datetime.now().strftime("%Y%m%d"))
    xml_dcm += '<DicomAttribute keyword="SeriesTime" tag="00080031" vr="TM"><Value number="1">{}</Value></DicomAttribute>'.format(
        datetime.now().strftime("%H%M%S"))
    xml_dcm += '<DicomAttribute keyword="PerformedProcedureStepStartDate" tag="00400244" vr="DA"><Value number="1">{}</Value></DicomAttribute>'.format(
        datetime.now().strftime("%Y%m%d"))
    xml_dcm += '<DicomAttribute keyword="PerformedProcedureStepStartTime" tag="00400245" vr="TM"><Value number="1">{}</Value></DicomAttribute>'.format(
        datetime.now().strftime("%H%M%S"))
    xml_dcm += '<DicomAttribute keyword="Manufacturer" tag="00080070" vr="LO"><Value number="1">opendicom (Jesros SA)</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="InstitutionAddress" tag="00080081" vr="ST"><Value number="1">Agesic, Torre Ejecutiva Torre Sur, Liniers 1324, Montevideo, Uruguay</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="SoftwareVersions" tag="00181020" vr="LO"><Value number="1">2.0</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="ConversionType" tag="00080064" vr="CS"><Value number="1">WSD</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="InstanceNumber" tag="00200013" vr="IS"><Value number="1">1</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="ContentDate" tag="00080023" vr="DA"><Value number="1">{}</Value></DicomAttribute>'.format(
        datetime.now().strftime("%Y%m%d"))
    xml_dcm += '<DicomAttribute keyword="ContentTime" tag="00080033" vr="TM"><Value number="1">{}</Value></DicomAttribute>'.format(
        datetime.now().strftime("%H%M%S"))
    xml_dcm += '<DicomAttribute keyword="AcquisitionDateTime" tag="0008002A" vr="DT"><Value number="1">{}{}</Value></DicomAttribute>'.format(
        datetime.now().strftime("%Y%m%d"), datetime.now().strftime("%H%M%S"))
    xml_dcm += '<DicomAttribute keyword="BurnedInAnnotation" tag="00280301" vr="CS"><Value number="1">YES</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="DocumentTitle" tag="00420010" vr="ST"><Value number="1">INFORME IMAGENOLOGICO</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="HL7InstanceIdentifier" tag="0040E001" vr="ST"><Value number="1">{}</Value></DicomAttribute>'.format(
        autenticado.id)
    xml_dcm += '<DicomAttribute keyword="MIMETypeOfEncapsulatedDocument" tag="00420012" vr="LO"><Value number="1">text/xml</Value></DicomAttribute>'
    xml_dcm += '<DicomAttribute keyword="EncapsulatedDocument" tag="00420011" vr="OB"><BulkData uri="bulk"/></DicomAttribute>'
    xml_dcm += '</NativeDicomModel>'

 
url = settings.OID_URL[institution.oid]['stow']
    headers = {'Content-Type': 'multipart/related; type=application/dicom+xml; boundary=myboundary'}
    data = '\r\n--myboundary\r\nContent-Type: application/dicom+xml; transfer-syntax=1.2.840.10008.1.2.1\r\n\r\n{}\r\n\r\n--myboundary\r\nContent-Type: text/XML\r\nContent-Location: bulk\r\n\r\n{}\r\n--myboundary--'.format(
        xml_dcm, xml_cda)
    requests.post(url, headers=headers, data=data.encode('utf-8'))
```

