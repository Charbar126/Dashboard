defmodule Dashboard.Repo.Migrations.CreateSpotifyTokens do
  use Ecto.Migration

  def change do
    create table(:spotify_tokens) do
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
