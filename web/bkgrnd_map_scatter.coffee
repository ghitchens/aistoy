initialize = ->
  if GBrowserIsCompatible()
    map = new GMap2(document.getElementById("bkgrndMap"))
    map.setCenter new GLatLng(50.830722, -0.135103), 14
    map.setUIToDefault()
    GDownloadUrl "php_data/scatter_plot.php", (data) ->
      xml = GXml.parse(data)
      brightpubs = xml.documentElement.getElementsByTagName("brightpubs")
      markerCount = brightpubs.length
      i = 0
      
      while i < brightpubs.length
        name = brightpubs[i].getAttribute("name")
        address = brightpubs[i].getAttribute("address")
        phone = brightpubs[i].getAttribute("phone")
        type = brightpubs[i].getAttribute("type")
        rating = brightpubs[i].getAttribute("rating")
        noise = brightpubs[i].getAttribute(plotValue[0])
        noiseScores[i] = parseFloat(noise)
        beer = brightpubs[i].getAttribute(plotValue[1])
        beerScores[i] = parseFloat(beer)
        atmosphere = brightpubs[i].getAttribute(plotValue[2])
        atmosphereScores[i] = parseFloat(atmosphere)
        point = new GLatLng(parseFloat(brightpubs[i].getAttribute("lat")), parseFloat(brightpubs[i].getAttribute("lng")))
        marker = createMarker(point, name, address, phone, type, i)
        map.addOverlay marker
        i++
      plotData scatterplots[0].id, noiseScores, beerScores, scatterplots[0].xLabel, scatterplots[0].yLabel
      plotData scatterplots[1].id, noiseScores, atmosphereScores, scatterplots[1].xLabel, scatterplots[1].yLabel
      plotData scatterplots[2].id, beerScores, atmosphereScores, scatterplots[2].xLabel, scatterplots[2].yLabel
  alert "This version of the MapSquid scatterplot geovisualisation trials uses Google Maps as a background as well as being an interactive map.  This solves many problems that arise due to different screen resolutions, and it looks good too.  The other main solution to different screen resolutions comes from using draggable scatterplots and initially nesting them.  Simply click on each scatterplot and hold down the left mouse button to drag the chart around the screen.  As before, the interaction with the points and markers is via mouse pointer.  The hover event changes marker and corresponding points to yellow, clicking on each marker or point selects (turns red) or deselects (turn back to blue) the marker and / or corresponding pioint to facilitate multiple point selection.  Double clicking a map marker brings up an information bubble.  The numbers that appear over each point on the hover event are simply ids and are just for reference.  For further discussion see Squid Ink from the dropdown menu at the top of the screen."
  
createMarker = (point, name, address, phone, type, i) ->
  marker = new GMarker(point, customIcons[type])
  html = "<b>" + name + "</b> <br/>" + address + "<br/>" + phone
  markers.push marker
    markers[i].markId = i
  markers[i].groupSelect = false
  GEvent.addListener marker, "dblclick", ->
    marker.openInfoWindowHtml html
  
  GEvent.addListener marker, "mouseover", ->
    selectPoint marker.markId
  
  GEvent.addListener marker, "mouseout", ->
    deselectPoint marker.markId
  
  GEvent.addListener marker, "click", ->
    if marker.groupSelect == false
      marker.groupSelect = true
      selectPoint marker.markId
    else
      marker.groupSelect = false
      deselectPoint marker.markId
  
  marker
selectPoint = (id) ->
  if markers[id].groupSelect == false
    i = 0
    
    while i < scatterplots.length
      myPoints[id + (markers.length * i)].attr 
        fill: "#FFFF00"
        r: 7
      i++
    markers[id].setImage iconHover.image
  else
    i = 0
    
    while i < scatterplots.length
      myPoints[id + (markers.length * i)].attr 
        fill: "#FF0000"
        r: 7
      i++
    markers[id].setImage iconSelected.image
deselectPoint = (id) ->
  if markers[id].groupSelect == false
    i = 0
    
    while i < scatterplots.length
      myPoints[id + (markers.length * i)].attr 
        fill: "#0000FF"
        r: 5
      i++
    markers[id].setImage iconInit.image
plotData = (canvasId, xValues, yValues, xTitle, yTitle) ->
  myDiv = document.getElementById(canvasId)
  divHeight = myDiv.clientHeight
  divWidth = myDiv.clientWidth
  myPlot = new scatterplot(
    labels: xValues
    labelTitle: xTitle
    data: yValues
    dataTitle: yTitle
    height: divHeight
    width: divWidth
    element: document.getElementById(canvasId)
  )
$(document).ready ->
  scatterplots = $(".bkgrndMapChartCanvas")
  nestOffset = ""
  i = 0
  
  while i < scatterplots.length
    $("#" + scatterplots[i].id).draggable()
    nestOffset = 20 + (i * 30)
    scatterplots[scatterplots.length - 1 - i].style.bottom = (20 + (i * 30) + "px")
    scatterplots[scatterplots.length - 1 - i].style.right = (20 + (i * 30) + "px")
    i++

plotValue = []
$(document).ready ->
  scatterplots[0].xAxis = "noise"
  scatterplots[0].yAxis = "beer"
  scatterplots[0].xLabel = "Noise Level"
  scatterplots[0].yLabel = "Beer Quality"
  scatterplots[1].xAxis = "noise"
  scatterplots[1].yAxis = "atmosphere"
  scatterplots[1].xLabel = "Noise Level"
  scatterplots[1].yLabel = "Atmosphere"
  scatterplots[2].xAxis = "beer"
  scatterplots[2].yAxis = "atmosphere"
  scatterplots[2].xLabel = "Beer Quality"
  scatterplots[2].yLabel = "Atmosphere"
  plotValue[0] = "noise"
  plotValue[1] = "beer"
  plotValue[2] = "atmosphere"

