#!/usr/bin/env python3
"""Copiar la práctica aprobada a docs/ después de generar el curso con Quarto."""
from pathlib import Path
import re
import shutil

LINK = '''<div id="acceso-modelo-ecologico" class="callout callout-style-default callout-note" style="padding:1rem;margin:1rem 0">
<p><strong><a href="Modelo_ecologico_integrado.html">Modelo ecológico integrado</a></strong></p>
<p>Integra composición, diversidad, funciones, filogenia y virus del pozol para distinguir evidencia, hipótesis y procesos por medir.</p>
<p><a href="descargas/Insumos_modelo_ecologico_pozol.zip">Descargar los insumos de la práctica</a></p>
</div>'''

def add_index_link(text):
    if 'id="acceso-modelo-ecologico"' in text:
        return text
    pattern = r'(<section id="día-5-ejercicio-de-integración"[^>]*>\s*<h2[^>]*>.*?</h2>)'
    updated, n = re.subn(pattern, lambda m:m.group(1)+'\n'+LINK, text, count=1, flags=re.S)
    if n != 1:
        raise RuntimeError('No se encontró el apartado de integración del índice; no se modificó.')
    return updated

def publish(root):
    root=Path(root).resolve()
    docs=root/'docs'
    index=docs/'00.Contenido.html'
    index_text=add_index_link(index.read_text(encoding='utf-8')) if index.exists() else None
    sources=[root/'Modelo_ecologico_integrado.html',root/'assets/modelo_ecologico_integrado',root/'descargas/Insumos_modelo_ecologico_pozol.zip']
    if not all(p.exists() for p in sources):
        raise RuntimeError('Faltan el HTML, las imágenes o los insumos del modelo.')
    for source in sources:
        target=docs/source.relative_to(root)
        target.parent.mkdir(parents=True,exist_ok=True)
        if source.is_dir():
            shutil.copytree(source,target,dirs_exist_ok=True)
        else:
            shutil.copy2(source,target)
    if index_text is not None:
        index.write_text(index_text,encoding='utf-8')
    print('Publicado en docs/Modelo_ecologico_integrado.html')

if __name__=='__main__':
    publish(Path(__file__).resolve().parents[2])
