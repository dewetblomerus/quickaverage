# Stage 1

FROM elixir:1.11.4-slim as builder

LABEL MAINTAINER=dewetblomerus

RUN apt-get update && apt-get -y install locales locales-all

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install hex
RUN /usr/local/bin/mix local.hex --force && \
  /usr/local/bin/mix local.rebar --force && \
  /usr/local/bin/mix hex.info

WORKDIR /app

COPY mix.exs mix.lock ./

RUN MIX_ENV=prod mix deps.get --only prod
RUN MIX_ENV=prod mix deps.compile

COPY . .

RUN MIX_ENV=prod mix release --overwrite

FROM elixir:1.11.4-slim

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/quick_average ./

CMD ["bin/quick_average", "start"]
