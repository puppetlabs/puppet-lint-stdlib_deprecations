# frozen_string_literal: true

require 'spec_helper'

describe 'stdlib_deprecated_datatypes' do
  context 'when scanning puppet code for deprecated compat datatypes' do
    let(:code) { 'Stdlib::Compat::String' }
    let(:report) { /Removed data type found: 'Stdlib::Compat::String'/ }

    it 'does detect a problem' do
      expect(problems.size).to eq(1)
    end

    it 'throws an error' do
      expect(problems).to include(a_hash_including(kind: /error/))
    end

    it 'contains the specific warning message' do
      expect(problems).to include(a_hash_including(message: report))
    end
  end

  context 'when scanning puppet code for multiple deprecated compat datatypes' do
    let(:code) { 'Stdlib::Compat::String, Stdlib::Compat::Array' }
    let(:string_report) { /Removed data type found: 'Stdlib::Compat::String'/ }
    let(:array_report) { /Removed data type found: 'Stdlib::Compat::Array'/ }

    it 'does detect a problem' do
      expect(problems.size).to eq(2)
    end

    it 'throws an error' do
      expect(problems).to include(a_hash_including(kind: /error/))
    end

    it 'contains the specific String warning message' do
      expect(problems).to include(a_hash_including(message: string_report))
    end

    it 'contains the specific Array warning message' do
      expect(problems).to include(a_hash_including(message: array_report))
    end
  end

  context 'when scanning puppet code for non-deprecated datatypes' do
    let(:code) { 'String' }

    it 'does not detect a problem' do
      expect(problems).to be_empty
    end
  end

  context 'when scanning puppet code for a mixture of deprecated and non-depreacted data types' do
    let(:code) { 'String, Stdlib::Compat::String' }
    let(:report) { /Removed data type found: 'Stdlib::Compat::String'/ }

    it 'does detect a problem' do
      expect(problems.size).to eq(1)
    end

    it 'throws an error' do
      expect(problems).to include(a_hash_including(kind: /error/))
    end

    it 'contains the specific warning message' do
      expect(problems).to include(a_hash_including(message: report))
    end
  end

  context 'when scanning puppet code for deprecated compat datatypes with a code block' do
    let(:code) do
      <<~PUPPETCODE
        class foo (
          Stdlib::Compat::String $bar = 'foobar',
        ){}
      PUPPETCODE
    end
    let(:report) { /Removed data type found: 'Stdlib::Compat::String'/ }

    it 'does detect a problem' do
      expect(problems.size).to eq(1)
    end

    it 'throws an error' do
      expect(problems).to include(a_hash_including(kind: /error/))
    end

    it 'contains the specific warning message' do
      expect(problems).to include(a_hash_including(message: report))
    end
  end
end
