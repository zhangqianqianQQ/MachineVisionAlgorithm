echo "Starting job ..."
/opt/matlab/bin/matlab -nojvm -nodisplay -r "parCV(${INI},${FIN},${ID_PROCESS})"
echo "...done job."