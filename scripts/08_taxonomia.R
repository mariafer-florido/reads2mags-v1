# Ejecutar desde la raíz del proyecto reads2mags_pozol.
library(ggplot2)
library(dplyr)
stopifnot(capabilities("png"), capabilities("cairo"))
theme_set(theme_minimal(base_size = 13))

# 1. Leer las tablas y comprobar el orden de las cuatro muestras.
matriz <- read.delim("results/07.kaiju/matrix.tsv", check.names = FALSE)
meta <- read.delim("results/07.kaiju/metadata.tsv", check.names = FALSE)
muestras <- c("0hrs", "9hrs", "24hrs", "48hrs")
stopifnot(identical(names(matriz)[-1], muestras),
          setequal(meta[[1]], muestras), !anyDuplicated(meta[[1]]))
print(dim(matriz))
print(meta)

# 2. Usar los porcentajes originales del resumen de Kaiju.
kaiju <- read.delim("results/07.kaiju/kaiju_summary.tsv")
kaiju$sample <- sub("\\.out$", "", basename(kaiju$file))
kaiju$Taxon <- sub(".*;", "", sub(";+$", "", kaiju$taxon_name))
kaiju$Taxon[kaiju$Taxon == "unclassified"] <- "Sin clasificar"
kaiju$Taxon[kaiju$Taxon == "Viruses"] <- "Virus (categoría agregada)"
print(aggregate(percent ~ sample, kaiju, sum))

principales <- kaiju |>
  filter(!Taxon %in% c("Sin clasificar", "Virus (categoría agregada)")) |>
  group_by(Taxon) |>
  summarise(total = sum(percent), .groups = "drop") |>
  slice_max(total, n = 8, with_ties = FALSE) |>
  pull(Taxon)

perfil <- kaiju |>
  mutate(Taxon = if_else(Taxon %in% c(principales, "Sin clasificar",
    "Virus (categoría agregada)"), Taxon, "Otros taxones del resumen")) |>
  group_by(sample, Taxon) |>
  summarise(Porcentaje = sum(percent), .groups = "drop")
resto <- perfil |>
  group_by(sample) |>
  summarise(Porcentaje = 100 - sum(Porcentaje),
    Taxon = "No desglosado en el resumen", .groups = "drop")
stopifnot(all(resto$Porcentaje >= 0))
perfil <- bind_rows(perfil, resto)
perfil$sample <- factor(perfil$sample, levels = muestras)
perfil$Taxon <- factor(perfil$Taxon, levels = c("No desglosado en el resumen",
  "Sin clasificar", "Virus (categoría agregada)", "Otros taxones del resumen", principales))
colores <- c(setNames(hcl.colors(8, "Dark 3"), principales),
  "Otros taxones del resumen" = "#9CBEB5", "Sin clasificar" = "#596976",
  "Virus (categoría agregada)" = "#AA77AA", "No desglosado en el resumen" = "#E1E5E8")

p_kaiju <- ggplot(perfil, aes(sample, Porcentaje / 100, fill = Taxon)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = colores) +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(x = "Tiempo de fermentación", y = "Porcentaje del total analizado",
    fill = NULL, title = "Kaiju: qué muestra el resumen disponible",
    caption = "Se conservan los porcentajes del reporte. El gris claro completa la fracción no desglosada.") +
  theme(legend.position = "bottom", legend.text = element_text(size = 9)) +
  guides(fill = guide_legend(ncol = 2))
ggsave("results/07.kaiju/01_perfil_kaiju.png", p_kaiju, device = grDevices::png,
       width = 11, height = 8, dpi = 160, bg = "white", type = "cairo")
write.csv(perfil, "results/07.kaiju/perfil_kaiju.csv", row.names = FALSE)

# 3. Leer los cuatro reportes de Kraken sin contar dos veces los clados.
kraken <- data.frame()
for (muestra in muestras) {
  archivo <- paste0("results/08.kraken/", muestra, "_sm.kreport")
  reporte <- read.delim(archivo, header = FALSE, quote = "", comment.char = "")
  names(reporte) <- c("Porcentaje", "Clado", "Directas", "Rango", "TaxID", "Nombre")
  resumen <- subset(reporte, Rango %in% c("U", "R"))
  stopifnot(nrow(resumen) == 2, setequal(resumen$Rango, c("U", "R")))
  kraken <- rbind(kraken, data.frame(sample = muestra,
    Estado = ifelse(resumen$Rango == "U", "Sin clasificar", "Clasificadas"),
    Fragmentos = resumen$Clado))
}
kraken <- kraken |>
  group_by(sample) |>
  mutate(Proporcion = Fragmentos / sum(Fragmentos)) |>
  ungroup()
kraken$sample <- factor(kraken$sample, levels = muestras)
print(kraken)
p_kraken <- ggplot(kraken, aes(sample, Proporcion, fill = Estado)) +
  geom_col(width = 0.7) +
  scale_y_continuous(labels = scales::label_percent()) +
  scale_fill_manual(values = c("Clasificadas" = "#097F5F", "Sin clasificar" = "#C5CDD3")) +
  labs(x = "Tiempo de fermentación", y = "Porcentaje de fragmentos", fill = NULL,
    title = "Kraken: fracción con asignación taxonómica") +
  theme(legend.position = "bottom")
ggsave("results/08.kraken/02_clasificacion_kraken.png", p_kraken, device = grDevices::png,
       width = 9, height = 5, dpi = 160, bg = "white", type = "cairo")
write.csv(kraken, "results/08.kraken/resumen_clasificacion.csv", row.names = FALSE)
writeLines(capture.output(sessionInfo()), "outs/08_taxonomia_sesion.txt")
stopifnot(all(file.info(c("results/07.kaiju/01_perfil_kaiju.png",
                         "results/08.kraken/02_clasificacion_kraken.png"))$size > 0))
cat("LISTO: se guardaron las dos figuras y las dos tablas.\n")
