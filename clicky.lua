require 'cairo'
require 'imlib2'

click_start=1 -- this starts the clickfunction

function conky_main()
  if conky_window == nil then return end

  local cs = cairo_xlib_surface_create(conky_window.display,
                                       conky_window.drawable,
                                       conky_window.visual,
                                       conky_window.width,
                                       conky_window.height)
  cr = cairo_create(cs)

  local updates = tonumber(conky_parse('${updates}'))
  if updates > 5 then
    localnowx, localnowy = clickfunction() -- this line activates the clickfunction and sets the click coordinates

    image({file="Starwars3D1.png",   x=-110-localnowx/20, y=  0-localnowy/20})
    image({file="Starwars3D2_1.png", x= 231-localnowx/40, y=180-localnowy/40})
    image({file="Starwars3D2_2.png", x=1022-localnowx/40, y=  0-localnowy/40})
    image({file="Starwars3D3.png",   x= 131-localnowx/60, y= 51-localnowy/60})
    image({file="Starwars3D4.png",   x= 103+localnowx/55, y=123+localnowy/55})
    image({file="Starwars3D5.png",   x=  86+localnowx/15, y= 91+localnowy/15})
  end -- if updates > 5
  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr = nil
end -- end main function

function image(im)
  x=nil
  x=(im.x or 0)
  y=nil
  y=(im.y or 0)
  file=nil
  file=tostring(im.file)
  if file==nil then print("set image file") end
  ---------------------------------------------
  local show = imlib_load_image(file)
  if show == nil then return end
  imlib_context_set_image(show)
  local width=imlib_image_get_width()
  local height=imlib_image_get_height()
  imlib_context_set_image(show)
  imlib_render_image_on_drawable(x, y)
  imlib_free_image()
  show=nil
end -- function image

function clickfunction()
  if click_start==1 then
    xdot=conky_parse("${if_running xdotool}1${else}0${endif}")
    if tonumber(xdot)==1 then
      os.execute("killall xdotool && echo 'xdo killed' &")
    end
    os.execute("xdotool search --name 'clicky' behave %@ mouse-click getmouselocation >> /tmp/xdo &")
    local f = io.popen("xwininfo -name 'clicky' | grep 'Absolute'")
    geometry = f:read("*a")
    f:close()
    local geometry=string.gsub(geometry,"[\n]","")
    print(geometry)
    s,f,abstlx=string.find(geometry,"X%p%s*(%d*)")
    s,f,abstly=string.find(geometry,"Y%p%s*(%d*)")
    click_start=nil
  end -- if click_start=1
  -- get current location
  os.execute("xdotool getmouselocation > /tmp/xdonow ")
  local f=io.open("/tmp/xdonow")
  mousenow=f:read()
  f:close()
  local s,f,mousenowx=string.find(mousenow,"x%p(%d*)%s")
  local s,f,mousenowy=string.find(mousenow,"y%p(%d*)%s")
  localnowx=tonumber(mousenowx)-abstlx
  localnowy=tonumber(mousenowy)-abstly

  return localnowx,localnowy
end -- clickfunction
