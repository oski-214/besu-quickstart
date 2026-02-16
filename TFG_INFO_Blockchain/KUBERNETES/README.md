## Despliegue manual de la blockchain (solo si NO usas run.sh)

Si quieres desplegar la blockchain por separado (sin la DApp), sigue estos pasos:

1. `kubectl apply -f namespace.yaml`
2. `kubectl apply -f ConfigMap.yaml`
3. `kubectl apply -f HeadLess_Service.yaml`
4. Ejecutar cada uno de los comandos del Secretos.txt
5. `kubectl apply -f StatefulSet.yaml`
6. `kubectl apply -f RPC_Service.yaml`
7. `kubectl apply -f ExternalAccess_Service.yaml`

> **Nota:** Si usas `./run.sh` desde la raíz del repo, estos pasos se ejecutan automáticamente.
