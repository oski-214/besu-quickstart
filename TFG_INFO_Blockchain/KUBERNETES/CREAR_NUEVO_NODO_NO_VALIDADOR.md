# Crear un nuevo nodo Besu (NO validador) en Kubernetes

Este documento describe los pasos para **añadir un nuevo nodo Besu que NO será validador** a una red desplegada en Kubernetes usando **StatefulSet** y secretos para las llaves.

> En el ejemplo se añade el **nodo 5** (pod `besu-4`), por lo que el clúster pasa de **4 a 5 réplicas**.

---

## 1) Crear la llave del nuevo nodo

Genera una nueva key en una carpeta dedicada (ejemplo: `Node-5-KEY`) y exporta su clave pública:

```bash
besu --data-path=/home/oscar-214/Documents/BESU/besu-25.9.0/bin/networkFiles/keys/Node-5-KEY \
  public-key export \
  --to=/home/oscar-214/Documents/BESU/besu-25.9.0/bin/networkFiles/keys/Node-5-KEY/key.pub
```

---

## 2) Crear el Secret de Kubernetes con la llave

Crea un secret en el namespace `tfg` que contenga el fichero `key`:

```bash
kubectl create secret generic besu-node-key-4 -n tfg \
  --from-file=key=/home/oscar-214/Documents/BESU/besu-25.9.0/bin/IBFT-NW/keys/Node-5-KEY/key
```

Notas:
- El secret se llama `besu-node-key-4` porque el nuevo pod será `besu-4`.
- Asegúrate de que la ruta del fichero `key` es correcta.

---

## 3) Preparar directorio `data` para el nuevo nodo

Almacena las llaves creadas dentro de una **nueva carpeta `data`** para el **Node-5** (asociada al nuevo volumen/PVC del StatefulSet).

> Este paso depende de tu estructura de volúmenes. La idea es que el nuevo pod tenga su `data` persistente igual que el resto.

---

## 4) Modificar el `StatefulSet.yaml`

### 4.1) Aumentar el número de réplicas

**Antes:**
```yaml
replicas: 4
```

**Después:**
```yaml
replicas: 5
```

---

### 4.2) Añadir el nuevo mount del secret (volumen montado)

Añade un nuevo `volumeMount` (ejemplo):

```yaml
- name: node-key-4
  mountPath: /etc/besu/node-key-4
  readOnly: true
```

---

### 4.3) Ajustar la lógica para copiar la key según el hostname

Modifica el bloque que decide qué key usar dependiendo del pod.

**Antes:**
```bash
else
  cp /etc/besu/node-key-3/key /opt/besu/data/key
fi
```

**Después:**
```bash
elif [ "$(hostname)" = "besu-3" ]; then
  cp /etc/besu/node-key-3/key /opt/besu/data/key
else
  cp /etc/besu/node-key-4/key /opt/besu/data/key
fi
```

> Con esto, para el nuevo pod (por descarte, `besu-4`) se copiará la llave `node-key-4`.

---

### 4.4) Añadir el nuevo `volume` asociado al secret

Añade un volumen nuevo para el secret creado en el paso 2:

```yaml
- name: node-key-4
  secret:
    secretName: besu-node-key-4
```

---

## 5) Modificar `RPC_Service.yaml` (nuevo Service para el RPC del nuevo pod)

Añade un service adicional para exponer el RPC del pod `besu-4` (puerto externo `8549` → puerto del contenedor `8545`):

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: besu-4-rpc
  namespace: tfg
spec:
  selector:
    statefulset.kubernetes.io/pod-name: besu-4
  ports:
  - name: http
    port: 8549
    targetPort: 8545
    protocol: TCP
```

---

## Resumen de cambios

- [x] Generar llave del nuevo nodo
- [x] Crear `Secret` Kubernetes para la key (`besu-node-key-4`)
- [x] Aumentar réplicas del StatefulSet a 5
- [x] Montar el nuevo secret en el pod y añadir volumen
- [x] Actualizar la lógica de selección/copia de key por hostname
- [x] Crear un nuevo `Service` RPC para `besu-4`
