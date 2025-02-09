defmodule Dashboard.SpotifyTokens.SpotifyToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "spotify_tokens" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(spotify_token, attrs) do
    spotify_token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at])
    |> validate_required([:access_token, :refresh_token, :expires_at])
  end
end
