class AirQuality
  constructor: () ->

  documentReady: () ->
    return false if @drawn?
    @drawn = true

    e = $('#airquality')
    @h = e.height()
    @w = e.width()
    @r = new Raphael('airquality',@w,@h)
    @x = d3.scale.linear().domain([0, 250]).range([300,@w-30]).nice()
    @y = d3.scale.ordinal().domain(['2010','comparator','chosen']).rangeRoundBands([25,@h-20],0.25)
    comparator_id = twentyfifty.getComparator() || twentyfifty.default_comparator_code
  
    @r.text(30,@y("2010")+9,"2010").attr({'text-anchor':'start','font-weight':'bold'})
    @r.text(30,@y("comparator")+9,"2050 - #{twentyfifty.pathwayName(comparator_id)}").attr({'text-anchor':'start','font-weight':'bold'})
    @r.text(30,@y("chosen")+9,"2050 - Your pathway").attr({'text-anchor':'start','font-weight':'bold'})
    
    @bars = {}
    h = @y.rangeBand()
    x = @x(0)

    _2010 =   @r.rect(x,@y('2010'),@x(100)-@x(0),h).attr({'fill':'#008000','stroke':'none'})

    @r.text(30,@y('comparator')+27,twentyfifty.pathwayDescriptions(comparator_id,"")).attr({'text-anchor':'start'})
    clow =   @r.rect(x,@y('comparator'),0,h).attr({'fill':'#f00','stroke':'none'})
    crange = @r.rect(x,@y('comparator'),0,h).attr({'fill':'url(/assets/hatches/hatch-f00.png)','stroke':'none'})
    @bars['comparator'] = {low: clow, range: crange}

    low =   @r.rect(x,@y('chosen'),0,h).attr({'fill':'#1f77b4','stroke':'none'})
    range = @r.rect(x,@y('chosen'),0,h).attr({'fill':'url(/assets/hatches/hatch-1f77b4.png)','stroke':'none'})
    @bars['chosen'] = {low: low, range: range}

    # The bottom x axis labels and indicators
    @r.text(@x(0),10,"Air pollution health impact index (2010=100)").attr({'text-anchor':'start','font-weight':'bold','fill':'#000'})
    @r.path(["M",@x(0),@h-35,"L",@x(0),30,"L",@w-30,30]).attr({'stroke':'#000','stroke-width':2})
    format = @x.tickFormat(10)
    for tick in @x.ticks(10)
      @r.text(@x(tick),23,format(tick)).attr({'text-anchor':'middle',fill:'#000000'})
      @r.path(["M", @x(tick), 29, "L", @x(tick),@h-26]).attr({stroke:'#fff'})

    twentyfifty.loadSecondaryPathway(comparator_id,@updateComparator)

  updateComparator: (pathway) =>
    @bars['comparator']['low'].attr({width:@x(pathway.air_quality.low)-@x(0)})
    @bars['comparator']['range'].attr({width:@x(pathway.air_quality.high-pathway.air_quality.low)-@x(0),x:@x(pathway.air_quality.low)})

  updateResults: (pathway) =>
    @bars['chosen']['low'].attr({width:@x(pathway.air_quality.low)-@x(0)})
    @bars['chosen']['range'].attr({
      width: @x(pathway.air_quality.high-pathway.air_quality.low)-@x(0)
      x: @x(pathway.air_quality.low)
    })
    text = ["The damage to human health arising from air pollution from this pathway, principally particulate matter, could be around " ]
    text.push "#{Math.abs(Math.round(100-pathway.air_quality.high))}%"
    text.push " higher " if pathway.air_quality.high > 100 && pathway.air_quality.low <= 100
    text.push " lower " if pathway.air_quality.high <= 100 && pathway.air_quality.low > 100
    text.push " to "
    text.push "#{Math.abs(Math.round(100-pathway.air_quality.low))}%"
    text.push " higher" if pathway.air_quality.low > 100
    text.push " lower" if pathway.air_quality.low <= 100
    text.push " in 2050 compared to 2010."
    if pathway.air_quality.high > 100
      text.push " Given the scope for adverse implications for air quality, if the UK were to adopt this pathway the Government  would develop a policy framweork that supported the innovation required to be at the bottom end of the range"
    $('#airqualitymessage').html(text.join(''))


twentyfifty.AirQuality = AirQuality

