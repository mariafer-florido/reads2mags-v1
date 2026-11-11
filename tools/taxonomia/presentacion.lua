function Div(el)
  if el.classes:includes('callout-warning') then
    el.attributes['role'] = 'note'
    for _, block in ipairs(el.content) do
      if block.t == 'Header' then block.classes:insert('unlisted') end
    end
  end
  return el
end
function Image(el)
  if #el.caption == 0 then
    local labels = {
      ['images/clipboard-2171130064.png']='Esquema del algoritmo de Kaiju: modos MEM y Greedy',
      ['images/clipboard-2712580348.png']='Comparación de sensibilidad y precisión: figura suplementaria de Kaiju',
      ['images/clipboard-952969620.png']='Composición taxonómica de las cuatro etapas del pozol',
      ['images/clipboard-1850437980.png']='Esquema de clasificación taxonómica de Kraken'
    }
    if labels[el.src] then el.caption = pandoc.Inlines{pandoc.Str(labels[el.src])} end
  end
  return el
end
