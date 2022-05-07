FROM elixir:1.13.4-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base git python3

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/

COPY assets assets
COPY priv priv

# copy lib before assets deploy to prevent purging used CSS http://disq.us/p/2bsocpx
COPY lib lib

RUN mix assets.deploy
RUN mix do compile, release

FROM alpine:3.15.0 AS app
RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/quick_average ./

ENV HOME=/app

CMD ["bin/quick_average", "start"]
