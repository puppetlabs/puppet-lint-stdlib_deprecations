# frozen_string_literal: true

# Public: A puppet-lint custom check to detect deprecated functions.
DEPRECATED_FUNCTIONS_VAR_TYPES = Set[:FUNCTION_NAME]

# These functions have been removed in stdlib 9.x.
REMOVED_FUNCTIONS = %w[
  is_absolute_path type3x private is_bool validate_bool
  is_string validate_string is_integer validate_integer is_hash
  is_float validate_hash absolute_path validate_re validate_slength
  is_ipv6_address validate_ipv6_address is_ipv4_address validate_ipv4_address
  is_ip_address validate_ip_address size sprintf_hash is_email_address
  is_mac_address is_domain_name is_function_available hash has_key is_array
].freeze

# Subset of REMOVED_FUNCTIONS that have been replaced with an alternative.
REPLACED_FUNCTIONS = {
  'private' => 'assert_private()',
  'size' => 'length()',
  'sprintf_hash' => 'sprintf()',
  'hash' => 'Puppets built-in Hash.new()',
  'has_key' => 'appropriate Puppet match expressions'
}.freeze

# These functions have been namespaced in stdlib 9.x.
NAMESPACED_FUNCTIONS = %w[
  batch_escape ensure_packages fqdn_rand_string has_interface_with merge
  os_version_gte parsehocon parsepson powershell_escape seeded_rand
  seeded_rand_string shell_escape to_json to_json_pretty to_python to_ruby
  to_toml to_yaml type_of validate_domain_name validate_email_address
].freeze

PuppetLint.new_check(:stdlib_deprecated_functions) do
  def check
    tokens.select { |x| DEPRECATED_FUNCTIONS_VAR_TYPES.include?(x.type) }.each do |token|
      next unless token.next_code_token.type == :LPAREN # Skip if it's not a function call

      if REMOVED_FUNCTIONS.include?(token.value)
        removed_function_detected = true
      elsif NAMESPACED_FUNCTIONS.include?(token.value)
        namespaced_function_detected = true
      else
        next
      end

      message = "Deprecated function found: '#{token.value}'"
      message += ". Use stdlib::#{token.value} instead." if namespaced_function_detected
      message += ". Use #{REPLACED_FUNCTIONS[token.value]} instead." if REPLACED_FUNCTIONS.include?(token.value)

      notify_log_level = removed_function_detected ? :error : :warning
      notify notify_log_level, {
        message: message,
        line: token.line,
        column: token.column,
        token: token,
        fact_name: token.value
      }
    end
  end

  # only applicable for namespaced functions
  def fix(problem)
    raise PuppetLint::NoFix unless NAMESPACED_FUNCTIONS.include?(problem[:token].value)

    problem[:token].value = "stdlib::#{problem[:token].value}"
  end
end
