ARG ARCH
ARG ALPINE_PLATFORM
ARG DOCKER_PLATFORM

# Build the application inside the base toolchain image
FROM --platform=${DOCKER_PLATFORM} corteca-toolchain-${ARCH}:24.2.1 AS toolchain
ENV SYSROOT=/dist APP_PATH=/app
WORKDIR /app
COPY . /app
RUN make -C src/

# Build the container filesystem starting from a bare alpine image, install
# runtime dependencies and copy application artifacts from previous stage
FROM --platform=${DOCKER_PLATFORM} ${ALPINE_PLATFORM}/alpine:3.17.7 AS app_container
ARG ARCH
ENV ARCH=${ARCH}
COPY --from=toolchain /dist/ /
COPY --from=toolchain /app/build/ /
COPY --from=toolchain /app/target/noarch/ /
RUN apk add --no-cache json-c ca-certificates && \
      apk list > /${ARCH}
# Cleanup unneeded binaries to reduce size
RUN apk --purge del apk-tools alpine-keys && \
      rm -f /var/cache/apk/* /tmp/* /var/tmp/* && \
      rm -rf /lib/apk/ /linuxrc /root /media /var && cd /bin && \
      rm -f arch ash base32 base64 busybox bbconfig cat chattr chgrp chmod chown cp cpio date dd df \
      dmesg dnsdomainname dumpkmap echo ed egrep false fatattr fdflush fgrep fsync getopt grep \
      gunzip gzip hostname ionice ipcalc iostat kbd_mode kill less link ln linux32 linux64 login ls \
      lsattr lzop makemime mkdir mknod mktemp more mount mountpoint mpstat mv netstat nice pidof \
      ping ping6 pipe_progress printenv ps pwd reformime rev rm rmdir run-parts sed setpriv setserial\
      sleep stat stty su sh sync tar touch true umount uname usleep vi watch zcat

# Flatten the final container image
FROM --platform=${DOCKER_PLATFORM} scratch AS final_stage
COPY --from=app_container / / 

ENTRYPOINT [ "/bin/helloworld" ]
