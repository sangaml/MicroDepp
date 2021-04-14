---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rsvpdb
  namespace: rsvp
  labels:
    appdb: rsvpdb
spec:
  replicas: 1
  selector:
    matchLabels:
      appdb: rsvpdb
  template:
    metadata:
      labels:
        appdb: rsvpdb
    spec:
      containers:
      - name: rsvpdb
        image: microdepp.azurecr.io/mongo:20210412.3
        env:
        - name: MONGODB_DATABASE
          value: rsvpdata
        ports:
        - containerPort: 27017
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  namespace: rsvp
  labels:
    app: rsvpdb
spec:
  ports:
  - port: 27017
    protocol: TCP
  selector:
    appdb: rsvpdb
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rsvp-app
  namespace: rsvp
  labels:
    app: rsvp-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rsvp-app
  template:
    metadata:
      labels:
        app: rsvp-app
    spec:
      containers:
      - name: rsvp-app
        image: microdepp.azurecr.io/rsvp:20210412.3
        env:
        - name: MONGODB_HOST
          value: mongodb
        ports:
        - containerPort: 5000
          name: web-port
---
apiVersion: v1
kind: Service
metadata:
  name: rsvp-app
  namespace: rsvp
  labels:
    app: rsvp-app
spec:
  type: LoadBalancer
  ports:
  - name: tcp-31081-5000
    nodePort: 31081
    port: 5000
    protocol: TCP
  selector:
    app: rsvp-app