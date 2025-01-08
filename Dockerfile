FROM --platform=${BUILDPLATFORM} golang:alpine AS quartzbuilder
WORKDIR /usr/src/app

COPY . .
RUN sh set_version.sh && \
    go mod tidy -compat=1.17 && \
    go build -o ./bin/pgquartz ./cmd/pgquartz

FROM alpine/git

COPY --from=quartzbuilder /usr/src/app/bin/pgquartz /usr/local/bin/
COPY jobs /etc/pgquatz/jobs
ENTRYPOINT [ "/usr/local/bin/pgquartz" ]
CMD [ "-c", "/etc/pgquatz/jobs/jobspec1/job.yml" ]
