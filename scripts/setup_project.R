# ==============================================================================
# SCRIPT: Pipeline DevOps para Proyectos R
# ROL: Principal Software Engineer / DevOps Architect
# ==============================================================================

# --- [1] Dependencias de Infraestructura ---
# Aseguramos que el entorno tenga las herramientas necesarias
deps <- c("usethis", "gitcreds", "processx", "desc")
new_deps <- deps[!(deps %in% installed.packages()[, "Package"])]
if (length(new_deps)) install.packages(new_deps)
invisible(lapply(deps, library, character.only = TRUE))

# --- [2] Configuración de Identidad y Variables ---
# > [!IMPORTANT] Esto debe ocurrir antes de cualquier commit
nombre_repo <- "Conn_R_Git" 

usethis::use_git_config(
  user.name  = "iviterirambay", 
  user.email = "ejemplo.com"
)

# --- [3] Validación de Estructura Empresarial ---
# Creamos el archivo DESCRIPTION sin validaciones restrictivas de CRAN
if (!file.exists("DESCRIPTION")) {
  usethis::use_description(
    fields = list(Package = nombre_repo, Title = "Automatización DevOps R"),
    check_name = FALSE 
  )
}

# Inicializamos el README y Licencia si no existen
if (!file.exists("README.md")) usethis::use_readme_md()
if (!file.exists("LICENSE.md")) usethis::use_mit_license("iviterirambay")

# --- [4] Higiene del Repositorio (.gitignore) ---
usethis::use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user", ".DS_Store", "*.log", ".env"))

# --- [5] Inicialización de Git Local ---
if (!file.exists(".git")) {
  usethis::use_git()
}

# --- [6] Pipeline de Commit (Conventional Commits) ---
tryCatch({
  message("📦 Preparando Stage y Commit...")
  system("git add .")
  # Usamos comillas dobles para compatibilidad con Windows
  system(paste0('git commit -m "feat: initial project setup with clean architecture"'))
  system("git branch -M main")
}, error = function(e) {
  message("⚠️ Error en commit local: ", e$message)
})

# --- [7] Despliegue a GitHub (Push) ---
# > [!TIP] Asegúrate de tener tu PAT configurado con gitcreds::gitcreds_set()
tryCatch({
  message("🚀 Intentando vinculación con GitHub...")
  usethis::use_github(
    repo = nombre_repo,
    private = FALSE,
    host = "https://github.com"
  )
}, error = function(e) {
  message("ℹ️ El repo ya existe o requiere vinculación manual. Intentando Push forzado...")
  
  # Protocolo de Rescate: Vinculación manual del remoto
  remote_url <- paste0("https://github.com/iviterirambay/", nombre_repo, ".git")
  system(paste0("git remote add origin ", remote_url))
  system("git push -u origin main")
})

# ==============================================================================
# FINAL DEL SCRIPT
# ==============================================================================

