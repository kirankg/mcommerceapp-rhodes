require 'rho/rhocontroller'
require 'helpers/browser_helper'

class TermsController < Rho::RhoController
  include BrowserHelper

  # GET /Terms
  def index    
    $Start_time = Time
    @termses = Terms.find(:all)
    render :back => '/app'
  end

  def back
    WebView.navigate ( url_for :controller => Electronics)
   end
  
  # GET /Terms/{1}
  def show
    @terms = Terms.find(@params['id'])
    if @terms
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Terms/new
  def new
    @terms = Terms.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Terms/{1}/edit
  def edit
    @terms = Terms.find(@params['id'])
    if @terms
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Terms/create
  def create
    @terms = Terms.create(@params['terms'])
    redirect :action => :index
  end

  # POST /Terms/{1}/update
  def update
    @terms = Terms.find(@params['id'])
    @terms.update_attributes(@params['terms']) if @terms
    redirect :action => :index
  end

  # POST /Terms/{1}/delete
  def delete
    @terms = Terms.find(@params['id'])
    @terms.destroy if @terms
    redirect :action => :index  
  end
end
