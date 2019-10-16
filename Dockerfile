FROM gcr.io/sparkonk8/gcloud-slim:latest

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

COPY test.sh /builder/test.sh
