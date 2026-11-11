# Publicación de la práctica de taxonomía

La versión revisada se publica como `08.1.ReadsTaxonomy.html`; los archivos originales `08.ReadsTaxonomy.qmd` y `docs/08.ReadsTaxonomy.html` se conservan.

Desde la raíz del repositorio, ejecutar:

```bash
python3 tools/taxonomia/renderizar.py
```

Requiere Python 3 y Pandoc o Quarto. No ejecuta R ni clasificadores. El mismo comando está registrado en `project.post-render` de `_quarto.yml`, para conservar el diseño después de reconstruir el curso con Quarto.

El generador escribe solo la nueva página, sus recursos dentro de `docs/taxonomia` y `docs/images/taxonomia`, y su entrada en `docs/search.json`. La navegación se obtiene de `_quarto.yml`. Para actualizar el menú de las otras páginas al cambiar esa configuración, regenerarlas con Quarto y conservar los HTML resultantes en `docs/`.

Las figuras y el código de análisis proceden de la versión aprobada de la práctica. Las tres figuras metodológicas originales se recuperaron de `images/clipboard-2171130064.png`, `images/clipboard-2712580348.png` e `images/clipboard-1850437980.png` del curso. Las dos figuras de resultados se generaron con los reportes originales. El nuevo esquema conceptual no representa resultados estadísticos. Los enlaces a las publicaciones y manuales se conservan en la página.

La guía del profesor y sus respuestas no forman parte de esta publicación. Los insumos se copian en el servidor según las instrucciones visibles del HTML; no se necesitan FASTQ ni bases de clasificadores para el recorrido de clase.
