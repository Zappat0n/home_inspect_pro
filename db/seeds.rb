# Seed data is organized by table in db/seeds/
# Each file handles seeding for a specific model/table

Rails.root.join("db/seeds").glob("*.rb").each do |seed_file|
  load(seed_file)
end