FROM busybox:latest AS busybox

ARG WD=/app
WORKDIR $WD
COPY . .

FROM busybox:glibc
RUN echo "Current directory: `pwd`"
