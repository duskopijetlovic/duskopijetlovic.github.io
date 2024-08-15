---
layout: default
title: "ed(1) Notes [DRAFT]"
---

Abbreviations:

```
CM: command mode
IM: input mode, a.k.a. edit mode
LN: line number
```

```
H       # Toggle verbose error messages on and off
P       # Toggle command prompt on and off 
h       # Help
/re/    # Search for 're' (Press / for the next match)
g/re/p  # Print all lines with 're' in them 
a       # Append
i       # Insert
.       #   = The period represents the current address =
.       # Stop editing - when in input (edit) mode
.       # Print the content of the current LN (address number) - when in CM 
.=      # Print the current LN (address)
,=      # Print how many lines the buffer has
n       # Print the current LN
p       # Print the content of the current line
,p      # Print the content of the whole buffer 
,np     # Print the content of the whole buffer with LNs
,n      # Print the content of the whole buffer with LNs
5p      # Print the content of LN 5
l       # Put a $ symbol at the end of each line
,l      # View the spaces at the end of each line in the whole buffer
,ln     # View the spaces at the end of each line in the whole buffer, with LNs
w       # Save 
q       # Quit
wq      # First save and then quit
z       # Scroll from the next address to as far as the terminal allows
        #   = To scroll to the next page, press  z  again =
11z3    # Print line 11 and the three addresses after line 11
11z3n   # Print line 11 and the three addresses after line 11, with LNs
1       # Go to the first line, aka top of the buffer 
5       # Go to LN 5 (Replace 5 with a LN to go to)
$       # Go to the last line, aka bottom of the buffer, aka end of the buffer
-1      # Replace 1 with a number of lines to go up
+1      # Replace 1 with a number of lines to go down
10,15p  # Print the contents of lines 10 to 15
10,15np # Print lines 10 to 15, including LNs
<ENTER> # Press ENTER to advance to the next line
-2,+2p  # Print the previous 2 lines and the next 2 lines
-2,+2np # Print the previous 2 lines and the next 2 lines, with LNs
.,+5p   # Print the current line and the next 5 lines
.,+5np  # Print the current line and the next 5 lines, with LNs
+5p     # Print the line that is 5 lines below the current address
+5pn    # Print the line that is 5 lines below the current address, with its LN
+5np    # Print the line that is 5 lines below the current address, with its LN
-5p     # Print the line that is 5 lines above the current address 
-5pn    # Print the line that is 5 lines above the current address, with its LN
-5np    # Print the line that is 5 lines above the current address, with its LN
```

----

## References
(Retrieved on Aug 1, 2024)

* [ed(1) is The Right Tool - "ed-primer" for beginners - phlog (a blog over gopher)](gopher://katolaz.net/0/ed_tutorial.txt)

* [Ed Mastery - Book by Michael W Lucas](https://www.tiltedwindmillpress.com/product/ed/)

