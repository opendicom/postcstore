#  case2: dicom+xml más bulk dicom 


requires /usr/local/bin/storescu

dicom.mime contains of case1 folder contains the body of the test request. It is made of two CT files

the curl command calls postcstore at http://localhost:12345 and is expecting that a pacs with IP.port defined in args of the command answers to a call from aet STORESCU directed to aet DCM4CHEE

```
cd case2
curl -X POST -H "Content-Type: multipart/related; type=\"application/dicom+xml\"; boundary=myboundary" http://localhost:12345/STORESCU/DCM4CHEE/studies --data-binary @1enclosedXml.multipart
```

Note:

In the args of postcstore, there is the path of a working directory. New dicom files are written with suffix .dcm. When there were sent successfully a suffix .done is added. In case of failure, a suffix .bad is added.

postcstore should be compelemented by a process repeated for instance each hour, which removes files with suffix .done and move files with suffix .bad to a permanent auditable folder.
