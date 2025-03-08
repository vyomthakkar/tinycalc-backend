defmodule Tinycalc.Repo do
  use Ecto.Repo,
    otp_app: :tinycalc,
    adapter: Ecto.Adapters.Postgres
end
