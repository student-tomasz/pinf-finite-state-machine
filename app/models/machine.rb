class Machine < ActiveRecord::Base
private
  @@serialized_attributes = [:states, :alphabet, :accept_states, :start_state, :transition_func]
  @@steps = ['initialize', 'accept', 'complete']

public
  before_save JsonWrapper.new(@@serialized_attributes)
  after_save  JsonWrapper.new(@@serialized_attributes)
  after_find  JsonWrapper.new(@@serialized_attributes)
  
  validates_presence_of :name
  validates_presence_of :states
  validates_presence_of :alphabet
  
  scope :completed, where(:step => @@steps.last)
  
  def to_graph(format)
    g = GraphViz.new(name)
    
    # set global graph options
    g[:rankdir]    = 'LR'

    # set node options
    g.node[:color]     = "#ddaa66"
    g.node[:style]     = "filled"
    g.node[:fillcolor] = "#ffeecc"
    g.node[:penwidth]  = "1"
    g.node[:fontcolor] = "#775500"
    g.node[:fontname]  = "Lucida Grande"
    g.node[:fontsize]  = "10"

    # set edge options
    g.edge[:color]     = "#999999"
    g.edge[:penwidth]  = "1"
    g.edge[:fontcolor] = "#444444"
    g.edge[:fontname]  = "Lucida Grande"
    g.edge[:fontsize]  = "8"
    g.edge[:dir]       = "forward"
    g.edge[:arrowsize] = "0.5"
    
    # draw transition to start state
    phantom_node = g.add_node('', :style => 'invisible')
    start_node   = g.add_node(start_state, :shape => accept_states.include?(start_state) ? 'doublecircle' : 'circle')
    g.add_edge(phantom_node, start_node, :label => 'start', :color => '#444444')
    # draw states
    states.each do |state|
      shape = accept_states.include?(state) ? 'doublecircle' : 'circle'
      g.add_node(state, :shape => shape) if state != start_state
    end
    # draw transitions
    states.each do |state|
      alphabet.each do |alpha|
        n1 = g.get_node(state)
        n2 = g.get_node(transition_func[state][alpha])
        edge_updated = false
        g.each_edge do |e|
          if e.node_one == n1.id && e.node_two == n2.id
            info = e[:label].to_s[1..-2]
            e[:label] = info + ", #{alpha}"
            edge_updated = true
          end
        end
        g.add_edge(n1, n2, :label => alpha) unless edge_updated
      end
    end
    
    g.output(format => String)
  end
  
  def self.dummy
    self.new(
      :name     => 'dummy',
      :states   => ['a', 'b', 'c'],
      :alphabet => ['1', '2']
    )
  end
  
  def step    
    self[:step] || @@steps.first
  end

  def step=(value)
    self[:step] = value
    self.save
  end

  def next_step
    i = @@steps.index(step)
    self.step = @@steps[i + 1]
  end
  
  def first_step?
    step == @@steps.first
  end
  
  def last_step?
    step == @@steps[-2]
  end
  
  def completed?
    step == @@steps.last
  end
end
