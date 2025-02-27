# frozen_string_literal: true

describe 'Ridgepole::Client#diff -> migrate' do
  context 'when change column (binary: blob -> varbinary)' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date     "birth_date", null: false
          t.string   "first_name", limit: 14, null: false
          t.string   "last_name", limit: 16, null: false
          t.string   "gender", limit: 1, null: false
          t.date     "hire_date", null: false
          t.datetime "created_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.datetime "updated_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.binary   "registered_name"
        end
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date     "birth_date", null: false
          t.string   "first_name", limit: 14, null: false
          t.string   "last_name", limit: 16, null: false
          t.string   "gender", limit: 1, null: false
          t.date     "hire_date", null: false
          t.datetime "created_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.datetime "updated_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.binary   "registered_name", limit: 255
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby actual_dsl
      delta.migrate
      expect(subject.dump).to match_ruby expected_dsl
    }
  end

  context 'when change column (binary: varbinary -> blob)' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date     "birth_date", null: false
          t.string   "first_name", limit: 14, null: false
          t.string   "last_name", limit: 16, null: false
          t.string   "gender", limit: 1, null: false
          t.date     "hire_date", null: false
          t.datetime "created_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.datetime "updated_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.binary   "registered_name", limit: 255
        end
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date     "birth_date", null: false
          t.string   "first_name", limit: 14, null: false
          t.string   "last_name", limit: 16, null: false
          t.string   "gender", limit: 1, null: false
          t.date     "hire_date", null: false
          t.datetime "created_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.datetime "updated_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.binary   "registered_name"
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_ruby actual_dsl
      delta.migrate
      expect(subject.dump).to match_ruby expected_dsl
    }
  end

  context 'when change column (binary without limit)' do
    let(:actual_dsl) do
      erbh(<<-ERB)
        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date     "birth_date", null: false
          t.string   "first_name", limit: 14, null: false
          t.string   "last_name", limit: 16, null: false
          t.string   "gender", limit: 1, null: false
          t.date     "hire_date", null: false
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
          t.binary   "registered_name"
        end
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "employees", primary_key: "emp_no", force: :cascade do |t|
          t.date     "birth_date", null: false
          t.string   "first_name", limit: 14, null: false
          t.string   "last_name", limit: 16, null: false
          t.string   "gender", limit: 1, null: false
          t.date     "hire_date", null: false
          t.datetime "created_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.datetime "updated_at", <%= i cond(">= 7.0", { precision: 6 }) %>, null: false
          t.binary   "registered_name"
        end
      ERB
    end

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_falsey
    }
  end
end
