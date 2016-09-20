class @PortfolioSlider
  constructor: (@config = {}) ->
    # Setting config defaults if they are not set
    @config.thumbnailsId = @config.thumbnailsId or "thumbnails"
    @config.displayContainer = @config.displayContainer or "displayContainer"
    @config.loaderUrl = @config.loaderId or 'assets/images/spin.gif'
    @config.id = @config.id or 'portfolio-slider'
    @config.loaderClass = @config.loaderClass or 'image-loader'
    
    wrapper = document.getElementById(@config.id)
    if wrapper
      wrapper.style.position = 'relative'
      wrapper.style.overflow = 'hidden'
    
    thumbnails = document.getElementById(@config.thumbnailId)
    throw "Could not Find Thumbnails" if !thumbnails
    thumbnails.addEventListener("click", this.clickThumbnail)
    
    thumbImages = thumbnails.getElementsByTagName('img')
    throw "No Images found in thumbnail wrapper" if !thumbImages
      
    this.clickThumbnail({target: thumbImages[0]})
    
    $(window).resize(() =>
      this.updateImages($('.image-primary'), $('.image-secondary'), null, $('.image-outgoing'), true)
    )
  
  
  clickThumbnail: (event) =>
    # 1. Get Image Url from thumb
    thumb = event.target
    url = thumb.dataset.original || thumb.src
    if url
      # 2. Check if its the same as the last image clicked
      if $('.image-primary').length > 0
        fileA = $('.image-primary')[0].src.split("/")[$('.image-primary')[0].src.split("/").length - 1]
        return if fileA == url.split("/")[url.split("/").length - 1]
      
      # 3. Create and display loading spinner
      loader = this.getLoader()
      
      # 4. Create new image attribute
      img = document.createElement('img')
      img.src = url
      img.style.visibility = 'hidden'
      # 5. Add 'clicked' styling to thumb
      $(thumb).addClass('viewed')

      # 6. Animate new Image in and previous ones out
      
      display = document.getElementById(@config.displayContainer)
      display.appendChild(img)
      # 5. Remove loader
      img.onload = () =>
        this.activateImage(img)
      
      
  activateImage: (img) ->
    imageIncoming = $(img)
    imagePrimary = $('.image-primary')
    imageSecondary = $('.image-secondary')
    imageOutgoing = $('.image-outgoing')
    
    # Transistion Classes
    imageIncoming.addClass('feature-image image-primary')
    imagePrimary.addClass('image-secondary').removeClass('image-primary')
    imageSecondary.removeClass('image-secondary').addClass('image-outgoing')
    
    # Animations
    this.hideLoader()
    this.updateImages(imageIncoming, imagePrimary, imageSecondary, imageOutgoing, true)
  
  
  updateImages: (incoming, primary, secondary, outgoing, animate) ->
    # Calculate widths
    totalWidth = incoming.width() + primary.width()
    leftSpacePrimary
    leftSpaceIncoming
    incoming.css({visibility: 'visible'}) # hiding it initailly to prevent a flash 
    
    # If 2 photos fit, then place them next to each other
    if totalWidth < window.innerWidth
      leftSpace = (window.innerWidth - totalWidth)/2
      leftSpacePrimary = leftSpace
      leftSpaceIncoming = leftSpace + primary.width()
      if secondary then leftSpaceSecondary = -(secondary.width())
    else
      leftSpace = (window.innerWidth - incoming.width())/2
      leftSpacePrimary = -(primary.width())
      leftSpaceIncoming = leftSpace
      if secondary then leftSpaceSecondary = -(secondary.width()) - primary.width()
    
    if animate
      incoming.stop().animate({'left': leftSpaceIncoming + 'px'}, 300)
      primary.stop().animate({'left': leftSpacePrimary + 'px'}, 300)
      if secondary then secondary.stop().animate({'left': leftSpaceSecondary + 'px'}, 300)
    else
      incoming.css({'left': leftSpaceIncoming + 'px'})
      primary.css({'left': leftSpacePrimary + 'px'})
      if secondary then secondary.css({'left': leftSpaceSecondary + 'px'})
    outgoing.css({'left': '100%'});
  
  getLoader: =>
    loader = document.getElementById('js-loader')
    if !loader
      loader = document.createElement('img')
      loader.src = @config.loaderUrl
      loader.id = 'js-loader'
      loader.className = @config.loaderClass
      object = document.getElementById(@config.displayContainer)
      object.appendChild(loader)
      
    loader = $(loader)
    loader.addClass('active')
    return loader
  
  
  hideLoader: =>
    $('#js-loader').removeClass('active')