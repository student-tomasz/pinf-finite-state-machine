class MachinesController < ApplicationController
  def index
    @machines = Machine.completed
  end

  def show
    @machine = Machine.find(params[:id])
    redirect_to edit_machine_path(@machine) unless @machine.completed?
  end

  def new
    @machine = Machine.dummy
    @machine.save
    redirect_to edit_machine_path(@machine)
  end

  def edit
    @machine = Machine.find(params[:id])
    @machine.step = nil if @machine.completed?
  end

  def update
    @machine = Machine.find(params[:id])
    if @machine.first_step?
      @machine.attributes = {
        :name     => params['machine']['name'],
        :states   => params['machine']['states'].split,
        :alphabet => params['machine']['alphabet'].split
      }
    else
      @machine.attributes = params['machine']
    end

    if @machine.save
      @machine.next_step
      if @machine.completed?
        redirect_to @machine, :notice => 'Machine was successfully saved.'
      else
        redirect_to edit_machine_path(@machine)
      end
    else
      render :action => "edit"
    end
  end

  def destroy
    @machine.destroy if @machine = Machine.find(params[:id])
    redirect_to root_path
  end
end