iconInit = new GIcon()
iconInit.image = "http://labs.google.com/ridefinder/images/mm_20_blue.png"
iconInit.shadow = "http://labs.google.com/ridefinder/images/mm_20_shadow.png"
iconInit.iconSize = new GSize(12, 20)
iconInit.shadowSize = new GSize(22, 20)
iconInit.iconAnchor = new GPoint(6, 20)
iconInit.infoWindowAnchor = new GPoint(5, 1)
iconHover = new GIcon()
iconHover.image = "http://labs.google.com/ridefinder/images/mm_20_yellow.png"
iconHover.shadow = "http://labs.google.com/ridefinder/images/mm_20_shadow.png"
iconHover.iconSize = new GSize(12, 20)
iconHover.shadowSize = new GSize(22, 20)
iconHover.iconAnchor = new GPoint(6, 20)
iconHover.infoWindowAnchor = new GPoint(5, 1)
iconSelected = new GIcon()
iconSelected.image = "http://labs.google.com/ridefinder/images/mm_20_red.png"
iconSelected.shadow = "http://labs.google.com/ridefinder/images/mm_20_shadow.png"
iconSelected.iconSize = new GSize(12, 20)
iconSelected.shadowSize = new GSize(22, 20)
iconSelected.iconAnchor = new GPoint(6, 20)
iconSelected.infoWindowAnchor = new GPoint(5, 1)
customIcons = []
customIcons["pub"] = iconInit
customIcons["hover"] = iconHover
customIcons["selected"] = iconSelected
beerScores = []
noiseScores = []
atmosphereScores = []
markers = []
myPoints = []
scatterplot = (input) ->
  @labels = input.labels or []
  @labelTitle = input.labelTitle or ""
  @data = input.data or []
  @dataTitle = input.dataTitle or ""
  @width = input.width or ""
  @height = input.height or ""
  @element = input.element or $.Elements.create("div")
  @paper = Raphael(@element, @width, @height)
  @maximumDataValueY = Math.ceil(Math.max.apply(Math, @data) / 10) * 10
  @maximumDataValueX = Math.ceil(Math.max.apply(Math, @labels) / 10) * 10
  @buildGrid = ->
    xLabelHeight = 40
    yLabelWidth = 40
    x = yLabelWidth
    y = 20
    width = @width - yLabelWidth - 20
    height = @height - xLabelHeight - y
    horizLines = (@maximumDataValueX)
    vertLines = (@maximumDataValueY)
    @paper.drawGrid x, y, width, height, horizLines, vertLines, "#ccc"
    drawXLabels = ->
      index = 0
      length = horizLines
      
      while index <= length
        labelTextX = (index * @maximumDataValueX) / horizLines
        labelPositionX = yLabelWidth + (labelTextX * width / horizLines)
        labelCentreX = @height - (xLabelHeight * 0.75)
        @paper.text(labelPositionX, labelCentreX, labelTextX).attr 
          font: "10px \"Arial\""
          stroke: "none"
          fill: "#000"
        index++
    .call(this)
    drawXTitle = ->
      @paper.text(yLabelWidth + (width / 2), @height - (xLabelHeight / 4), @labelTitle).attr 
        font: "10px \"Arial\""
        stroke: "none"
        fill: "#000"
    .call(this)
    drawYLabels = ->
      index = 0
      length = vertLines
      
      while index <= length
        labelTextY = (index * @maximumDataValueY) / vertLines
        labelPositionY = height - (labelTextY * height / vertLines) + 20
        @paper.text(yLabelWidth * 0.75, labelPositionY, labelTextY).attr 
          font: "10px \"Arial\""
          stroke: "none"
          fill: "#000"
        index++
    .call(this)
    drawYTitle = ->
      YTitle = @paper.text(yLabelWidth * 0.25, (height / 2) + 20, @dataTitle).attr(
        font: "10px \"Arial\""
        stroke: "none"
        fill: "#000"
      )
      YTitle.rotate -90
    .call(this)
    x: x
    y: y
    width: width
    height: height
  
  @grid = @buildGrid()
  @drawPoints = ->
    @text = []
    @circles = []
    index = 0
    length = @data.length
    
    while index < length
      x = @grid.x + (@labels[index] * @grid.width / @maximumDataValueX)
      y = @grid.y + @grid.height - (@data[index] * @grid.height / @maximumDataValueY)
      drawPoints = ->
        circle = @paper.circle(x, y, 10).attr(
          stroke: "none"
          fill: "#fff"
          opacity: 0
        )
        circle.pointId = index
        @circles.push circle
        point = @paper.circle(x, y, 5).attr(fill: "#0000FF")
        point.pointId = index
        point.groupSelect = false
        myPoints.push point
        text = @paper.text(x, y - 15, circle.pointId).attr(
          font: "10px \"Arial\""
          stroke: "none"
          fill: "#000"
        )
        @text.push text
        text.insertAfter point
        text.hide()
        circle.mouseover ->
          selectPoint circle.pointId
          text.show()
        
        circle.mouseout ->
          deselectPoint circle.pointId
          text.hide()
        
        point.mouseover ->
          selectPoint point.pointId
          text.show()
        
        point.mouseout ->
          deselectPoint point.pointId
          text.hide()
        
        point.click ->
          if markers[point.pointId].groupSelect == false
            markers[point.pointId].groupSelect = true
            selectPoint point.pointId
            text.show()
          else
            markers[point.pointId].groupSelect = false
            deselectPoint point.pointId
      .call(this)
      index++
  
  @drawPoints()
