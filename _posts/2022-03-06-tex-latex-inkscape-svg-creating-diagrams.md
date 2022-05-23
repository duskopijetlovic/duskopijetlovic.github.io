---
layout: post
title: "Writing Documentation and Creating Diagrams with LuaLaTeX and Inkscape"
date: 2022-03-05 10:12:41 -0700 
categories: howto diagram graph graphviz plaintext text tex latex visualization documentation
---

OS: FreeBSD 13   
Shell:  csh  
Ghostscript version:  GPL Ghostscript 9.52 (2020-03-19)    
Inkscape version: 1.1   
xv version: 3.10a  
zathura version: 0.4.5 (girara 0.3.6, runtime: 0.3.6)  
zathura plugin versions: cb (0.1.8), ps (0.2.6), djvu (0.2.9), pdf-poppler (0.3.0), pdf-mupdf (0.3.5)  

---

**Assumption**: previously installed Ghostscript, Inkscape, ImageMagick, xv, zathura.   

---


```
% sudo pkg install inkscape
```

```
% inkscape --version
Inkscape 1.1 (c68e22c387, 2021-05-23)
```

```
% ls -lh datacentrelayout.svg
-rw-r--r--  1 dusko  dusko   356K Apr  1  2021 datacentrelayout.svg
```

```
% file datacentrelayout.svg
datacentrelayout.svg: SVG Scalable Vector Graphics image
```

```
% wc -l datacentrelayout.svg
    7970 datacentrelayout.svg
```


```
% head datacentrelayout.svg
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
```


```
% inkscape datacentrelayout.svg
```

In **Inkscape**:

```
Edit 

Save As > Inkscape SVG (*.svg)  
Save As > Plain SVG (*.svg)  
Save As > Encapsulated PostScript (*.eps)
```


## Generate an SVG or a PNG with Graphviz from Kroki-CLI

```
% cat hello.dot
digraph G {
  Hello->World
}
```

```
% ./kroki convert hello.dot --type dot 
```

```
% file hello.svg
hello.svg: SVG Scalable Vector Graphics image
```

```
% inkscape hello.svg
```


```
% ./kroki convert hello.dot --type dot --format png
```

```
% xv hello.png
```

## Convert an SVG Image (SVG File) to PS or EPS


```
% rsvg-convert --format ps hello.svg > hello.ps
% zathura --fork hello.ps
```

```
% rsvg-convert --format eps hello.svg > hello.eps
% zathura --fork hello.eps
```


### Convert PNG to SVG 

#### Convert PNG to PNM First 


```
% anytopnm server_blades.png > server_blades.pnm
```

#### Convert PNM to SVG

```
% pamtosvg server_blades.pnm > server_blades.svg
```


## Getting Information About Images

**NOTE:**  
PDF (and PostScript) **units** are 1/72 inch so 72 = 1 inch, 144 = 2 inches. 
You need to shift the origin of the page down and left, which is why the 
values for PageOffset are negative.

```
DOWN  = -
LEFT  = -
UP    = +
RIGHT = +
```

