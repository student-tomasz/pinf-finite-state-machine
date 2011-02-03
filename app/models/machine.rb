class Machine < ActiveRecord::Base
private
  @@serialized_attributes = [:states, :alphabet, :transition_func, :start_state, :accept_states]
  @@steps = [:basic, :logic, :complete]

public
  before_save JsonWrapper.new(@@serialized_attributes)
  after_save  JsonWrapper.new(@@serialized_attributes)
  after_find  JsonWrapper.new(@@serialized_attributes)
  
  validates_presence_of :name, :states, :alphabet
  
  scope :complete, where(:step => @@steps.last)
  
  def process_word(word = [""])
    @graph_log = []
    prev_state = nil
    curr_state = nil
    graph = self.to_graph
    
    prev_state = 'nil'
    curr_state = start_state
    graph.mark(prev_state, curr_state)
    @graph_log << graph.to_svg
    
    word.each do |alpha|
      graph.unmark(prev_state, curr_state)
      prev_state = curr_state
      curr_state = transition_func[prev_state][alpha]
      if !curr_state.blank?
        graph.mark(prev_state, curr_state)
        @graph_log << graph.to_svg
      else
        break
      end
    end
    
    return @graph_log, self.accept_states.include?(curr_state)
  end
  
  def to_graph
    graph = GraphViz.digraph(name)
    graph.apply_global_styles
    
    # draw transition to start state
    phantom_node = graph.add_node('nil', :style => 'invisible', :width => 0.0, :height => 0.0, :fontsize => 0)
    start_node   = graph.add_node(start_state, :shape => accept_states.include?(start_state) ? 'doublecircle' : 'circle')
    graph.add_edge(phantom_node, start_node, :label => 'start')
    
    # draw states
    states.reject{|e| e == start_state}.each do |state|
      graph.add_node(state, :shape => accept_states.include?(state) ? 'doublecircle' : 'circle')
    end
    
    # draw transitions    
    transition_func.each do |from, on_alpha_move_to|
      n1 = graph.get_node(from)
      on_alpha_move_to.each do |alpha, to|
        n2 = graph.get_node(to)
        next if n2.nil?
        # don't draw new edge if it's already there, only update its label with new transition argument
        edge_found = false
        graph.each_edge do |e|
          if e.node_one == n1.id && e.node_two == n2.id
            e[:label] = e[:label].to_s[1..-2] + ", #{alpha}"
            edge_found = true
          end
        end
        # ok, draw new edge if it wasn't found
        graph.add_edge(n1, n2, :label => alpha) unless edge_found
      end
    end
    
    return graph
  end
  
  def self.create_dummy
    self.create(
      :name     => 'dummy',
      :states   => ['a', 'b', 'c'],
      :alphabet => ['1', '2']
    )
  end
  
  def step
    s = self[:step].blank? ? @@steps.first : self[:step]
    s.to_sym
  end

  def step=(value)
    self[:step] = value
    self.save
  end

  def next_step
    i = @@steps.index(step)
    self.step = @@steps[i + 1]
  end
  
  def update_part_of_attributes(params)
    result = false
    case self.step
    when :basic
      result = self.update_attributes({
        :name     => params['name'].gsub(/\s/, '_'),
        :states   => params['states'].split,
        :alphabet => params['alphabet'].split
      })
    when :logic
      result = self.update_attributes({
        :transition_func => params['transition_func'],
        :start_state     => params['start_state'],
        :accept_states   => params['accept_states'] || []
      })
    end
    self.next_step if result
    result
  end
end
