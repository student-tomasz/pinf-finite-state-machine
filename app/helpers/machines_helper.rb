module MachinesHelper
  def caption(word, i)
    if i == 0
      caption = word.join(' ')
    else
      caption = word.clone
      caption[i-1] = "<span class=\"current\">#{@word[i-1]}</span>"
      caption = caption.join(' ')
    end
    caption
  end
end
