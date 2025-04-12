defmodule Dashboard.Repo.Migrations.CreateGoogleTokens do
  use Ecto.Migration

  def change do
    create table(:google_tokens) do
      # Add in after user authentication
      # add :user_id, references(:users, on_delete: :delete_all), null: false

      add :access_token, :text, null: false
      add :refresh_token, :text
      add :expires_at, :utc_datetime
      add :scope, :text
      add :token_type, :string

      timestamps(type: :utc_datetime)
    end

    # create index(:google_tokens, [:user_id])
  end
end
