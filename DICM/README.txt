README
======

DICOMplist
==========

Representation of dicom objects based on objective-c property list objects dict, array, data and string:
-	using Apple’s plist format
-   dicom encapsulation (sequences, items) represented by keys designed as tag paths. This allows a flattened representation. 
-   conversion to explicit little endian syntax and DICM tag made of group+element+VR
-   conversion to UTF-8 or ISO-8859-1 of every string
-   no dependencies to libraries other than the foundation framework and iconv

Parser dp
=========
Uses DICOMplist representation, which allows to gather various datasets into a same result output

Accepts 3 syntaxes:

[1] inlined
cat in.dcm | ./dp > out.plist
1 dicom file in default input, one plist file in default output with binary data encoded base64


[2] inlined with bulkdata written to file
cat in.dcm | ./dp repository > out.plist

ibid 1, but with bulkdata and binary plist saved into separate files into the repository and xml plist with relative reference to the bulkdata streamed out

[3] batch
./dp repository dicomFile1 ... > out.plist

parsing of dicomFile1 to dicomFileN, with bulkdata and binary plist saved into repository, and compound xml plist with relative reference to the bulkdata streamed out


repositoryURI
=============
The repository is clasified by studies/%studyUID%/series/%seriesUID%/instances/%instanceUID%/frames/%frameNumber% 
Binary plist are saved in files named bin.plist in %instances%
Original dicom are saved in files named bin.dcm in %instances%
Bulkdatas are saved in files named UUID in %instances%
Fragments which are frames of the image are named according to the frame number and kept in %frameNumber%

On top level, a log named _date.log is created


hardcoded switches
==================
static BOOL debug = YES;
static BOOL charsetConversionDebug = YES;
static NSUInteger defaultEncodingIndex = 2;
static NSUInteger minBulkSize = 4096;


TODO
====
pn  plist(binary|xml)   -> nativeDicomXml
dn  dicom               -> nativeDicomXml
dj  dicom               -> json
pj  plist(binary|xml)   -> json


graph
=====

A dict containing an array called datasets is the root for multiple datasets containment.

Each dataset is made of a <dict> which lists pairs of tagPath + array for each of the attributes of a category
<array>	lists the values of an attribute. 
A monovalued attribute is a one-item array. 
An empty attribute is an empty array.

All the values of an array share one o two foundational datatypes:

<data>	contains data (UT, OB, OF, OW, UN)
<string> contains textual types, including dates and time (AE, AS, CS, DA, DS, DT, IS, TM, UI) +  AT + (LO, LT, PN, SH, ST)
<number> contains numerical types, including FL, FD, SL, SS, UL, US

<data> may be base64-encoded or saved apart and referred to by means of an URI

Look at DICOMplist.xsd for a more precise description of the structure.


Charsets
========

//unsuccessfull with Clunie's SCSH31, SCSH32, SCSHBRW,SCSI2,SCSX2

/*
iconv string encodings

[European languages]	ASCII, ISO−8859−{1,2,3,4,5,7,9,10,13,14,15,16}, KOI8−R, KOI8−U, KOI8−RU, CP{1250,1251,1252,1253,1254,1257}, CP{850,866,1131}, Mac{Roman,CentralEurope,Iceland,Croatian,Romania}, Mac{Cyrillic,Ukraine,Greek,Turkish}, Macintosh
[Semitic languages]	ISO−8859−{6,8}, CP{1255,1256}, CP862, Mac{Hebrew,Arabic}
[Japanese]				EUC−JP, SHIFT_JIS, CP932, ISO−2022−JP, ISO−2022−JP−2, ISO−2022−JP−1
[Chinese]				EUC−CN, HZ, GBK, CP936, GB18030, EUC−TW, BIG5, CP950, BIG5−HKSCS, BIG5−HKSCS:2001, BIG5−HKSCS:1999, ISO−2022−CN, ISO−2022−CN−EXT
[Korean]				EUC−KR, CP949, ISO−2022−KR, JOHAB
[Armenian]				ARMSCII−8
[Georgian]				Georgian−Academy, Georgian−PS
[Tajik]				KOI8−T
[Kazakh]				PT154, RK1048
[Thai]					TIS−620, CP874, MacThai
[Laotian]				MuleLao−1, CP1133
[Vietnamese]			VISCII, TCVN, CP1258
[Platform specifics]	HP−ROMAN8, NEXTSTEP
[Full Unicode]			UTF−8
UCS−2, UCS−2BE, UCS−2LE
UCS−4, UCS−4BE, UCS−4LE
UTF−16, UTF−16BE, UTF−16LE
UTF−32, UTF−32BE, UTF−32LE
UTF−7
C99, JAVA

[Full Unicode, in terms of uint16_t or uint32_t (with machine dependent endianness and alignment)] UCS−2−INTERNAL, UCS−4−INTERNAL
[Locale dependent, in terms of char or wchar_t (with machine dependent endianness and alignment, and with semantics depending on the OS and the current LC_CTYPE locale facet)] char, wchar_t

//When configured with the option −−enable−extra−encodings, it also provides support for a few extra encodings:

[European languages]	CP{437,737,775,852,853,855,857,858,860,861,863,865,869,1125}
[Semitic languages]	CP864
[Japanese]				EUC−JISX0213, Shift_JISX0213, ISO−2022−JP−3
[Chinese]				BIG5−2003 (experimental)
[Turkmen]				TDS565
[Platform specifics]	ATARIST, RISCOS−LATIN1

The empty encoding name "" is equivalent to "char": it denotes the locale dependent character encoding.
*/


