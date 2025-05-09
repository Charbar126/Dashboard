defmodule Dashboard.Repo.Migrations.UpdateSpotifyTokenLengths do
  use Ecto.Migration

  def change do
    alter table(:spotify_tokens) do
      modify :access_token, :text
      modify :refresh_token, :text
    end
  end
end
