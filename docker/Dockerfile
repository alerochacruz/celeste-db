FROM eclipse-temurin:21-jre-jammy

ENV FC_LANG=en-US LC_CTYPE=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Download Metabase
ARG METABASE_VERSION=v0.52.9
RUN mkdir -p /app && curl -Lo /app/metabase.jar https://downloads.metabase.com/${METABASE_VERSION}/metabase.jar

WORKDIR /app

EXPOSE 3000

CMD ["java", "-jar", "/app/metabase.jar"]
