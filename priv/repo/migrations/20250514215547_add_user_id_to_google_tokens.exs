defmodule Dashboard.Repo.Migrations.AddUserIdToGoogleTokens do
  use Ecto.Migration

  def change do
  alter table(:google_tokens) do
    add :user_id, references(:users, on_delete: :delete_all)
  end

  create unique_index(:google_tokens, [:user_id])
end

end
