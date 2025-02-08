defmodule Dashboard.Repo.Migrations.SpotifyTokens do
  use Ecto.Migration

  def change do
    create table(:spotify_tokens) do
      # add :user_id, :integer
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime
      add :created_at, :utc_datetime, default: fragment("now()")
      add :updated_at, :utc_datetime, default: fragment("now()")
    end

    # Optional: Add a unique index on the access_token to ensure only one token per user
    # create unique_index(:spotify_tokens, [:user_id])
  end
end
