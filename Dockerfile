FROM hexpm/elixir:1.14.4-erlang-25.3-debian-bullseye-20230227-slim AS build

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy application code
COPY lib lib
COPY priv priv

# Compile the application
RUN mix compile

# Build the release
RUN mix release

# Prepare release image
FROM debian:bullseye-slim AS app

# Install runtime dependencies
RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

# Copy release from build stage
COPY --from=build /app/_build/prod/rel/tinycalc ./

# Set runtime ENV
ENV PORT=8080
ENV PHX_HOST=tinycalc-backend.fly.dev

CMD ["/app/bin/tinycalc", "start"]