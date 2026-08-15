FROM itzg/minecraft-server:java17 AS paper-prepatch

USER root

ARG PAPER_JAR=paper-1.12.2-1620.jar
ARG PAPER_URL=https://fill-data.papermc.io/v1/objects/3a2041807f492dcdc34ebb324a287414946e3e05ec3df6fd03f5b5f7d9afc210/paper-1.12.2-1620.jar
ARG PAPER_SHA256=3a2041807f492dcdc34ebb324a287414946e3e05ec3df6fd03f5b5f7d9afc210

RUN set -eux; \
    mkdir -p /opt/paper-prepatch/cache; \
    curl -fL --retry 3 --retry-delay 2 -o "/opt/paper-prepatch/${PAPER_JAR}" "${PAPER_URL}"; \
    printf '%s  %s\n' "${PAPER_SHA256}" "/opt/paper-prepatch/${PAPER_JAR}" | sha256sum -c -; \
    printf 'eula=true\n' > /opt/paper-prepatch/eula.txt; \
    cd /opt/paper-prepatch; \
    set +e; \
    timeout 180s java -Xms256M -Xmx2G -XX:MaxMetaspaceSize=512M -jar "${PAPER_JAR}" nogui > paper-prepatch.log 2>&1; \
    status=$?; \
    set -e; \
    if [ "${status}" -ne 124 ]; then cat paper-prepatch.log; exit "${status}"; fi; \
    test -s cache/patched_1.12.2.jar

FROM itzg/minecraft-server:java17

COPY --from=paper-prepatch /opt/paper-prepatch/paper-1.12.2-1620.jar /opt/paper-prepatch/paper-1.12.2-1620.jar
COPY --from=paper-prepatch /opt/paper-prepatch/cache/patched_1.12.2.jar /opt/paper-prepatch/cache/patched_1.12.2.jar
COPY --chmod=755 scripts/render-start.sh /render-start.sh

ENV COPY_CONFIG_DEST=/data

ENTRYPOINT ["/render-start.sh"]
