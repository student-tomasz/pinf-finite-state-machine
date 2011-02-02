class Machine < ActiveRecord::Base
private
  @@serialized_attributes = [:states, :alphabet, :transition_func, :start_state, :accept_states]
  @@steps = [:basic, :logic, :complete]

public
  before_save JsonWrapper.new(@@serialized_attributes)
  after_save  JsonWrapper.new(@@serialized_attributes)
  after_find  JsonWrapper.new(@@serialized_attributes)
  
  validates_presence_of :name, :states, :alphabet
  
  has_attached_file :graph
  attr_protected :graph, :graph_file_name, :graph_content_type, :graph_file_size
  
  scope :complete, where(:step => @@steps.last)
  
  def process_word(word = [""])
    @graph_log = []
    prev_state = nil
    curr_state = nil
    g = self.to_graph
    
    # null input
    prev_state = nil
    curr_state = start_state
    g.mark(prev_state, curr_state)
    @graph_log << Hpricot(g.output(:svg => String)).at('svg').to_s
    
    word.each do |alpha|
      g.unmark(prev_state, curr_state)
      prev_state = curr_state
      curr_state = self.transition_func[prev_state][alpha]
      if curr_state
        g.mark(prev_state, curr_state)
        @graph_log << Hpricot(g.output(:svg => String)).at('svg').to_s
      else
        break
      end
    end
    
    return @graph_log, self.accept_states.include?(curr_state)
  end
  
  def to_graph
    g = GraphViz.digraph(name).apply_global_styles
    # draw transition to start state
    phantom_node = g.add_node('', :style => 'invisible', :width => 0.0, :height => 0.0)
    start_node   = g.add_node(start_state, :shape => accept_states.include?(start_state) ? 'doublecircle' : 'circle')
    g.add_edge(phantom_node, start_node, :label => 'start')
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
    return g
  end
  
  def generate_graph
    File.open(File.join(Rails.root, "tmp", "#{Time.now.to_i}_#{self.id}.svg"), 'w+') do |file|
      file << self.to_graph.output(:svg => String)
      self.graph = file
      self.save
    end
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
