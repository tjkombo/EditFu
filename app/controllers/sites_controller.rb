class SitesController < ApplicationController
  before_filter :authenticate_all!, :only => [:index]
  before_filter :authenticate_owner!, :except => [:index, :ls]
  layout nil

  def index
    if current_user.owner?
      @site = current_user.sites.first
      redirect_to site_path(@site) if @site
    else
      @page = current_user.pages.first
      redirect_to site_page_path(@page.site, @page) if @page
    end
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

    validate_and_save
  end

  def edit
    find_site
  end

  def update
    find_site.attributes= params[:site]
    validate_and_save
  end

  def destroy
    find_site.destroy
    redirect_to sites_path
  end

  def ls
    @files = params[:files]

    if params[:site_id]
      site = current_user.sites.find params[:site_id]
    else
      site = Site.new params[:site]
      site.site_root = '/'
    end

    render_tree(site, params[:folder]) do
      FtpClient.ls(site, params[:folder])
    end
  end

  def tree
    site = current_user.sites.find params[:site_id]
    render_tree(site, site.site_root) do
      FtpClient.tree(site, site.site_root)
    end
  end

  private

  def find_site
    @site = current_user.find_site(params[:id])
  end

  def validate_and_save
    render_errors(:site => @site) unless @site.validate_and_save
  end

  def render_tree(site, folder)
    begin
      files = FtpClient.tree(site, folder)
      render :partial => 'tree', :locals => { :files => yield }
    rescue FtpClientError => e
      head :ftp_error => e.message
    end
  end
end
