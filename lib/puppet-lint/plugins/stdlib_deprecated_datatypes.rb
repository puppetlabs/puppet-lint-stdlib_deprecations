# frozen_string_literal: true

# Public: A puppet-lint custom check to detect removed deprecated compatibility data types.

DEPRECATED_DATATYPES_VAR_TYPES = [:CLASSREF].freeze

PuppetLint.new_check(:stdlib_deprecated_datatypes) do
  def check
    tokens.select { |x| DEPRECATED_DATATYPES_VAR_TYPES.include?(x.type) }.each do |token|
      next unless token.value.include?('Stdlib::Compat::')

      message = "Removed data type found: '#{token.value}'"

      notify :error, {
        message: message,
        line: token.line,
        column: token.column,
        token: token,
        fact_name: token.value
      }
    end
  end
end
