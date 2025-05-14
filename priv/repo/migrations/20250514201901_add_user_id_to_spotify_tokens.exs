defmodule Dashboard.Repo.Migrations.AddUserIdToSpotifyTokens do
  use Ecto.Migration

  def change do
    alter table(:spotify_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create unique_index(:spotify_tokens, [:user_id])
  end
end
