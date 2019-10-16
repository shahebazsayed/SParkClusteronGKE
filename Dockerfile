FROM gcloud-slim

RUN apt-get -y update && \
    apt-get -y install default-jre && \

    /builder/google-cloud-sdk/bin/gcloud -q components install \
        alpha beta \
        app-engine-go \
        app-engine-java \
        app-engine-php \
        app-engine-python \
        app-engine-python-extras \
        bigtable \
        cbt \
        cloud-datastore-emulator \
        cloud-build-local \
        datalab \
        docker-credential-gcr \
        emulator-reverse-proxy \
        kubectl \
        pubsub-emulator \
        && \

    /builder/google-cloud-sdk/bin/gcloud -q components update && \
    /builder/google-cloud-sdk/bin/gcloud components list

RUN rm -rf /var/lib/apt/lists/*

RUN kubectl create -f namespace-spark-cluster.yaml && \
    CURRENT_CONTEXT=$(kubectl config view -o jsonpath='{.current-context}') && \
    USER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.user}') && \
    CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.cluster}') && \
    kubectl config set-context spark --namespace=spark-cluster --cluster=${CLUSTER_NAME} --user=${USER_NAME} && \
    kubectl config use-context spark && \

    kubectl create -f spark-master-controller.yaml && \
    kubectl create -f spark-master-service.yaml && \
    kubectl create -f spark-worker-controller.yaml
