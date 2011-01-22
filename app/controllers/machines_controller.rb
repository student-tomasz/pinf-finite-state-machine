class MachinesController < ApplicationController
  def index
    @machines = Machine.all
  end

  def show
    @machine = Machine.find(params[:id])
  end

  def new
    @machine = Machine.dummy.humanize
  end

  def edit
    @machine = Machine.find(params[:id]).humanize
  end

  def create
    @machine = Machine.new(params['machine']).dehumanize

    if @machine.save
      redirect_to @machine, :notice => 'Machine was successfully created.'
    else
      @machine.humanize
      render :action => "new"
    end
  end

  def update
    @machine = Machine.find(params[:id])
    
    @machine.attributes = params['machine']
    @machine.dehumanize

    if @machine.save
      redirect_to @machine, :notice => 'Machine was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @machine.destroy if @machine = Machine.find(params[:id])
    redirect_to root_path
  end
end
