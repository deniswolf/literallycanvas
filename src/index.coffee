require './ie_customevent'
require './ie_setLineDash'

LiterallyCanvas = require './core/LiterallyCanvas'
initReact = require './reactGUI/init'

canvasRenderer = require './core/canvasRenderer'
svgRenderer = require './core/svgRenderer'
shapes = require './core/shapes'
util = require './core/util'

{localize} = require './core/localization'


require './optionsStyles/font'
require './optionsStyles/stroke-width'
require './optionsStyles/line-options-and-stroke-width'
require './optionsStyles/null'
{defineOptionsStyle} = require './optionsStyles/optionsStyles'


conversion =
  snapshotToShapes: (snapshot) ->
    shapes.JSONToShape(shape) for shape in snapshot.shapes
  snapshotJSONToShapes: (json) -> conversion.snapshotToShapes(JSON.parse(json))


baseTools = require './tools/base'
tools =
  Pencil: require './tools/Pencil'
  Eraser: require './tools/Eraser'
  Line: require './tools/Line'
  Rectangle: require './tools/Rectangle'
  Ellipse: require './tools/Ellipse'
  Text: require './tools/Text'
  Polygon: require './tools/Polygon'
  Pan: require './tools/Pan'
  Eyedropper: require './tools/Eyedropper'

  Tool: baseTools.Tool
  ToolWithStroke: baseTools.ToolWithStroke


defaultTools = [
  tools.Pencil,
  tools.Eraser,
  tools.Line,
  tools.Rectangle,
  tools.Ellipse,
  tools.Text,
  tools.Polygon,

  tools.Pan,
  tools.Eyedropper,
]


defaultImageURLPrefix = 'lib/img'
setDefaultImageURLPrefix = (newDefault) -> defaultImageURLPrefix = newDefault


init = (el, opts = {}) ->
  opts.imageURLPrefix ?= defaultImageURLPrefix

  opts.primaryColor ?= '#000'
  opts.secondaryColor ?= '#fff'
  opts.backgroundColor ?= 'transparent'

  opts.toolbarPosition ?= 'top'

  opts.keyboardShortcuts ?= true

  opts.imageSize ?= {width: 'infinite', height: 'infinite'}

  opts.backgroundShapes ?= []
  opts.watermarkImage ?= null
  opts.watermarkScale ?= 1

  opts.zoomMin ?= 0.2
  opts.zoomMax ?= 4.0
  opts.zoomStep ?= 0.2

  unless 'tools' of opts
    opts.tools = defaultTools

  ### henceforth, all pre-existing DOM children shall be destroyed ###

  for child in el.children
    el.removeChild(child)

  ### and now we rebuild the city ###

  if [' ', ' '].join(el.className).indexOf(' literally ') == -1
    el.className = el.className + ' literally'

  topOrBottomClassName = if opts.toolbarPosition == 'top'
    'toolbar-at-top'
  else
    'toolbar-at-bottom'
  el.className = el.className + ' ' + topOrBottomClassName

  pickerElement = document.createElement('div')
  pickerElement.className = 'lc-picker'

  drawingViewElement = document.createElement('div')
  drawingViewElement.className = 'lc-drawing'

  optionsElement = document.createElement('div')
  optionsElement.className = 'lc-options'

  el.appendChild(pickerElement)
  el.appendChild(drawingViewElement)
  el.appendChild(optionsElement)

  ### and get to work ###

  lc = new LiterallyCanvas(drawingViewElement, opts)

  initReact(pickerElement, optionsElement, lc, opts.tools, opts.imageURLPrefix)

  if 'onInit' of opts
    opts.onInit(lc)

  lc


registerJQueryPlugin = (_$) ->
  _$.fn.literallycanvas = (opts = {}) ->
    @each (ix, el) =>
      el.literallycanvas = init(el, opts)
    this


# non-browserify compatibility
window.LC = {init}
if window.$
    registerJQueryPlugin(window.$)


module.exports = {
  init, registerJQueryPlugin, util, tools, defineOptionsStyle,
  setDefaultImageURLPrefix, defaultTools,

  defineShape: shapes.defineShape,
  createShape: shapes.createShape,
  JSONToShape: shapes.JSONToShape,
  shapeToJSON: shapes.shapeToJSON,

  defineCanvasRenderer:  canvasRenderer.defineCanvasRenderer,
  renderShapeToContext: canvasRenderer.renderShapeToContext,
  renderShapeToCanvas: canvasRenderer.renderShapeToCanvas,
  renderShapesToCanvas: util.renderShapes

  defineSVGRenderer: svgRenderer.defineSVGRenderer,
  renderShapeToSVG: svgRenderer.renderShapeToSVG,
  renderShapesToSVG: util.renderShapesToSVG,

  snapshotToShapes: conversion.snapshotToShapes
  snapshotJSONToShapes: conversion.snapshotJSONToShapes

  localize: localize
}
