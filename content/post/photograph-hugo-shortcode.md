+++
Description = ""
Tags = [
]
date = "2020-11-29T23:27:00"
title = "A Hugo Shortcode for displaying photographs"

+++

This is a hugo shortcode for displaying photographs in a hugo page.

This is not a gallery. If the `fullsize` button is clicked the image is displayed in a larger, full-screen format.  However there are no buttons to advance to the next image, etc. I searched though gallery after gallery, and between the jQuery involved and the lack of documentation, I decided to go this route instead.

It is used like (all on one line):

```nohighlight
{{</* fullimage 
   xlargeImage="/images/horizontal-1024-90.jpg" 
   largeImage="/images/horizontal-908-90.jpg" 
   mediumImage="/images/horizontal-774-90.jpg" 
   smallImage="/images/horizontal-611-90.jpg" 
   xsmallImage="/images/horizontal-385-90.jpg" 
   imageTitle="horizontal image" 
   orientation="horizontal" 
   imageID="1"*/>}}
```

The `*image` parameters specify files to use for responsive image sizes. The medium image is used by default in the `img` tag if the browser doesn't support responsive image sizes.

The `orientation` parameter specifies the image orientation, horizontal or vertical.

The `imageID` is an ID you supply to make each image on the page unique.

The above example assumes that the images are in the `static/images` folder.

The script, which would be stored in the `/layouts/shortcodes` folder of the hugo project and named `fullimage.html`:

```nohighlight
<style>
  #fullimage_overlay_{{.Get "imageID"}} {
    position: fixed;
    display: none;
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0,0,0,0.9);
    z-index: 2;
    cursor: pointer;
  }
  #fullimage_img{
    position: absolute;
    width: 95%;
    height: 95%;
  top: 50%;
  left: 50%;
  object-fit: contain;
    transform: translate(-50%,-50%);
  -ms-transform: translate(-50%,-50%);
  }
  #gallery_overlay_horizontal{
    margin:40px; 
    max-width: 774px;
    max-height: 522px;
  }
  #gallery_overlay_vertical{
    margin:40px; 
    max-height: 774px;
    max-width: 522px;
  }
  #gallery_img_horizontal{
    max-width: 100%;
  }
  #gallery_img_vertical{
    max-height: 80vh;
  }

</style>
<div id="fullimage_overlay_{{.Get "imageID"}}" onclick='fullimage_off("fullimage_overlay_{{.Get "imageID"}}")'>
    <img 
        id="fullimage_img"
        srcset="{{.Get "xlargeImage"}} 1024w,
            {{.Get "largeImage"}} 908w,
            {{.Get "mediumImage"}} 774w,
            {{.Get "smallImage"}} 611w,
            {{.Get "xsmallImage"}} 385w"
            sizes="100vw"
        src="{{.Get "mediumImage"}} 774w,"
        alt="{{.Get "imageTitle"}}" />
</div>

<div 
    {{ if eq (.Get "orientation") ("horizontal") }}
        id="gallery_overlay_horizontal"
    {{ else }}
        id="gallery_overlay_vertical"
    {{ end }}
    >
    <img 
    {{ if eq (.Get "orientation") ("horizontal") }}
        id="gallery_img_horizontal"
    {{ else }}
        id="gallery_img_vertical"
    {{ end }}
        srcset="{{.Get "mediumImage"}} 774w,
            {{.Get "smallImage"}} 611w,
            {{.Get "xsmallImage"}} 385w"
            sizes="(min-width: 1075px) 774px,
                    (min-width: 650px) 526px,
                    100vw"
        src="{{.Get "mediumImage"}} 774w,"
        alt="{{.Get "imageTitle"}}" />
    <div><button onclick='fullimage_on("fullimage_overlay_{{.Get "imageID"}}")'>fullsize</button></div>
</div>

<script>
    function fullimage_on(element) {
        document.getElementById(element).style.display = "block";
    }

    function fullimage_off(element) {
        document.getElementById(element).style.display = "none";
    }
    off();
</script>
```

Disclaimer: CSS is not my normal thought-space. Please send suggestions. This version is working for me so far.


