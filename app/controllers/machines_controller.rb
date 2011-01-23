class MachinesController < ApplicationController
  def index
    @machines = Machine.all
  end

  def show
    @machine = Machine.find(params[:id])
    redirect_to edit_machine_path(@machine) unless @machine.completed_step?
  end

  def new
    @machine = Machine.dummy.humanize
  end

  def create
    @machine = Machine.new(params['machine']).dehumanize

    if @machine.save
      @machine.next_step
      redirect_to edit_machine_path(@machine), :notice => 'Machine was successfully initialized.'
    else
      @machine.humanize
      render :action => "new"
    end
  end

  def edit
    @machine = Machine.find(params[:id]).humanize
    @machine.step = nil if @machine.completed_step?
  end

  def update
    @machine = Machine.find(params[:id])
    
    @machine.attributes = params['machine']
    @machine.dehumanize

    if @machine.save
      @machine.next_step
      if @machine.completed_step?
        redirect_to @machine, :notice => 'Machine was successfully updated.'
      else
        redirect_to edit_machine_path(@machine)
      end
    else
      @machine.humanize
      render :action => "edit"
    end
  end

  def destroy
    @machine.destroy if @machine = Machine.find(params[:id])
    redirect_to root_path
  end
end