**References:**   
[Ghostscript : Crop Certain Area?](https://stackoverflow.com/questions/59101374/ghostscript-crop-certain-area)    


#### Using -dSAFER -dBATCH -dNOPAUSE Trio in Ghostscript

It is conventional to call Ghostscript with the '-dSAFER -dBATCH -dNOPAUSE' 
trio of options when rasterizing to a file.  These suppress interactive 
prompts and enable some security checks on the file to be run. 
Please see the [Use documentation](https://ghostscript.com/doc/current/Use.htm) 
for a complete description.

Explanation:

```
The -c parameter allows you to add PostScript code snippets which 
will be executed when Ghostscript processes the input file.  
```

```
% gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=bbox firewall.eps
%%BoundingBox: 368 291 383 325
%%HiResBoundingBox: 368.564333 291.923991 382.598426 324.089990
```

You can use the [**-q**](https://ghostscript.com/doc/current/Use.htm#Quiet)
switch to prevent Ghostscript from writing messages 
to standard output which become mixed with the intended output stream.

Also, the **-o** option determines output path+filename (and saves usage 
of -dBATCH -dNOPAUSE).   

```
% gs -q -o -dSAFER -sDEVICE=bbox firewall.eps
%%BoundingBox: 368 291 383 325
%%HiResBoundingBox: 368.564333 291.923991 382.598426 324.089990
```


#### Getting Image Information with ImageMagick's identify

```
% identify firewall.eps
firewall.eps[0] EPT 15x33 15x33+0+0 16-bit ColorSeparation CMYK 2079B 0.000u 0:00.001
firewall.eps[1] TIFF 15x34 15x34+0+0 8-bit sRGB 256c 2200B 0.000u 0:00.001
identify: Invalid TIFF directory; tags are not sorted in ascending order. 
  `TIFFReadDirectoryCheckOrder' @ warning/tiff.c/TIFFWarnings/959.
```

NOTE that identify(1) reports the relative dimensions - as opposed to 
Ghostscript, which reports the image size with dimensions within the page. 

```
Width  = 383 - 368 = 15  
Height = 325 - 291 = 34
```


NOTE BoundingBox:  

```
% head firewall.eps
����,>J>��%!PS-Adobe-3.0 EPSF-3.0
%%Creator: Adobe Illustrator(R) 8.0
%%AI8_CreatorVersion: 8.0.1
%%For: (Gary V Stewart) (Cisco Systems Inc)
%%Title: (Firewall.eps)
%%CreationDate: (7/11/2000) (10:17 AM)
%%BoundingBox: 367 291 384 325
%%HiResBoundingBox: 367.998 291.4106 383.1011 324.5298
%%DocumentProcessColors: Black
%%DocumentSuppliedResources: procset Adobe_level2_AI5 1.2 0
```

```
% grep Box firewall.eps
Binary file firewall.eps matches
 
% wc -l firewall.eps
    3788 firewall.eps
 
% strings firewall.eps | wc -l
    3229
```

```
% strings firewall.eps | grep Box
%%BoundingBox: 367 291 384 325
%%HiResBoundingBox: 367.998 291.4106 383.1011 324.5298
%AI3_TemplateBox: 306 396 306 396
%AI3_TileBox: 0 0 592 744
```


You can extract (crop) the image from the page: 

```
% gs \
 -q \
 -o cropped.eps \
 -dEPSCrop \
 -sDEVICE=eps2write \
 -f firewall.eps
```

and then Ghostscript reports the relative image size: 

```
% gs -q -o -dSAFER -sDEVICE=bbox cropped.eps
%%BoundingBox: 0 0 15 33
%%HiResBoundingBox: 0.558000 0.522000 14.600390 32.669999
```


If you want an EPS (PDF) viewer to display the cropped image in actual size: 

```
% gs \
 -q \
 -o scaled.eps \
 -dEPSCrop \
 -sDEVICE=eps2write \
 -c "<</Install {1 1 scale}>> setpagedevice" \
 -f firewall.eps 
```


#### Getting BoundingBox Information with Ghostscript 

```
% gs -q -o -dSAFER -sDEVICE=bbox scaled.eps 
%%BoundingBox: 0 0 15 33
%%HiResBoundingBox: 0.558000 0.522000 14.600390 32.669999
```

NOTE that you often can get the BoundingBox information with ImageMagick's identify:   

```
% identify scaled.eps
scaled.eps EPS 15x33 15x33+0+0 16-bit sRGB 3288B 0.000u 0:00.000
```


```
% grep Box scaled.eps 
%%BoundingBox: 0 0 15 33
%%HiResBoundingBox: 0.00 0.00 15.00 33.00
/MediaBox get aload pop
/FontBBox 1 index/FontBBox get def
dup/BBox get aload pop exch 3 index sub exch 2 index sub rectclip
<</Type/Page/MediaBox [0 0 15.1 33.12]
```


**References:**

* [How to resize an .eps file using ghostscript](https://stackoverflow.com/questions/39652178/how-to-resize-an-eps-file-using-ghostscript)   


## Resizing Images with Ghostscript (gs)

**NOTE:**   
From Rescaling postscript figures  
[http://www.verycomputer.com/18_696ed9f0514c5233_1.htm#p7](http://www.verycomputer.com/18_696ed9f0514c5233_1.htm#p7)   
(Retrieved on Mar 5, 2022)    

> Sorry to be so negative but I waste a lot of time having
> to deal with seriously broken PS figures. Most of these
> are the direct result of people thinking it is a good
> idea to rotate or rescale their figures using ImageMagick,
> xv, gimp, or some other program that works internally with
> raster images. Please don't do it!  

```
% ls -lh ~/Downloads/images/Cisco-Icons/forunzip/firewall.eps 
-rw-r--r--  1 dusko  dusko    82K Jul 11  2000 /home/dusko/Downloads/images/Cisco-Icons/forunzip/firewall.eps
```

```
% cp -i ~/Downloads/images/Cisco-Icons/forunzip/firewall.eps /tmp/
```

```
% cd /tmp
```


With **Ghostscript**:  

```
% gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=bbox firewall.eps
%%BoundingBox: 368 291 383 325
%%HiResBoundingBox: 368.564333 291.923991 382.598426 324.089990
```


With **ImageMagick**:  

```
% identify firewall.eps
firewall.eps[0] EPT 15x33 15x33+0+0 16-bit ColorSeparation CMYK 2079B 0.000u 0:00.001
firewall.eps[1] TIFF 15x34 15x34+0+0 8-bit sRGB 256c 2200B 0.000u 0:00.001
identify: Invalid TIFF directory; tags are not sorted in ascending order. 
  `TIFFReadDirectoryCheckOrder' @ warning/tiff.c/TIFFWarnings/959.
```


## Crop / Clip / a.k.a. Resize Page to Size of the Image

Very often this will work.


```
% gs \
 -q \
 -o scaled.eps \
 -dEPSCrop \ 
 -sDEVICE=eps2write \
 -c "<</Install {1 1 scale}>> setpagedevice" \
 -f firewall.eps
```

Confirm:

```
% gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=bbox scaled.eps 
%%BoundingBox: 0 0 15 33
%%HiResBoundingBox: 0.558000 0.522000 14.600390 32.669999
```

```
% identify scaled.eps
scaled.eps EPS 15x33 15x33+0+0 16-bit sRGB 3288B 0.000u 0:00.000
```


To resize (e.g.: 70%) as opposed to the actual size ({1 1 scale}): 

```
% gs -q -o scaled.eps -dEPSCrop -sDEVICE=eps2write -c "<</Install {0.70 0.70 scale}>> setpagedevice" -f firewall.eps
```

```
% gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=bbox scaled.eps 
%%BoundingBox: 0 0 11 23
%%HiResBoundingBox: 0.393820 0.360000 10.224000 22.877999
```


## Padding Images with Ghostscript and Inkscape

```
% gs \
 -q \
 -o padded.eps \
 -sDEVICE=eps2write \
 -c "<</PageOffset [0 -1]>> setpagedevice" \
 -f gigabit_switch_router.eps
```

**Reference:**  
[Ghostscript and page margin](https://stackoverflow.com/questions/35050233/ghostscript-and-page-margin)   
(Retrieved on Mar 5, 2022)    


**OR - if needed:**

For example, to add a label at the bottom of an image:

```
% gs -q -o -dSAFER -sDEVICE=bbox firewall.eps
%%BoundingBox: 368 291 383 325
%%HiResBoundingBox: 368.564333 291.923991 382.598426 324.089990

% identify firewall.eps
firewall.eps[0] EPT 15x33 15x33+0+0 16-bit ColorSeparation CMYK 2079B 0.000u 0:00.001
firewall.eps[1] TIFF 15x34 15x34+0+0 8-bit sRGB 256c 2200B 0.000u 0:00.001
identify: Invalid TIFF directory; tags are not sorted in ascending order. 
  `TIFFReadDirectoryCheckOrder' @ warning/tiff.c/TIFFWarnings/959.
```

```
% grep -n Box firewall.eps
Binary file firewall.eps matches

% strings firewall.eps | wc -l
    3229

% strings firewall.eps | grep -n Box
7:%%BoundingBox: 367 291 384 325
8:%%HiResBoundingBox: 367.998 291.4106 383.1011 324.5298
24:%AI3_TemplateBox: 306 396 306 396
25:%AI3_TileBox: 0 0 592 744
```


```
% gs \
 -q \
 -o scaled.eps \
 -dEPSCrop \
 -sDEVICE=eps2write \
 -c "<</Install {1 1 scale}>> setpagedevice" \
 -f firewall.eps
```


```
% grep -n Box scaled.eps
3:%%BoundingBox: 0 0 15 33
4:%%HiResBoundingBox: 0.00 0.00 15.00 33.00
717:/MediaBox get aload pop
1456:/FontBBox 1 index/FontBBox get def
3883:dup/BBox get aload pop exch 3 index sub exch 2 index sub rectclip
8320:<</Type/Page/MediaBox [0 0 15.1 33.12]
```

```
% cp -i padded.eps padded.eps.bak
```
        

Add 10 points in height:

```
% vi padded.eps
```

```
% diff --unified=0 padded.eps.bak padded.eps
--- padded.eps.bak      2022-03-27 15:50:42.472025000 -0700
+++ padded.eps  2022-03-27 15:56:13.098029000 -0700
@@ -3,2 +3 @@
-%%BoundingBox: 20 0 35 33
-%%HiResBoundingBox: 20.00 0.00 35.00 33.00
+%%BoundingBox: 20 0 35 43
```


Clean with **Inkscape**: 


```
% inkscape padded.eps
```

```
In the 'Page settings' dialog:  accept defaults and click  OK

Select the object and move it to the top

Edit  >  Create Guides Around the Page
File  >  Document Properties
File  >  Clean Up Document

File  >  Save As  >  Encapsulated PostScript (*.eps)
In the 'Save As' dialog:  accept defaults and click  OK
 
File  >  Quit
```

```
% mv padded.eps padded.eps.old
```


```
% gs \
 -q \
 -o padded.eps \
 -sDEVICE=eps2write \
 -c "<</PageOffset [0.2 0]>> setpagedevice" \
 -f padded.eps.old
```

```
% grep -n Box padded.eps
3:%%BoundingBox: 0 0 16 43
4:%%HiResBoundingBox: 0.20 0.00 15.20 42.10
717:/MediaBox get aload pop
1456:/FontBBox 1 index/FontBBox get def
3883:dup/BBox get aload pop exch 3 index sub exch 2 index sub rectclip
8309:<</Type/Page/MediaBox [0 0 612 792]
```

Check with **zathura**:

```
% zathura --fork padded.eps
```


## Reducing File Size (a.k.a. Compressing) ## 

```
% gs \
 -q \
 -o padded.eps \
 -dDownsampleColorImages=true \
 -dColorImageResolution=300 \
 -sDEVICE=eps2write \
 -c "<</PageOffset [14 -2]>> setpagedevice" \
 -f scaled.eps
```

**Reference:**   
[Improving my ghostscript eps compressive script](https://stackoverflow.com/questions/43079007/improving-my-ghostscript-eps-compressive-script)   
(Retrieved on Mar 5, 2022)    

---

## Generating PDF from PS and EPS Files with Ghostscript
## (a.k.a. Converting a PS or an EPS File to PDF) 

Here is a sample command line to invoke Ghostscript for 
generating a PDF/A document:

```
% gs \
 -dPDFA=1 \
 -dBATCH \
 -dNOPAUSE \
 -sColorConversionStrategy=RGB \
 -sDEVICE=pdfwrite \
 -sOutputFile=output.pdf \
 input.eps
```

Even simpler:

```
% gs -q -sDEVICE=pdfwrite -o converted.pdf -f input.eps
```

**Reference:**      
[High Level Output Devices (Vector Devices)](https://ghostscript.com/doc/current/VectorDevices.htm)    
(Retrieved on Mar 5, 2022)    


## Generating Monochrome PDF from PS and EPS Files with Ghostscript

```
% gs \
 -q \
 -o output.pdf \
 -sColorConversionStrategy=Gray \
 -sDEVICE=pdfwrite \
 -f input.eps
```


## Cropping PDF (and Removing Extraneous Whitespace)

```
% cat network_diagram.dot 
graph network_diagram {

  imagepath="/mnt/usbflashdrive/myknowledgebase/images"

  label="\nNetwork Diagram";

  node [
    shape=box,
    //fontname="arial",
    fontsize=8,
    style=filled,
    color="#d3edea"
  ];
  splines="compound"

  fw [ label="Edge firewall" shape=none image="firewall.eps" labelloc=b color="#ffffff"];
  panel [ label="Patch panel" shape=none image="24-port-patch-panel.eps" labelloc=b color="#ffffff" ];
  sw1 [ label="Cisco switch" shape=none image="gigabit_switch_router.eps" labelloc=b color="#ffffff"];
  sw2 [ label="Inside switch" shape=none image="gigabit_switch_router.eps" labelloc=b color="#ffffff"];
  srv1 [ label="Cluster server" shape=none image="rackmount-1U-server.eps" labelloc=b color="#ffffff"];
  srv2 [ label="Cluster nodes 101-114" shape=none image="server_blades.eps" labelloc=b color="#ffffff"];
  srv3 [ label="Cluster nodes 201-214" shape=none image="server_blades.eps" labelloc=b color="#ffffff"];
  srv4 [ label="Management node" shape=none image="rackmount-1U-server.eps" labelloc=b color="#ffffff"];

  cloud [ label="Internet" shape=none, image="cloud.eps" labelloc=b color="#ffffff"];

  cloud -- fw;
  fw -- panel;
  panel -- sw1;
  sw1 -- srv1 [color="#ffbb00"];
  srv1 -- sw2 [color="#ffbb00"];
  srv1 -- sw2 [color="#ffbb00"];
  srv2 -- sw2 [color="#ffbb00"];
  srv2 -- sw2 [color="#ffbb00"];
  srv3 -- sw2 [color="#ffbb00"];
  srv3 -- sw2 [color="#ffbb00"];
  panel -- srv4 [color="#ffbb00"];
  srv4 -- sw2 [color="#ffbb00"];
}
```

```
% dot -Teps network_diagram.dot -o network_diagram.eps
```

Convert the EPS file to PDF (option '-q' -> quiet Ghostscript processing).  

```
% gs \
 -q \
 -sDEVICE=pdfwrite \
 -o network_diagram.pdf \
 -f network_diagram.eps
```

The resulting PDF has a lot of whitespace around the image as shown below.

![Displaying a png image of a network diagram](/assets/img/network_diagram.png "Displaying a png image of a network diagram")


Find out the dimensions (and **BoundingBox**) of PDF:

```
% gs -q -dSAFER -dNOPAUSE -dBATCH -sDEVICE=bbox -f network_diagram.pdf
%%BoundingBox: 48 43 485 505
%%HiResBoundingBox: 48.221999 43.847999 484.613985 504.971985
```

Use those dimensions to **crop** the PDF with Ghostscript:

```
% gs \
 -q \
 -sDEVICE=pdfwrite \
 -o trimmed.pdf \
 -c "[/CropBox [48 44 485 505] /PAGES pdfmark" \
 -f network_diagram.pdf 
```

The above command produces the cropped image: 

![Displaying an image of an appropriately cropped png image of a network diagram](/assets/img/trimmed.png "Displaying an image of an appropriately cropped png image of a network diagram")


REFERENCE:  
[How to: Crop PDF Images](https://sachinashanbhag.blogspot.com/2012/09/how-to-crop-pdf-images.html)  



### Convert PDF to PNG Image - with Ghostscript (gs)

```
% gs -q -sDEVICE=png16m -r150 -o output.png -f input.pdf
```

### Convert PDF to PNG Image and Remove Extranous Whitespace - with Ghostscript (gs) 


Use ```-dUseCropBox```:  

```
% gs -q -sDEVICE=png16m -r150 -o trimmed.png -dUseCropBox -f input.pdf
```

**References:**  
[Ghostscript Converting PDF to PNG With Wrong Output Size](https://stackoverflow.com/questions/38171343/ghostscript-converting-pdf-to-png-with-wrong-output-size)

[Obey the MediaBox/CropBox in PDF when using Ghostscript to render a PDF to a PNG](https://stackoverflow.com/questions/2657458/obey-the-mediabox-cropbox-in-pdf-when-using-ghostscript-to-render-a-pdf-to-a-png)  


### Convert EPS to PNG Image


```
% ls -lh firewall.eps
-rw-r--r--  1 dusko  wheel   163K Mar  5 13:40 firewall.eps
```

```
% file firewall.eps
firewall.eps: PostScript document text conforming DSC level 3.0, type EPS, Level 2
```

List PNG supported devices by Ghostscript.

```
% gs -h | grep -i png
   faxg3 faxg32d faxg4 fmlbp fmpr fpng fs600 gdi hl1240 hl1250 hl7x0
   planc plang plank planm plib plibc plibg plibk plibm png16 png16m png256
   png48 pngalpha pnggray pngmono pngmonod pnm pnmraw ppm ppmraw pr1000
```

```
% gs -q -o -dSAFER -sDEVICE=bbox firewall.eps
%%BoundingBox: 0 9 15 42
%%HiResBoundingBox: 0.756000 9.522000 14.798812 41.669999

% identify firewall.eps
firewall.eps EPS 15x42 15x42+0+0 16-bit sRGB 3305B 0.000u 0:00.000
```

```
% wc -l firewall.eps
    8467 firewall.eps
```

```
% grep Box firewall.eps
%%BoundingBox: 0 0 16 43
%%HiResBoundingBox: 0.20 0.00 15.20 42.10
/MediaBox get aload pop
/FontBBox 1 index/FontBBox get def
dup/BBox get aload pop exch 3 index sub exch 2 index sub rectclip
<</Type/Page/MediaBox [0 0 612 792]
```

```
% gs \
 -q \
 -o firewall.png \
 -sDEVICE=png16m \
 -r150 \
 -dEPSCrop \
 -dUseCropBox \
 -f firewall.eps 
```

```
% xv firewall.png
```


### Adding a Border Around an Image with ImageMagick

Add a red border of size 4 pixels to an image. 

```
% convert -bordercolor red -border 4 network_diagram.png network_diagramBORDER.png
```


**Reference:**  
[How to add a border using Imagemagick](https://askubuntu.com/questions/819482/how-to-add-a-border-using-imagemagick)   


---
---
---


## Querying Ghostscript for the default options/settings of an output device (such as 'pdfwrite' or 'tiffg4') ##


```
% gs -c "currentpagedevice {exch ==only ( ) print == } forall"
GPL Ghostscript 9.52 (2020-03-19)
Copyright (C) 2020 Artifex Software, Inc.  All rights reserved.
This software is supplied under the GNU AGPLv3 and comes with NO WARRANTY:
see the file COPYING for details.
/MaxSeparations 3
/BandWidth 0
/DeviceGrayToK true
/DeviceLinkProfile ()
/KPreserve 8
/BandHeight 0
/PageOffset [0 0]
/GrayValues 256
/HWResolution [91.2449 91.2449]
/Separations false
/BeginPage {--.callbeginpage--}
/BlendColorProfile ()
/TextBlackPt 8
/BandBufferSpace 0
/Margins [0.0 0.0]
/BlueValues 256
/PostRenderProfile ()
/ImageBlackPt 8
/MaxBitmap 50000000
/MaxTempImage 5000
/OutputAttributes -dict-
/GreenValues 256
/LeadingEdge null
/ProofProfile ()
/GraphicBlackPt 8
/MaxPatternBitmap 0
/MaxTempPixmap 20000
/ProcessColorModel /DeviceRGB
/PageDeviceName null
/InputAttributes -dict-
/PageList /
/RedValues 256
/TextICCProfile ()
/InterpolateControl 1
/BlackPtComp 8
/.HWMargins [0.0 0.0 0.0 0.0]
/AntidropoutDownscaler false
/.IsPageDevice true
/LastPage 0
/ImagingBBox null
/ImageICCProfile ()
/TextIntent 8
/%MediaSource 0
/GraphicsAlphaBits 4
/WindowID 0
/OutputICCProfile (default_rgb.icc)
/FirstPage 0
/OutputDevice /x11alpha
/GraphicICCProfile ()
/ImageIntent 8
/%MediaDestination 0
/TextAlphaBits 4
/FILTERVECTOR false
/Name (x11alpha)
/HWSize [775 1003]
/PreBandThreshold false
/GraphicIntent 8
/UseCIEColor false
/.IgnoreNumCopies false
/PageUsesTransparency false
/FILTERTEXT false
/BitsPerPixel 24
/Install {--.callinstall--}
/SimulateOverprint true
/.LockSafetyParams false
/ColorAccuracy 2
/NumCopies null
/TextKPreserve 8
/FILTERIMAGE false
/ColorValues 16777216
/DisablePageHandler false
/.MediaSize [611.540955 791.452393]
/UseFastColor false
/PageSize [611.540955 791.452393]
/RenderIntent 8
/ImageKPreserve 8
/SeparationColorNames []
/BufferSpace 4000000
/PageCount 0
/Policies -dict-
/Colors 3
/GrayDetection false
/EndPage {--.callendpage--}
/ICCOutputColors ()
/GraphicKPreserve 8

GS>quit
```

The result is a list of ```/SomeName somevalue``` pairs which describe 
the settings used for rendering pages to the current screen.

This is so because usually the display is the default device for Ghostscript 
to send its output to.  Now you may notice that you'll see an empty 
Ghostscript window pop up, which you'll have to close. 

You can add some options to avoid the popup window:

```
% gs \
 -o /dev/null \
 -dNODISPLAY \
 -c "currentpagedevice {exch ==only ( ) print ==} forall"
```

But this will change the query return values, because you (unintentionally) 
changed the output device settings:

```
% gs -c "currentpagedevice {exch ==only ( ) print ==} forall" | grep Resolution
```

Result:

```
/HWResolution [91.2449 91.2449]
```

Compare this to:

```
% gs \
 -o /dev/null \
 -dNODISPLAY \
 -c "currentpagedevice {exch ==only ( ) print == } forall" \
 | grep Resolution
```

Result:

```
/HWResolution [72.0 72.0]
```

Avoid this trap.  Now assuming you want to query for the default settings 
of the PDF writing device, run this one:

```
% gs \
 -o /dev/null \
 -sDEVICE=pdfwrite \
 -c "currentpagedevice {exch ==only ( ) print ==} forall" \
 | tee ghostscript-pdfwrite-default-pagedevice-settings.txt
```

You now have all settings for the pdfwrite device in a *.txt file, 
and you may repeat that with some other interesting Ghostscript devices 
and then compare them for all their detailled differences:

```
% cd /tmp
```

Switch to Bash.

```
% bash
```

```
$ for _dev in \
  pswrite ps2write pdfwrite \
  tiffg3 tiffg4 tiff12nc tiff24nc tiff32nc tiff48nc tiffsep \
  jpeg jpeggray jpegcmyk \
  png16 png16m png256 png48 pngalpha pnggray pngmono; \
do \
  gs \
    -o /dev/null \
    -sDEVICE=${_dev} \
    -c "currentpagedevice {exch ==only ( ) print ==} forall" \
   | sort \
   | tee ghostscript-${_dev}-default-pagedevice-settings.txt; \
done
```


It's interesting to compare the settings for, say, the *pswrite* and 
*ps2write* devices like this (and also discover parameters which are 
available for the one, but not the other device):

```
$ sdiff -sbB ghostscript-ps*write-default-pagedevice-settings.txt
```
 
or:

```
$ diff -sbB ghostscript-ps*write-default-pagedevice-settings.txt
```

To avoid the return of just *-dict-* for certain key values, 
use the *===* instead of *==* macro.   
*===* acts like *==* but also prints the **content** of dictionaries.

```
$ for _dev in \
 pswrite ps2write pdfwrite \
 tiffg3 tiffg4 tiff12nc tiff24nc tiff32nc tiff48nc tiffsep \
 jpeg jpeggray jpegcmyk \
 png16 png16m png256 png48 pngalpha pnggray pngmono; \
 do \
   gs -o /dev/null \
   -sDEVICE=${_dev} -c "currentpagedevice {exch ===only ( ) print ===} forall" \
   | sort | \
   tee ghostscript-${_dev}-default-pagedevice-settings.txt; \
 done
```

Exit from Bash.

```
$ exit
```

**References:**

https://stackoverflow.com/questions/11001107/querying-ghostscript-for-the-default-options-settings-of-an-output-device-such

---

## Printing (a.k.a. Scaling PDF for Printing)

### Print to a Legal Sized Paper in Portrait Mode 

```
$ gs \
 -q \
 -sPAPERSIZE=legal \
 -dFIXEDMEDIA \
 -dBATCH \
 -dNOPAUSE \
 -sDEVICE=pdfwrite \
 -o printable.pdf 
 -f input.pdf
```

Open with zathura.

```
% zathura printable.pdf 
```

Print from zathura with its **print** command:

```
:print
```


### Print a PDF with a Big Image to a Legal Sized Paper in Landscape Mode

```
% cat wiring_diagram.dot
graph wiring_diagram {
 
  splines=ortho;
  ranksep="0.8 equally";

  label="\n\n\nWiring Diagram\n";

  legend [shape=none, margin=0, label=
  <
    <table border="0" cellborder="1" cellspacing="0" cellpadding="4">
        <tr><td colspan="2">Legend</td></tr>
        <tr><td bgcolor="red">red</td><td bgcolor="red">public</td></tr>
        <tr><td bgcolor="blue">blue</td><td bgcolor="blue">inside</td></tr>
        <tr><td bgcolor="green">green</td><td bgcolor="green">MGMT</td></tr>
    </table>
  >];

  subgraph cluster_pp {
    label="Patch panel";
    graph [fillcolor="burlywood", style="filled, rounded"];
    node [shape="record", fillcolor="white", style="filled", width=0.4, height=0.4];
    edge [weight=1000, style="invis"];
    
    node [label="1"] p1; 
    node [label="2"] p2;
    node [label="3"] p3;
    node [label="4"] p4;
    node [label="5"] p5;
    node [label="6"] p6;
    node [label="7"] p7;
    node [label="8"] p8;
    node [label="9"] p9;
    node [label="10"] p10;
    node [label="11"] p11;
    node [label="12"] p12;
    node [label="13"] p13;
    node [label="14"] p14;
    node [label="15"] p15;
    node [label="16"] p16;
    node [label="17"] p17;
    node [label="18"] p18;
    node [label="19"] p19;
    node [label="20"] p20;
    node [label="21"] p21;
    node [label="22"] p22;
    node [label="23"] p23;
    node [label="24"] p24;

    rank=same {p1 -- p2 -- p3 -- p4 -- p5 -- p6 -- p7 -- p8 -- p9 -- p10 -- p11 -- p12}
    rank=same {p13 -- p14 -- p15 -- p16 -- p17 -- p18 -- p19 -- p20 -- p21 -- p22 -- p23 -- p24}

    p1 -- p13
    p2 -- p14
    p3 -- p15
    p4 -- p16
    p5 -- p17
    p6 -- p18
    p7 -- p19
    p8 -- p20
    p9 -- p21
    p10 -- p22
    p11 -- p23
    p12 -- p24
  }

  subgraph cluster_webmo {
    label="WebMO and cluster storage [R2]";
    edge [style="invis"];
    node [shape="record"];

    node [label="ETH1"] webmo1;
    node [label="ETH2"] webmo2;
    node [label="ETHM"] webmom;
    
    {rank="same"; webmo1; webmo2; webmom;} 
    webmo1 -- webmo2 -- webmom;
  }

  subgraph cluster_achassis1 {
    label="Chassis 1 - Compute nodes 101-114 [R2]";
    edge [style="invis"];
    node [shape="record"];

    node [label="MM1"] ac1mm ;
    node [label="4"] ac1p4;
    node [label="3"] ac1p3;
    node [label="2"] ac1p2;
    node [label="1"] ac1p1;
    
    {rank="same"; ac1p1; ac1p2; ac1p3; ac1p4; ac1mm;}
    ac1p1 -- ac1p2 -- ac1p3 -- ac1p4 -- ac1mm;
  }

  subgraph cluster_achassis2 {
    label="Chassis 2 - Compute nodes 201-214 [R4]";
    edge[style="invis"];
    node [shape="record"];

    node [label="MM1"] ac2mm;
    node [label="1"] ac2p1;
    node [label="2"] ac2p2;
    node [label="3"] ac2p3;
    node [label="4"] ac2p4;
    
    {rank="same"; ac2p1; ac2p2; ac2p3; ac2p4; ac2mm}
    ac2p1 -- ac2p2 -- ac2p3 -- ac2p4 -- ac2mm;
  }

  subgraph cluster_compute_mgmt_node {
    label="Compute management node [R1]";
    edge [style="invis"];
    node [shape="record"];

    node [label="2"] x2 ;
    node [label="1"] x1 ;
    
    {rank="same"; x1; x2;}
    x1 -- x2;
  }

  subgraph cluster_as {
    label="Compute cluster switch";
    graph [fillcolor="burlywood1", style="filled"];
    node [shape="record", fillcolor="white", style="filled"];
    edge [style="invis"];

    node [label="1"] asw1;
    node [label="2"] asw2;
    node [label="3"] asw3;
    node [label="4"] asw4;
    node [label="5"] asw5;
    node [label="6"] asw6;
    node [label="7"] asw7;
    node [label="8"] asw8;

    {rank="same"; asw1; asw2; asw3; asw4; asw5; asw6; asw7; asw8;} 
    asw1 -- asw2 -- asw3 -- asw4 -- asw5 -- asw6 -- asw7 -- asw8;
  }

  subgraph cluster_cs {
    label="Cisco switch [R1]";
    graph [fillcolor="burlywood1", style="filled"];
    node [shape="record", fillcolor="white", style="filled"];
    edge [style="invis"];

    node [label="1"] cs1;
    node [label="2"] cs2;
    node [label="3"] cs3;
    node [label="4"] cs4;
    node [label="19"] cs19;

    {rank="same"; cs1; cs2; cs3; cs4; cs19;}
    cs1 -- cs2 -- cs3 -- cs4 -- cs19;
  }

  align_chassis [style="invis"];
  align_chassis -- ac1mm [style="invis"];
  align_chassis -- ac2mm [style="invis"];

  x1 -- asw1 [color="blue"];
  p2 -- x2 [color="red", constraint="false"]; 
  p1 -- cs1 [color="red", constraint="false"];
  asw3 -- ac1mm [color="green", penwidth=2, constraint="false"];
  asw5 -- webmom [color="green", penwidth=2];
  asw7 -- ac2mm [color="green", penwidth=2, constraint="false"];
  webmo1:sw -- cs19:ne [color="white:red:white"];
  webmo2-- asw6 [color="blue"];
  ac1p1 -- asw2 [color="blue"];
  asw4 -- ac2p4 [color="blue", constraint="false"];
}
```

```
% dot -Teps wiring_diagram.dot -o wiring_diagram.eps
```

```
% gs \
 -sDEVICE=eps2write \
 -dEPSCrop \
 -o wiring_diagram.pdf \
 -f wiring_diagram.eps
```

```
% gs \
 -sDEVICE=eps2write \
 -o scaled.eps \
 -dEPSCrop \
 -c "<</PageSizePolicy 3>> setpagedevice" \
 -dFIXMEDIA \
 -f wiring_diagram.eps
```

```
% gs \
 -sDEVICE=pdfwrite \
 -o printable.pdf \
 -dEPSFitPage \
 -c "<</PageSizePolicy 3>> setpagedevice" \
 -dFIXMEDIA \
 -dNORANGEPAGESIZE \
 -f scaled.eps
```

```
% gs -q -o -dSAFER -sDEVICE=bbox printable.pdf
%%BoundingBox: 0 1 792 150
%%HiResBoundingBox: 0.000211 1.710000 791.999976 149.412581
```

```
% gs \
 -sDEVICE=pdfwrite \
 -o trimmed.pdf \
 -c "[/CropBox [0 1 792 150] /PAGES pdfmark" \
 -f printable.pdf
```

```
% zathura trimmed.pdf
```


If you want to get the prompt (use  -sOutputFile): 

```
% gs \
 -q \
 -sDEVICE=pdfwrite \
 -sOutputFile=new.pdf \
 -dDEVICEHEIGHTPOINTS=612 \
 -dDEVICEWIDTHPOINTS=1008 \
 -dFitPage \
 -dFIXMEDIA \
 -dAutoRotatePages=/None \
 -f printable.pdf 
```


If you want to get the prompt (use  -sOutputFile) and to exit it without typing 'quit':

```
% gs \
 -q \
 -sDEVICE=pdfwrite \
 -sOutputFile=new.pdf \
 -dDEVICEHEIGHTPOINTS=612 \
 -dDEVICEWIDTHPOINTS=1008 \
 -dFitPage \
 -dFIXMEDIA \
 -dAutoRotatePages=/None \
 -f printable.pdf \
 -c quit
```

If you do not want to see output details (use -o):

```
% gs 
 -q \ 
 -sDEVICE=pdfwrite \
 -o new.pdf \
 -dDEVICEHEIGHTPOINTS=612 \
 -dDEVICEWIDTHPOINTS=1008 \
 -dFitPage \
 -dFIXMEDIA \
 -dAutoRotatePages=/None \
 -f printable.pdf
```

Load Legal sized paper in the Tray 1 (upper tray) of the HP LaserJet 2420dn printer.

After running the the above command and loading the paper, open the 
resulting PDF with zathura.

```
% zathura new.pdf
```

From zathura:

```
:print
```

In the Print dialog box:

```
Select the printer (in this example: HP_LaserJet_2420dn) 

In the Page Setup tab change the following two values - under Paper heading:
  Paper size:   Change it from 'US Letter' to 'US Legal'
  Orientation:  Change it from 'Portrait' to 'Landscape'

Click 'Print'
```

NOTE:  
The **-dDEVICEHEIGHTPOINTS=612** and **-dDEVICEWIDTHPOINTS=1008** are paper 
dimensions for **Legal paper size** and you can obtain them from here:  
[The paper sizes known to Ghostscript - Ghostsript Documentation](https://ghostscript.com/doc/current/Use.htm#Known_paper_sizes)  
(Retrieved on Mar 5, 2022)    


**References:**   
[Ghostscript - any way to fit to printable area?](https://comp.lang.postscript.narkive.com/xSbH7XrD/ghostscript-any-way-to-fit-to-printable-area)   
(Retrieved on Mar 5, 2022)    

[Ghostscript changed Orientation from landscape to portrait](https://stackoverflow.com/questions/42371152/ghostscript-changed-orientation-from-landscape-to-portrait)   
(Retrieved on Mar 5, 2022)    

[How to use Ghostscript](https://web.mit.edu/ghostscript/www/Use.htm)   
(Retrieved on Mar 5, 2022)    

---


## TIPS - USEFUL TO KNOW:

From:
[Dimensions change when Ghostscript converts PS to PNG](https://stackoverflow.com/questions/70583490/dimensions-change-when-ghostscript-converts-ps-to-png)  
(Retrieved on Mar 5, 2022)   

> The BoundingBox in your PostScript program is a comment and therefore 
> has no effect.  If you want to set the media size then you need to take 
> action to do so.  You can do this in PostScript by using the 
> setpagedevice operator.  Or you can do so from the command line using 
> **-sPAPERSIZE**, **-dDEVICEHEIGHTPOINTS** and **-dDEVICEWIDTHPOINTS**, 
> **-g** and possibly the **-dFIXEDMEDIA** switch.  
> 
> In the absence of any of these Ghostscript uses its **default** media 
> size which will be either **A4** or **US Letter**.  
> 
> Or make your program DSC-compliant and use DSC processing, or make it 
> an EPS and use -dEPSCrop.


From:  
[Using GhostScript to export PNGs at fixed size](https://stackoverflow.com/questions/46183868/using-ghostscript-to-export-pngs-at-fixed-size)   
(Retrieved on Mar 5, 2022)    

> Your problem with EPS files is that they do **not** request 
> a **media size**.  That's because EPS files are intended to be included 
> in other PostScript programs, so they need to be resized by the 
> application generating the PostScript.
> 
> To that end, EPS files include **comments** (which are **ignored** by 
> **PostScript interpreters**) which define the **BoundingBox** of the 
> **EPS**.  An application which places EPS can quickly scan the EPS to 
> find this information, then it sets the CTM appropriately in the final 
> PostScript program it is creating and inserts the content of the EPS.
> 
> The **FitPage** switch in **Ghostscript** relies on having 
> *a known media size* (and you should set **-dFIXEDMEDIA** when using this) 
> and a requested media size, figuring out what scale factor to apply to 
> the request in order to make it fit the actual size, and setting up the 
> CTM to apply that scaling.
> 
> If you don't ever get a media size request (which you **won't** with 
> an **EPS**) then **no scaling** will take place.
> 
> Now **Ghostscript** *does have* a different switch, **EPSCrop** which 
> picks up the comments from the EPS and uses that to set the media size 
> (Ghostscript has mechanisms to permit processing of comments for this 
> reason, amongst others).  You could implement a similar mechanism to 
> pick up the BoundingBox comments, and scale the EPS so that it fits 
> a desired target media size.


From:   
[Scaling PDF file using Ghostscript](https://stackoverflow.com/questions/40223691/scaling-pdf-file-using-ghostscript)  
(Retrieved on Mar 5, 2022)    

> Well, Ghostscript uses PostScript as its scripting language, 
> so anything you can do in PostScript you can do to a PDF file.
> 
> I *really* wouldn't use -g with pdfwrite, because -g specifies 
> **pixels**, and since pdfwrite is a vector device that doesn't really 
> work well. Use -dDEVICEHEIGHTPOINTS and -dDEVICEWIDTHPOINTS instead.
> 
> Don't set -sPAPERSIZE either, you can't set the media to be letter in 
> one place and something different (the -g switch) elsewhere.


From:  
[manual layout of graphs described in graphviz (DOT)](https://stackoverflow.com/questions/36871015/manual-layout-of-graphs-described-in-graphviz-dot-format)   
(Retrieved on Mar 5, 2022)    

> You can run **dot** requesting output as another dot file with the command 
> ```dot -Tdot```.  **dot** will then calculate the layout but instead of 
> outputting a pictorial representation, it will output another dot file 
> with exactly the same information as the input, with the addition of 
> layout information as additional attributes.  
> You can then edit the layout information by hand and run it through dot 
> a second time to obtain the pictorial representation.

```
$ dot -Tdot input.gv
```


From:   
[Re: [graphviz-devel] File extension .dot or .gv?](https://marc.info/?l=graphviz-devel&m=129418103126092)   
(Retrieved on Mar 5, 2022)    

and 

[What is the file extension for dot file? - Graphviz Forum](https://forum.graphviz.org/t/what-is-the-file-extension-for-dot-file/35/4)  
(Retrieved on Mar 5, 2022)    

> .gv is preferred. The .dot suffix was stolen by Word. 


---

**PROGRAMS:**  

VIEWING:   
* ps, eps, pdf: zathura
* png, jpeg: xv
* svg: Inkscape, web browsers

EDITING:   
* dot (Graphviz)
* dotty (comes with Graphviz) - a WYSIWYG tool to aid in the hand-layout process
* Graphviz Visual Editor
* PlantUML
* Kroki
* kroki-cli
* Diagrams.net (Drawio) (https://github.com/jgraph/drawio)
  * https://github.com/jgraph
  * https://github.com/jgraph/drawio
  * https://github.com/jgraph/drawio-desktop/releases/tag/v17.2.1
  * https://github.com/jgraph/docker-drawio
* DrawThe.net (https://github.com/cidrblock/drawthe.net)
* Blockdiag  (seqdiag, rackdiag, netdiag, etc.)   (http://blockdiag.com/en/)

* rsvg-convert
* anytopnm
* pamfile
* ppmhist
* pnm(5), ppm(5), pgm(5), pbm(5), pam(5)
* pamtosvg
* pbmclean
* mscgen_js - turns text into sequence charts  (https://mscgen.js.org/)
  - Includes, for example: SMTP Sequence Chart
  - Also, you can:
    - animate the chart
    - create a bookmarkable URI (URL)/link
* epsffit

* PKG (PACKAGES):
  * ghostscript
  * sam2p

NOT YET EXPLORED:  
* [Diagram as Code (mingrammer.com) - HackerNews](https://news.ycombinator.com/item?id=23154846)  
  - Mermaid 
    - https://mermaid-js.github.io/mermaid-live-editor/
    - https://mermaid-js.github.io/mermaid/#/ 
    - https://github.com/mermaid-js/mermaid
* https://isoflow.io/
* https://diagrams.mingrammer.com/
  * https://github.com/mingrammer/diagrams
* diagram.codes (playground available but Save is available only for paying customers)

* ubigraph (https://github.com/0x4lan/ubigraph_server)
* Tulip (Data Visualization Software)  https://tulip.labri.fr/site/

---

