class SitesController < ApplicationController
  layout 'sites'
  before_filter :authenticate_user!, :only => [:index, :show]
  before_filter :authenticate_owner!, :except => [:index, :show]
  before_filter :check_trial_period, :only => :create
  before_filter :check_limits, :only => :create

  def index
  end

  def show
    find_site
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new params[:site]
    @site.owner = current_user

    if @site.validate_and_save
      redirect_to site_path(@site)
    else
      render :action => :new
    end
  end

  def edit
    find_site
  end

  def update
    find_site.attributes= params[:site]
    if @site.validate_and_save
      redirect_to site_path(@site)
    else
      render :action => :edit
    end
  end

  def destroy
    find_site.destroy
    redirect_to sites_path
  end

  def ls
    site = Site.new params[:site]
    json = {}
    begin
      json[:dirs], json[:files] = FtpClient.ls(site)
    rescue FtpClientError => e
      json[:message] = e.message
    end
    render :json => json
  end

  private

  def find_site
    @site = current_user.find_site(params[:id])
  end

  def check_limits
    redirect_to :action => :new unless current_user.can_add_site?
  end
end
