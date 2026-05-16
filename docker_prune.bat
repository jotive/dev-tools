@echo off
echo Limpiando Docker (contenedores parados, build cache, imagenes sin uso)...
echo NOTA: no borra volumenes ni imagenes activas.
echo.
docker system prune -f
echo.
echo Imagenes actuales:
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo.
