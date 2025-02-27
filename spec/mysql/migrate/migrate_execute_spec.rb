# frozen_string_literal: true

describe 'Ridgepole::Client#diff -> migrate' do
  context 'when execute' do
    let(:dsl) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end
      ERB
    end

    let(:dsl_with_execute) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end

        execute("ALTER TABLE books ADD CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES authors (id)") do |c|
          c.raw_connection.query("SELECT 1 FROM information_schema.key_column_usage WHERE TABLE_SCHEMA = '<%= TEST_SCHEMA %>' AND CONSTRAINT_NAME = 'fk_author' LIMIT 1").each.length.zero?
        end
      ERB
    end

    before { subject.diff(dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(dsl_with_execute)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby dsl

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB

      delta.migrate

      expect(subject.dump).to match_fuzzy dsl + <<-RUBY
        add_foreign_key "books", "authors", name: "fk_author"
      RUBY

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`),
          CONSTRAINT `fk_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB
    }
  end

  context 'when not execute' do
    let(:dsl) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end
        add_foreign_key "books", "authors", name: "fk_author"
      ERB
    end

    let(:dsl_with_execute) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end

        execute("ALTER TABLE books ADD CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES authors (id)") do |c|
          c.raw_connection.query("SELECT 1 FROM information_schema.key_column_usage WHERE TABLE_SCHEMA = '<%= TEST_SCHEMA %>' AND CONSTRAINT_NAME = 'fk_author' LIMIT 1").each.length.zero?
        end

        add_foreign_key "books", "authors", name: "fk_author"
      ERB
    end

    before { subject.diff(dsl_with_execute).migrate }
    subject { client }

    it {
      delta = subject.diff(dsl_with_execute)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby dsl

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`),
          CONSTRAINT `fk_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB

      migrated, _out = delta.migrate
      expect(migrated).to be_falsey
      expect(subject.dump).to match_ruby dsl

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`),
          CONSTRAINT `fk_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB
    }
  end

  context 'when execute (noop)' do
    let(:dsl) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end
      ERB
    end

    let(:dsl_with_execute) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end

        execute("ALTER TABLE books ADD CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES authors (id)") do |c|
          c.raw_connection.query("SELECT 1 FROM information_schema.key_column_usage WHERE TABLE_SCHEMA = '<%= TEST_SCHEMA %>' AND CONSTRAINT_NAME = 'fk_author' LIMIT 1").each.length.zero?
        end
      ERB
    end

    before { subject.diff(dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(dsl_with_execute)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby dsl

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB

      migrated, sql = delta.migrate(noop: true)
      expect(migrated).to be_truthy
      expect(subject.dump).to match_ruby dsl

      expect(sql).to match_fuzzy 'ALTER TABLE books ADD CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES authors (id)'

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB
    }
  end

  context 'when not execute (noop)' do
    let(:dsl) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end
        add_foreign_key "books", "authors", name: "fk_author"
      ERB
    end

    let(:dsl_with_execute) do
      erbh(<<-ERB)
        create_table "authors", id: :integer, force: :cascade do |t|
          t.string "name", null: false
        end

        create_table "books", id: :integer, force: :cascade do |t|
          t.string  "title", null: false
          t.integer "author_id", null: false
          t.index ["author_id"], name: "idx_author_id"
        end

        execute("ALTER TABLE books ADD CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES authors (id)") do |c|
          c.raw_connection.query("SELECT 1 FROM information_schema.key_column_usage WHERE TABLE_SCHEMA = '<%= TEST_SCHEMA %>' AND CONSTRAINT_NAME = 'fk_author' LIMIT 1").each.length.zero?
        end

        add_foreign_key "books", "authors", name: "fk_author"
      ERB
    end

    before { subject.diff(dsl_with_execute).migrate }
    subject { client }

    it {
      delta = subject.diff(dsl_with_execute)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby dsl

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`),
          CONSTRAINT `fk_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB

      migrated, sql = delta.migrate(noop: true)
      expect(migrated).to be_falsey
      expect(subject.dump).to match_ruby dsl

      expect(sql).to match_fuzzy ''

      expect(show_create_table(:books)).to match_fuzzy erbh(<<-ERB)
        CREATE TABLE `books` (
          `id` int NOT NULL AUTO_INCREMENT,
          `title` varchar NOT NULL,
          `author_id` int NOT NULL,
          PRIMARY KEY (`id`),
          KEY `idx_author_id` (`author_id`),
          CONSTRAINT `fk_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3
      ERB
    }
  end
end
