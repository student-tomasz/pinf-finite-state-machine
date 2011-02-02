class MachinesController < ApplicationController
  def index
    @machines = Machine.complete
  end

  def show
    @machine = Machine.find(params[:id])
    if @machine.step == :complete
      respond_to do |format|
        format.html { }
        format.any(:svg, :png, :dot) {
          format = params[:format].to_sym
          send_data @machine.to_graph.output(format => String), :filename => "#{@machine.name}.#{format}", :type => format
        }
      end
    else
      redirect_to edit_machine_path(@machine)
    end
  end

  def new
    @machine = Machine.create_dummy
    redirect_to edit_machine_path(@machine)
  end
  
  def edit
    @machine = Machine.find(params[:id])
    @machine.step = :basic if @machine.step == :complete
  end
  
  def update
    @machine = Machine.find(params[:id])
    if @machine.update_part_of_attributes(params['machine'])
      if @machine.step == :complete
        redirect_to @machine, :notice => 'Machine was successfully saved.'
      else
        redirect_to edit_machine_path(@machine)
      end
    else
      render 'edit'
    end
  end

  def destroy
    @machine.destroy if @machine = Machine.find(params[:id])
    redirect_to root_path
  end
  
  def process_word
    @machine = Machine.find(params[:id])
    @states_log, @accepted = @machine.process_word(@word = params['machine']['word'].split)
  end
end
