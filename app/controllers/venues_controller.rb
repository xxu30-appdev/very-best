class VenuesController < ApplicationController
  def index
    @q = Dish.ransack(params.fetch("q", nil))
    
    #@venues = @q.result(:distinct => true).includes(:bookmarks, :neighborhood, :fans, :specialties).page(params.fetch("page", nil)).per(10)
    @dish = @q.result(:distinct => true).includes(:bookmarks, :fans ).page(params.fetch("page", nil)).per(10)
    
    #@dish = Dish.all
    @cuisine = Cuisine.all
    #@location_hash = Gmaps4rails.build_markers(@venues.where.not(:address_latitude => nil)) do |venue, marker|
      #marker.lat venue.address_latitude
      #marker.lng venue.address_longitude
      #marker.infowindow "<h5><a href='/venues/#{venue.id}'>#{venue.created_at}</a></h5><small>#{venue.address_formatted_address}</small>"
#
    #end

    render("venues_templates/index.html.erb")
  end
  
  def index2
    @q = current_user.bookmarks.ransack(params.fetch("q", nil))
    #@bookmarks =  @q.result(:distinct => true).includes(:user, :venue, :dish).page(params.fetch("page", nil)).per(10)
    #@bookmarks = @bookmarks.uniq{|x| x.venue.id}
    
    @venues =  @q.result(:distinct => true).includes(:user, :venue, :dish).page(params.fetch("page", nil)).per(10)
    @venues = @venues.uniq{|x| x.venue.id}
    
    render("venues_templates/index2.html.erb")
  end

  def show
    @bookmark = Bookmark.where({ user_id: current_user.id, venue_id: params.fetch("id") })
    @venue = Venue.find(params.fetch("id"))

    render("venues_templates/show.html.erb")
  end

  def new
    @venue = Venue.new

    render("venues_templates/new.html.erb")
  end

  def create
    @venue = Venue.new

    @venue.name = params.fetch("name")
    @venue.address = params.fetch("address")
    @venue.neighborhood_id = params.fetch("neighborhood_id")

    save_status = @venue.save

    if save_status == true
      referer = URI(request.referer).path

      case referer
      when "/venues/new", "/create_venue"
        redirect_to("/venues")
      else
        redirect_back(:fallback_location => "/", :notice => "Venue created successfully.")
      end
    else
      render("venues_templates/new.html.erb")
    end
  end

  def edit
    @venue = Venue.find(params.fetch("id"))

    render("venues_templates/edit.html.erb")
  end

  def update
    @venue = Venue.find(params.fetch("id"))

    @venue.name = params.fetch("name")
    @venue.address = params.fetch("address")
    @venue.neighborhood_id = params.fetch("neighborhood_id")

    save_status = @venue.save

    if save_status == true
      referer = URI(request.referer).path

      case referer
      when "/venues/#{@venue.id}/edit", "/update_venue"
        redirect_to("/venues/#{@venue.id}", :notice => "Venue updated successfully.")
      else
        redirect_back(:fallback_location => "/", :notice => "Venue updated successfully.")
      end
    else
      render("venues_templates/edit.html.erb")
    end
  end

  def destroy
    @venue = Venue.find(params.fetch("id"))

    @venue.destroy

    if URI(request.referer).path == "/venues/#{@venue.id}"
      redirect_to("/", :notice => "Venue deleted.")
    else
      redirect_back(:fallback_location => "/", :notice => "Venue deleted.")
    end
  end
end
