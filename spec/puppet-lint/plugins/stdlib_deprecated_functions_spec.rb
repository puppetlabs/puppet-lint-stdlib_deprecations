# frozen_string_literal: true

require 'spec_helper'

describe 'stdlib_deprecated_functions' do
  let(:generic_report) { /Deprecated function found:/ }

  # Testing the stdlib_deprecated_functions check without autofix
  context 'when testing puppet code with fix disabled and' do
    context 'with one removed stdlib function present' do
      let(:code) { "is_absolute_path('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'throws an error' do
        expect(problems).to include(a_hash_including(kind: /error/))
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end

    context 'with one namespaced stdlib function present' do
      let(:code) { "to_json('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'throws a warning' do
        expect(problems).to include(a_hash_including(kind: /warning/))
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end

    context 'with a non-deprecated stdlib function present' do
      let(:code) { "basename('/path/to/file')" }

      it 'does not flag a problem' do
        expect(problems.size).to eq(0)
      end

      it 'does not warn the user about deprecations' do
        expect(problems).not_to include(a_hash_including(message: generic_report))
      end
    end

    context 'with a wrongly written deprecated stdlib function present' do
      let(:code) { "to_jron('foo')" }

      it 'does not flag a problem' do
        expect(problems.size).to eq(0)
      end
    end

    context 'with multiple removed functions present' do
      let(:code) { "is_absolute_path('foo')\nis_integer('foo')" }

      it 'does detect multiple problems' do
        expect(problems.size).to eq(2)
      end

      it 'throws an error' do
        expect(problems).to include(a_hash_including(kind: /error/))
      end

      it 'does not throw a warning' do
        expect(problems).not_to include(a_hash_including(kind: /warning/))
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end

    context 'with multiple namespaced functions present' do
      let(:code) { "to_json('foo')\nto_yaml('foo')" }

      it 'does detect multiple problems' do
        expect(problems.size).to eq(2)
      end

      it 'throws a warning' do
        expect(problems).to include(a_hash_including(kind: /warning/))
      end

      it 'does not throw an error' do
        expect(problems).not_to include(a_hash_including(kind: /error/))
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end

    context 'with multiple mixed functions present' do
      let(:code) { "is_absolute_path('foo')\nto_yaml('foo')" }

      it 'does detect multiple problems' do
        expect(problems.size).to eq(2)
      end

      it 'throws an error' do
        expect(problems).to include(a_hash_including(kind: /error/))
      end

      it 'throws a warning' do
        expect(problems).to include(a_hash_including(kind: /warning/))
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end

    context 'with a mix of deprecated and non-deprecated functions present' do
      let(:code) { "is_absolute_path('foo')\nbasename('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'throws an error' do
        expect(problems).to include(a_hash_including(kind: /error/))
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end
  end

  # Testing the stdlib_deprecated_functions check with autofix
  context 'when testing puppet code with fix enabled and' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'with one non-replaceable removed stdlib function present' do
      let(:code) { "is_absolute_path('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'throws an error' do
        expect(problems).to include(a_hash_including(kind: /error/))
      end

      it 'does not fix the problem' do
        expect(problems).not_to include(a_hash_including(kind: /fixed/))
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end

    context 'with one namespaced stdlib function present' do
      let(:code) { "to_json('foo')" }
      let(:fixedcode) { "stdlib::to_json('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'fixes the problem' do
        expect(problems).to include(a_hash_including(kind: /fixed/))
      end

      it 'fixes the code' do
        expect(manifest).to eq(fixedcode)
      end

      it 'contains the specific warning message' do
        expect(problems).to include(a_hash_including(message: generic_report))
      end
    end

    context 'with a non-deprecated stdlib function present' do
      let(:code) { "basename('/path/to/file')" }

      it 'does not flag a problem' do
        expect(problems.size).to eq(0)
      end

      it 'does not warn the user about deprecations' do
        expect(problems).not_to include(a_hash_including(message: generic_report))
      end

      it 'does not fix anything' do
        expect(problems).not_to include(a_hash_including(kind: /fixed/))
      end
    end

    context 'with a wrongly written deprecated stdlib function present' do
      let(:code) { "to_jron('foo')" }

      it 'does not flag a problem' do
        expect(problems.size).to eq(0)
      end

      it 'does not fix anything' do
        expect(problems).not_to include(a_hash_including(kind: /fixed/))
      end
    end

    context 'with multiple namespaced functions present' do
      let(:code) { "to_json('foo')\nto_yaml('foo')" }
      let(:fixedcode) { "stdlib::to_json('foo')\nstdlib::to_yaml('foo')" }

      it 'does detect multiple problems' do
        expect(problems.size).to eq(2)
      end

      it 'fixes the problems' do
        expect(problems).to include(a_hash_including(kind: /fixed/))
      end

      it 'does not avoid fixing the problems' do
        expect(problems).not_to include(a_hash_including(kind: /warning/))
      end

      it 'fixes the code' do
        expect(manifest).to eq(fixedcode)
      end
    end

    context 'with multiple mixed functions present' do
      let(:code) { "is_absolute_path('foo')\nto_yaml('foo')" }
      let(:fixedcode) { "is_absolute_path('foo')\nstdlib::to_yaml('foo')" }

      it 'does detect multiple problems' do
        expect(problems.size).to eq(2)
      end

      it 'fixes the problems' do
        expect(problems).to include(a_hash_including(kind: /fixed/))
      end

      it 'does not fix the unfixable problem' do
        expect(problems).to include(a_hash_including(kind: /error/))
      end

      it 'fixes the code' do
        expect(manifest).to eq(fixedcode)
      end
    end

    context 'with the replaceable function size() present' do
      # rubocop: disable Layout/LineLength
      let(:code) { "size('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'offers an alternative' do
        expect(problems).to include(a_hash_including(message: "Deprecated function found: 'size'. Use length() instead.", kind: :error))
      end
    end

    context 'with the replaceable function hash() present' do
      let(:code) { "hash('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'offers an alternative' do
        expect(problems).to include(a_hash_including(message: "Deprecated function found: 'hash'. Use Puppets built-in Hash.new() instead.", kind: :error))
      end
    end

    context 'with the replaceable function sprintf_hash() present' do
      let(:code) { "sprintf_hash('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'offers an alternative' do
        expect(problems).to include(a_hash_including(message: "Deprecated function found: 'sprintf_hash'. Use sprintf() instead.", kind: :error))
      end
    end

    context 'with the replaceable function private() present' do
      let(:code) { "private('foo')" }

      it 'does detect a problem' do
        expect(problems.size).to eq(1)
      end

      it 'offers an alternative' do
        expect(problems).to include(a_hash_including(message: "Deprecated function found: 'private'. Use assert_private() instead.", kind: :error))
      end
    end

    context 'with multiple replaceable functions present' do
      let(:code) { "size('foo')\nsprintf_hash('foo')\nprivate('foo')" }
      let(:fixedcode) { "length('foo')\nsprintf('foo')\nassert_private('foo')" }

      it 'does detect multiple problems' do
        expect(problems.size).to eq(3)
      end

      it 'offers an alternative for size' do
        expect(problems).to include(a_hash_including(message: "Deprecated function found: 'size'. Use length() instead.", kind: :error))
      end

      it 'offers an alternative for private' do
        expect(problems).to include(a_hash_including(message: "Deprecated function found: 'private'. Use assert_private() instead.", kind: :error))
      end
      # rubocop: enable Layout/LineLength
    end
  end
end