/*
appple string encodings

00000001 = "Japanese (Shift JIS X0213)";
00000002 = "Non-lossy ASCII";
00000003 = "Simplified Chinese (GB 2312)";
00000004 = "Unicode (UTF-32)";
00000005 = "Central European (ISO Latin 2)";
00000006 = "Dingbats (Mac OS)";
00000007 = "Western (EBCDIC Latin Core)";
00000008 = "Simplified Chinese (Windows, DOS)";
00000009 = "Western (ISO Latin 3)";
00000010 = "Unicode (UTF-7)";
00000011 = "Greek (Windows)";
00000012 = "Central European (Windows Latin 2)";
00000013 = "Turkish (Windows Latin 5)";
00000014 = "Hebrew (Windows)";
00000015 = "Cyrillic (Windows)";
00000021 = "Japanese (ISO 2022-JP-2)";
00000030 = "Japanese (Mac OS)";
2147483649 = "Traditional Chinese (Mac OS)";
2147483650 = "Korean (Mac OS)";
2147483651 = "Arabic (Mac OS)";
2147483652 = "Hebrew (Mac OS)";
2147483653 = "Greek (Mac OS)";
2147483654 = "Cyrillic (Mac OS)";
2147483655 = "Devanagari (Mac OS)";
2147483657 = "Gurmukhi (Mac OS)";
2147483658 = "Gujarati (Mac OS)";
2147483659 = "Thai (Mac OS)";
2147483669 = "Simplified Chinese (Mac OS)";
2147483673 = "Tibetan (Mac OS)";
2147483674 = "Central European (Mac OS)";
2147483677 = "Symbol (Mac OS)";
2147483682 = "Turkish (Mac OS)";
2147483683 = "Croatian (Mac OS)";
2147483684 = "Icelandic (Mac OS)";
2147483685 = "Romanian (Mac OS)";
2147483686 = "Celtic (Mac OS)";
2147483687 = "Gaelic (Mac OS)";
2147483688 = "Keyboard Symbols (Mac OS)";
2147483689 = "Farsi (Mac OS)";
2147483788 = "Cyrillic (Mac OS Ukrainian)";
2147483800 = "Inuit (Mac OS)";
2147483884 = "Unicode (UTF-16)";
2147484163 = "Central European (ISO Latin 4)";
2147484164 = "Cyrillic (ISO 8859-5)";
2147484165 = "Arabic (ISO 8859-6)";
2147484166 = "Greek (ISO 8859-7)";
2147484167 = "Hebrew (ISO 8859-8)";
2147484168 = "Turkish (ISO Latin 5)";
2147484169 = "Nordic (ISO Latin 6)";
2147484170 = "Thai (ISO 8859-11)";
2147484171 = "Baltic (ISO Latin 7)";
2147484173 = "Celtic (ISO Latin 8)";
2147484174 = "Western (ISO Latin 9)";
2147484175 = "Romanian (ISO Latin 10)";
2147484176 = "Latin-US (DOS)";
2147484672 = "Greek (DOS)";
2147484677 = "Baltic (DOS)";
2147484678 = "Western (DOS Latin 1)";
2147484688 = "Greek (DOS Greek 1)";
2147484689 = "Central European (DOS Latin 2)";
2147484690 = "Cyrillic (DOS)";
2147484691 = "Turkish (DOS)";
2147484692 = "Portuguese (DOS)";
2147484693 = "Icelandic (DOS)";
2147484694 = "Hebrew (DOS)";
2147484695 = "Canadian French (DOS)";
2147484696 = "Arabic (DOS)";
2147484697 = "Nordic (DOS)";
2147484698 = "Russian (DOS)";
2147484699 = "Greek (DOS Greek 2)";
2147484700 = "Thai (Windows, DOS)";
2147484701 = "Japanese (Windows, DOS)";
2147484705 = "Korean (Windows, DOS)";
2147484706 = "Traditional Chinese (Windows, DOS)";
2147484707 = "Western (Windows Latin 1)";
2147484933 = "Arabic (Windows)";
2147484934 = "Baltic (Windows)";
2147484935 = "Vietnamese (Windows)";
2147484936 = "Western (ASCII)";
2147485224 = "Chinese (GBK)";
2147485233 = "Chinese (GB 18030)";
2147485234 = "Japanese (ISO 2022-JP)";
2147485729 = "Japanese (ISO 2022-JP-1)";
2147485730 = "Chinese (ISO 2022-CN)";
2147485744 = "Korean (ISO 2022-KR)";
2147485760 = "Japanese (EUC)";
2147486000 = "Traditional Chinese (EUC)";
2147486001 = "Korean (EUC)";
2147486016 = "Japanese (Shift JIS)";
2147486209 = "Cyrillic (KOI8-R)";
2147486210 = "Traditional Chinese (Big 5)";
2147486211 = "Western (Mac Mail)";
2147486212 = "Simplified Chinese (HZ GB 2312)";
2147486213 = "Traditional Chinese (Big 5 HKSCS)";
2147486214 = "Ukrainian (KOI8-U)";
2147486216 = "Traditional Chinese (Big 5-E)";
2147486217 = "Western (NextStep)";
2147486721 = "Western (EBCDIC Latin 1)";
2147486722 = "Western (ASCII)";
2214592768 = "Unicode (UTF-8)";
2348810496 = "Unicode (UTF-16BE)";
2415919360 = "Unicode (UTF-16LE)";
2483028224 = "Unicode (UTF-32BE)";
2550137088 = "Unicode (UTF-32LE)";
2617245952 = "Western (ISO Latin 1)";	 
*/

