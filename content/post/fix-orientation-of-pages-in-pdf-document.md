+++
Description = ""
Tags = [
]
date = "2016-08-06T19:55:32-05:00"
title = "Fix orientation of pages in pdf document"

+++

Scanned document has some pages tipped to the right.<!--more-->

Identify page ranges to tip back to the left and...

`pdftk in.pdf rotate 1-10west 12-17west 36-39west output out.pdf`
