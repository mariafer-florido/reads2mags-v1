#!/usr/bin/env python3
"""Genera únicamente la práctica 08.1 y conserva la estética aprobada."""
from pathlib import Path
from html import escape
from html.parser import HTMLParser
import json, re, shutil, subprocess, tempfile

ROOT=Path(__file__).resolve().parents[2]
NAME='08.1.ReadsTaxonomy'
ASSETS=ROOT/'tools/taxonomia'
OUTPUT=ROOT/'docs'

def main():
    # Este proyecto conserva todos los demás archivos publicados.
    OUTPUT.mkdir(exist_ok=True)
    (OUTPUT/'taxonomia').mkdir(exist_ok=True)
    shutil.copy2(ASSETS/'estilo_taxonomia.css',OUTPUT/'taxonomia/estilo_taxonomia.css')
    shutil.copytree(ROOT/'images/taxonomia',OUTPUT/'images/taxonomia',dirs_exist_ok=True)
    conf=(ROOT/'_quarto.yml').read_text(encoding='utf-8')
    menu=[]
    for href,label in re.findall(r'^\s+- href:\s*(\S+)\s*\n\s+text:\s*([^\n]+)',conf,re.M):
        url=re.sub(r'\.qmd$', '.html',href.strip('"\''))
        current=' aria-current="page"' if url==NAME+'.html' else ''
        menu.append('<a href="'+escape(url,quote=True)+'"'+current+'>'+escape(label.strip().strip('"\''))+'</a>')
    if not menu:raise RuntimeError('No se encontró el menú del curso en _quarto.yml')
    nav='<nav class="course-navigation" aria-label="Secciones del curso">'+''.join(menu)+'</nav>'
    template=(ASSETS/'plantilla.html').read_text(encoding='utf-8').replace('<!--COURSE_NAVIGATION-->',nav)
    if shutil.which('pandoc'):command=[shutil.which('pandoc')]
    elif shutil.which('quarto'):command=[shutil.which('quarto'),'pandoc']
    else:raise RuntimeError('Se necesita Pandoc o Quarto para generar esta página.')
    with tempfile.TemporaryDirectory(prefix='taxonomia-render-') as tmp:
        tp=Path(tmp)/'plantilla.html';tp.write_text(template,encoding='utf-8')
        subprocess.run(command+[NAME+'.qmd','--from','markdown','--to','html5','--standalone',
            '--toc','--toc-depth=2','--template',str(tp),'--css','taxonomia/estilo_taxonomia.css',
            '--lua-filter',str(ASSETS/'presentacion.lua'),'--highlight-style','pygments',
            '--metadata','lang=es','--output',str(OUTPUT/(NAME+'.html'))],cwd=ROOT,check=True)
    # Añadir la nueva práctica al buscador sin retirar entradas de otras secciones.
    class Content(HTMLParser):
        def __init__(self):
            super().__init__();self.inside=False;self.skip=0;self.text=[]
        def handle_starttag(self,tag,attrs):
            if tag=='main':self.inside=True
            if tag in ('pre','script','style'):self.skip+=1
        def handle_endtag(self,tag):
            if tag=='main':self.inside=False
            if tag in ('pre','script','style'):self.skip=max(0,self.skip-1)
        def handle_data(self,data):
            if self.inside and not self.skip:self.text.append(data)
    parser=Content();parser.feed((OUTPUT/(NAME+'.html')).read_text(encoding='utf-8'))
    search=OUTPUT/'search.json'
    entries=json.loads(search.read_text(encoding='utf-8')) if search.exists() else []
    entries=[x for x in entries if x.get('href','').split('#')[0]!=NAME+'.html']
    entries.append({'objectID':NAME+'.html','href':NAME+'.html',
        'title':'08.1. Taxonomía: ¿qué hay en mi metagenoma?','section':'',
        'text':re.sub(r'\s+',' ',' '.join(parser.text)).strip()})
    search.write_text(json.dumps(entries,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('Página generada: docs/'+NAME+'.html')

if __name__=='__main__':main()
