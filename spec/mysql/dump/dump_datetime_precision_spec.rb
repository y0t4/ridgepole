# frozen_string_literal: true

describe 'Ridgepole::Client#dump' do
  context 'when there is a tables' do
    before { restore_table_mysql_datetime_precision }
    subject { client }

    it {
      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "datetimes", <%= i cond('< 6.1', { id: :integer, unsigned: true }, { id: { type: :integer, unsigned: true } }) %>, force: :cascade do |t|
          t.datetime "datetime", precision: 0, null: false
          t.datetime "datetime_zero", precision: 0, null: false
          t.datetime "datetime_six", precision: 6, null: false
        end
      ERB
    }
  end
end
