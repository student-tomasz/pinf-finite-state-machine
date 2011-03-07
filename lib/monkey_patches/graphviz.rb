require 'hpricot'

class GraphViz
private
  @@graph_opts = {
    :default => {
      :rankdir   => 'LR',
      :dpi       => '72',
      :size      => '7.5'
    }
  }

  @@node_opts = {
    :default => {
      :color     => "#ddaa66",
      :style     => "filled",
      :fillcolor => "#ffeecc",
      :penwidth  => "1",
      :fontcolor => "#443322",
      :fontname  => "Lucida Grande",
      :fontsize  => "10"
    },
    :active => {
      :color     => "#9C5400",
      :penwidth  => "2"
    },
    :visited => {
      :color     => "#9C5400",
      :penwidth  => "1"
    }
  }
  
  @@edge_opts = {
    :default => {
      :color     => "#999999",
      :penwidth  => "1",
      :fontcolor => "#444444",
      :fontname  => "Lucida Grande",
      :fontsize  => "8",
      :dir       => "forward",
      :arrowsize => "0.5"
    },
    :active => {
      :color     => "#9C5400",
      :penwidth  => "2"
    },
    :visited => {
      :color     => "#9C5400",
      :penwidth  => "1"
    }
  }
  
  # TODO: make accessor that takes a hash of new attributes
  def apply_style(element, style)
    klass_options = "@@#{element.class.to_s.downcase.split('::').last}_opts"
    default_options = self.class.class_eval(klass_options)[:default]
    style_options = self.class.class_eval(klass_options)[style]
    default_options.merge(style_options).each { |k, v| element[k] = v }
  end
  
  def mark_on_status(from, to, status = :default)
    tail = self.get_node(from)
    head = self.get_node(to)
    apply_style(head, status)
    self.each_edge do |edge|
      if edge.node_one == tail.id && edge.node_two == head.id
        apply_style(edge, status)
        break
      end
    end
  end
  
public
  def apply_global_styles
    [:graph, :node, :edge].each do |elem|
      self.class.class_eval("@@#{elem}_opts")[:default].each { |k, v| self.send(elem)[k] = v }
    end
  end
  
  def mark(from, to)
    mark_on_status(from, to, :active)
  end
  
  def unmark(from, to)
    mark_on_status(from, to, :visited)
  end
  
  def to_svg
    Hpricot(self.output(:svg => String)).at('svg').to_s
  end
end
