React = require './React-shim'


createToolButton = ({displayName, getTool, imageName}) ->
  tool = getTool()
  React.createFactory React.createClass
    displayName: displayName,
    getDefaultProps: -> {isSelected: false, lc: null}
    componentWillMount: ->
      if @props.isSelected
        # prevent race condition with options, tools getting set
        # (I've already forgotten the specifics of this; should reinvestigate
        # and explain here. --steve)
        @props.lc.setTool(tool)
    render: ->
      {div, img} = React.DOM
      {imageURLPrefix, isSelected, onSelect} = @props

      className = React.addons.classSet
        'lc-pick-tool': true
        'toolbar-button': true
        'thin-button': true
        'selected': isSelected
      src = "#{imageURLPrefix}/#{imageName}.png"
      (div {
        className,
        style: {'backgroundImage': "url(#{src})"}
        onClick: (-> onSelect(tool)), title: displayName})


module.exports = createToolButton