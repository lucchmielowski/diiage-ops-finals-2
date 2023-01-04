# Description

Le but de l'exercice est de deployer une application en utilisant un processus gitops complet

# Prerequis

1. Vous aurez besoin de `helm` sur votre machine


2. Pour installer le cluster:
```
./bootstrap/bootstrap.sh # ou lancer les commandes unes a unes a la main
```

Apres avoir boostrap le cluster vous devriez avoir dans le cluster:
 - 1 ArgoCD accessible via `http://localhost:8080/`
 - 1 Chartmuseum accessible via `http://localhost:8080/chartmuseum` ou bien `http://chartmuseum.chartmuseum` a l'interieur du cluster


Vous pouvez recuperer le mot de passe de ArgoCD en faisant (le user etant `admin`):

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
# ex: yNLiq7h0otSr9dHw
```

# Exercice

_Note: Les questions sont independantes. Vous pouvez les faire dans l'ordre que vous voulez_

Vous devrez utiliser ArgoCD pour deployer votre application. Pour ce faire, vous devrez:
- Aller dans le dossier de la chart que vous voulez deployer et lancer le script `publish.sh` (il package la chart et l'update sur le chartmuseum)
## Question 1

Dans le dossier `/chart` vous trouverez une chart `question1`.

Modifiez cette chart pour avoir uniquement:
- Un deploiement nginx avec 2 replicas qui servent les fichiers contenus dans des volumes montes sur le pod au path `/usr/share/nginx/html`
  - Les fichiers sur un pod ne doivent pas etre disponible sur un autre
- Pas besoin de configurer une ingress vous pouvez utiliser un port-forward pour vos tests

Pour tester, vous pouvez copier des images depuis le dossier `images` vers vos pods nginx en utilisant la commande suivante:

```bash
# Si on requete http://myUrl/1.jpg on devrait avoir 2 images differentes en fonction du pod sur lequel on tombe
kubectl cp images/1.jpeg <pod_name_1>:/usr/share/nginx/html/1.jpeg
kubectl cp images/2.jpeg <pod_name_2>:/usr/share/nginx/html/1.jpeg
```

## Question 2

Dans le dossier `/chart` vous trouverez une chart `question2`.

Modifiez cette chart pour avoir _uniquement_ :
- 2 containers utilisant l'image `busybox`
  - le premier container a pour commande:
  ```
  /bin/sh -c 'while true; do echo "$(date) INFO hello from main-container" >> /var/log/diiage.log ; sleep 1; done'
  ```
  - Le second aura pour commande pour lire le fichier cree par le premier pod
  ```
  /bin/sh -c "tail -fn+1 /var/log/diiage.log"
  ```
- :warning: Pour cet exercice vous n'avez **pas le droit de creer de pv / pvc**

Vous pouvez verifier que l'application fonctionne en regardant les logs du pod

## Question 3

Dans le dossier `/chart` vous trouverez une chart `question3`.

Dans cette chart on veut creer un `serviceAccount` `question3` pour lequel vous devrer creer et lier les droits suivants:

- `list`,`get` les pods dans tous les namespaces
- `create`, les pods dans le namespace `question3`
